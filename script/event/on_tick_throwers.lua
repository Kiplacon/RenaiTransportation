local ArmPastHalfway = {
    [0] = function(HandPosition, ThrowerPosition, BurnerSelfRefuelCompensation)
        return HandPosition.y >= ThrowerPosition.y+BurnerSelfRefuelCompensation end,
    [0.25] = function(HandPosition, ThrowerPosition, BurnerSelfRefuelCompensation)
        return HandPosition.x <= ThrowerPosition.x-BurnerSelfRefuelCompensation end,
    [0.50] = function(HandPosition, ThrowerPosition, BurnerSelfRefuelCompensation)
        return HandPosition.y <= ThrowerPosition.y-BurnerSelfRefuelCompensation end,
    [0.75] = function(HandPosition, ThrowerPosition, BurnerSelfRefuelCompensation)
        return HandPosition.x >= ThrowerPosition.x+BurnerSelfRefuelCompensation end
}

local function ThrowersOnTick(event)
    local group = game.tick%storage.ThrowerGroups + 1
        for ThrowerDestroyNumber, properties in pairs(storage.ThrowerProcessing[group]) do
            local ThrowerEntity = properties.entity
            if (ThrowerEntity.valid) then
                if (properties.timeout == nil) then
                    -- power check. low power makes inserter arms stretch
                    if (properties.IsElectric == true and ThrowerEntity.energy/ThrowerEntity.electric_buffer_size >= 0.9) then
                        ThrowerEntity.active = true
                    elseif (properties.IsElectric == true and ThrowerEntity.is_connected_to_electric_network() == true) then
                        ThrowerEntity.active = false
                        rendering.draw_animation
                            {
                                animation = "RTMOREPOWER",
                                x_scale = 0.5,
                                y_scale = 0.5,
                                target = ThrowerEntity,
                                surface = ThrowerEntity.surface,
                                time_to_live = storage.ThrowerGroups
                            }
                    end
                    local ThrowerPosition = ThrowerEntity.position
                    local ThrowerStack = ThrowerEntity.held_stack
                    if (properties.RangeAdjustable == true) then
                        local range = ThrowerEntity.get_signal({type="virtual", name="ThrowerRangeSignal"}, defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
                        if (properties.range==nil or properties.range~=range) then
                            if (range > 0 and range <= properties.NormalRange) then
                                SetThrowerRange(ThrowerEntity, range)
                            elseif (range > properties.NormalRange) then
                                SetThrowerRange(ThrowerEntity, properties.NormalRange)
                            end
                        end
                    end
                    -- check if inserter is ready to throw
                    -- if it's passed the "half swing" point
                    if (ArmPastHalfway[ThrowerEntity.orientation](ThrowerEntity.held_stack_position, ThrowerPosition, properties.BurnerSelfRefuelCompensation) and ThrowerStack.valid_for_read) then -- if the arm is past halfway
                        
                        local HandPosition = ThrowerEntity.held_stack_position
                        local HeldItem = ThrowerStack.name
                        local DestinationDestroyNumber
                        local OnTheWayToTarget
                        if (properties.targets[HeldItem] and properties.targets[HeldItem].valid) then
                            DestinationDestroyNumber = script.register_on_object_destroyed(properties.targets[HeldItem])
                            OnTheWayToTarget = storage.OnTheWay[DestinationDestroyNumber]
                        end
                        -- activate/disable thrower based on overflow prevention
                        if (ThrowerEntity.name ~= "RTThrower-PrimerThrower" and settings.global["RTOverflowComp"].value == true and properties.InSpace == false) then
                            -- pointing at some entity
                            if (OnTheWayToTarget -- receptions are being tracked for the entity
                            and OnTheWayToTarget[HeldItem]) then -- receptions are being tracked for the entity for the particular item
                                ThrowerEntity.active = CanFitThrownItem
                                    {
                                        TargetEntity = properties.targets[HeldItem],
                                        ItemStack = ThrowerStack,
                                        thrower = ThrowerEntity
                                    }

                            -- pointing at nothing/the ground
                            elseif (properties.targets[HeldItem] == "nothing") then
                                ThrowerEntity.active = true

                            -- item needs path validation/is currently tracking path
                            elseif (properties.targets[HeldItem] == nil) then
                                -- start path tracking, repeatedly stops here until trace ends, setting the target in properties
                                if (properties.ImAlreadyTracer == nil or properties.ImAlreadyTracer == "traced") then
                                    properties.ImAlreadyTracer = "tracing"
                                    -- set tracer "projectile"
                                    InvokeThrownItem({
                                        type = "tracer",
                                        ItemName = HeldItem,
                                        count = 0, -- just to pacify the function
                                        quality = "normal", -- just to pacify the function
                                        start = properties.entity.position,
                                        target = {x=properties.entity.drop_position.x, y=properties.entity.drop_position.y},
                                        surface = ThrowerEntity.surface,
                                        tracing = ThrowerDestroyNumber,
                                        space = false,
                                    })
                                end
                                ThrowerEntity.active = false

                            -- first time throws for items to this target, tracer not landed yet
                            elseif (properties.targets[HeldItem]
                            and properties.targets[HeldItem].valid
                            and OnTheWayToTarget == nil) then
                                storage.OnTheWay[DestinationDestroyNumber] = {[HeldItem] = 0}
                                ThrowerEntity.active = false

                            -- first time throws for this particular item to this target, tracer not landed yet
                            elseif (properties.targets[HeldItem]
                            and properties.targets[HeldItem].valid
                            and OnTheWayToTarget
                            and OnTheWayToTarget[HeldItem] == nil) then
                                OnTheWayToTarget[HeldItem] = 0
                                --ThrowerEntity.active = false
                            end
                        -- overflow prevention is set to off
                        else
                            ThrowerEntity.active = true
                        end

                        -- if the thrower is still active after the checks then:
                        if (ThrowerEntity.active == true) then
                            if (ThrowerEntity.name == "RTThrower-PrimerThrower" and prototypes.entity["RTPrimerThrowerShooter-"..HeldItem]) then
                                ThrowerEntity.inserter_stack_size_override = 1
                                ThrowerEntity.active = false
                                storage.PrimerThrowerLinks[script.register_on_object_destroyed(properties.entangled.detector)].ready = true
                            else
                                -- starting parameters
                                local x = ThrowerEntity.drop_position.x
                                local y = ThrowerEntity.drop_position.y
                                local distance = math.sqrt((x-HandPosition.x)^2 + (y-HandPosition.y)^2)
                                -- calcaulte projectile parameters
                                local speed = 0.18
                                if (ThrowerEntity.name == "RTThrower-EjectorHatchRT" or ThrowerEntity.name == "RTThrower-FilterEjectorHatchRT") then
                                    distance = math.sqrt((x-ThrowerPosition.x)^2 + (y-ThrowerPosition.y)^2)
                                    speed = 0.25
                                    ThrowerEntity.surface.play_sound
                                    {
                                        path = "RTThrower-EjectorHatchRT-sound",
                                        position = ThrowerPosition,
                                    }
                                else
                                    ThrowerEntity.surface.play_sound
                                    {
                                        path = "RTThrow",
                                        position = ThrowerPosition,
                                        volume_modifier = 0.2
                                    }
                                end
                                local AirTime = math.max(1, math.floor(distance/speed)) -- for super fast throwers that move right on top of their target
                                if (settings.global["RTOverflowComp"].value == true and properties.InSpace == false) then
                                    if (properties.targets[HeldItem] ~= nil and properties.targets[HeldItem].valid) then
                                        if (storage.OnTheWay[DestinationDestroyNumber] == nil) then
                                            storage.OnTheWay[DestinationDestroyNumber] = {}
                                            storage.OnTheWay[DestinationDestroyNumber][HeldItem] = ThrowerStack.count
                                        elseif (storage.OnTheWay[DestinationDestroyNumber][HeldItem] == nil) then
                                            storage.OnTheWay[DestinationDestroyNumber][HeldItem] = ThrowerStack.count
                                        else
                                            storage.OnTheWay[DestinationDestroyNumber][HeldItem] = storage.OnTheWay[DestinationDestroyNumber][HeldItem] + ThrowerStack.count
                                        end
                                    elseif (properties.targets[HeldItem] == "nothing") then -- recheck pointing at nothing/things without unit_numbers
                                        properties.targets[HeldItem] = nil
                                    end
                                end
                                
                                if (properties.InSpace == false) then
                                    InvokeThrownItem({
                                        type = "ReskinnedStream",
                                        stack = ThrowerStack,
                                        thrower = ThrowerEntity, -- for thrower hand position
                                        speed = speed,
                                        start = ThrowerPosition,
                                        target = {x=ThrowerEntity.drop_position.x, y=ThrowerEntity.drop_position.y},
                                        DestinationDestroyNumber = DestinationDestroyNumber,
                                        surface = ThrowerEntity.surface,
                                        space = false,
                                        adjustment = properties.TrajectoryAdjust,
                                    })
                                else
                                    x = x + (-storage.OrientationUnitComponents[ThrowerEntity.orientation].x * 100)
                                    y = y + (-storage.OrientationUnitComponents[ThrowerEntity.orientation].y * 100)
                                    distance = math.sqrt((x-HandPosition.x)^2 + (y-HandPosition.y)^2)
                                    AirTime = math.max(1, math.floor(distance/speed))
                                    local vector = {x=x-HandPosition.x, y=y-HandPosition.y}
                                    local path = {}
                                    for i = 1, AirTime do
                                        local progress = i/AirTime
                                        path[i] =
                                        {
                                            x = HandPosition.x+(progress*vector.x),
                                            y = HandPosition.y+(progress*vector.y),
                                            height = 0
                                        }
                                    end
                                    InvokeThrownItem({
                                        type = "CustomPath",
                                        stack = ThrowerStack,
                                        thrower = ThrowerEntity,
                                        start = ThrowerPosition,
                                        target={x=x, y=y},
                                        surface=ThrowerEntity.surface,
                                        --speed = 0.2,
                                        space = true,
                                        path = path,
                                        AirTime = AirTime,
                                    })
                                end
                            end
                        elseif (OnTheWayToTarget ~= nil) then -- path is traced (untraced path doesn't need to timeout)
                            properties.timeout = settings.global["RTOverflowTimeout"].value*60
                        end
                    elseif (ThrowerEntity.active == false and ThrowerStack.valid_for_read == false) then
                        ThrowerEntity.active = true
                    end
                else
                    properties.timeout = properties.timeout - storage.ThrowerGroups
                    if (properties.timeout <= 0) then
                        properties.timeout = nil
                    end
                end

            elseif (ThrowerEntity.valid == false) then
                storage.ThrowerProcessing[group][ThrowerDestroyNumber] = nil
            end
        end

end


return ThrowersOnTick

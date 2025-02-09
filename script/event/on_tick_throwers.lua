local function ThrowersOnTick(event)
    local group = game.tick%storage.ThrowerGroups + 1
        for ThrowerDestroyNumber, properties in pairs(storage.ThrowerProcessing[group]) do
            local ThrowerEntity = properties.entity
            if (ThrowerEntity.valid) then
                local ThrowerPosition = ThrowerEntity.position
                local ThrowerStack = ThrowerEntity.held_stack
                --local CatapulyDestroyNumber = script.register_on_object_destroyed(catapult)
                -- power check. low power makes inserter arms stretch
                --[[ if (properties.IsElectric == true and ThrowerEntity.energy/ThrowerEntity.electric_buffer_size >= 0.9) then
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
                            time_to_live = 4
                        }
                end ]]

                if (ThrowerStack.valid_for_read) then -- if it has power
                    local HeldItem = ThrowerStack.name
                    local HandPosition = ThrowerEntity.held_stack_position
                    -- if it's passed the "half swing" point
                    if (ThrowerEntity.orientation == 0    and HandPosition.y >= ThrowerPosition.y+properties.BurnerSelfRefuelCompensation)
                    or (ThrowerEntity.orientation == 0.25 and HandPosition.x <= ThrowerPosition.x-properties.BurnerSelfRefuelCompensation)
                    or (ThrowerEntity.orientation == 0.50 and HandPosition.y <= ThrowerPosition.y-properties.BurnerSelfRefuelCompensation)
                    or (ThrowerEntity.orientation == 0.75 and HandPosition.x >= ThrowerPosition.x+properties.BurnerSelfRefuelCompensation)
                    then
                        local OnTheWayToTarget
                        if (properties.targets[HeldItem] and properties.targets[HeldItem].valid) then
                            OnTheWayToTarget = storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])]
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
                                    CreateThrownItem({
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

                            -- first time throws for items to this target
                            elseif (properties.targets[HeldItem]
                            and properties.targets[HeldItem].valid
                            and OnTheWayToTarget == nil) then
                                storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])] = {}
                                storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])][HeldItem] = 0
                                ThrowerEntity.active = false

                            -- first time throws for this particular item to this target
                            elseif (properties.targets[HeldItem]
                            and properties.targets[HeldItem].valid
                            and OnTheWayToTarget
                            and OnTheWayToTarget[HeldItem] == nil) then
                                OnTheWayToTarget[HeldItem] = 0
                                ThrowerEntity.active = false
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
                                    --[[ catapult.surface.play_sound
                                    {
                                        path = "RTEjector",
                                        position = catapult.position,
                                        volume_modifier = 0.1
                                    } ]]
                                else
                                    ThrowerEntity.surface.play_sound
                                    {
                                        path = "RTThrow",
                                        position = ThrowerPosition,
                                        volume_modifier = 0.2
                                    }
                                end
                                local AirTime = math.max(1, math.floor(distance/speed)) -- for super fast throwers that move right on top of their target
                                local DestinationDestroyNumber
                                if (settings.global["RTOverflowComp"].value == true and properties.InSpace == false) then
                                    if (properties.targets[HeldItem] ~= nil and properties.targets[HeldItem].valid) then
                                        DestinationDestroyNumber = script.register_on_object_destroyed(properties.targets[HeldItem])
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
                                --[[ storage.FlyingItems[storage.FlightNumber] =
                                    {
                                        item=HeldItem,
                                        count=catapult.held_stack.count,
                                        quality=catapult.held_stack.quality.name,
                                        --thrower=catapult, -- not used?
                                        ThrowerPosition=catapult.position,
                                        target={x=x, y=y},
                                        --start=start, --ThrowerPosition now
                                        AirTime=AirTime,
                                        StartTick=game.tick,
                                        LandTick=game.tick+AirTime,
                                        destination=DestinationDestroyNumber,
                                        space=properties.InSpace,
                                        surface=catapult.surface,
                                    } ]]
                                
                                if (properties.InSpace == false) then
                                    CreateThrownItem({
                                        type = "ReskinnedStream",
                                        stack = ThrowerStack,
                                        thrower = ThrowerEntity, -- for thrower hand position
                                        speed = speed,
                                        start = ThrowerPosition,
                                        target = {x=ThrowerEntity.drop_position.x, y=ThrowerEntity.drop_position.y},
                                        DestinationDestroyNumber = DestinationDestroyNumber,
                                        surface = ThrowerEntity.surface,
                                        space = false,
                                    })
                                    --[[ if (prototypes.entity["RTItemProjectile-"..HeldItem..speed*100]) then
                                        catapult.surface.create_entity
                                        {
                                            name="RTItemProjectile-"..HeldItem..speed*100,
                                            position=catapult.held_stack_position,
                                            source_position=ShootPosition,
                                            target_position=catapult.drop_position
                                        }
                                    else
                                        catapult.surface.create_entity
                                        {
                                            name="RTTestProjectile"..speed*100,
                                            position=catapult.held_stack_position,
                                            source_position=ShootPosition,
                                            target_position=catapult.drop_position
                                        }
                                    end ]]
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
                                    CreateThrownItem({
                                        type = "CustomPath",
                                        ItemName = HeldItem,
                                        count=ThrowerStack.count,
                                        quality=ThrowerStack.quality.name,
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
                                --[[ if (catapult.held_stack.item_number ~= nil) then
                                    local CloudStorage = game.create_inventory(1)
                                    CloudStorage.insert(catapult.held_stack)
                                    storage.FlyingItems[storage.FlightNumber].CloudStorage = CloudStorage
                                end

                                -- Ultracube irreplaceables detection & handling
                                if storage.Ultracube and storage.Ultracube.prototypes.irreplaceable[HeldItem] then -- Ultracube mod is active, and the held item is an irreplaceable
                                    -- Sets cube_token_id and cube_should_hint for the new FlyingItems entry
                                    CubeFlyingItems.create_token_for(storage.FlyingItems[storage.FlightNumber])
                                end
                                
                                storage.FlightNumber = storage.FlightNumber + 1
                                catapult.held_stack.clear() ]]
                            end
                        end
                    end

                elseif (ThrowerEntity.active == false and ThrowerStack.valid_for_read == false) then
                    ThrowerEntity.active = true
                end

                if (properties.RangeAdjustable == true) then
                    local range = ThrowerEntity.get_signal({type="virtual", name="ThrowerRangeSignal"}, defines.wire_connector_id.circuit_red)
                    if (properties.range==nil or properties.range~=range) then
                        if (range > 0 and range <= ThrowerEntity.prototype.inserter_drop_position[2]+0.1) then
                            ThrowerEntity.drop_position =
                                {
                                    ThrowerPosition.x + -range*storage.OrientationUnitComponents[ThrowerEntity.orientation].x,
                                    ThrowerPosition.y + -range*storage.OrientationUnitComponents[ThrowerEntity.orientation].y
                                }
                            properties.range = range
                            ResetThrowerOverflowTracking(ThrowerEntity)
                        end
                    end
                end

            elseif (ThrowerEntity.valid == false) then
                storage.ThrowerProcessing[group][ThrowerDestroyNumber] = nil
            end
        end

end


return ThrowersOnTick

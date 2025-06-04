---@diagnostic disable: newline-call
function NewFlightNumber()
    storage.FlightNumber = storage.FlightNumber + 1
    if (storage.FlightNumber > 1000000) then -- maybe unnecessary
        storage.FlightNumber = 1
    end
    return storage.FlightNumber
end

function InvokeThrownItem(stuff)
    local ProjectileType = stuff.type
    if (ProjectileType == nil) then
        error("CreateThrownItem: type is nil")
    else
        if ((stuff.ItemName and stuff.count and stuff.quality) or (stuff.stack) or (ProjectileType == "tracer" and stuff.ItemName and stuff.tracing) or stuff.bouncing or (stuff.player and stuff.AirTime and stuff.SwapBack and stuff.IAmSpeed))
        and (stuff.start and stuff.target and (stuff.surface or stuff.bouncing)) then
            -- setup the flying item data
            local bounced = stuff.bouncing or {}
            local stack = stuff.stack or {quality={}}
            local ItemName = bounced.item or stack.name or stuff.ItemName
            local count = bounced.amount or stuff.ThrowFromStackAmount or stack.count or stuff.count
            local quality = bounced.quality or stack.quality.name or stuff.quality or "normal"
            local start = stuff.start -- {x=0,y=0} or {0,0} or entity
            if (type(stuff.start) == "userdata") then
                start = stuff.start.position
            end
            local target = stuff.target -- {x=0,y=0} or {0,0} or entity
            local TargetX = target.x or target[1]
            local TargetY = target.y or target[2]
            local surface = bounced.surface or stuff.surface
            local space = bounced.space or stuff.space or false
            local speed = bounced.speed or stuff.speed or 0.18
            local FlyingItem =
            {
                type = ProjectileType,
                item=ItemName,
                amount=count,
                quality=quality,
                ThrowerPosition=start, -- for bounce pad redirecting
                target={x=TargetX, y=TargetY},
                DestinationDestroyNumber=bounced.DestinationDestroyNumber or stuff.DestinationDestroyNumber, -- for overflow prevention
                space=space,
                surface=surface, -- to search for things by the landing zone
            }

            -- create the visual projectile
            if (ProjectileType == "ReskinnedStream") then
                local stream
                local StreamStart = start
                if (stuff.thrower and stuff.thrower.name ~= "RTThrower-EjectorHatchRT") then
                    StreamStart = stuff.thrower.held_stack_position
                end
                if (prototypes.entity["RTItemProjectile-"..ItemName..speed*100]) then
                    stream = FlyingItem.surface.create_entity
                    {
                        name="RTItemProjectile-"..ItemName..speed*100,
                        position=start,
                        source_position=OffsetPosition(StreamStart, (stuff.StartOffset or {0,0})), -- offset should be pretty small so that the calculated air time lines up with the visual
                        target_position={TargetX, TargetY}
                    }
                else
                    stream = FlyingItem.surface.create_entity
                    {
                        name="RTTestProjectile"..speed*100,
                        position=start,
                        source_position=OffsetPosition(StreamStart, (stuff.StartOffset or {0,0})), -- offset should be pretty small so that the calculated air time lines up with the visual
                        target_position={TargetX, TargetY}
                    }
                end
                local StreamDestroyNumber = script.register_on_object_destroyed(stream)
                FlyingItem.StreamDestroyNumber = StreamDestroyNumber
                storage.FlyingItems[StreamDestroyNumber] = FlyingItem
            elseif (ProjectileType == "CustomPath") then
                if (stuff.path and stuff.AirTime) then
                    FlyingItem.path = stuff.path
                    --[[ local distance = math.sqrt((TargetX-(start.x or start[1]))^2 + (TargetY-(start.y or start[2]))^2)
                    local AirTime = math.max(1, math.floor(distance/speed)) ]]
                    FlyingItem.AirTime = stuff.AirTime
                    FlyingItem.StartTick = game.tick
                    FlyingItem.LandTick = game.tick+stuff.AirTime
                    FlyingItem.sprite = rendering.draw_sprite
                    {
                        sprite = "item/"..ItemName,
                        render_layer = stuff.render_layer or "under-elevated",
                        x_scale = 0.5,
                        y_scale = 0.5,
                        target = start,
                        surface = surface
                    }
                    if (not space) then
                        FlyingItem.shadow = rendering.draw_sprite
                        {
                            sprite = "item/"..ItemName,
                            render_layer = "under-elevated",
                            tint = {0,0,0,0.5},
                            x_scale = 0.5,
                            y_scale = 0.5,
                            target = start,
                            surface = surface
                        }
                    end
                    FlyingItem.spin = stuff.spin or math.random(-10,10)*0.01
                    local FlightNumber = "CustomPath"..NewFlightNumber()
                    FlyingItem.FlightNumber = FlightNumber
                    storage.FlyingItems[FlightNumber] = FlyingItem
                    storage.CustomPathFlyingItemSprites[FlightNumber] = true
                else
                    error("CustomPath requires a path and air time")
                end
            elseif (ProjectileType == "tracer") then
                FlyingItem.AirTime = 1
                FlyingItem.StartTick = game.tick
                FlyingItem.LandTick = game.tick+1
                FlyingItem.tracing = bounced.tracing or stuff.tracing
                local FlightNumber = "tracer"..NewFlightNumber()
                FlyingItem.FlightNumber = FlightNumber
                storage.FlyingItems[FlightNumber] = FlyingItem
                storage.CustomPathFlyingItemSprites[FlightNumber] = true
            elseif (ProjectileType == "ItemShell") then
                -- Only for Ultracube (otherwise item shells are handled entirely in effect_triggered)
                -- Projectile creation already handled by on_tick_ItemCannons
                FlyingItem.AirTime = math.ceil((storage.ItemCannonRange or 200) / storage.ItemCannonSpeed) -- err towards maximum possible AirTime
                FlyingItem.StartTick = game.tick
                FlyingItem.projectile = stuff.projectile
                local ProjectileDestroyNumber = script.register_on_object_destroyed(stuff.projectile)
                FlyingItem.StreamDestroyNumber = ProjectileDestroyNumber
                storage.FlyingItems[ProjectileDestroyNumber] = FlyingItem

            elseif (ProjectileType == "PlayerGuide") then
                FlyingItem.AirTime = stuff.AirTime
                FlyingItem.StartTick = game.tick
                FlyingItem.LandTick = game.tick+stuff.AirTime
                FlyingItem.player = stuff.player
                FlyingItem.path = stuff.path
                FlyingItem.SwapBack = stuff.SwapBack
                FlyingItem.IAmSpeed = stuff.IAmSpeed
                FlyingItem.shadow = stuff.shadow
                FlyingItem.shadow.sprite = "RTCharacterGhostMoving"
                local FlightNumber = "PlayerGuide"..NewFlightNumber()
                FlyingItem.FlightNumber = FlightNumber
                storage.FlyingItems[FlightNumber] = FlyingItem
                storage.CustomPathFlyingItemSprites[FlightNumber] = true
            end

            -- Transfer items if needed
            if (stuff.stack ~= nil) then
                if (stuff.stack.item_number) then
                    local CloudStorage = game.create_inventory(1)
                    CloudStorage.insert(stuff.stack) -- inserts a copy, doesnt transfer
                    CloudStorage[1].count = stuff.ThrowFromStackAmount or stuff.stack.count
                    FlyingItem.CloudStorage = CloudStorage
                end
                stuff.stack.count = stuff.stack.count - count
            elseif (bounced.CloudStorage) then
                FlyingItem.CloudStorage = bounced.CloudStorage
            end

            -- space stuff
            if (space and stuff.thrower and stuff.thrower.surface.platform and stuff.thrower.surface.platform.state == defines.space_platform_state.on_the_path and stuff.thrower.orientation == 0) then
                stuff.thrower.surface.platform.speed = stuff.thrower.surface.platform.speed + (0.002*count)
            end

            -- Ultracube irreplaceables detection & handling
            if storage.Ultracube and storage.Ultracube.prototypes.irreplaceable[ItemName] and FlyingItem.amount > 0 then -- Ultracube mod is active, and the held item is an irreplaceable
                FlyingItem.speed = speed
                if (stuff.thrower and stuff.thrower.name ~= "RTThrower-EjectorHatchRT") then
                    FlyingItem.StreamStart = stuff.thrower.held_stack_position
                end
                if stuff.bouncing and stuff.bouncing.cube_token_id then
                    -- Update and transfer an existing cube_token_id to the new FlyingItem
                    CubeFlyingItems.bounce_update(stuff.bouncing, FlyingItem)
                else
                    -- Sets cube_token_id and cube_should_hint for the new FlyingItems entry
                    CubeFlyingItems.create_token_for(FlyingItem)
                end
            end
            return FlyingItem

        else
            error("Thrown item missing required parameters")
        end
    end
end

function CanFitThrownItem(stuff)
    local TargetEntity = stuff.TargetEntity
    local ItemStack = stuff.ItemStack
    local thrower = stuff.thrower --optional
    -- Checks if the item can be thrown into the target entity taking into account items still in the air
    local ItemName = ItemStack.name
    local ItemCount = ItemStack.count
    local ItemQuality = ItemStack.quality.name
    local ItemSpoilage = ItemStack.spoil_percent
    local CanFit
    local TargetDestroyNumber = script.register_on_object_destroyed(TargetEntity)
    if storage.OnTheWay[TargetDestroyNumber] -- receptions are being tracked for the entity
    and storage.OnTheWay[TargetDestroyNumber][ItemName] then -- receptions are being tracked for the entity for the particular item
        if (TargetEntity.type ~= "transport-belt") then
            if (storage.OnTheWay[TargetDestroyNumber][ItemName] < 0) then
                storage.OnTheWay[TargetDestroyNumber][ItemName] = 0  -- correct any miscalculaltions resulting in negative values
            end
            local total = storage.OnTheWay[TargetDestroyNumber][ItemName] + ItemCount
            local inserted = TargetEntity.insert({name=ItemName, count=total, quality=ItemQuality, spoil_percent=ItemSpoilage})
            if (inserted < total) then
                CanFit = false
            else
                CanFit = true
            end
            if (inserted > 0) then -- when the destination is full. Have to check otherwise there's an error
                TargetEntity.remove_item({name=ItemName, count=inserted, quality=ItemQuality})
            end
        elseif (TargetEntity.type == "transport-belt") then
            local incomming = 0
            for name, count in pairs(storage.OnTheWay[TargetDestroyNumber]) do
                incomming = incomming + count
            end
            local total = incomming + TargetEntity.get_transport_line(1).get_item_count() + TargetEntity.get_transport_line(2).get_item_count() + ItemCount
            if (TargetEntity.belt_shape == "straight" and total <= 8)
            or (TargetEntity.belt_shape ~= "straight" and total <= 7) then
                CanFit = true
            else
                CanFit = false
            end
        end
    else
        CanFit = true
    end
    return CanFit
end

function ResetThrowerOverflowTracking(thrower)
    local ThrowerDestroyNumber = script.register_on_object_destroyed(thrower)
    if (storage.CatapultList[ThrowerDestroyNumber]) then
        storage.CatapultList[ThrowerDestroyNumber].targets = {}
        for componentUN, PathsItsPartOf in pairs(storage.ThrowerPaths) do
            for ThrowerUN, TrackedItems in pairs(PathsItsPartOf) do
                if (ThrowerUN == ThrowerDestroyNumber) then
                    storage.ThrowerPaths[componentUN][ThrowerUN] = {}
                end
            end
        end
    end
end
function ResetPathComponentOverflowTracking(component)
    local ComponentDestroyNumber = script.register_on_object_destroyed(component)
    if (storage.ThrowerPaths[ComponentDestroyNumber]) then
        for ThrowerUN, TrackedItems in pairs(storage.ThrowerPaths[ComponentDestroyNumber]) do
            if (storage.CatapultList[ThrowerUN]) then
                for item, asthma in pairs(TrackedItems) do
                    storage.CatapultList[ThrowerUN].targets[item] = nil
                end
            end
        end
        storage.ThrowerPaths[ComponentDestroyNumber] = {}
    end
end

local function DropOntoGround(FlyingItem)
    if (FlyingItem.CloudStorage) then
        if (settings.global["RTSpillSetting"].value == "Destroy") then
            FlyingItem.surface.pollute(FlyingItem.target, FlyingItem.amount*0.5)
            FlyingItem.surface.create_entity
            ({
                name = "water-splash",
                position = FlyingItem.target
            })
        else
            --game.print(game.tick.." "..FlyingItem.surface.name)
            --game.print(FlyingItem.item.." | "..FlyingItem.target.x..", "..FlyingItem.target.y)
            local spilt = FlyingItem.surface.spill_item_stack
                {
                    position = FlyingItem.surface.find_non_colliding_position("item-on-ground", FlyingItem.target, 500, 0.1),
                    stack = FlyingItem.CloudStorage[1]
                }
            if (settings.global["RTSpillSetting"].value == "Spill and Mark") then
                for every, thing in pairs(spilt) do
                    thing.order_deconstruction("player")
                end
            end
        end
        FlyingItem.CloudStorage.destroy()
    else
        if (settings.global["RTSpillSetting"].value == "Destroy") then
            FlyingItem.surface.pollute(FlyingItem.target, FlyingItem.amount*0.5)
            FlyingItem.surface.create_entity
            ({
                name = "water-splash",
                position = FlyingItem.target
            })
        else
            local spilt = FlyingItem.surface.spill_item_stack
            {
                position = FlyingItem.surface.find_non_colliding_position("item-on-ground",FlyingItem.target, 500, 0.1),
                stack = {name=FlyingItem.item, count=FlyingItem.amount, quality=FlyingItem.quality}
            }
            if (settings.global["RTSpillSetting"].value == "Spill and Mark") then
                for every, thing in pairs(spilt) do
                    thing.order_deconstruction("player")
                end
            end
        end
    end
end
local CloserSideOrder = {
    up = {
        [0]={2,1},
        [0.25]={2,1},
        [0.5]={2,1},
        [0.75]={1,2}
    },
    down = {
        [0]={1,2},
        [0.25]={1,2},
        [0.5]={2,1},
        [0.75]={2,1}
    },
    left = {
        [0]={2,1},
        [0.25]={2,1},
        [0.5]={1,2},
        [0.75]={2,1}
    },
    right = {
        [0]={1,2},
        [0.25]={2,1},
        [0.5]={2,1},
        [0.75]={2,1}
    },
}
local function DropOntoBelt(FlyingItem, belt, SpillExcess)
    if (SpillExcess == nil) then -- only used for vacuum hatches with this set to false because the spill of excess is handled by it instead
        SpillExcess = true
    end
    ---- determine "From" direction ----
    local origin = FlyingItem.ThrowerPosition or FlyingItem.start
    local order = {1,2}
    if (origin.y > FlyingItem.target.y
    and math.abs(origin.y-FlyingItem.target.y) > math.abs(origin.x-FlyingItem.target.x)) then
        order = CloserSideOrder.up[belt.orientation]
    elseif (origin.y < FlyingItem.target.y
    and math.abs(origin.y-FlyingItem.target.y) > math.abs(origin.x-FlyingItem.target.x)) then
        order = CloserSideOrder.down[belt.orientation]
    elseif (origin.x > FlyingItem.target.x
    and math.abs(origin.y-FlyingItem.target.y) < math.abs(origin.x-FlyingItem.target.x)) then
        order = CloserSideOrder.left[belt.orientation]
    elseif (origin.x < FlyingItem.target.x
    and math.abs(origin.y-FlyingItem.target.y) < math.abs(origin.x-FlyingItem.target.x)) then
        order = CloserSideOrder.right[belt.orientation]
    end
    local deposited = false
    if (FlyingItem.CloudStorage) then
        for _, l in pairs(order) do
            for i = 1, 0, -0.1 do
                if (FlyingItem.CloudStorage[1].count > 0 and belt.get_transport_line(l).can_insert_at(i) == true) then
                    belt.get_transport_line(l).insert_at(i, FlyingItem.CloudStorage[1])
                    FlyingItem.CloudStorage[1].count = FlyingItem.CloudStorage[1].count - 1
                    deposited = true
                end
            end
        end
        if (SpillExcess and FlyingItem.CloudStorage[1].count > 0) then
            if (settings.global["RTSpillSetting"].value == "Destroy") then
                FlyingItem.surface.pollute(FlyingItem.target, FlyingItem.CloudStorage[1].count*0.5)
                FlyingItem.surface.create_entity
                ({
                    name = "water-splash",
                    position = FlyingItem.target
                })
            else
                local spilt = FlyingItem.surface.spill_item_stack
                    {
                        position = FlyingItem.surface.find_non_colliding_position("item-on-ground", FlyingItem.target, 500, 0.1),
                        stack = FlyingItem.CloudStorage[1]
                    }
                if (settings.global["RTSpillSetting"].value == "Spill and Mark") then
                    for _, thing in pairs(spilt) do
                        thing.order_deconstruction("player")
                    end
                end
            end
            deposited = true
        end
        if (deposited) then
            FlyingItem.CloudStorage.destroy()
        end
    else
        local total = FlyingItem.amount
        if (belt.type == "transport-belt") then
            for _, l in pairs(order) do
                for i = 0, 0.9, 0.1 do
                    if (total > 0 and belt.get_transport_line(l).can_insert_at(i) == true) then
                        belt.get_transport_line(l).insert_at(i, {name=FlyingItem.item, count=1, quality=FlyingItem.quality})
                        total = total - 1
                        deposited = true
                    end
                end
            end
        end
        if (SpillExcess and total > 0) then
            if (settings.global["RTSpillSetting"].value == "Destroy") then
                FlyingItem.surface.pollute(FlyingItem.target, total*0.5)
                FlyingItem.surface.create_entity
                ({
                    name = "water-splash",
                    position = FlyingItem.target
                })
            else
                local spilt = FlyingItem.surface.spill_item_stack
                {
                    position = FlyingItem.surface.find_non_colliding_position("item-on-ground",FlyingItem.target, 500, 0.1),
                    stack = {name=FlyingItem.item, count=total, quality=FlyingItem.quality}
                }
                if (settings.global["RTSpillSetting"].value == "Spill and Mark") then
                    for _, thing in pairs(spilt) do
                        thing.order_deconstruction("player")
                    end
                end
            end
            deposited = true
        end
    end
    return deposited
end
function ResolveThrownItem(FlyingItem)
    local ClearOverflowTracking = true -- tracers and OnTheWay tracking. Dont clear if hittimg bounce pad
    local ThingLandedOn = FlyingItem.surface.find_entities_filtered
        {
        position = {math.floor(FlyingItem.target.x)+0.5, math.floor(FlyingItem.target.y)+0.5},
        collision_mask = "object"
        }[1]
    local LandedOnCargoWagon = FlyingItem.surface.find_entities_filtered
        {
            area = {{FlyingItem.target.x-0.5, FlyingItem.target.y-0.5}, {FlyingItem.target.x+0.5, FlyingItem.target.y+0.5}},
            type = "cargo-wagon"
        }[1]

    -- dummy ItemShells for Ultracube
    if (FlyingItem.type == "ItemShell") then
        -- By the time this called the ownership token should have been released already
        -- If for some reason that's not the case, trigger Ultracube's forced recovery
        if FlyingItem.cube_token_id then
            CubeFlyingItems.panic(FlyingItem)
        end

        -- do nothing else except cleanup

    -- landed on something
    elseif (ThingLandedOn) then
        --game.print(ThingLandedOn.name)
        if (string.find(ThingLandedOn.name, "BouncePlate") and FlyingItem.type ~= "ItemShell") then -- if that thing was a bounce plate
            if (FlyingItem.sprite) then -- from impact unloader
                FlyingItem.sprite.destroy()
                FlyingItem.sprite = nil
            end
            if (FlyingItem.shadow and FlyingItem.player == nil) then -- from impact unloader
                FlyingItem.shadow.destroy()
                FlyingItem.shadow = nil
            end
            ClearOverflowTracking = false
            local unitx = 1
            local unity = 1
            local effect = "BouncePlateParticle"
            if (string.find(ThingLandedOn.name, "DirectedBouncePlate")) then
                unitx = storage.OrientationUnitComponents[ThingLandedOn.orientation].x
                unity = storage.OrientationUnitComponents[ThingLandedOn.orientation].y
                --[[ if (FlyingItem.player) then
                    storage.AllPlayers[FlyingItem.player.index].PlayerLauncher.direction = storage.OrientationUnitComponents[ThingLandedOn.orientation].name
                end ]]
            elseif (string.find(ThingLandedOn.name, "DirectorBouncePlate")) then
                for section = 2, 5 do
                    for slot = 1, 10 do
                        local setting = ThingLandedOn.get_or_create_control_behavior().get_section(section).get_slot(slot).value
                        if (setting and setting.name and setting.name == FlyingItem.item) then
                            if (section == 1) then
                                unitx = 0
                                unity = -1
                                effect = "BouncePlateParticlered"
                            elseif (section == 2) then
                                unitx = 1
                                unity = 0
                                effect = "BouncePlateParticlegreen"
                            elseif (section == 3) then
                                unitx = 0
                                unity = 1
                                effect = "BouncePlateParticleblue"
                            elseif (section == 4) then
                                unitx = -1
                                unity = 0
                                effect = "BouncePlateParticleyellow"
                            end
                            goto kkkkkk
                        end
                    end
                end
                ::kkkkkk::
                if (unitx == 1 and unity == 1) then -- if there is no matching signal
                    if (FlyingItem.ThrowerPosition.y > FlyingItem.target.y
                    and math.abs(FlyingItem.ThrowerPosition.y-FlyingItem.target.y) > math.abs(FlyingItem.ThrowerPosition.x-FlyingItem.target.x)) then
                        unitx = 0
                        unity = -1
                    elseif (FlyingItem.ThrowerPosition.y < FlyingItem.target.y
                    and math.abs(FlyingItem.ThrowerPosition.y-FlyingItem.target.y) > math.abs(FlyingItem.ThrowerPosition.x-FlyingItem.target.x)) then
                        unitx = 0
                        unity = 1
                    elseif (FlyingItem.ThrowerPosition.x > FlyingItem.target.x
                    and math.abs(FlyingItem.ThrowerPosition.y-FlyingItem.target.y) < math.abs(FlyingItem.ThrowerPosition.x-FlyingItem.target.x)) then
                        unitx = -1
                        unity = 0
                    elseif (FlyingItem.ThrowerPosition.x < FlyingItem.target.x
                    and math.abs(FlyingItem.ThrowerPosition.y-FlyingItem.target.y) < math.abs(FlyingItem.ThrowerPosition.x-FlyingItem.target.x)) then
                        unitx = 1
                        unity = 0
                    end
                end
            else -- normal, primer, and train bounce pads
                ---- determine "From" direction ----
                local origin = FlyingItem.ThrowerPosition or FlyingItem.start
                if (origin.y > FlyingItem.target.y
                and math.abs(origin.y-FlyingItem.target.y) > math.abs(origin.x-FlyingItem.target.x)) then
                    unitx = 0
                    unity = -1
                elseif (origin.y < FlyingItem.target.y
                and math.abs(origin.y-FlyingItem.target.y) > math.abs(origin.x-FlyingItem.target.x)) then
                    unitx = 0
                    unity = 1
                elseif (origin.x > FlyingItem.target.x
                and math.abs(origin.y-FlyingItem.target.y) < math.abs(origin.x-FlyingItem.target.x)) then
                    unitx = -1
                    unity = 0
                elseif (origin.x < FlyingItem.target.x
                and math.abs(origin.y-FlyingItem.target.y) < math.abs(origin.x-FlyingItem.target.x)) then
                    unitx = 1
                    unity = 0
                end
            end

            ---- Bounce modifiers ----
            -- Defaults --
            local primable = ""
            local range = 9.9
            local RangeBonus = 0
            local SidewaysShift = 0
            local tunez = "bounce"
            if (string.find(ThingLandedOn.name, "Train")) then
                range = 40
            elseif (string.find(ThingLandedOn.name, "Primer") == nil) then
                range = ThingLandedOn.get_or_create_control_behavior().get_section(1).get_slot(1).min
                local BouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(ThingLandedOn)]
                if (BouncePadProperties.arrow.x_scale*10 ~= range) then
                    local xflip = 1
                    local yflip = 1
                    if (ThingLandedOn.name == "DirectedBouncePlate") then
                        if (ThingLandedOn.orientation == 0) then
                            xflip = 1
                            yflip = 1
                        elseif (ThingLandedOn.orientation == 0.25) then
                            xflip = 1
                            yflip = 1
                        elseif (ThingLandedOn.orientation == 0.5) then
                            xflip = 1
                            yflip = -1
                        elseif (ThingLandedOn.orientation == 0.75) then
                            xflip = -1
                            yflip = 1
                        end
                    end
                    BouncePadProperties.arrow.x_scale = xflip*range/10
                    BouncePadProperties.arrow.y_scale = yflip*range/10
                end
            end

            -- Modifiers --
            if (ThingLandedOn.name == "PrimerBouncePlate" and FlyingItem.player == nil and prototypes.entity[FlyingItem.item.."-projectileFromRenaiTransportationPrimed"]) then
                primable = "Primed"
                RangeBonus = 30
                tunez = "PrimeClick"
                effect = "PrimerBouncePlateParticle"
            elseif (ThingLandedOn.name == "PrimerSpreadBouncePlate" and FlyingItem.player == nil and prototypes.entity[FlyingItem.item.."-projectileFromRenaiTransportationPrimed"]) then
                primable = "Primed"
                tunez = "PrimeClick"
                effect = "PrimerBouncePlateParticle"
            end

            if (not FlyingItem.tracing) then --if its an item and not a tracer
                ---- Creating the bounced thing ----
                if (primable == "Primed") then
                    for kidamogus = 1, FlyingItem.amount do
                        if (ThingLandedOn.name == "PrimerSpreadBouncePlate") then
                        RangeBonus = math.random(270,300)*0.1
                        SidewaysShift = math.random(-200,200)*0.1
                        end
                        ThingLandedOn.surface.create_entity
                        ({
                            name = FlyingItem.item.."-projectileFromRenaiTransportation"..primable,
                            position = ThingLandedOn.position, --required setting for rendering, doesn't affect spawn
                            source_position = ThingLandedOn.position,
                            target_position = {ThingLandedOn.position.x  +unitx*(range+RangeBonus)  +unity*(SidewaysShift), ThingLandedOn.position.y  +unity*(range+RangeBonus)  +unitx*(SidewaysShift)},
                            force = ThingLandedOn.force
                        })
                    end
                else
                    local TargetX = ThingLandedOn.position.x  +unitx*(range+RangeBonus)  +unity*(SidewaysShift)
                    local TargetY = ThingLandedOn.position.y  +unity*(range+RangeBonus)  +unitx*(SidewaysShift)
                    local distance = math.sqrt((TargetX-ThingLandedOn.position.x)^2 + (TargetY-ThingLandedOn.position.y)^2)
                    if (range <= 15) then
                        FlyingItem.speed = 0.18
                    elseif (range > 15 and range < 40) then
                        FlyingItem.speed = 0.25
                    else
                        FlyingItem.speed = 0.60
                    end
                    local AirTime = math.floor(distance/FlyingItem.speed)
                    FlyingItem.target={x=TargetX, y=TargetY}
                    FlyingItem.start=ThingLandedOn.position
                    FlyingItem.ThrowerPosition=ThingLandedOn.position
                    FlyingItem.StartTick=game.tick
                    FlyingItem.AirTime=AirTime
                    FlyingItem.LandTick=game.tick+AirTime
                    if (FlyingItem.player == nil) then -- the player doesnt have a projectile sprite
                        InvokeThrownItem({
                            type = "ReskinnedStream",
                            bouncing = FlyingItem,
                            start = ThingLandedOn.position,
                            target = {TargetX, TargetY},
                            speed = FlyingItem.speed
                        })
                    else
                        storage.AllPlayers[FlyingItem.player.index].PlayerLauncher.direction = storage.OrientationUnitComponents[ThingLandedOn.orientation].name
                        local arc = 0.3236*distance^-0.404 -- lower number is higher arc
                        local vector = {x=TargetX-ThingLandedOn.position.x, y=TargetY-ThingLandedOn.position.y}
                        local path = {}
                        for j = 0, AirTime do
                            local progress = j/AirTime
                            path[j] =
                            {
                                x = ThingLandedOn.position.x+(progress*vector.x),
                                y = ThingLandedOn.position.y+(progress*vector.y),
                                height = progress * (1-progress) / arc
                            }
                        end
                        FlyingItem.path = path
                    end

                end
                ThingLandedOn.surface.create_particle
                ({
                    name = effect,
                    position = ThingLandedOn.position,
                    movement = {0,0},
                    height = 0,
                    vertical_speed = 0.1,
                    frame_speed = 1
                })
                ThingLandedOn.surface.play_sound
                {
                    path = tunez,
                    position = ThingLandedOn.position,
                    volume = 0.7
                }
            else --it is a tracer
            -- add the bounce pad to the bounce path list if its a tracer
                if (primable ~= "Primed") then
                    local OnDestroyNumber = script.register_on_object_destroyed(ThingLandedOn)
                    if (storage.ThrowerPaths[OnDestroyNumber] == nil) then
                        storage.ThrowerPaths[OnDestroyNumber] = {}
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing] = {}
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing][FlyingItem.item] = true
                    elseif (storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing] == nil) then
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing] = {}
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing][FlyingItem.item] = true
                    else
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing][FlyingItem.item] = true
                    end
                    -- tracers can be adjusted like this because they aren't really in the game so dont need to use CreateThrownItem to continue its tracing
                    local x = ThingLandedOn.position.x  +unitx*(range+RangeBonus)  +unity*(SidewaysShift)
                    local y = ThingLandedOn.position.y  +unity*(range+RangeBonus)  +unitx*(SidewaysShift)
                    FlyingItem.target={x=x, y=y}
                    --FlyingItem.start=ThingLandedOn.position
                    FlyingItem.ThrowerPosition=ThingLandedOn.position -- for redirecting
                    FlyingItem.StartTick=game.tick
                    FlyingItem.AirTime=1
                    FlyingItem.LandTick=game.tick+1
                else
                    storage.CatapultList[FlyingItem.tracing].ImAlreadyTracer = "traced"
                    storage.CatapultList[FlyingItem.tracing].targets[FlyingItem.item] = "nothing"
                    ClearOverflowTracking = true
                end
            end

        -- non-tracers falling on something
        elseif (FlyingItem.tracing == nil) then
            -- players falling on something
            if (FlyingItem.player) then
                ---- Doesn't make sense for player landingit ----
                if (ThingLandedOn.name == "cliff") then
                    FlyingItem.player.teleport(ThingLandedOn.surface.find_non_colliding_position("iron-chest", FlyingItem.target, 0, 0.5))
                elseif (ThingLandedOn.name ~= "PlayerLauncher" and ThingLandedOn.prototype.collision_mask.layers["player"]) then
                    ---- Damage the player based on thing's size and destroy what they landed on to prevent getting stuck ----
                    FlyingItem.player.character.damage(10*(ThingLandedOn.bounding_box.right_bottom.x-ThingLandedOn.bounding_box.left_top.x)*(ThingLandedOn.bounding_box.right_bottom.y-ThingLandedOn.bounding_box.left_top.y), "neutral", "impact", ThingLandedOn)
                    ThingLandedOn.die()
                end
            --[[ elseif (FlyingItem.type == "ItemShell") then
                -- items falling on something
                game.print("item shell expired on something") ]]
            else
                if (ThingLandedOn.name == "OpenContainer" and ThingLandedOn.can_insert({name=FlyingItem.item, quality=FlyingItem.quality})) then
                    if (FlyingItem.CloudStorage) then
                        ThingLandedOn.insert(FlyingItem.CloudStorage[1])
                        FlyingItem.CloudStorage.destroy()
                    elseif storage.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
                        CubeFlyingItems.release_and_insert(FlyingItem, ThingLandedOn)
                    else
                        ThingLandedOn.insert({name=FlyingItem.item, count=FlyingItem.amount, quality=FlyingItem.quality})
                    end
                    ThingLandedOn.surface.play_sound
                    {
                        path = "RTClunk",
                        position = ThingLandedOn.position,
                        volume_modifier = 0.7
                    }

                ---- If the thing it landed on has an inventory and a hatch, insert the item ----
                elseif (ThingLandedOn.type ~= "transport-belt"
                and settings.startup["RTThrowersSetting"].value == true  -- if false, HatchRT doesn't exist. With 2.1, there are potentially more possible ways thrown items can exist without the base thrower and hatch stuff
                and ThingLandedOn.surface.find_entities_filtered(
                    {
                    name='HatchRT',
                    position={math.floor(FlyingItem.target.x)+0.5, math.floor(FlyingItem.target.y)+0.5},
                    limit = 1
                    })[1]
                ) then
                    if (ThingLandedOn.can_insert({name=FlyingItem.item, quality=FlyingItem.quality})) then
                        if (FlyingItem.CloudStorage) then
                            ThingLandedOn.insert(FlyingItem.CloudStorage[1])
                            FlyingItem.CloudStorage.destroy()
                        elseif storage.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
                            CubeFlyingItems.release_and_insert(FlyingItem, ThingLandedOn)
                        else
                            ThingLandedOn.insert({name=FlyingItem.item, count=FlyingItem.amount, quality=FlyingItem.quality})
                        end
                        ThingLandedOn.surface.play_sound
                        {
                            path = "RTClunk",
                            position = ThingLandedOn.position,
                            volume_modifier = 0.7
                        }
                    else
                        local bounce = math.random(10, 20)*0.1
                        local XBounce = FlyingItem.target.x + (bounce*math.random(-2, 2))
                        local YBounce = FlyingItem.target.y + (bounce*math.random(-2, 2))
                        InvokeThrownItem({
                            type = "ReskinnedStream",
                            bouncing = FlyingItem,
                            start = FlyingItem.target,
                            target = {XBounce, YBounce},
                            speed = 0.25
                        })
                    end

                elseif (ThingLandedOn.name=='RTVacuumHatch') then
                    local properties = storage.VacuumHatches[script.register_on_object_destroyed(ThingLandedOn)]
                    if (properties.output == nil or properties.output.valid == false) then
                        properties.output = ThingLandedOn.surface.find_entities_filtered
                        ({
                            collision_mask = "object",
                            position = OffsetPosition(ThingLandedOn.position, {-1*storage.OrientationUnitComponents[ThingLandedOn.orientation].x, -1*storage.OrientationUnitComponents[ThingLandedOn.orientation].y}),
                            limit = 1
                        })[1]
                    end
                    local deposited = false
                    if (properties.output and properties.output.valid) then
                        if (properties.output.type == "transport-belt") then
                            deposited = DropOntoBelt(FlyingItem, properties.output, false)
                        elseif (properties.output.can_insert({name=FlyingItem.item, quality=FlyingItem.quality})) then
                            if (FlyingItem.CloudStorage) then
                                properties.output.insert(FlyingItem.CloudStorage[1])
                                FlyingItem.CloudStorage.destroy()
                            elseif storage.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
                                CubeFlyingItems.release_and_insert(FlyingItem, properties.output)
                            else
                                properties.output.insert({name=FlyingItem.item, count=FlyingItem.amount, quality=FlyingItem.quality})
                            end
                            deposited = true
                        end
                    else
                        properties.output = nil
                    end
                    if (not deposited) then
                        local XBounce = FlyingItem.target.x + storage.OrientationUnitComponents[ThingLandedOn.orientation].x
                        local YBounce = FlyingItem.target.y + storage.OrientationUnitComponents[ThingLandedOn.orientation].y
                        InvokeThrownItem({
                            type = "ReskinnedStream",
                            bouncing = FlyingItem,
                            start = FlyingItem.target,
                            target = {XBounce, YBounce},
                            speed = 0.25
                        })
                    end
                    ThingLandedOn.surface.play_sound
                    {
                        path = "RTClunk",
                        position = ThingLandedOn.position,
                        volume_modifier = 0.4
                    }

                ---- If it landed on something but there's also a cargo wagon there
                elseif (LandedOnCargoWagon ~= nil and LandedOnCargoWagon.draw_data.height==0 and LandedOnCargoWagon.can_insert({name=FlyingItem.item, quality=FlyingItem.quality})) then
                    if (FlyingItem.CloudStorage) then
                        LandedOnCargoWagon.insert(FlyingItem.CloudStorage[1])
                        FlyingItem.CloudStorage.destroy()
                    elseif storage.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
                        CubeFlyingItems.release_and_insert(FlyingItem, LandedOnCargoWagon)
                    else
                        LandedOnCargoWagon.insert({name=FlyingItem.item, count=FlyingItem.amount, quality=FlyingItem.quality})
                    end

                -- If it's an Ultracube FlyingItem, just spill it near whatever it landed on, potentially onto a belt
                elseif storage.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
                    CubeFlyingItems.release_and_spill(FlyingItem, ThingLandedOn)

                -- transport belt
                elseif (ThingLandedOn.type == "transport-belt") then
                    DropOntoBelt(FlyingItem, ThingLandedOn)

                ---- otherwise it bounces off whatever it landed on and lands as an item on the nearest empty space within 10 tiles. destroyed if no space ----
                else
                    DropOntoGround(FlyingItem)
                end
            end
        -- tracers falling on something
        else
            if (storage.CatapultList[FlyingItem.tracing]) then -- incase the thrower was removed the split second between starting tracing and now
                if (LandedOnCargoWagon and LandedOnCargoWagon.speed == 0) then
                    local OnDestroyNumber = script.register_on_object_destroyed(LandedOnCargoWagon)
                    storage.CatapultList[FlyingItem.tracing].targets[FlyingItem.item] = LandedOnCargoWagon
                    if (storage.ThrowerPaths[OnDestroyNumber] == nil) then
                        storage.ThrowerPaths[OnDestroyNumber] = {}
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing] = {}
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing][FlyingItem.item] = true
                    elseif (storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing] == nil) then
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing] = {}
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing][FlyingItem.item] = true
                    else
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing][FlyingItem.item] = true
                    end
                    
                elseif (ThingLandedOn.unit_number == nil) then -- cliffs/trees/other things without unit_numbers
                    storage.CatapultList[FlyingItem.tracing].targets[FlyingItem.item] = "nothing"

                else
                    local OnDestroyNumber = script.register_on_object_destroyed(ThingLandedOn)
                    storage.CatapultList[FlyingItem.tracing].targets[FlyingItem.item] = ThingLandedOn
                    if (storage.ThrowerPaths[OnDestroyNumber] == nil) then
                        storage.ThrowerPaths[OnDestroyNumber] = {}
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing] = {}
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing][FlyingItem.item] = true
                    elseif (storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing] == nil) then
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing] = {}
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing][FlyingItem.item] = true
                    else
                        storage.ThrowerPaths[OnDestroyNumber][FlyingItem.tracing][FlyingItem.item] = true
                    end
                end
                storage.CatapultList[FlyingItem.tracing].ImAlreadyTracer = "traced"
            end
        end

    -- didn't land on anything
    elseif (FlyingItem.tracing == nil) then -- thrown items
        local ProjectileSurface = FlyingItem.surface
        if (ProjectileSurface.find_tiles_filtered{position = FlyingItem.target, radius = 1, limit = 1, collision_mask = "lava_tile"}[1] ~= nil) then
            ProjectileSurface.create_entity
                ({
                    name = "wall-explosion",
                    position = FlyingItem.target
                })
            ProjectileSurface.create_trivial_smoke
                {
                    name = "fire-smoke",
                    position = FlyingItem.target
                }
            if (FlyingItem.player and FlyingItem.player.character) then
                if (FlyingItem.player.character.get_inventory(defines.inventory.character_armor)
                and FlyingItem.player.character.get_inventory(defines.inventory.character_armor).is_full()
                and FlyingItem.player.character.get_inventory(defines.inventory.character_armor)[1].prototype.provides_flight == true) then
                    -- character lives
                else
                    FlyingItem.player.character.die()
                end
            else
                if ((FlyingItem.item == "ironclad" or FlyingItem.item == "ironclad-ironclad-mortar" or FlyingItem.item == "ironclad-ironclad-cannon") and script.active_mods["aai-vehicles-ironclad"] and ProjectileSurface.can_place_entity{name="ironclad", position=FlyingItem.target} == true) then
                    ProjectileSurface.create_entity
                    {
                        name = FlyingItem.item,
                        position = FlyingItem.target,
                        force = "player",
                        raise_built = true
                    }
                elseif storage.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
                    CubeFlyingItems.panic(FlyingItem) -- Purposefully resort to Ultracube forced recovery
                else
                    ProjectileSurface.pollute(FlyingItem.target, FlyingItem.amount*0.5)
                end

                if (FlyingItem.CloudStorage) then
                    FlyingItem.CloudStorage.destroy()
                end
            end
        elseif (ProjectileSurface.find_tiles_filtered{position = FlyingItem.target, radius = 0.01, limit = 1, collision_mask = "player"}[1] ~= nil) then -- in theory, tiles the player cant walk on are some sort of fluid or other non-survivable ground
            ProjectileSurface.create_entity
                ({
                    name = "water-splash",
                    position = FlyingItem.target
                })
            for eee = 1, 2 do
                ProjectileSurface.create_particle
                {
                    name = "metal-particle-small",
                    position = FlyingItem.target,
                    movement = {-0.01,0},
                    height = 0,
                    vertical_speed = -0.1,
                    frame_speed = 0
                }
            end

            if (FlyingItem.player and FlyingItem.player.character) then
                if (FlyingItem.player.character.get_inventory(defines.inventory.character_armor)
                and FlyingItem.player.character.get_inventory(defines.inventory.character_armor).is_full()
                and FlyingItem.player.character.get_inventory(defines.inventory.character_armor)[1].prototype.provides_flight == true) then
                    -- character lives
                else
                    FlyingItem.player.character.die()
                end
            else
                if (FlyingItem.item == "raw-fish") then
                    for i = 1, math.floor(FlyingItem.amount/prototypes.entity.fish.mineable_properties.products[1].amount) do
                        ProjectileSurface.create_entity
                        {
                            name = "fish",
                            position = FlyingItem.target,
                        }
                    end
                elseif ((FlyingItem.item == "ironclad" or FlyingItem.item == "ironclad-ironclad-mortar" or FlyingItem.item == "ironclad-ironclad-cannon") and script.active_mods["aai-vehicles-ironclad"] and ProjectileSurface.can_place_entity{name="ironclad", position=FlyingItem.target} == true) then
                    ProjectileSurface.create_entity
                    {
                        name = FlyingItem.item,
                        position = FlyingItem.target,
                        force = "player",
                        raise_built = true
                    }
                elseif storage.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
                    CubeFlyingItems.panic(FlyingItem) -- Purposefully resort to Ultracube forced recovery
                else
                    ProjectileSurface.pollute(FlyingItem.target, FlyingItem.amount*0.5)
                end

                if (FlyingItem.CloudStorage) then
                    FlyingItem.CloudStorage.destroy()
                end
            end
        else
            if (FlyingItem.player == nil) then
                if storage.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
                    CubeFlyingItems.release_and_spill(FlyingItem)
                elseif (FlyingItem.type == "ItemShell") then
                    -- the contents of the shell fly out over the ground
                    local spilt = ProjectileSurface.spill_item_stack
                        {
                            position = ProjectileSurface.find_non_colliding_position("item-on-ground", FlyingItem.target, 500, 0.1),
                            stack = {name=FlyingItem.item, count=FlyingItem.amount, quality=FlyingItem.quality}
                        }
                    if (settings.global["RTSpillSetting"].value == "Spill and Mark") then
                        for every, thing in pairs(spilt) do
                            thing.order_deconstruction("player")
                        end
                    end
                else
                    DropOntoGround(FlyingItem)
                end
            end
        end

    -- tracer
    elseif (FlyingItem.tracing and storage.CatapultList[FlyingItem.tracing]) then
        storage.CatapultList[FlyingItem.tracing].ImAlreadyTracer = "traced"
        storage.CatapultList[FlyingItem.tracing].targets[FlyingItem.item] = "nothing"
    end
    
    -- cleanup
    -- overflow tracking
    if (FlyingItem.tracing == nil and ClearOverflowTracking == true and FlyingItem.DestinationDestroyNumber ~= nil and storage.OnTheWay[FlyingItem.DestinationDestroyNumber]) then
        storage.OnTheWay[FlyingItem.DestinationDestroyNumber][FlyingItem.item] = storage.OnTheWay[FlyingItem.DestinationDestroyNumber][FlyingItem.item] - FlyingItem.amount
    end
    if (FlyingItem.player and ClearOverflowTracking == true) then
        if (FlyingItem.player.character) then
            FlyingItem.player.character_running_speed_modifier = FlyingItem.IAmSpeed
            FlyingItem.player.character.walking_state = {walking = false, direction = FlyingItem.player.character.direction}
            SwapBackFromGhost(FlyingItem.player, FlyingItem)
        end
        storage.AllPlayers[FlyingItem.player.index].state = "default"
    end
    if (FlyingItem.sprite and ClearOverflowTracking == true) then
        FlyingItem.sprite.destroy()
    end
    if (FlyingItem.shadow and ClearOverflowTracking == true) then
        FlyingItem.shadow.destroy()
    end
    if ((FlyingItem.tracing or FlyingItem.player) and ClearOverflowTracking == false) then
        -- let it cook
    else
        local FlightID = FlyingItem.StreamDestroyNumber or FlyingItem.FlightNumber -- should never have both
        storage.FlyingItems[FlightID] = nil
        storage.CustomPathFlyingItemSprites[FlightID] = nil
    end
end
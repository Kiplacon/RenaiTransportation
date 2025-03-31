local targets = {
    [0] = {-100, -100},
    [0.25] = {100, -100},
    [0.5] = {100, 100},
    [0.75] = {-100, 100},
}
local increment = 15

local function PersonalFitness(event)
    for each, ItemCannonProperties in pairs(storage.ItemCannons) do
        if (game.tick%increment == 0) then
            if (ItemCannonProperties.timeout) then
                if (ItemCannonProperties.timeout - increment <= 0) then
                    ItemCannonProperties.timeout = nil
                else
                    ItemCannonProperties.timeout = ItemCannonProperties.timeout - increment
                end
            elseif (ItemCannonProperties.entity.valid and ItemCannonProperties.entity.energy == ItemCannonProperties.entity.electric_buffer_size) then
                local slot1 = ItemCannonProperties.chest.get_output_inventory()[1]
                local slot2 = ItemCannonProperties.chest.get_output_inventory()[2]
                if (slot2.valid_for_read
                and slot2.name == "RTItemShellItem"
                and slot1.valid_for_read
                and slot1.count == slot1.prototype.stack_size) then
                    local cannon = ItemCannonProperties.entity
                    if (prototypes.entity["RTItemShell"..slot1.name.."-Q-"..slot1.quality.name]) then
                        --[[ InvokeThrownItem
                        {
                            type = "ItemShell",
                            ItemName = PackedItem,
                            count = prototypes.item[PackedItem].stack_size,
                            quality = ItemCannonProperties.chest.get_output_inventory()[1].quality.name,
                            start = cannon.position,
                            target = OffsetPosition(cannon.position, targets[cannon.orientation]),
                            surface = cannon.surface,
                            cannon = cannon,
                        } ]]
                        cannon.surface.create_entity
                        {
                            name="RTItemShell"..slot1.name.."-Q-"..slot1.quality.name,
                            source = cannon,
                            position = cannon.position,
                            target = OffsetPosition(cannon.position, targets[cannon.orientation]),
                            speed=storage.ItemCannonSpeed,
                            max_range = 100
                        }
                        slot1.clear()
                        slot2.count = slot2.count - 1
                        if (ItemCannonProperties.CantLoad) then
                            ItemCannonProperties.CantLoad.visible = false
                        end
                        ItemCannonProperties.entity.energy = 0
                    else
                        if (ItemCannonProperties.CantLoad == nil) then
                            ItemCannonProperties.CantLoad = rendering.draw_text
                            {
                                text = {"RTmisc.CantLoad", "item-name."..slot1.name},
                                surface = cannon.surface,
                                target = cannon,
                                color = {1,1,1}
                            }
                        else
                            ItemCannonProperties.CantLoad.text = {"RTmisc.CantLoad", slot1.name}
                            ItemCannonProperties.CantLoad.visible = true
                        end
                    end
                    ItemCannonProperties.timeout = (60*3)/increment
                end
            else
                ItemCannonProperties.timeout = 60/increment
            end
        end
        -- laser pointer
        if (ItemCannonProperties.LaserPointer) then
            local cannon = ItemCannonProperties.entity
            cannon.surface.create_entity
            {
                name="RTItemShellLaserPointer-Q-normal",
                source = cannon,
                position = cannon.position,
                target = OffsetPosition(cannon.position, targets[cannon.orientation]),
                speed=0.75,
                max_range = 100
            }
        end
    end
end

return PersonalFitness
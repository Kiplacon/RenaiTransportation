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
                elseif (ItemCannonProperties.entity.valid
                and ItemCannonProperties.chest
                and ItemCannonProperties.chest.get_output_inventory()[1].valid_for_read
                and string.find(ItemCannonProperties.chest.get_output_inventory()[1].name, "RTItemShell") ~= nil) then
                    local item = ItemCannonProperties.chest.get_output_inventory()[1]
                    local cannon = ItemCannonProperties.entity
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
                        name=item.name.."-Q-"..item.quality.name,
                        source = cannon,
                        position = cannon.position,
                        target = OffsetPosition(cannon.position, targets[cannon.orientation]),
                        speed=storage.ItemCannonSpeed,
                        max_range = 100
                    }
                    item.clear()
                    ItemCannonProperties.timeout = (60*3)/increment
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
                    speed=1,
                    max_range = 100
                }
            end
        end
end

return PersonalFitness
local targets = {
    [0] = {-100, -100},
    [0.25] = {100, -100},
    [0.5] = {100, 100},
    [0.75] = {-100, 100},
}
local increment = 15

local function PersonalFitness(event)
    if (game.tick%increment == 0) then
        for each, ItemCannonProperties in pairs(storage.ItemCannons) do
            if (ItemCannonProperties.timeout) then
                if (ItemCannonProperties.timeout - increment <= 0) then
                    ItemCannonProperties.timeout = nil
                else
                    ItemCannonProperties.timeout = ItemCannonProperties.timeout - increment
                end
            elseif (ItemCannonProperties.entity.valid and ItemCannonProperties.chest and ItemCannonProperties.chest.get_output_inventory()[1].valid_for_read) then
                local cannon = ItemCannonProperties.entity
                cannon.surface.create_entity
                {
                    name="RTItemShellwood",
                    source = cannon,
                    position = cannon.position,
                    target = OffsetPosition(cannon.position, targets[cannon.orientation]),
                    speed=storage.ItemCannonSpeed,
                    max_range = 100
                }
                ItemCannonProperties.chest.get_output_inventory()[1].clear()
                ItemCannonProperties.timeout = (60*3)/increment
            else
                ItemCannonProperties.timeout = 60/increment
            end
        end
    end
end

return PersonalFitness
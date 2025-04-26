local function pickerz(event)
    -- player_index = player_index, -- The index of the player who moved the entity
    -- moved_entity = entity, -- The entity that was moved
    -- start_pos = position -- The position that the entity was moved from
    -- start_direction defines.direction The start direction of the entity (since 2.5.0)
    -- start_unit_number integer?        The original unit number of the entity (since 2.5.0)
    local player = game.players(event.player_index)
    local entity = event.moved_entity
    local OldPosition = event.start_pos
    if (entity.name == "RTItemCannon") then
        local properties = storage.ItemCannons[entity.unit_number]
        properties.chest.teleport(entity.position)
        properties.mask.teleport(entity.position)
    end
end

return pickerz
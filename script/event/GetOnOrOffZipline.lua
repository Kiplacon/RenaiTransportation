---@diagnostic disable: need-check-nil
local function GetOnOrOffZipline(event) -- has .name = event ID number, .tick = tick number, .player_index, and .input_name = custom input name
	local player = game.get_player(event.player_index)
	local PlayerProperties = storage.AllPlayers[event.player_index]
	local CursorPosition = event.cursor_position
	local ThingHovering = player.selected

    --| Drop from ziplining
	if (PlayerProperties.state == "zipline" and (player.selected == nil or player.selected.type ~= "electric-pole")) then
        if (player.character.get_inventory(defines.inventory.character_armor)
        and player.character.get_inventory(defines.inventory.character_armor).is_full()
        and player.character.get_inventory(defines.inventory.character_armor)[1].prototype.provides_flight == true) then
            GetOffZipline(player, PlayerProperties)

        elseif (player.surface.find_non_colliding_position("character", {player.position.x, player.position.y+2}, 5, 0.01)
        and player.character.get_inventory(defines.inventory.character_armor)
        and (
                (player.character.get_inventory(defines.inventory.character_armor).is_full()
                and player.character.get_inventory(defines.inventory.character_armor)[1].prototype.provides_flight == false)
            or
                (player.character.get_inventory(defines.inventory.character_armor).is_empty())
            )
        ) then
            GetOffZipline(player, PlayerProperties)

        else
            player.print({"zipline-stuff.NoFreeSpot"})
        end
		--game.print("manually detached")
	end

    --| Hovering something
	if (ThingHovering) then
    --|| Zipline
		if (player.character
		and player.character.driving == false
		and (not string.find(player.character.name, "RTGhost"))
		and (not string.find(player.character.name, "-jetpack"))
		and PlayerProperties.state == "default"
		and ThingHovering.type == "electric-pole"
		and ElectricPoleBlackList[ThingHovering.name] == nil
		and ThingHovering.get_wire_connector(defines.wire_connector_id.pole_copper, true).connection_count > 0) then
			if (math.sqrt((player.position.x-ThingHovering.position.x)^2+(player.position.y-ThingHovering.position.y)^2) <= 6) then
				if (player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].valid_for_read
				and string.find(player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name, "RTZiplineItem")
				and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].valid_for_read)
				then
					GetOnZipline(player, PlayerProperties, ThingHovering)
				else
					player.print({"zipline-stuff.reqs"})
				end
			else
				player.print({"zipline-stuff.range"})
			end

		elseif (player.character and player.character.driving == false and PlayerProperties.state == "default" and ThingHovering.type == "electric-pole" and string.find(player.character.name, "-jetpack")) then
			player.print({"zipline-stuff.range"})

		elseif (player.character and player.character.driving == false and PlayerProperties.state == "default" and ThingHovering.type == "electric-pole" and #ThingHovering.neighbours == 0) then
			player.print({"zipline-stuff.NotConnected"})

		end
    end
end

return GetOnOrOffZipline
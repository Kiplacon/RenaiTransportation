-- effect_id :: string: The effect_id specified in the trigger effect.
-- surface_index :: uint: The surface the effect happened on.
-- source_position :: Position (optional)
-- source_entity :: LuaEntity (optional)
-- target_position :: Position (optional)
-- target_entity :: LuaEntity (optional)

local function effect_triggered(event)
	if (event.effect_id == "RTCrank"
	and global.AllPlayers[event.source_entity.player.index].sliding
	and global.AllPlayers[event.source_entity.player.index].succ.energy ~= 0
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].valid_for_read
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name == "RTZiplineItem"
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event.source_entity.player.index).character.selected_gun_index].valid_for_read
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name == "RTZiplineCrankControlsItem"
	and game.get_player(event.source_entity.player.index).walking_state.walking == true
	) then
		if (global.AllPlayers[event.source_entity.player.index].ForwardDirection[game.get_player(event.source_entity.player.index).walking_state.direction] ~= nil) then
			if (global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed <= 0.420) then
				global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed = global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed + 0.040 --increments slower than 0.008 don't seem to do anything
				game.get_player(event.source_entity.player.index).surface.play_sound
					{
						path = "RTZipAttach",
						position = game.get_player(event.source_entity.player.index).position,
						volume = 0.7
					}
			end
		elseif (global.AllPlayers[event.source_entity.player.index].BackwardsDirection[game.get_player(event.source_entity.player.index).walking_state.direction] ~= nil) then
			if (global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed >= -0.420) then
				global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed = global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed - 0.040
				game.get_player(event.source_entity.player.index).surface.play_sound
					{
						path = "RTZipAttach",
						position = game.get_player(event.source_entity.player.index).position,
						volume = 0.7
					}
			end
		end
	end
end

return effect_triggered

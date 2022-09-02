-- effect_id :: string: The effect_id specified in the trigger effect.
-- surface_index :: uint: The surface the effect happened on.
-- source_position :: Position (optional)
-- source_entity :: LuaEntity (optional)
-- target_position :: Position (optional)
-- target_entity :: LuaEntity (optional)

local function effect_triggered(event)
	if (event.effect_id == "RTCrank"
	and event.source_entity
	and event.source_entity.player
	and global.AllPlayers[event.source_entity.player.index].state == "zipline"
	and global.AllPlayers[event.source_entity.player.index].zipline.succ.energy ~= 0
	and global.AllPlayers[event.source_entity.player.index].zipline.path == nil
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].valid_for_read
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name == "RTZiplineItem"
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event.source_entity.player.index).character.selected_gun_index].valid_for_read
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name == "RTZiplineCrankControlsItem"
	and game.get_player(event.source_entity.player.index).walking_state.walking == true
	) then
		local PlayerProperties = global.AllPlayers[event.source_entity.player.index]
		local MaxBoostedSpeed = 0.420
		local BoostAmount = 0.040
		if (PlayerProperties.zipline.ForwardDirection ~= nil and PlayerProperties.zipline.ForwardDirection[game.get_player(event.source_entity.player.index).walking_state.direction] ~= nil) then
			if (PlayerProperties.zipline.LetMeGuideYou.speed <= MaxBoostedSpeed) then
				PlayerProperties.zipline.LetMeGuideYou.speed = PlayerProperties.zipline.LetMeGuideYou.speed + BoostAmount
				game.get_player(event.source_entity.player.index).surface.play_sound
					{
						path = "RTZipAttach",
						position = game.get_player(event.source_entity.player.index).position,
						volume = 0.7
					}
			end
		elseif (PlayerProperties.zipline.BackwardsDirection ~= nil and PlayerProperties.zipline.BackwardsDirection[game.get_player(event.source_entity.player.index).walking_state.direction] ~= nil) then
			if (PlayerProperties.zipline.LetMeGuideYou.speed >= -MaxBoostedSpeed) then
				PlayerProperties.zipline.LetMeGuideYou.speed = PlayerProperties.zipline.LetMeGuideYou.speed - BoostAmount
				game.get_player(event.source_entity.player.index).surface.play_sound
					{
						path = "RTZipAttach",
						position = game.get_player(event.source_entity.player.index).position,
						volume = 0.7
					}
			end
		end
	elseif (event.effect_id == "PrimerThrowerCheck") then
		local detector = event.source_entity
		local thrower = global.PrimerThrowerLinks[detector.unit_number].thrower
		--local box = global.PrimerThrowerLinks[detector.unit_number].box
		if (global.PrimerThrowerLinks[detector.unit_number].ready == true) then
			game.surfaces[event.surface_index].create_entity
			{
				name = "RTPrimerThrowerShooter-"..thrower.held_stack.name,
				position = thrower.held_stack_position,
				direction = detector.direction,
				target = event.target_entity,
				force = detector.force,
				raise_built = true,
				create_build_effect_smoke = false
			}.destructible = false
			thrower.held_stack.clear()
			--box.insert({name="RTDataTrackerItem"})
			global.PrimerThrowerLinks[detector.unit_number].ready = false
		else
			--box.get_output_inventory().clear()
		end
	end
end

return effect_triggered

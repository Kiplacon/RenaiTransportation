-- effect_id :: string: The effect_id specified in the trigger effect.
-- surface_index :: uint: The surface the effect happened on.
-- source_position :: Position (optional)
-- source_entity :: LuaEntity (optional)
-- target_position :: Position (optional)
-- target_entity :: LuaEntity (optional)
-- cause_entity :: LuaEntity (optional)

local function effect_triggered(event)
	if (event.effect_id == "RTCrank"
	and event.source_entity
	and event.source_entity.player
	and storage.AllPlayers[event.source_entity.player.index].state == "zipline"
	--and storage.AllPlayers[event.source_entity.player.index].zipline.succ.energy ~= 0
	and storage.AllPlayers[event.source_entity.player.index].zipline.path == nil
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].valid_for_read
	and string.find(game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name, "RTZiplineItem")
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event.source_entity.player.index).character.selected_gun_index].valid_for_read
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name == "RTZiplineCrankControlsItem"
	and game.get_player(event.source_entity.player.index).walking_state.walking == true
	) then
		local EquippedTrolley = game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name
		local PlayerProperties = storage.AllPlayers[event.source_entity.player.index]
		local MaxBoostedSpeed = 0.420
		local BoostAmount = 0.040
		if (EquippedTrolley == "RTZiplineItem") then
			-- MaxSpeed = 0.3
			-- accel = 0.004
			MaxBoostedSpeed = 0.420
			BoostAmount = 0.040
		elseif (EquippedTrolley == "RTZiplineItem2") then
			-- MaxSpeed = 0.6
			-- accel = 0.008
			MaxBoostedSpeed = 0.8
			BoostAmount = 0.080
		elseif (EquippedTrolley == "RTZiplineItem3") then
			-- MaxSpeed = 1.5
			-- accel = 0.012
			MaxBoostedSpeed = 2
			BoostAmount = 0.120
		elseif (EquippedTrolley == "RTZiplineItem4") then
			-- MaxSpeed = 4
			-- accel = 0.016
			MaxBoostedSpeed = 0.6
			BoostAmount = 0.20
		elseif (EquippedTrolley == "RTZiplineItem5") then
			-- MaxSpeed = 10
			-- accel = 0.05
			MaxBoostedSpeed = 15
			BoostAmount = 1
		end
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
		local DetectorNumber = script.register_on_object_destroyed(detector)
		local thrower = storage.PrimerThrowerLinks[DetectorNumber].thrower
		if (storage.PrimerThrowerLinks[DetectorNumber].ready == true) then
			if (thrower.held_stack.valid_for_read == true) then
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
			end
			storage.PrimerThrowerLinks[DetectorNumber].ready = false
		else
			--box.get_output_inventory().clear()
		end
	end
end

return effect_triggered

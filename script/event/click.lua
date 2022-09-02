local magnetRamps = require("__RenaiTransportation__/script/trains/magnet_ramps")

local function click(event)
	--| Toggle range overlay in alt-view
	local PlayerProperties = global.AllPlayers[event.player_index]
	local player = game.get_player(event.player_index)
	local clicked = game.get_player(event.player_index).selected
	if (game.get_player(event.player_index).selected and global.BouncePadList[game.get_player(event.player_index).selected.unit_number] ~= nil) then
		rendering.set_visible(global.BouncePadList[game.get_player(event.player_index).selected.unit_number].arrow, not rendering.get_visible(global.BouncePadList[game.get_player(event.player_index).selected.unit_number].arrow))

	--| Start setting range of magenet ramp
	elseif (game.get_player(event.player_index).selected and (game.get_player(event.player_index).selected.name == "RTMagnetTrainRamp" or game.get_player(event.player_index).selected.name == "RTMagnetTrainRampNoSkip") and PlayerProperties.SettingRampRange.SettingRange == false) then
		local ramp = game.get_player(event.player_index).selected
		local MaxRange = settings.global["RTMagRampRange"].value
		game.get_player(event.player_index).print({"magnet-ramp-stuff.Step2"})
		local rektangle = rendering.draw_sprite
			{
				sprite = "RTMagnetTrainRampRange",
				surface = ramp.surface,
				orientation = ramp.orientation+0.25,
				target = ramp,
				target_offset =
					{
						global.OrientationUnitComponents[ramp.orientation+0.25].x-(MaxRange+1)/2*global.OrientationUnitComponents[ramp.orientation].x,
						global.OrientationUnitComponents[ramp.orientation+0.25].y-(MaxRange+1)/2*global.OrientationUnitComponents[ramp.orientation].y
					},
				x_scale = MaxRange/2,
				y_scale = 1,
				tint = {r = 0.5, g = 0, b = 0, a = 0}
			}
		PlayerProperties.SettingRampRange.SettingRange = true
		PlayerProperties.SettingRampRange.Setting = ramp
		PlayerProperties.SettingRampRange.point = ramp.orientation
		PlayerProperties.SettingRampRange.rekt = rektangle
		PlayerProperties.SettingRampRange.range = MaxRange

	--| Set magnet ramp range
	elseif (PlayerProperties.SettingRampRange.SettingRange == true and game.get_player(event.player_index).selected) then
		local TheRail = game.get_player(event.player_index).selected
		local TheRamp = PlayerProperties.SettingRampRange.Setting

		if (TheRail.name == "straight-rail" or TheRail.name == "RTTrainBouncePlate" or TheRail.name == "RTTrainDirectedBouncePlate") then
			--|| Vertical ramps
			if ((PlayerProperties.SettingRampRange.point == 0 or PlayerProperties.SettingRampRange.point == 0.5)
				and TheRamp ~= nil
				and TheRamp.valid == true
				and TheRail.position.x == TheRamp.position.x+global.OrientationUnitComponents[TheRamp.orientation+0.25].x
				and math.abs(TheRail.position.y-TheRamp.position.y) <= PlayerProperties.SettingRampRange.range
			) then
				local range = math.abs(TheRail.position.y-TheRamp.position.y)
				magnetRamps.setRange(
					global.MagnetRamps[TheRamp.unit_number],
					range,
					game.get_player(event.player_index)
				)

			--|| Horizontal ramps
			elseif ((PlayerProperties.SettingRampRange.point == 0.25 or PlayerProperties.SettingRampRange.point == 0.75)
				and TheRamp ~= nil
				and TheRamp.valid == true
				and TheRail.position.y == TheRamp.position.y+global.OrientationUnitComponents[PlayerProperties.SettingRampRange.Setting.orientation+0.25].y
				and math.abs(TheRail.position.x-TheRamp.position.x) <= PlayerProperties.SettingRampRange.range
			) then
				local comp = 0
				if (TheRail.name == "RTTrainBouncePlate" or TheRail.name == "RTTrainDirectedBouncePlate") then
					comp = 1
				end
				local range = math.abs(TheRail.position.x-TheRamp.position.x)
				magnetRamps.setRange(
					global.MagnetRamps[TheRamp.unit_number],
					range,
					game.get_player(event.player_index)
				)
			elseif (TheRamp == nil or TheRamp.valid == false) then
				game.get_player(event.player_index).print({"magnet-ramp-stuff.missing"})


			else
				game.get_player(event.player_index).print({"magnet-ramp-stuff.BeyondRange", PlayerProperties.SettingRampRange.range})

			end

		else
			game.get_player(event.player_index).print({"magnet-ramp-stuff.StraightRail"})

		end

		if (rendering.is_valid(PlayerProperties.SettingRampRange.rekt)) then
			rendering.destroy(PlayerProperties.SettingRampRange.rekt)
		end
		if (TheRamp.valid and global.MagnetRamps[TheRamp.unit_number] and global.MagnetRamps[TheRamp.unit_number].rangeID ~= nil) then
			rendering.destroy(global.MagnetRamps[TheRamp.unit_number].rangeID)
		end
		PlayerProperties.SettingRampRange = {SettingRange=false}

	elseif (PlayerProperties.state == "default"
	and clicked and clicked.name == "RTZiplineTerminal"
	and player.character
	and (not string.find(player.character.name, "-jetpack"))
	and player.is_cursor_empty() == true) then
		if (player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].valid_for_read
		and string.find(player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name, "ZiplineItem")
		and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].valid_for_read
		and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].name == "RTProgrammableZiplineControlsItem") then
			if (DistanceBetween(player.character.position, clicked.position) <= 3) then
				PlayerProperties.GUI.SwapTo = "ZiplineTerminal"
				PlayerProperties.GUI.terminal = clicked
				ShowZiplineTerminalGUI(player, clicked)
			else
				PlayerProperties.GUI.CloseOut = "bofa"
				player.print({"zipline-stuff.range"})
			end
		else
			PlayerProperties.GUI.CloseOut = "bofa"
			player.print({"zipline-stuff.terminalReqs"})
		end
	end
end

return click

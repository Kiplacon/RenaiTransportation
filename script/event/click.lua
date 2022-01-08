local magnetRamps = require("__RenaiTransportation__/script/trains/magnet_ramps")

local function click(event)
	--| Toggle range overlay in alt-view
	if (game.get_player(event.player_index).selected and global.BouncePadList[game.get_player(event.player_index).selected.unit_number] ~= nil) then
		rendering.set_visible(global.BouncePadList[game.get_player(event.player_index).selected.unit_number].arrow, not rendering.get_visible(global.BouncePadList[game.get_player(event.player_index).selected.unit_number].arrow))

	--| Start setting range of magenet ramp
	elseif (game.get_player(event.player_index).selected and (game.get_player(event.player_index).selected.name == "RTMagnetTrainRamp" or game.get_player(event.player_index).selected.name == "RTMagnetTrainRampNoSkip") and global.AllPlayers[event.player_index].SettingRange == nil) then
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
		global.AllPlayers[event.player_index].SettingRange = true
		global.AllPlayers[event.player_index].Setting = ramp
		global.AllPlayers[event.player_index].point = ramp.orientation
		global.AllPlayers[event.player_index].rekt = rektangle
		global.AllPlayers[event.player_index].range = MaxRange

	--| Set magnet ramp range
	elseif (global.AllPlayers[event.player_index].SettingRange == true and game.get_player(event.player_index).selected) then
		local TheRail = game.get_player(event.player_index).selected
		local TheRamp = global.AllPlayers[event.player_index].Setting

		if (TheRail.name == "straight-rail" or TheRail.name == "RTTrainBouncePlate" or TheRail.name == "RTTrainDirectedBouncePlate") then
			--|| Vertical ramps
			if ((global.AllPlayers[event.player_index].point == 0 or global.AllPlayers[event.player_index].point == 0.5)
				and TheRamp ~= nil
				and TheRamp.valid == true
				and TheRail.position.x == TheRamp.position.x+global.OrientationUnitComponents[TheRamp.orientation+0.25].x
				and math.abs(TheRail.position.y-TheRamp.position.y) <= global.AllPlayers[event.player_index].range
			) then
				local range = math.abs(TheRail.position.y-TheRamp.position.y)
				magnetRamps.setRange(
					global.MagnetRamps[TheRamp.unit_number],
					range,
					game.get_player(event.player_index)
				)

			--|| Horizontal ramps
			elseif ((global.AllPlayers[event.player_index].point == 0.25 or global.AllPlayers[event.player_index].point == 0.75)
				and TheRamp ~= nil
				and TheRamp.valid == true
				and TheRail.position.y == TheRamp.position.y+global.OrientationUnitComponents[global.AllPlayers[event.player_index].Setting.orientation+0.25].y
				and math.abs(TheRail.position.x-TheRamp.position.x) <= global.AllPlayers[event.player_index].range
			) then
				local range = math.abs(TheRail.position.x-TheRamp.position.x)

				magnetRamps.setRange(
					global.MagnetRamps[TheRamp.unit_number],
					range,
					game.get_player(event.player_index)
				)
			elseif (TheRamp == nil or TheRamp.valid == false) then
				game.get_player(event.player_index).print({"magnet-ramp-stuff.missing"})


			else
				game.get_player(event.player_index).print({"magnet-ramp-stuff.BeyondRange", global.AllPlayers[event.player_index].range})

			end

		else
			game.get_player(event.player_index).print({"magnet-ramp-stuff.StraightRail"})

		end

		if (rendering.is_valid(global.AllPlayers[event.player_index].rekt)) then
			rendering.destroy(global.AllPlayers[event.player_index].rekt)
		end
		if (TheRamp.valid and global.MagnetRamps[TheRamp.unit_number] and global.MagnetRamps[TheRamp.unit_number].rangeID ~= nil) then
			rendering.destroy(global.MagnetRamps[TheRamp.unit_number].rangeID)
		end
		global.AllPlayers[event.player_index] = {}

	end
end

return click

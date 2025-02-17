---@diagnostic disable: need-check-nil
local magnetRamps = require("__RenaiTransportation__/script/trains/magnet_ramps")

local function click(event)
	--| Toggle range overlay in alt-view
	local PlayerProperties = storage.AllPlayers[event.player_index]
	local player = game.get_player(event.player_index)
	local clicked = game.get_player(event.player_index).selected
	if (clicked) then
		if (storage.BouncePadList[script.register_on_object_destroyed(clicked)] ~= nil) then
			storage.BouncePadList[script.register_on_object_destroyed(clicked)].arrow.visible = not storage.BouncePadList[script.register_on_object_destroyed(clicked)].arrow.visible

		--| Start setting range of magenet ramp
		elseif ((clicked.name == "RTMagnetTrainRamp" or clicked.name == "RTMagnetTrainRampNoSkip") and PlayerProperties.SettingRampRange.SettingRange == false) then
			local ramp = clicked
			local MaxRange = settings.global["RTMagRampRange"].value
			game.get_player(event.player_index).print({"magnet-ramp-stuff.Step2"})
			local rektangle = rendering.draw_sprite
				{
					sprite = "RTMagnetTrainRampRange",
					surface = ramp.surface,
					orientation = ramp.orientation+0.25,
					target =
						{
							ramp.position.x+(0.5*storage.OrientationUnitComponents[ramp.orientation+0.25].x)-(MaxRange)/2*storage.OrientationUnitComponents[ramp.orientation].x,
							ramp.position.y+(0.5*storage.OrientationUnitComponents[ramp.orientation+0.25].y)-(MaxRange)/2*storage.OrientationUnitComponents[ramp.orientation].y
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
		elseif (PlayerProperties.SettingRampRange.SettingRange == true) then
			local TheRamp = PlayerProperties.SettingRampRange.Setting

			if (TheRamp == nil or TheRamp.valid == false) then
				game.get_player(event.player_index).print({"magnet-ramp-stuff.missing"})
			else
				local TheRail = clicked
				local RampDestroyNumber = script.register_on_object_destroyed(TheRamp)
				local RampProperties = storage.TrainRamps[RampDestroyNumber]
				if (TheRail.name == "straight-rail"
				or TheRail.name == "RTTrainBouncePlate"
				or TheRail.name == "RTTrainDirectedBouncePlate"
				or TheRail.name == "elevated-straight-rail") then
					local NotRail = 0
					if (TheRail.name ~= "straight-rail") then
						NotRail = 2
					end
					--|| Vertical ramps
					if ((PlayerProperties.SettingRampRange.point == 0 or PlayerProperties.SettingRampRange.point == 0.5)
						and TheRamp ~= nil
						and TheRamp.valid == true
						--and TheRail.position.x == TheRamp.position.x+storage.OrientationUnitComponents[TheRamp.orientation+0.25].x
						and math.abs(TheRail.position.x - TheRamp.position.x-storage.OrientationUnitComponents[TheRamp.orientation+0.25].x) < 2
						and math.abs(TheRail.position.y-TheRamp.position.y) <= PlayerProperties.SettingRampRange.range
						and TheRail.position.y
					) then
						local range = math.abs(TheRail.position.y-TheRamp.position.y) - NotRail
						magnetRamps.setRange(
							RampProperties,
							range,
							player,
							true,
							TheRail
						)
					--|| Horizontal ramps
					elseif ((PlayerProperties.SettingRampRange.point == 0.25 or PlayerProperties.SettingRampRange.point == 0.75)
						and TheRamp ~= nil
						and TheRamp.valid == true
						--and TheRail.position.y == TheRamp.position.y+storage.OrientationUnitComponents[PlayerProperties.SettingRampRange.Setting.orientation+0.25].y
						and math.abs(TheRail.position.y - TheRamp.position.y-storage.OrientationUnitComponents[PlayerProperties.SettingRampRange.Setting.orientation+0.25].y) < 2
						and math.abs(TheRail.position.x-TheRamp.position.x) <= PlayerProperties.SettingRampRange.range
					) then
						local range = math.abs(TheRail.position.x-TheRamp.position.x) - NotRail
						magnetRamps.setRange(
							RampProperties,
							range,
							player,
							true,
							TheRail
						)
					--out of range
					else
						game.get_player(event.player_index).print({"magnet-ramp-stuff.BeyondRange", PlayerProperties.SettingRampRange.range})
						player.play_sound{path="utility/cannot_build"}
					end
				else
					game.get_player(event.player_index).print({"magnet-ramp-stuff.StraightRail"})
					player.play_sound{path="utility/cannot_build"}
				end
				if (TheRamp.valid and RampProperties and RampProperties.rangeID ~= nil) then
					RampProperties.rangeID.destroy()
				end
			end

			if (PlayerProperties.SettingRampRange.rekt and PlayerProperties.SettingRampRange.rekt.valid) then
				PlayerProperties.SettingRampRange.rekt.destroy()
			end
			
			PlayerProperties.SettingRampRange = {SettingRange=false}
		end
	end
end

return click

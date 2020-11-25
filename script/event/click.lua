local function click(event)
	--| Toggle range overlay in alt-view
	if (game.get_player(event.player_index).selected and global.BouncePadList[game.get_player(event.player_index).selected.unit_number] ~= nil) then
		rendering.set_visible(global.BouncePadList[game.get_player(event.player_index).selected.unit_number].arrow, not rendering.get_visible(global.BouncePadList[game.get_player(event.player_index).selected.unit_number].arrow))

	--| Start setting range of magenet ramp
	elseif (game.get_player(event.player_index).selected and (game.get_player(event.player_index).selected.name == "RTMagnetTrainRamp" or game.get_player(event.player_index).selected.name == "RTMagnetTrainRampNoSkip") and global.AllPlayers[event.player_index].SettingRange == nil) then
		local ramp = game.get_player(event.player_index).selected
		local MaxRange = 100
		game.get_player(event.player_index).print("Now click a straight rail in range to set Magnet Ramp jump distance.")
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
				global.MagnetRamps[TheRamp.unit_number].range = range+6

				local q = rendering.draw_sprite
					{
						sprite = "RTMagnetTrainRampRange",
						surface = TheRamp.surface,
						orientation = TheRamp.orientation+0.25,
						target = TheRamp,
						target_offset =
							{
								global.OrientationUnitComponents[TheRamp.orientation+0.25].x-(range+1)/2*global.OrientationUnitComponents[TheRamp.orientation].x,
								global.OrientationUnitComponents[TheRamp.orientation+0.25].y-(range+1)/2*global.OrientationUnitComponents[TheRamp.orientation].y
							},
						only_in_alt_mode = true,
						x_scale = range/2,
						y_scale = 0.5,
						tint = {r = 0.5, g = 0.5, b = 0, a = 0.5}
					}

				for each, tile in pairs(global.MagnetRamps[TheRamp.unit_number].tiles) do
					tile.destroy()
				end
				global.MagnetRamps[TheRamp.unit_number].tiles = {}

				for i = 0, range do
					local a = TheRamp.surface.create_entity
						({
							name = "RTMagnetRail",
							position = {TheRamp.position.x+0.5*global.OrientationUnitComponents[TheRamp.orientation+0.25].x, TheRamp.position.y+i*-global.OrientationUnitComponents[TheRamp.orientation].y},
							create_build_effect_smoke = true
						})
					rendering.draw_sprite
						{
							sprite = "RTMagnetRailSprite",
							x_scale = 0.5,
							y_scale = 0.5,
							surface = TheRamp.surface,
							target = a,
							render_layer = "80"
						}
					a.destructible = false
					table.insert(global.MagnetRamps[TheRamp.unit_number].tiles, a)

					local b = TheRamp.surface.create_entity
						({
							name = "RTMagnetRail",
							position = {TheRamp.position.x+1.5*global.OrientationUnitComponents[TheRamp.orientation+0.25].x, TheRamp.position.y+i*-global.OrientationUnitComponents[TheRamp.orientation].y},
							create_build_effect_smoke = true
						})
					rendering.draw_sprite
						{
							sprite = "RTMagnetRailSprite",
							x_scale = 0.5,
							y_scale = 0.5,
							surface = TheRamp.surface,
							target = b,
							render_layer = "80"
						}
					b.destructible = false
					table.insert(global.MagnetRamps[TheRamp.unit_number].tiles, b)
				end
				global.MagnetRamps[TheRamp.unit_number].power.electric_buffer_size = 100000*#global.MagnetRamps[TheRamp.unit_number].tiles

				game.get_player(event.player_index).print("Set Range: "..range.." tiles. Required power: "..0.1*#global.MagnetRamps[TheRamp.unit_number].tiles.."MJ")
				global.MagnetRamps[TheRamp.unit_number].rangeID = q

			--|| Horizontal ramps
			elseif ((global.AllPlayers[event.player_index].point == 0.25 or global.AllPlayers[event.player_index].point == 0.75)
				and TheRamp ~= nil
				and TheRamp.valid == true
				and TheRail.position.y == TheRamp.position.y+global.OrientationUnitComponents[global.AllPlayers[event.player_index].Setting.orientation+0.25].y
				and math.abs(TheRail.position.x-TheRamp.position.x) <= global.AllPlayers[event.player_index].range
			) then

				local range = math.abs(TheRail.position.x-TheRamp.position.x)
				global.MagnetRamps[TheRamp.unit_number].range = range+6

				local q = rendering.draw_sprite
					{
						sprite = "RTMagnetTrainRampRange",
						surface = TheRamp.surface,
						orientation = TheRamp.orientation+0.25,
						target = TheRamp,
						target_offset =
							{
								global.OrientationUnitComponents[TheRamp.orientation+0.25].x-(range+1)/2*global.OrientationUnitComponents[TheRamp.orientation].x,
								global.OrientationUnitComponents[TheRamp.orientation+0.25].y-(range+1)/2*global.OrientationUnitComponents[TheRamp.orientation].y
							},
						only_in_alt_mode = true,
						x_scale = range/2,
						y_scale = 0.5,
						tint = {r = 0.5, g = 0.5, b = 0, a = 0.5}
					}

				for each, tile in pairs(global.MagnetRamps[TheRamp.unit_number].tiles) do
					tile.destroy()
				end
				global.MagnetRamps[TheRamp.unit_number].tiles = {}

				for i = 0, range do
					local a = TheRamp.surface.create_entity
						({
							name = "RTMagnetRail",
							position = {TheRamp.position.x+i*-global.OrientationUnitComponents[TheRamp.orientation].x, TheRamp.position.y+0.5*global.OrientationUnitComponents[TheRamp.orientation+0.25].y},
							create_build_effect_smoke = true
						})
					rendering.draw_sprite
						{
							sprite = "RTMagnetRailSprite",
							x_scale = 0.5,
							y_scale = 0.5,
							surface = TheRamp.surface,
							target = a,
							render_layer = "80"
						}
					a.destructible = false
					table.insert(global.MagnetRamps[TheRamp.unit_number].tiles, a)

					local b = TheRamp.surface.create_entity
						({
							name = "RTMagnetRail",
							position = {TheRamp.position.x+i*-global.OrientationUnitComponents[TheRamp.orientation].x, TheRamp.position.y+1.5*global.OrientationUnitComponents[TheRamp.orientation+0.25].y},
							create_build_effect_smoke = true
						})
					rendering.draw_sprite
						{
							sprite = "RTMagnetRailSprite",
							x_scale = 0.5,
							y_scale = 0.5,
							surface = TheRamp.surface,
							target = b,
							render_layer = "80"
						}
					b.destructible = false
					table.insert(global.MagnetRamps[TheRamp.unit_number].tiles, b)
				end
				global.MagnetRamps[TheRamp.unit_number].power.electric_buffer_size = 100000*#global.MagnetRamps[TheRamp.unit_number].tiles
				game.get_player(event.player_index).print("Set Range: "..range.." tiles. Required power: "..0.1*#global.MagnetRamps[TheRamp.unit_number].tiles.."MJ")
				global.MagnetRamps[TheRamp.unit_number].rangeID = q


			elseif (TheRamp == nil or TheRamp.valid == false) then
				game.get_player(event.player_index).print("Magnet Ramp is missing")


			else
				game.get_player(event.player_index).print("Out of range, womp")

			end

		else
			game.get_player(event.player_index).print("That's not a straight rail")

		end

		if (rendering.is_valid(global.AllPlayers[event.player_index].rekt)) then
			rendering.destroy(global.AllPlayers[event.player_index].rekt)
		end
		if (TheRamp.valid and global.MagnetRamps[TheRamp.unit_number] and global.MagnetRamps[TheRamp.unit_number].rangeID ~= nil) then
			rendering.destroy(global.MagnetRamps[TheRamp.unit_number].rangeID)
		end
		global.AllPlayers[event.player_index] = {}
	-- elseif (game.get_player(event.player_index).selected and string.find(game.get_player(event.player_index).selected.name, "RTThrower-")) then
		-- game.print(global.CatapultList[game.get_player(event.player_index).selected.unit_number].target.name)
	end
end

return click

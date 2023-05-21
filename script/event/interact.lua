local function interact(event1) -- has .name = event ID number, .tick = tick number, .player_index, and .input_name = custom input name

	local player = game.get_player(event1.player_index)
	local PlayerProperties = global.AllPlayers[event1.player_index]

	local ThingHovering = player.selected

	--| Player Launcher
	if (settings.startup["RTThrowersSetting"].value == true) then
		PlayerLauncher = player.surface.find_entity("PlayerLauncher", {math.floor(player.position.x)+0.5, math.floor(player.position.y)+0.5})
	else
		PlayerLauncher = nil
	end

	if (PlayerLauncher ~= nil
	and player.character
	and (not string.find(player.character.name, "RTGhost"))
	and PlayerProperties.state == "default") then
		PlayerProperties.state = "jumping"
		local OG = SwapToGhost(player)
		player.teleport(PlayerLauncher.position) -- align player on the launch pad
		local shadow = rendering.draw_circle
			{
				color = {0,0,0,0.5},
				radius = 0.25,
				filled = true,
				target = player.position,
				surface = player.surface
			}
		local x = PlayerLauncher.drop_position.x
		local y = PlayerLauncher.drop_position.y
		local distance = 10
		local speed = 0.2
		local arc = -0.13 -- closer to 0 is higher arc
		local AirTime = math.floor(distance/speed)
		local vector = {x=x-player.position.x, y=y-player.position.y}
		global.FlyingItems[global.FlightNumber] =
			{
				shadow=shadow,
				speed=speed,
				arc=arc,
				player=player,
				SwapBack=OG,
				target={x=x, y=y},
				start=player.position,
				AirTime=AirTime,
				StartTick=game.tick,
				LandTick=game.tick+AirTime,
				vector=vector,
				space=false,
				surface=player.surface
			}
		PlayerProperties.PlayerLauncher.tracker = global.FlightNumber
		PlayerProperties.PlayerLauncher.direction = global.OrientationUnitComponents[PlayerLauncher.orientation].name
		global.FlightNumber = global.FlightNumber + 1
	end

	--| Drop from ziplining
	if (PlayerProperties.state == "zipline") then
		SwapBackFromGhost(player)
		PlayerProperties.zipline.LetMeGuideYou.surface.play_sound
			{
				path = "RTZipDettach",
				position = PlayerProperties.zipline.LetMeGuideYou.position,
				volume = 0.4
			}
		PlayerProperties.zipline.LetMeGuideYou.surface.play_sound
			{
				path = "RTZipWindDown",
				position = PlayerProperties.zipline.LetMeGuideYou.position,
				volume = 0.4
			}
		PlayerProperties.zipline.LetMeGuideYou.destroy()
		PlayerProperties.zipline.ChuggaChugga.destroy()
		PlayerProperties.zipline.succ.destroy()
		player.teleport(player.surface.find_non_colliding_position("character", {player.position.x, player.position.y+2}, 0, 0.01))
		PlayerProperties.zipline = {}
		PlayerProperties.state = "default"

		--game.print("manually detached")
	end

	--| Hovering something
	if (ThingHovering) then
		--|| Adjusting Thrower Range
		if (string.find(ThingHovering.name, "RTThrower-") and ThingHovering.name ~= "RTThrower-PrimerThrower" and global.CatapultList[ThingHovering.unit_number].RangeAdjustable == true) then
			CurrentRange = math.ceil(math.abs(ThingHovering.drop_position.x-ThingHovering.position.x + ThingHovering.drop_position.y-ThingHovering.position.y))
			if ((ThingHovering.name ~= "RTThrower-long-handed-inserter" and CurrentRange >= 15) or CurrentRange >= 25) then
				ThingHovering.drop_position =
					{
						ThingHovering.drop_position.x+(CurrentRange-1)*global.OrientationUnitComponents[ThingHovering.orientation].x,
						ThingHovering.drop_position.y+(CurrentRange-1)*global.OrientationUnitComponents[ThingHovering.orientation].y
					}
			else
				ThingHovering.drop_position =
					{
						ThingHovering.drop_position.x-global.OrientationUnitComponents[ThingHovering.orientation].x,
						ThingHovering.drop_position.y-global.OrientationUnitComponents[ThingHovering.orientation].y
					}
			end
			local NewRange = math.ceil(math.abs(ThingHovering.drop_position.x-ThingHovering.position.x + ThingHovering.drop_position.y-ThingHovering.position.y))
			ThingHovering.surface.create_entity
				({
					name = "flying-text",
					position = ThingHovering.drop_position,
					text = "Range: "..NewRange
				})
			player.play_sound{
				path="utility/gui_click",
				position=player.position,
				volume_modifier=1
				}
			global.CatapultList[ThingHovering.unit_number].range = NewRange
			if (global.CatapultList[ThingHovering.unit_number]) then
				global.CatapultList[ThingHovering.unit_number].targets = {}
				for componentUN, PathsItsPartOf in pairs(global.ThrowerPaths) do
					for ThrowerUN, TrackedItems in pairs(PathsItsPartOf) do
						if (ThrowerUN == ThingHovering.unit_number) then
							global.ThrowerPaths[componentUN][ThrowerUN] = {}
						end
					end
				end
			end
		--|| Swap Primer Modes
		elseif (ThingHovering.name == "PrimerBouncePlate") then
			ThingHovering.surface.create_entity
				({
				name = "PrimerSpreadBouncePlate",
				position = ThingHovering.position,
				force = player.force,
				create_build_effect_smoke = false,
				raise_built = true
				})
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.destroy()
		elseif (ThingHovering.name == "PrimerSpreadBouncePlate") then
			ThingHovering.surface.create_entity
				({
				name = "PrimerBouncePlate",
				position = ThingHovering.position,
				force = player.force,
				create_build_effect_smoke = false,
				raise_built = true
				})
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.destroy()
		--|| Swap Ramp Modes
		elseif (ThingHovering.name == "RTTrainRamp") then
			ElPosition = ThingHovering.position
			ElForce = player.force
			ElDirection = ThingHovering.direction
			ElSurface = ThingHovering.surface
			ThingHovering.destroy()
			ElSurface.create_entity
				({
				name = "RTTrainRampNoSkip",
				position = ElPosition,
				direction = ElDirection,
				force = ElForce,
				raise_built = true,
				create_build_effect_smoke = false
				})
			player.play_sound{
				path="utility/rotated_big",
				position=player.position,
				volume_modifier=1
				}
		elseif (ThingHovering.name == "RTTrainRampNoSkip") then
			ElPosition = ThingHovering.position
			ElForce = player.force
			ElDirection = ThingHovering.direction
			ElSurface = ThingHovering.surface
			ThingHovering.destroy()
			ElSurface.create_entity
				({
				name = "RTTrainRamp",
				position = ElPosition,
				direction = ElDirection,
				force = ElForce,
				raise_built = true,
				create_build_effect_smoke = false
				})
			player.play_sound{
				path="utility/rotated_big",
				position=player.position,
				volume_modifier=1
				}
		--|| Swap Magnet Ramp Modes
		elseif (ThingHovering.name == "RTMagnetTrainRamp") then
			ElPosition = ThingHovering.position
			ElForce = player.force
			ElDirection = ThingHovering.direction
			ElSurface = ThingHovering.surface
			ThingHovering.destroy()
			ElSurface.create_entity
				({
				name = "RTMagnetTrainRampNoSkip",
				position = ElPosition,
				direction = ElDirection,
				force = ElForce,
				raise_built = true,
				create_build_effect_smoke = false,
				raise_built = true
				})
			player.play_sound{
				path="utility/rotated_big",
				position=player.position,
				volume_modifier=1
				}
		elseif (ThingHovering.name == "RTMagnetTrainRampNoSkip") then
			ElPosition = ThingHovering.position
			ElForce = player.force
			ElDirection = ThingHovering.direction
			ElSurface = ThingHovering.surface
			ThingHovering.destroy()
			ElSurface.create_entity
				({
				name = "RTMagnetTrainRamp",
				position = ElPosition,
				direction = ElDirection,
				force = ElForce,
				raise_built = true,
				create_build_effect_smoke = false,
				raise_built = true
				})
			player.play_sound{
				path="utility/rotated_big",
				position=player.position,
				volume_modifier=1
				}
		-- bound pad ranges
		elseif (ThingHovering.name == "BouncePlate") then
			ThingHovering.surface.create_entity
				({
				name = "BouncePlate15",
				position = ThingHovering.position,
				force = player.force,
				create_build_effect_smoke = false,
				raise_built = true
				})
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.destroy()
		elseif (ThingHovering.name == "BouncePlate15") then
			ThingHovering.surface.create_entity
				({
				name = "BouncePlate5",
				position = ThingHovering.position,
				force = player.force,
				create_build_effect_smoke = false,
				raise_built = true
				})
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.destroy()
		elseif (ThingHovering.name == "BouncePlate5") then
			ThingHovering.surface.create_entity
				({
				name = "BouncePlate",
				position = ThingHovering.position,
				force = player.force,
				create_build_effect_smoke = false,
				raise_built = true
				})
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.destroy()
		-- director range
		elseif (ThingHovering.name == "DirectedBouncePlate") then
			ThingHovering.surface.create_entity
				({
				name = "DirectedBouncePlate15",
				position = ThingHovering.position,
				direction = ThingHovering.direction,
				force = player.force,
				create_build_effect_smoke = false,
				raise_built = true
				})
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.destroy()
		elseif (ThingHovering.name == "DirectedBouncePlate15") then
			ThingHovering.surface.create_entity
				({
				name = "DirectedBouncePlate5",
				position = ThingHovering.position,
				direction = ThingHovering.direction,
				force = player.force,
				create_build_effect_smoke = false,
				raise_built = true
				})
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.destroy()
		elseif (ThingHovering.name == "DirectedBouncePlate5") then
			ThingHovering.surface.create_entity
				({
				name = "DirectedBouncePlate",
				position = ThingHovering.position,
				direction = ThingHovering.direction,
				force = player.force,
				create_build_effect_smoke = false,
				raise_built = true
				})
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.destroy()
		--|| Zipline
		elseif (player.character
		and player.character.driving == false
		and (not string.find(player.character.name, "RTGhost"))
		and (not string.find(player.character.name, "-jetpack"))
		and PlayerProperties.state == "default"
		and ThingHovering.type == "electric-pole"
		and #ThingHovering.neighbours["copper"] ~= 0) then
			if (math.sqrt((player.position.x-ThingHovering.position.x)^2+(player.position.y-ThingHovering.position.y)^2) <= 3 ) then
				if (player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].valid_for_read
				and string.find(player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name, "RTZiplineItem")
				and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].valid_for_read)
				then
					GetOnZipline(player, PlayerProperties, ThingHovering)
					-- local OG = SwapToGhost(player)
					-- ---------- get on zipline -----------------
					-- local TheGuy = player
					-- local FromXWireOffset = game.recipe_prototypes["RTGetTheGoods-"..ThingHovering.name.."X"].emissions_multiplier
					-- local FromYWireOffset = game.recipe_prototypes["RTGetTheGoods-"..ThingHovering.name.."Y"].emissions_multiplier
					-- local SpookySlideGhost = ThingHovering.surface.create_entity
					-- 	({
					-- 		name = "RTPropCar",
					-- 		position = {ThingHovering.position.x+FromXWireOffset, ThingHovering.position.y+FromYWireOffset},
					-- 		--force = TheGuy.force,
					-- 		create_build_effect_smoke = false
					-- 	})
					-- local trolley = ThingHovering.surface.create_entity
					-- 	({
					-- 		name = "RTZipline",
					-- 		position = {ThingHovering.position.x+FromXWireOffset, ThingHovering.position.y+FromYWireOffset},
					-- 		force = TheGuy.force,
					-- 		create_build_effect_smoke = false
					-- 	})
					-- local drain = ThingHovering.surface.create_entity
					-- 	({
					-- 		name = "RTZiplinePowerDrain",
					-- 		position = ThingHovering.position,
					-- 		force = TheGuy.force,
					-- 		create_build_effect_smoke = false
					-- 	})
					-- rendering.draw_animation
					-- 	{
					-- 		animation = "RTZiplineOverGFX",
					-- 		surface = TheGuy.surface,
					-- 		target = trolley,
					-- 		target_offset = {0, -0.3},
					-- 		x_scale = 0.5,
					-- 		y_scale = 0.5,
					-- 		render_layer = "wires-above"
					-- 	}
					-- rendering.draw_sprite
					-- 	{
					-- 		sprite = "RTZiplineHarnessGFX",
					-- 		surface = TheGuy.surface,
					-- 		target = trolley,
					-- 		target_offset = {0.03, 0.1},
					-- 		x_scale = 0.5,
					-- 		y_scale = 0.5,
					-- 		render_layer = "128"
					-- 	}
					-- trolley.destructible = false
					-- SpookySlideGhost.destructible = false
					-- drain.destructible = false
					-- TheGuy.teleport({SpookySlideGhost.position.x, 2+SpookySlideGhost.position.y})
					-- trolley.teleport({SpookySlideGhost.position.x, 0.5+SpookySlideGhost.position.y})
					-- PlayerProperties.zipline.LetMeGuideYou = SpookySlideGhost
					-- PlayerProperties.zipline.ChuggaChugga = trolley
					-- PlayerProperties.zipline.WhereDidYouComeFrom = ThingHovering
					-- PlayerProperties.zipline.AreYouStillThere = true
					-- PlayerProperties.zipline.succ = drain
					-- --game.print("Attached to track")
					-- PlayerProperties.state = "zipline"
					-- PlayerProperties.zipline.StartingSurface = TheGuy.surface
					-- PlayerProperties.SwapBack = OG
					-- ThingHovering.surface.play_sound
					-- 	{
					-- 		path = "RTZipAttach",
					-- 		position = ThingHovering.position,
					-- 		volume = 0.7
					-- 	}
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


	--| Adjust thrower range before placing
	if (player.character
	and player.cursor_stack.valid_for_read
	and string.find(player.cursor_stack.name, "RTThrower-")
	and player.cursor_stack.name ~= "RTThrower-EjectorHatchRTItem"
	and player.force.technologies["RTFocusedFlinging"].researched == true) then
		local thrower = string.gsub(player.cursor_stack.name, "-Item", "")
		player.activate_paste() -- tests if activating paste brings up a blueprint to cursor
		if (player.is_cursor_blueprint() == false) then -- only happens in saves where the player has never copied anything yet
			local vvv = player.surface.create_entity({
				name = "wooden-chest",
				position = {0, 0},
				raise_built = false,
				create_build_effect_smoke = false})
			vvv.insert({name = "blueprint"})
			vvv.get_inventory(defines.inventory.chest)[1].set_blueprint_entities(
				{
					{entity_number = 1, name = thrower, position = {0,0}, direction = 4, drop_position = {0,-.8984} }
				})
			player.add_to_clipboard(vvv.get_inventory(defines.inventory.chest)[1])
			player.activate_paste()
			vvv.destroy()
		else
			player.cursor_stack.set_blueprint_entities(
				{
					{entity_number = 1, name = thrower, position = {0,0}, direction = 4, drop_position = {0,-.8984} }
				})
		end
		PlayerProperties.RangeAdjusting = true -- seems to immediately reset to false since the cursor stack changes to the blueprint but idk how to have the check go first and then set the global.RangeAdjusting

	elseif (player.is_cursor_blueprint()
	and player.get_blueprint_entities() ~= nil
	and #player.get_blueprint_entities() == 1
	and string.find(player.get_blueprint_entities()[1].name, "RTThrower-")
	and player.cursor_stack.name ~= "RTThrower-EjectorHatchRTItem"
	and player.get_blueprint_entities()[1].drop_position
	and player.force.technologies["RTFocusedFlinging"].researched == true) then
		local thrower = player.get_blueprint_entities()[1]
		local OneD = player.get_blueprint_entities()[1].direction
		local CurrentRange = math.ceil(math.abs(thrower.drop_position.x-thrower.position.x + thrower.drop_position.y-thrower.position.y))
		if ((thrower.name ~= "RTThrower-long-handed-inserter" and CurrentRange >= 16) or CurrentRange >= 26) then
			WhereWeDroppin =
				{
					thrower.drop_position.x+(CurrentRange-2)*global.OrientationUnitComponents[global.Dir2Ori[thrower.direction]].x,
					thrower.drop_position.y+(CurrentRange-2)*global.OrientationUnitComponents[global.Dir2Ori[thrower.direction]].y
				}
		else
			WhereWeDroppin =
				{
					thrower.drop_position.x-global.OrientationUnitComponents[global.Dir2Ori[thrower.direction]].x,
					thrower.drop_position.y-global.OrientationUnitComponents[global.Dir2Ori[thrower.direction]].y
				}
		end

		player.cursor_stack.set_blueprint_entities(
			{
				{entity_number = 1, name = thrower.name, position = {0,0}, direction = OneD, drop_position = WhereWeDroppin }
			})
		PlayerProperties.RangeAdjusting = true


	end
end

return interact

local function interact(event1) -- has .name = event ID number, .tick = tick number, .player_index, and .input_name = custom input name

	ThingHovering = game.get_player(event1.player_index).selected
	--| Player Launcher
	SteppingOn = game.get_player(event1.player_index).surface.find_entities_filtered
	{
		name = "PlayerLauncher",
		position = game.get_player(event1.player_index).position,
		radius = 0.6
	}[1]

	if (SteppingOn ~= nil and global.AllPlayers[event1.player_index].sliding == nil) then
		game.get_player(event1.player_index).teleport(SteppingOn.position) -- align player on the launch pad

		global.AllPlayers[event1.player_index].direction = global.OrientationUnitComponents[SteppingOn.orientation].name
		global.AllPlayers[event1.player_index].StartMovementTick = event1.tick
		global.AllPlayers[event1.player_index].jumping = true
		global.AllPlayers[event1.player_index].GuideProjectile =
			game.get_player(event1.player_index).surface.create_entity
				({
					name = "test-projectileFromRenaiTransportation",
					position = game.get_player(event1.player_index).position, --required setting for rendering, doesn't affect spawn
					source = game.get_player(event1.player_index).character,
					target_position = SteppingOn.drop_position
				})
	end

	--| Drop from ziplining
	if (global.AllPlayers[event1.player_index].sliding and global.AllPlayers[event1.player_index].sliding == true) then
		global.AllPlayers[event1.player_index].LetMeGuideYou.surface.play_sound
			{
				path = "RTZipDettach",
				position = global.AllPlayers[event1.player_index].LetMeGuideYou.position,
				volume = 0.4
			}
		global.AllPlayers[event1.player_index].LetMeGuideYou.surface.play_sound
			{
				path = "RTZipWindDown",
				position = global.AllPlayers[event1.player_index].LetMeGuideYou.position,
				volume = 0.4
			}
		global.AllPlayers[event1.player_index].LetMeGuideYou.destroy()
		global.AllPlayers[event1.player_index].ChuggaChugga.destroy()
		global.AllPlayers[event1.player_index].succ.destroy()
		game.get_player(event1.player_index).character_running_speed_modifier = 0
		game.get_player(event1.player_index).teleport(game.get_player(event1.player_index).surface.find_non_colliding_position("character", {game.get_player(event1.player_index).position.x, game.get_player(event1.player_index).position.y+2}, 0, 0.01))
		global.AllPlayers[event1.player_index] = {}

		--game.print("manually detached")
	end

	--| Hovering something
	if (ThingHovering) then
		--|| Adjusting Thrower Range
		if (string.find(ThingHovering.name, "RTThrower-") and game.get_player(event1.player_index).force.technologies["RTFocusedFlinging"].researched == true) then
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
			ThingHovering.surface.create_entity
				({
					name = "flying-text",
					position = ThingHovering.drop_position,
					text = "Range: "..math.ceil(math.abs(ThingHovering.drop_position.x-ThingHovering.position.x + ThingHovering.drop_position.y-ThingHovering.position.y))
				})
			game.get_player(event1.player_index).play_sound{
				path="utility/gui_click",
				position=game.get_player(event1.player_index).position,
				volume_modifier=1
				}
		--|| Swap Primer Modes
		elseif (ThingHovering.name == "PrimerBouncePlate") then
			ThingHovering.surface.create_entity
				({
				name = "PrimerSpreadBouncePlate",
				position = ThingHovering.position,
				force = game.get_player(event1.player_index).force,
				create_build_effect_smoke = false,
				raise_built = true
				})
			game.get_player(event1.player_index).play_sound{
				path="utility/rotated_medium",
				position=game.get_player(event1.player_index).position,
				volume_modifier=1
				}
			ThingHovering.destroy()
		elseif (ThingHovering.name == "PrimerSpreadBouncePlate") then
			ThingHovering.surface.create_entity
				({
				name = "PrimerBouncePlate",
				position = ThingHovering.position,
				force = game.get_player(event1.player_index).force,
				create_build_effect_smoke = false,
				raise_built = true
				})
			game.get_player(event1.player_index).play_sound{
				path="utility/rotated_medium",
				position=game.get_player(event1.player_index).position,
				volume_modifier=1
				}
			ThingHovering.destroy()
		--|| Swap Ramp Modes
		elseif (ThingHovering.name == "RTTrainRamp") then
			ElPosition = ThingHovering.position
			ElForce = game.get_player(event1.player_index).force
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
			game.get_player(event1.player_index).play_sound{
				path="utility/rotated_big",
				position=game.get_player(event1.player_index).position,
				volume_modifier=1
				}
		elseif (ThingHovering.name == "RTTrainRampNoSkip") then
			ElPosition = ThingHovering.position
			ElForce = game.get_player(event1.player_index).force
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
			game.get_player(event1.player_index).play_sound{
				path="utility/rotated_big",
				position=game.get_player(event1.player_index).position,
				volume_modifier=1
				}
		--|| Swap Magnet Ramp Modes
		elseif (ThingHovering.name == "RTMagnetTrainRamp") then
			ElPosition = ThingHovering.position
			ElForce = game.get_player(event1.player_index).force
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
			game.get_player(event1.player_index).play_sound{
				path="utility/rotated_big",
				position=game.get_player(event1.player_index).position,
				volume_modifier=1
				}
		elseif (ThingHovering.name == "RTMagnetTrainRampNoSkip") then
			ElPosition = ThingHovering.position
			ElForce = game.get_player(event1.player_index).force
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
			game.get_player(event1.player_index).play_sound{
				path="utility/rotated_big",
				position=game.get_player(event1.player_index).position,
				volume_modifier=1
				}
		--|| Zipline
		elseif (game.get_player(event1.player_index).character and game.get_player(event1.player_index).character.driving == false and global.AllPlayers[event1.player_index].LetMeGuideYou == nil and ThingHovering.type == "electric-pole" and #ThingHovering.neighbours["copper"] ~= 0) then
			if (math.sqrt((game.get_player(event1.player_index).position.x-ThingHovering.position.x)^2+(game.get_player(event1.player_index).position.y-ThingHovering.position.y)^2) <= 3 ) then
				if (game.get_player(event1.player_index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event1.player_index).character.selected_gun_index].valid_for_read
				and game.get_player(event1.player_index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event1.player_index).character.selected_gun_index].name == "RTZiplineItem"
				and game.get_player(event1.player_index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event1.player_index).character.selected_gun_index].valid_for_read)
				then
					local TheGuy = game.get_player(event1.player_index)
					local FromXWireOffset = game.recipe_prototypes["RTGetTheGoods-"..ThingHovering.name.."X"].emissions_multiplier
					local FromYWireOffset = game.recipe_prototypes["RTGetTheGoods-"..ThingHovering.name.."Y"].emissions_multiplier
					local SpookySlideGhost = ThingHovering.surface.create_entity
						({
							name = "RTPropCar",
							position = {ThingHovering.position.x+FromXWireOffset, ThingHovering.position.y+FromYWireOffset},
							--force = TheGuy.force,
							create_build_effect_smoke = false
						})
					local trolley = ThingHovering.surface.create_entity
						({
							name = "RTZipline",
							position = {ThingHovering.position.x+FromXWireOffset, ThingHovering.position.y+FromYWireOffset},
							force = TheGuy.force,
							create_build_effect_smoke = false
						})
					local drain = ThingHovering.surface.create_entity
						({
							name = "RTZiplinePowerDrain",
							position = ThingHovering.position,
							force = TheGuy.force,
							create_build_effect_smoke = false
						})
					rendering.draw_animation
						{
							animation = "RTZiplineOverGFX",
							surface = TheGuy.surface,
							target = trolley,
							target_offset = {0, -0.3},
							x_scale = 0.5,
							y_scale = 0.5,
							render_layer = "wires-above"
						}
					rendering.draw_sprite
						{
							sprite = "RTZiplineHarnessGFX",
							surface = TheGuy.surface,
							target = trolley,
							target_offset = {0.03, 0.1},
							x_scale = 0.5,
							y_scale = 0.5,
							render_layer = "128"
						}
					trolley.destructible = false
					SpookySlideGhost.destructible = false
					drain.destructible = false
					TheGuy.teleport({SpookySlideGhost.position.x, 2+SpookySlideGhost.position.y})
					trolley.teleport({SpookySlideGhost.position.x, 0.5+SpookySlideGhost.position.y})
					global.AllPlayers[event1.player_index].LetMeGuideYou = SpookySlideGhost
					global.AllPlayers[event1.player_index].ChuggaChugga = trolley
					global.AllPlayers[event1.player_index].WhereDidYouComeFrom = ThingHovering
					global.AllPlayers[event1.player_index].AreYouStillThere = true
					global.AllPlayers[event1.player_index].succ = drain
					--game.print("Attached to track")
					global.AllPlayers[event1.player_index].sliding = true
					global.AllPlayers[event1.player_index].StartingSurface = TheGuy.surface
					ThingHovering.surface.play_sound
						{
							path = "RTZipAttach",
							position = ThingHovering.position,
							volume = 0.7
						}
				else
					game.get_player(event1.player_index).print("I need an Electric Zipline Trolley with Controller equipped and selected to ride power lines.")
				end
			else
				game.get_player(event1.player_index).print("Out of range.")
			end

		elseif (game.get_player(event1.player_index).character and game.get_player(event1.player_index).character.driving == false and global.AllPlayers[event1.player_index].LetMeGuideYou == nil and ThingHovering.type == "electric-pole" and #ThingHovering.neighbours == 0) then
			game.get_player(event1.player_index).print("That pole isn't connected to anything")

		end
	end


	--| Adjust thrower range before placing
	if (game.get_player(event1.player_index).cursor_stack.valid_for_read
	and string.find(game.get_player(event1.player_index).cursor_stack.name, "RTThrower-")
	and game.get_player(event1.player_index).cursor_stack.name ~= "RTThrower-EjectorHatchRTItem"
	and game.get_player(event1.player_index).force.technologies["RTFocusedFlinging"].researched == true) then
		local thrower = string.gsub(game.get_player(event1.player_index).cursor_stack.name, "-Item", "")
		game.get_player(event1.player_index).activate_paste() -- tests if activating paste brings up a blueprint to cursor
		if (game.get_player(event1.player_index).is_cursor_blueprint() == false) then -- only happens in saves where the player has never copied anything yet
			local vvv = game.get_player(event1.player_index).surface.create_entity({
				name = "wooden-chest",
				position = {0, 0},
				raise_built = false,
				create_build_effect_smoke = false})
			vvv.insert({name = "blueprint"})
			vvv.get_inventory(defines.inventory.chest)[1].set_blueprint_entities(
				{
					{entity_number = 1, name = thrower, position = {0,0}, direction = 4, drop_position = {0,-.8984} }
				})
			game.get_player(event1.player_index).add_to_clipboard(vvv.get_inventory(defines.inventory.chest)[1])
			game.get_player(event1.player_index).activate_paste()
			vvv.destroy()
		else
			game.get_player(event1.player_index).cursor_stack.set_blueprint_entities(
				{
					{entity_number = 1, name = thrower, position = {0,0}, direction = 4, drop_position = {0,-.8984} }
				})
		end
		global.AllPlayers[event1.player_index].RangeAdjusting = true -- seems to immediately reset to false since the cursor stack changes to the blueprint but idk how to have the check go first and then set the global.RangeAdjusting

	elseif (game.get_player(event1.player_index).is_cursor_blueprint()
	and game.get_player(event1.player_index).get_blueprint_entities() ~= nil
	and #game.get_player(event1.player_index).get_blueprint_entities() == 1
	and string.find(game.get_player(event1.player_index).get_blueprint_entities()[1].name, "RTThrower-")
	and game.get_player(event1.player_index).cursor_stack.name ~= "RTThrower-EjectorHatchRTItem"
	and game.get_player(event1.player_index).get_blueprint_entities()[1].drop_position
	and game.get_player(event1.player_index).force.technologies["RTFocusedFlinging"].researched == true) then
		local thrower = game.get_player(event1.player_index).get_blueprint_entities()[1]
		local OneD = game.get_player(event1.player_index).get_blueprint_entities()[1].direction
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

		game.get_player(event1.player_index).cursor_stack.set_blueprint_entities(
			{
				{entity_number = 1, name = thrower.name, position = {0,0}, direction = OneD, drop_position = WhereWeDroppin }
			})
		-- game.get_player(event1.player_index).create_local_flying_text
			-- {
				-- create_at_cursor = true,
				-- text = "Range: "..math.ceil(math.abs(thrower.drop_position.x-thrower.position.x + thrower.drop_position.y-thrower.position.y))
			-- }
		global.AllPlayers[event1.player_index].RangeAdjusting = true


	end
end

return interact

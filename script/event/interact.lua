local function interact(event1) -- has .name = event ID number, .tick = tick number, .player_index, and .input_name = custom input name

	local player = game.get_player(event1.player_index)

	ThingHovering = player.selected

	--| Player Launcher
	SteppingOn = player.surface.find_entities_filtered
	{
		name = "PlayerLauncher",
		position = {math.floor(player.position.x)+0.5, math.floor(player.position.y)+0.5}
	}[1]

	if (SteppingOn ~= nil and global.AllPlayers[event1.player_index].sliding == nil and global.AllPlayers[event1.player_index].jumping == nil) then
		local OG = player.character
		player.character = nil
		OG.destructible = false
		OG.teleport({1000000,1000000})
		player.create_character(OG.name.."RTGhost")
		player.character.health = OG.health
		player.character.selected_gun_index = OG.selected_gun_index
		for i = 1, #OG.get_main_inventory() do
			player.character.get_main_inventory().insert(OG.get_main_inventory()[i])
		end
		for i = 1, #OG.get_inventory(defines.inventory.character_guns) do
			player.character.get_inventory(defines.inventory.character_guns).insert(OG.get_inventory(defines.inventory.character_guns)[i])
		end
		for i = 1, #OG.get_inventory(defines.inventory.character_ammo) do
			player.character.get_inventory(defines.inventory.character_ammo).insert(OG.get_inventory(defines.inventory.character_ammo)[i])
		end
		for i = 1, #OG.get_inventory(defines.inventory.character_armor) do
			player.character.get_inventory(defines.inventory.character_armor).insert(OG.get_inventory(defines.inventory.character_armor)[i])
		end
		for i = 1, #OG.get_inventory(defines.inventory.character_trash) do
			player.character.get_inventory(defines.inventory.character_trash).insert(OG.get_inventory(defines.inventory.character_trash)[i])
		end
		OG.get_main_inventory().clear()
		OG.get_inventory(defines.inventory.character_guns).clear()
		OG.get_inventory(defines.inventory.character_ammo).clear()
		OG.get_inventory(defines.inventory.character_armor).clear()
		OG.get_inventory(defines.inventory.character_trash).clear()

		player.teleport(SteppingOn.position) -- align player on the launch pad
		local sprite = rendering.draw_sprite
			{
				sprite = "RTBlank",
				target = player.position,
				surface = player.surface
			}
		local shadow = rendering.draw_circle
			{
				color = {0,0,0,0.5},
				radius = 0.25,
				filled = true,
				target = player.position,
				surface = player.surface
			}
		local	x = SteppingOn.drop_position.x
		local y = SteppingOn.drop_position.y
		local distance = 10
		local speed = 0.2
		local arc = -0.13 -- closer to 0 is higher arc
		local AirTime = math.floor(distance/speed)
		local vector = {x=x-player.position.x, y=y-player.position.y}
		global.FlyingItems[global.FlightNumber] = {sprite=sprite, shadow=shadow, speed=speed, arc=arc, player=player, SwapBack=OG, target={x=x, y=y}, start=player.position, AirTime=AirTime, StartTick=game.tick, LandTick=game.tick+AirTime, vector=vector}
		global.AllPlayers[event1.player_index].jumping = global.FlightNumber
		global.AllPlayers[event1.player_index].direction = global.OrientationUnitComponents[SteppingOn.orientation].name
		global.FlightNumber = global.FlightNumber + 1
	end

	--| Drop from ziplining
	if (global.AllPlayers[event1.player_index].sliding and global.AllPlayers[event1.player_index].sliding == true) then
		local player = game.players[event1.player_index]
		local stuff = global.AllPlayers[event1.player_index]
		if (player.character) then
			local OG2 = player.character
			stuff.SwapBack.teleport(player.position)
			player.character = stuff.SwapBack
			stuff.SwapBack.direction = OG2.direction
			for i = 1, #OG2.get_main_inventory() do
				player.character.get_main_inventory().insert(OG2.get_main_inventory()[i])
			end
			for i = 1, #OG2.get_inventory(defines.inventory.character_guns) do
				player.character.get_inventory(defines.inventory.character_guns).insert(OG2.get_inventory(defines.inventory.character_guns)[i])
			end
			for i = 1, #OG2.get_inventory(defines.inventory.character_ammo) do
				player.character.get_inventory(defines.inventory.character_ammo).insert(OG2.get_inventory(defines.inventory.character_ammo)[i])
			end
			for i = 1, #OG2.get_inventory(defines.inventory.character_armor) do
				player.character.get_inventory(defines.inventory.character_armor).insert(OG2.get_inventory(defines.inventory.character_armor)[i])
			end
			for i = 1, #OG2.get_inventory(defines.inventory.character_trash) do
				player.character.get_inventory(defines.inventory.character_trash).insert(OG2.get_inventory(defines.inventory.character_trash)[i])
			end
			stuff.SwapBack.destructible = true
			stuff.SwapBack.health = OG2.health
			stuff.SwapBack.selected_gun_index = OG2.selected_gun_index
			player.character_running_speed_modifier = 0
			OG2.destroy()
		end
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
		player.character_running_speed_modifier = 0
		player.teleport(player.surface.find_non_colliding_position("character", {player.position.x, player.position.y+2}, 0, 0.01))
		global.AllPlayers[event1.player_index] = {}

		--game.print("manually detached")
	end

	--| Hovering something
	if (ThingHovering) then
		--|| Adjusting Thrower Range
		if (string.find(ThingHovering.name, "RTThrower-") and player.force.technologies["RTFocusedFlinging"].researched == true) then
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
			player.play_sound{
				path="utility/gui_click",
				position=player.position,
				volume_modifier=1
				}
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
		--|| Zipline
	elseif (player.character and player.character.driving == false and global.AllPlayers[event1.player_index].jumping == nil and global.AllPlayers[event1.player_index].LetMeGuideYou == nil and ThingHovering.type == "electric-pole" and #ThingHovering.neighbours["copper"] ~= 0) then
			if (math.sqrt((player.position.x-ThingHovering.position.x)^2+(player.position.y-ThingHovering.position.y)^2) <= 3 ) then
				if (player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].valid_for_read
				and player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name == "RTZiplineItem"
				and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].valid_for_read)
				then
					local OG = player.character
					player.character = nil
					OG.destructible = false
					OG.teleport({1000000,1000000})
					player.create_character(OG.name.."RTGhost")
					player.character.health = OG.health
					player.character.selected_gun_index = OG.selected_gun_index
					for i = 1, #OG.get_main_inventory() do
						player.character.get_main_inventory().insert(OG.get_main_inventory()[i])
					end
					for i = 1, #OG.get_inventory(defines.inventory.character_guns) do
						player.character.get_inventory(defines.inventory.character_guns).insert(OG.get_inventory(defines.inventory.character_guns)[i])
					end
					for i = 1, #OG.get_inventory(defines.inventory.character_ammo) do
						player.character.get_inventory(defines.inventory.character_ammo).insert(OG.get_inventory(defines.inventory.character_ammo)[i])
					end
					for i = 1, #OG.get_inventory(defines.inventory.character_armor) do
						player.character.get_inventory(defines.inventory.character_armor).insert(OG.get_inventory(defines.inventory.character_armor)[i])
					end
					for i = 1, #OG.get_inventory(defines.inventory.character_trash) do
						player.character.get_inventory(defines.inventory.character_trash).insert(OG.get_inventory(defines.inventory.character_trash)[i])
					end
					OG.get_main_inventory().clear()
					OG.get_inventory(defines.inventory.character_guns).clear()
					OG.get_inventory(defines.inventory.character_ammo).clear()
					OG.get_inventory(defines.inventory.character_armor).clear()
					OG.get_inventory(defines.inventory.character_trash).clear()
					local TheGuy = player
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
					global.AllPlayers[event1.player_index].SwapBack = OG
					ThingHovering.surface.play_sound
						{
							path = "RTZipAttach",
							position = ThingHovering.position,
							volume = 0.7
						}
				else
					player.print("I need an Electric Zipline Trolley with Controller equipped and selected to ride power lines.")
				end
			else
				player.print("Out of range.")
			end

		elseif (player.character and player.character.driving == false and global.AllPlayers[event1.player_index].LetMeGuideYou == nil and ThingHovering.type == "electric-pole" and #ThingHovering.neighbours == 0) then
			player.print("That pole isn't connected to anything")

		end
	end


	--| Adjust thrower range before placing
	if (player.cursor_stack.valid_for_read
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
		global.AllPlayers[event1.player_index].RangeAdjusting = true -- seems to immediately reset to false since the cursor stack changes to the blueprint but idk how to have the check go first and then set the global.RangeAdjusting

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
		-- player.create_local_flying_text
			-- {
				-- create_at_cursor = true,
				-- text = "Range: "..math.ceil(math.abs(thrower.drop_position.x-thrower.position.x + thrower.drop_position.y-thrower.position.y))
			-- }
		global.AllPlayers[event1.player_index].RangeAdjusting = true


	end
end

return interact

---@diagnostic disable: need-check-nil
local magnetRamps = require("__RenaiTransportation__/script/trains/magnet_ramps")
local function interact(event1) -- has .name = event ID number, .tick = tick number, .player_index, and .input_name = custom input name

	local player = game.get_player(event1.player_index)
	local PlayerProperties = storage.AllPlayers[event1.player_index]
	local CursorPosition = event1.cursor_position
	local ThingHovering = player.selected

	--| Player Launcher
	local PlayerLauncher
	if (settings.startup["RTThrowersSetting"].value == true) then
		PlayerLauncher = player.surface.find_entities_filtered({
			name="PlayerLauncher",
			position={math.floor(player.position.x)+0.5, math.floor(player.position.y)+0.5}})[1]
	end
	if (PlayerLauncher ~= nil
	and player.character
	and (not string.find(player.character.name, "RTGhost"))
	and PlayerProperties.state == "default") then
		PlayerProperties.state = "jumping"
		local OG = SwapToGhost(player)
		player.teleport(PlayerLauncher.position) -- align player on the launch pad
		--[[ local shadow = rendering.draw_circle
			{
				color = {0,0,0,0.5},
				radius = 0.25,
				filled = true,
				target = player.position,
				surface = player.surface
			} ]]
		local x = PlayerLauncher.drop_position.x
		local y = PlayerLauncher.drop_position.y
		local distance = DistanceBetween(PlayerLauncher.position, PlayerLauncher.drop_position)
		local speed = 0.15
		local AirTime = math.floor(distance/speed)
		local vector = {x=x-player.position.x, y=y-player.position.y}
		--[[ storage.FlyingItems[FlightNumber] =
			{
				shadow=shadow,
				speed=speed,
				arc=arc,
				player=player,
				IAmSpeed=player.character.character_running_speed_modifier,
				SwapBack=OG,
				target={x=x, y=y},
				ThrowerPosition=player.position,
				AirTime=AirTime,
				StartTick=game.tick,
				LandTick=game.tick+AirTime,
				vector=vector,
				space=false,
				surface=player.surface
			} ]]
		local FlyingItem = CreateThrownItem({
			type = "PlayerGuide",
			player = player,
			AirTime = AirTime,
			vector = vector,
			SwapBack = OG,
			IAmSpeed = player.character.character_running_speed_modifier,
			--speed = speed,
			ItemName = "wood", -- just need something
			count = 0,-- just need something
			quality = "normal",-- just need something
			start = player.position,
			target={x=x, y=y},
			surface=player.surface,
		})
		PlayerProperties.PlayerLauncher.tracker = FlyingItem.FlightNumber
		PlayerProperties.PlayerLauncher.direction = storage.OrientationUnitComponents[PlayerLauncher.orientation].name
	end

	--| Drop from ziplining
	--[[ if (PlayerProperties.state == "zipline" and (player.selected == nil or player.selected.type ~= "electric-pole")) then
		GetOffZipline(player, PlayerProperties)
		--game.print("manually detached")
	end ]]

	--| Hovering something
	if (ThingHovering) then
		local DestroyNumber = script.register_on_object_destroyed(ThingHovering)
		--game.print(DestroyNumber)
		--|| Adjusting Thrower Range
		if (ThingHovering.type == "inserter" and string.find(ThingHovering.name, "RTThrower-") and ThingHovering.name ~= "RTThrower-PrimerThrower" and storage.CatapultList[DestroyNumber].RangeAdjustable == true) then
			local CurrentRange = math.ceil(math.abs(ThingHovering.drop_position.x-ThingHovering.position.x + ThingHovering.drop_position.y-ThingHovering.position.y))
			if (CurrentRange >= ThingHovering.prototype.inserter_drop_position[2]) then
				ThingHovering.drop_position =
					{
						ThingHovering.drop_position.x+(CurrentRange-2)*storage.OrientationUnitComponents[ThingHovering.orientation].x,
						ThingHovering.drop_position.y+(CurrentRange-2)*storage.OrientationUnitComponents[ThingHovering.orientation].y
					}
			else
				ThingHovering.drop_position =
					{
						ThingHovering.drop_position.x - storage.OrientationUnitComponents[ThingHovering.orientation].x,
						ThingHovering.drop_position.y - storage.OrientationUnitComponents[ThingHovering.orientation].y
					}
			end
			local NewRange = math.ceil(math.abs(ThingHovering.drop_position.x-ThingHovering.position.x + ThingHovering.drop_position.y-ThingHovering.position.y))
			player.create_local_flying_text
				{
					position = ThingHovering.position,
					text = "Range: "..NewRange-1
				}
			player.play_sound{
				path="utility/gui_click",
				position=player.position,
				volume_modifier=1
				}
			storage.CatapultList[DestroyNumber].range = NewRange
			ResetThrowerOverflowTracking(ThingHovering)
			--[[ if (storage.CatapultList[DestroyNumber]) then
				storage.CatapultList[DestroyNumber].targets = {}
				for componentUN, PathsItsPartOf in pairs(storage.ThrowerPaths) do
					for ThrowerUN, TrackedItems in pairs(PathsItsPartOf) do
						if (ThrowerUN == DestroyNumber) then
							storage.ThrowerPaths[componentUN][ThrowerUN] = {}
						end
					end
				end
			end ]]
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
			local ElPosition = ThingHovering.position
			local ElForce = player.force
			local ElDirection = ThingHovering.direction
			local ElSurface = ThingHovering.surface
			ThingHovering.destroy()
			local NewKid = ElSurface.create_entity
				({
					name = "RTTrainRampNoSkip",
					position = ElPosition,
					direction = ElDirection,
					force = ElForce,
					raise_built = true,
					create_build_effect_smoke = false
				})
			player.play_sound
				{
					path="utility/rotated_large",
					position=player.position,
					volume_modifier=1
				}
		elseif (ThingHovering.name == "RTTrainRampNoSkip") then
			local ElPosition = ThingHovering.position
			local ElForce = player.force
			local ElDirection = ThingHovering.direction
			local ElSurface = ThingHovering.surface
			ThingHovering.destroy()
			local NewKid = ElSurface.create_entity
				({
					name = "RTTrainRamp",
					position = ElPosition,
					direction = ElDirection,
					force = ElForce,
					raise_built = true,
					create_build_effect_smoke = false
				})
			player.play_sound
				{
					path="utility/rotated_large",
					position=player.position,
					volume_modifier=1
				}

		--|| Swap Elevated Ramp Modes
		elseif (string.find(ThingHovering.name, "-Elevated") ~= nil and string.find(ThingHovering.name, "NoSkip") == nil) then
			local ElPosition = ThingHovering.position
			local ElForce = player.force
			local ElDirection = ThingHovering.direction
			local ElSurface = ThingHovering.surface
			local NewKid = ElSurface.create_entity
				({
					name = ThingHovering.name.."NoSkip",
					position = ElPosition,
					direction = ElDirection,
					force = ElForce,
					raise_built = true,
					create_build_effect_smoke = false
				})
			player.play_sound
				{
					path="utility/rotated_large",
					position=player.position,
					volume_modifier=1
				}
			ThingHovering.destroy()
		elseif (string.find(ThingHovering.name, "-Elevated") ~= nil and string.find(ThingHovering.name, "NoSkip") ~= nil) then
			local ElPosition = ThingHovering.position
			local ElForce = player.force
			local ElDirection = ThingHovering.direction
			local ElSurface = ThingHovering.surface
			local NewKid = ElSurface.create_entity
				({
					name = string.gsub(ThingHovering.name, "NoSkip", ""),
					position = ElPosition,
					direction = ElDirection,
					force = ElForce,
					raise_built = true,
					create_build_effect_smoke = false
				})
			player.play_sound
				{
					path="utility/rotated_large",
					position=player.position,
					volume_modifier=1
				}
			ThingHovering.destroy()
									
		--|| Swap Magnet Ramp Modes
		elseif (ThingHovering.name == "RTMagnetTrainRamp") then
			local ElPosition = ThingHovering.position
			local ElForce = player.force
			local ElDirection = ThingHovering.direction
			local ElSurface = ThingHovering.surface
			local OldRange = storage.MagnetRamps[script.register_on_object_destroyed(ThingHovering)].range-3
			ThingHovering.destroy()
			local NewKid = ElSurface.create_entity
				({
				name = "RTMagnetTrainRampNoSkip",
				position = ElPosition,
				direction = ElDirection,
				force = ElForce,
				raise_built = true,
				create_build_effect_smoke = false,
				})
			player.play_sound{
				path="utility/rotated_large",
				position=player.position,
				volume_modifier=1
				}
			local RampDestroyNumber = script.register_on_object_destroyed(NewKid)
			local RampProperties = storage.MagnetRamps[RampDestroyNumber]
			magnetRamps.setRange(
					RampProperties,
					OldRange,
					player
				)
		elseif (ThingHovering.name == "RTMagnetTrainRampNoSkip") then
			local ElPosition = ThingHovering.position
			local ElForce = player.force
			local ElDirection = ThingHovering.direction
			local ElSurface = ThingHovering.surface
			local OldRange = storage.MagnetRamps[script.register_on_object_destroyed(ThingHovering)].range-3
			ThingHovering.destroy()
			local NewKid = ElSurface.create_entity
				({
				name = "RTMagnetTrainRamp",
				position = ElPosition,
				direction = ElDirection,
				force = ElForce,
				raise_built = true,
				create_build_effect_smoke = false,
				})
			player.play_sound{
				path="utility/rotated_large",
				position=player.position,
				volume_modifier=1
				}
			local RampDestroyNumber = script.register_on_object_destroyed(NewKid)
			local RampProperties = storage.MagnetRamps[RampDestroyNumber]
			magnetRamps.setRange(
					RampProperties,
					OldRange,
					player
				)

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
		--[[ elseif (player.character
		and player.character.driving == false
		and (not string.find(player.character.name, "RTGhost"))
		and (not string.find(player.character.name, "-jetpack"))
		and PlayerProperties.state == "default"
		and ThingHovering.type == "electric-pole"
		and ElectricPoleBlackList[ThingHovering.name] == nil
		and ThingHovering.get_wire_connector(defines.wire_connector_id.pole_copper, true).connection_count > 0) then
			if (math.sqrt((player.position.x-ThingHovering.position.x)^2+(player.position.y-ThingHovering.position.y)^2) <= 6 ) then
				if (player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].valid_for_read
				and string.find(player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name, "RTZiplineItem")
				and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].valid_for_read)
				then
					GetOnZipline(player, PlayerProperties, ThingHovering)
				else
					player.print({"zipline-stuff.reqs"})
				end
			else
				player.print({"zipline-stuff.range"})
			end

		elseif (player.character and player.character.driving == false and PlayerProperties.state == "default" and ThingHovering.type == "electric-pole" and string.find(player.character.name, "-jetpack")) then
			player.print({"zipline-stuff.range"})

		elseif (player.character and player.character.driving == false and PlayerProperties.state == "default" and ThingHovering.type == "electric-pole" and #ThingHovering.neighbours == 0) then
			player.print({"zipline-stuff.NotConnected"}) ]]

		end
	end


	--| Adjust thrower range before placing
	-- give player the adjusting blueprint
	if (player.character
	and player.cursor_stack.valid_for_read
	and string.find(player.cursor_stack.name, "RTThrower-")
	and player.cursor_stack.name ~= "RTThrower-EjectorHatchRTItem"
	and player.cursor_stack.name ~= "RTThrower-FilterEjectorHatchRTItem"
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
					{entity_number = 1, name = thrower, position = {0,0}, direction = 8, drop_position = {0,-1.2} }
				})
			player.add_to_clipboard(vvv.get_inventory(defines.inventory.chest)[1])
			player.activate_paste()
			vvv.destroy()
		else
			player.cursor_stack.set_blueprint_entities(
				{
					{entity_number = 1, name = thrower, position = {0,0}, direction = 8, drop_position = {0,-1.2} }
				})
		end
		player.play_sound{
			path="utility/gui_click",
			position=player.position,
			volume_modifier=1
			}
		player.create_local_flying_text
			{
				position = CursorPosition,
				text = "Range: "..1
			}
		PlayerProperties.RangeAdjusting = true -- seems to immediately reset to false since the cursor stack changes to the blueprint but idk how to have the check go first and then set the storage.RangeAdjusting
		PlayerProperties.RangeAdjustingDirection = 8
		PlayerProperties.RangeAdjustingRange = 1.2

	--adjust range of blueprint thrower
	elseif (PlayerProperties.RangeAdjusting == true) then
		local thrower = player.cursor_stack.get_blueprint_entities()[1]
		local CurrentRange = PlayerProperties.RangeAdjustingRange
		if (CurrentRange >= prototypes.entity[thrower.name].inserter_drop_position[2]) then
			CurrentRange = 1.2
		else
			CurrentRange = CurrentRange + 1
		end
		player.cursor_stack.set_blueprint_entities(
			{
				{entity_number = 1, name = thrower.name, position = {0,0}, direction = 8, drop_position = {0, -CurrentRange}}
			})
		player.play_sound{
			path="utility/gui_click",
			position=player.position,
			volume_modifier=1
			}
		PlayerProperties.RangeAdjusting = true
		PlayerProperties.RangeAdjustingRange = CurrentRange
		player.create_local_flying_text
			{
				position = CursorPosition,
				text = "Range: "..CurrentRange-0.2
			}
	end
end

return interact

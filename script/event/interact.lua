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
		local OG, shadow = SwapToGhost(player)
		player.teleport(PlayerLauncher.position) -- align player on the launch pad
		local TargetX = PlayerLauncher.drop_position.x
		local TargetY = PlayerLauncher.drop_position.y
		local distance = DistanceBetween(PlayerLauncher.position, PlayerLauncher.drop_position)
		local speed = 0.15
		local AirTime = math.floor(distance/speed)
		local arc = 0.3236*distance^-0.404 -- lower number is higher arc
		local vector = {x=TargetX-player.position.x, y=TargetY-player.position.y}
		local path = {}
		for j = 0, AirTime do
			local progress = j/AirTime
			path[j] =
			{
				x = player.character.position.x+(progress*vector.x),
				y = player.character.position.y+(progress*vector.y),
				height = progress * (1-progress) / arc
			}
		end
		local FlyingItem = InvokeThrownItem({
			type = "PlayerGuide",
			player = player,
			shadow = shadow,
			AirTime = AirTime,
			SwapBack = OG,
			IAmSpeed = player.character.character_running_speed_modifier,
			path = path,
			start = player.position,
			target={x=TargetX, y=TargetY},
			surface=player.surface,
		})
		PlayerProperties.PlayerLauncher.tracker = FlyingItem.FlightNumber
		PlayerProperties.PlayerLauncher.direction = storage.OrientationUnitComponents[PlayerLauncher.orientation].name
		PlayerLauncher.surface.create_particle
		({
			name = "PlayerLauncherParticle",
			position = PlayerLauncher.position,
			movement = {0,0},
			height = 0,
			vertical_speed = 0.1,
			frame_speed = 1
		})
		PlayerLauncher.surface.play_sound
		{
			path = "bounce",
			position = PlayerLauncher.position,
			volume = 0.7
		}
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
		--|| Swap Primer Modes
		elseif (settings.startup["RTBounceSetting"].value == true and ThingHovering.name == "PrimerBouncePlate") then
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
			player.create_local_flying_text
			{
				position = ThingHovering.position,
				text = {"interact-toggling.PrimerPadSpread"}
			}
			ThingHovering.destroy()
		elseif (settings.startup["RTBounceSetting"].value == true and ThingHovering.name == "PrimerSpreadBouncePlate") then
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
			player.create_local_flying_text
			{
				position = ThingHovering.position,
				text = {"interact-toggling.PrimerPadPrecise"}
			}
			ThingHovering.destroy()

		--|| Swap Ramp Modes
		elseif (ThingHovering.name == "RTTrainRamp" or ThingHovering.name == "RTSwitchTrainRamp") then
			local switch = ""
			if (string.find(ThingHovering.name, "Switch")) then
				switch = "Switch"
			end
			local ElPosition = ThingHovering.position
			local ElForce = player.force
			local ElDirection = ThingHovering.direction
			local ElSurface = ThingHovering.surface
			local RailLayer = ThingHovering.rail_layer
			player.create_local_flying_text
			{
				position = ThingHovering.position,
				text = {"interact-toggling.RampScheduleSkipOff"}
			}
			ThingHovering.destroy()
			local NewKid = ElSurface.create_entity
				({
					name = "RT"..switch.."TrainRampNoSkip",
					position = OffsetPosition(ElPosition, {-TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ElDirection][1], -TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ElDirection][2]}),
					direction = ElDirection,
					force = ElForce,
					raise_built = true,
					create_build_effect_smoke = false,
					rail_layer = RailLayer
				})
			player.play_sound
				{
					path="utility/rotated_large",
					position=player.position,
					volume_modifier=1
				}
			
		elseif (ThingHovering.name == "RTTrainRampNoSkip" or ThingHovering.name == "RTSwitchTrainRampNoSkip") then
			local switch = ""
			if (string.find(ThingHovering.name, "Switch")) then
				switch = "Switch"
			end
			local ElPosition = ThingHovering.position
			local ElForce = player.force
			local ElDirection = ThingHovering.direction
			local ElSurface = ThingHovering.surface
			local RailLayer = ThingHovering.rail_layer
			player.create_local_flying_text
			{
				position = ThingHovering.position,
				text = {"interact-toggling.RampScheduleSkipOn"}
			}
			ThingHovering.destroy()
			local NewKid = ElSurface.create_entity
				({
					name = "RT"..switch.."TrainRamp",
					position = OffsetPosition(ElPosition, {-TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ElDirection][1], -TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ElDirection][2]}),
					direction = ElDirection,
					force = ElForce,
					raise_built = true,
					create_build_effect_smoke = false,
					rail_layer = RailLayer
				})
			player.play_sound
				{
					path="utility/rotated_large",
					position=player.position,
					volume_modifier=1
				}
									
		--|| Swap Magnet Ramp Modes
		elseif (ThingHovering.name == "RTMagnetTrainRamp" or ThingHovering.name == "RTMagnetSwitchTrainRamp") then
			local switch = ""
			if (string.find(ThingHovering.name, "Switch")) then
				switch = "Switch"
			end
			local ElPosition = ThingHovering.position
			local ElForce = player.force
			local ElDirection = ThingHovering.direction
			local ElSurface = ThingHovering.surface
			local OldRange = storage.TrainRamps[script.register_on_object_destroyed(ThingHovering)].range-6
			local ElRailLayer = ThingHovering.rail_layer
			local ElSignal = ThingHovering.get_or_create_control_behavior().circuit_condition
			ThingHovering.destroy() -- rail signals cannot be on the same spot
			local NewKid = ElSurface.create_entity
				({
				name = "RTMagnet"..switch.."TrainRampNoSkip",
				position = OffsetPosition(ElPosition, {-TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ElDirection][1], -TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ElDirection][2]}),
				direction = ElDirection,
				force = ElForce,
				raise_built = true,
				create_build_effect_smoke = false,
				rail_layer = ElRailLayer
				})
			player.play_sound{
				path="utility/rotated_large",
				position=player.position,
				volume_modifier=1
				}
			local RampDestroyNumber = script.register_on_object_destroyed(NewKid)
			local RampProperties = storage.TrainRamps[RampDestroyNumber]
			magnetRamps.setRange(
					RampProperties,
					OldRange,
					player,
					nil,
					nil,
					ElSignal
				)
			player.create_local_flying_text
			{
				position = ElPosition,
				text = {"interact-toggling.RampScheduleSkipOff"}
			}
		elseif (ThingHovering.name == "RTMagnetTrainRampNoSkip" or ThingHovering.name == "RTMagnetSwitchTrainRampNoSkip") then
			local switch = ""
			if (string.find(ThingHovering.name, "Switch")) then
				switch = "Switch"
			end
			local ElPosition = ThingHovering.position
			local ElForce = player.force
			local ElDirection = ThingHovering.direction
			local ElSurface = ThingHovering.surface
			local OldRange = storage.TrainRamps[script.register_on_object_destroyed(ThingHovering)].range-6
			local ElRailLayer = ThingHovering.rail_layer
			local ElSignal = ThingHovering.get_or_create_control_behavior().circuit_condition
			ThingHovering.destroy() -- rail signals cannot be on the same spot
			local NewKid = ElSurface.create_entity
				({
				name = "RTMagnet"..switch.."TrainRamp",
				position = OffsetPosition(ElPosition, {-TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ElDirection][1], -TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ElDirection][2]}),
				direction = ElDirection,
				force = ElForce,
				raise_built = true,
				create_build_effect_smoke = false,
				rail_layer = ElRailLayer
				})
			player.play_sound{
				path="utility/rotated_large",
				position=player.position,
				volume_modifier=1
				}
			local RampDestroyNumber = script.register_on_object_destroyed(NewKid)
			local RampProperties = storage.TrainRamps[RampDestroyNumber]
			magnetRamps.setRange(
					RampProperties,
					OldRange,
					player,
					nil,
					nil,
					ElSignal
				)
			player.create_local_flying_text
			{
				position = ElPosition,
				text = {"interact-toggling.RampScheduleSkipOn"}
			}

		-- bound pad ranges
		elseif (settings.startup["RTBounceSetting"].value == true and ThingHovering.name == "RTBouncePlate") then
			local BouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(ThingHovering)]
			local range = ThingHovering.get_or_create_control_behavior().get_section(1).get_slot(1).min
			local increment = 5 -- make this a setting?
			local possibilities = 3 -- make this a setting?
			if (range+increment > increment*possibilities) then
				range = increment
			else
				range = range+increment
			end
			BouncePadProperties.arrow.x_scale = range/10
			BouncePadProperties.arrow.y_scale = range/10
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.get_or_create_control_behavior().get_section(1).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=range})
			player.create_local_flying_text
			{
				position = ThingHovering.position,
				text = {"interact-toggling.SetBounceRange", range}
			}
		-- directed range
		elseif (settings.startup["RTBounceSetting"].value == true and ThingHovering.name == "DirectedBouncePlate") then
			local BouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(ThingHovering)]
			local range = ThingHovering.get_or_create_control_behavior().get_section(1).get_slot(1).min
			local increment = 5 -- make this a setting?
			local possibilities = 3 -- make this a setting?
			if (range+increment > increment*possibilities) then
				range = increment
			else
				range = range+increment
			end
			local xflip = 1
			local yflip = 1
			if (ThingHovering.orientation == 0) then
				xflip = 1
				yflip = 1
			elseif (ThingHovering.orientation == 0.25) then
				xflip = 1
				yflip = 1
			elseif (ThingHovering.orientation == 0.5) then
				xflip = 1
				yflip = -1
			elseif (ThingHovering.orientation == 0.75) then
				xflip = -1
				yflip = 1
			end
			BouncePadProperties.arrow.x_scale = xflip*range/10
			BouncePadProperties.arrow.y_scale = yflip*range/10
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.get_or_create_control_behavior().get_section(1).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=range})
			player.create_local_flying_text
			{
				position = ThingHovering.position,
				text = {"interact-toggling.SetBounceRange", range}
			}
		-- director range
		elseif (settings.startup["RTBounceSetting"].value == true and ThingHovering.name == "DirectorBouncePlate") then
			local BouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(ThingHovering)]
			local range = ThingHovering.get_or_create_control_behavior().get_section(1).get_slot(1).min
			local increment = 5 -- make this a setting?
			local possibilities = 3 -- make this a setting?
			if (range+increment > increment*possibilities) then
				range = increment
			else
				range = range+increment
			end
			BouncePadProperties.arrow.x_scale = range/10
			BouncePadProperties.arrow.y_scale = range/10
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			ThingHovering.get_or_create_control_behavior().get_section(1).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=range})
			player.create_local_flying_text
			{
				position = ThingHovering.position,
				text = {"interact-toggling.SetBounceRange", range}
			}

		elseif (ThingHovering.name == "RTItemCannon") then
			storage.ItemCannons[script.register_on_object_destroyed(ThingHovering)].LaserPointer = not storage.ItemCannons[script.register_on_object_destroyed(ThingHovering)].LaserPointer
			player.play_sound{
				path="utility/rotated_medium",
				position=player.position,
				volume_modifier=1
				}
			local text = "ItemCannonLaserPointerOn"
			if (storage.ItemCannons[script.register_on_object_destroyed(ThingHovering)].LaserPointer == false) then
				text = "ItemCannonLaserPointerOff"
			end
			player.create_local_flying_text
			{
				position = ThingHovering.position,
				text = {"interact-toggling."..text}
			}
		end
	end


	--| Adjust thrower range before placing
	-- give player the adjusting blueprint
	if (--player.character and
	player.cursor_stack.valid_for_read
	and string.find(player.cursor_stack.name, "RTThrower-")
	and player.cursor_stack.name ~= "RTThrower-EjectorHatchRTItem"
	and player.cursor_stack.name ~= "RTThrower-FilterEjectorHatchRTItem"
	and player.force.technologies["RTFocusedFlinging"].researched == true) then
		local thrower = string.gsub(player.cursor_stack.name, "-Item", "")
		player.activate_paste() -- tests if activating paste brings up a blueprint to cursor
		if (player.is_cursor_blueprint() == false) then -- only happens in saves where the player has never copied anything yet
			--[[ local vvv = player.surface.create_entity({
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
			vvv.destroy() ]]
			local vvv = game.create_inventory(1) 
			vvv.insert({name = "blueprint"})
			vvv[1].set_blueprint_entities(
				{
					{entity_number = 1, name = thrower, position = {0,0}, direction = 8, drop_position = {0,-1.2} }
				})
			player.add_to_clipboard(vvv[1])
			player.activate_paste()
			vvv.destroy()
		else
			player.cursor_stack.set_blueprint_entities(
				{
					{entity_number = 1, name = thrower, position = {0,0}, direction = 8, drop_position = {0,-1.2} }
				})
		end
		player.cursor_stack_temporary = true
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

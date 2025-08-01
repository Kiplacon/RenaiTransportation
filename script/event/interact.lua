---@diagnostic disable: need-check-nil
local magnetRamps = require("__RenaiTransportation__/script/trains/magnet_ramps")
local function interact(event1) -- has .name = event ID number, .tick = tick number, .player_index, and .input_name = custom input name

	local player = game.get_player(event1.player_index)
	local PlayerProperties = storage.AllPlayers[event1.player_index]
	local CursorPosition = event1.cursor_position
	local ThingHovering = player.selected

	--| Player Launcher
	if (settings.startup["RTThrowersSetting"].value == true) then
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
		if (settings.startup["RTThrowersSetting"].value == true and player.force.technologies["RTFocusedFlinging"].researched == true and ThingHovering.valid and ThingHovering.type == "inserter" and string.find(ThingHovering.name, "RTThrower-") and ThingHovering.name ~= "RTThrower-PrimerThrower" and storage.CatapultList[DestroyNumber].RangeAdjustable == true) then
			IncreaseThrowerRange(ThingHovering)
			player.create_local_flying_text
				{
					position = ThingHovering.position,
					text = "Range: "..storage.CatapultList[DestroyNumber].range
				}
			player.play_sound{
				path="utility/gui_click",
				position=player.position,
				volume_modifier=1
				}
		end
		--|| Swap Primer Modes
		if (settings.startup["RTBounceSetting"].value == true and ThingHovering.valid) then
			if (ThingHovering.name == "PrimerBouncePlate") then
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
				player.create_local_flying_text
				{
					position = ThingHovering.position,
					text = {"interact-toggling.PrimerPadPrecise"}
				}
				ThingHovering.destroy()
			end
		end

		--|| Swap Ramp Modes
		if (settings.startup["RTTrainRampSetting"].value == true and ThingHovering.valid) then
			if (ThingHovering.name == "RTTrainRamp" or ThingHovering.name == "RTSwitchTrainRamp") then
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
			end
		end

		-- bound pad ranges
		if (settings.startup["RTThrowersSetting"].value == true and ThingHovering.valid) then
			if (ThingHovering.name == "RTBouncePlate") then
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
			elseif (ThingHovering.name == "DirectedBouncePlate") then
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
			elseif (ThingHovering.name == "DirectorBouncePlate") then
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
			end
		end

		if (settings.startup["RTItemCannonSetting"].value == true and ThingHovering.valid and ThingHovering.name == "RTItemCannon") then
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
	if (settings.startup["RTThrowersSetting"].value == true and player.force.technologies["RTFocusedFlinging"].researched == true) then
		if (--player.character and
				player.cursor_stack.valid_for_read
				and string.find(player.cursor_stack.name, "RTThrower-")
				and player.cursor_stack.name ~= "RTThrower-EjectorHatchRT"
				and player.cursor_stack.name ~= "RTThrower-FilterEjectorHatchRT"
			)
		or (
				player.cursor_ghost ~= nil
				and string.find(player.cursor_ghost.name.name, "RTThrower-")
				and player.cursor_ghost.name.name ~= "RTThrower-EjectorHatchRT"
				and player.cursor_ghost.name.name ~= "RTThrower-FilterEjectorHatchRT"
		) then
			local ThrowerName
			if (player.cursor_stack.valid_for_read) then
				ThrowerName = string.gsub(player.cursor_stack.name, "-Item", "")
			else
				ThrowerName = string.gsub(player.cursor_ghost.name.name, "-Item", "")
			end
			local ThrowerNormalRange = math.sqrt(prototypes.entity[ThrowerName].inserter_drop_position[1]^2 + prototypes.entity[ThrowerName].inserter_drop_position[2]^2)
			local ThrowerUnitX = prototypes.entity[ThrowerName].inserter_drop_position[1]/ThrowerNormalRange
			local ThrowerUnitY = prototypes.entity[ThrowerName].inserter_drop_position[2]/ThrowerNormalRange
			player.clear_cursor()
			player.cursor_stack.set_stack({name = "blueprint"})
			player.cursor_stack.set_blueprint_entities(
			{
				{entity_number = 1, name = ThrowerName, position = {0,0}, direction = 8, drop_position = {-ThrowerUnitX - ((ThrowerUnitX ~= 0) and (0.2) or 0), -ThrowerUnitY - ((ThrowerUnitY ~= 0) and (0.2) or 0)} }
			})
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
			PlayerProperties.RangeAdjusting = true
			PlayerProperties.RangeAdjustingDirection = 8
			PlayerProperties.RangeAdjustingRange = 1

		--adjust range of blueprint thrower
		elseif (PlayerProperties.RangeAdjusting == true) then
			if (player.is_cursor_blueprint() == true) then
				local thrower = player.cursor_stack.get_blueprint_entities()[1]
				local ThrowerName = thrower.name
				local ThrowerNormalRange = math.sqrt(prototypes.entity[ThrowerName].inserter_drop_position[1]^2 + prototypes.entity[ThrowerName].inserter_drop_position[2]^2)
				local ThrowerUnitX = prototypes.entity[ThrowerName].inserter_drop_position[1]/ThrowerNormalRange
				local ThrowerUnitY = prototypes.entity[ThrowerName].inserter_drop_position[2]/ThrowerNormalRange
				local CurrentRange = PlayerProperties.RangeAdjustingRange
				local NewDrop
				--game.print("CurrentRange: "..CurrentRange.." ThrowerNormalRange: "..ThrowerNormalRange)
				if (CurrentRange >= math.floor(ThrowerNormalRange)) then
					CurrentRange = 1
					NewDrop = {-ThrowerUnitX - ((ThrowerUnitX ~= 0) and (0.2) or 0), -ThrowerUnitY - ((ThrowerUnitY ~= 0) and (0.2) or 0)}
				else
					CurrentRange = CurrentRange + 1
					NewDrop = {-ThrowerUnitX * CurrentRange - ((ThrowerUnitX ~= 0) and (0.2) or 0), -ThrowerUnitY * CurrentRange - ((ThrowerUnitY ~= 0) and (0.2) or 0)}
				end
				player.cursor_stack.set_blueprint_entities(
					{
						{entity_number = 1, name = thrower.name, position = {0,0}, direction = 8, drop_position = NewDrop}
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
						text = "Range: "..CurrentRange
					}
			else
				PlayerProperties.RangeAdjusting = false
			end
		end
	end
end

return interact

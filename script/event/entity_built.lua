local trainHandler = require("__RenaiTransportation__/script/trains/entity_built")

local function NextThrowerGroup()
	storage.CatapultGroup = storage.CatapultGroup + 1
	if (storage.CatapultGroup > storage.ThrowerGroups) then
		storage.CatapultGroup = 1
	end
	return storage.CatapultGroup
end

local function entity_built(event)
	local entity = event.created_entity or event.entity or event.destination or {name="ghost"}
	local player = nil

	if event.player_index then
		player = game.players[event.player_index]
		if (storage.AllPlayers[event.player_index].RangeAdjusting == true
		and entity.name == "entity-ghost"
		and string.find(entity.ghost_prototype.name, "RTThrower-")
		and player.get_main_inventory().find_item_stack(entity.ghost_prototype.name.."-Item")
		) then
			player.get_main_inventory().remove({name=entity.ghost_prototype.name.."-Item", count=1})
			entity.revive({raise_revive = true})
			return
		end
	elseif event.robot then
		player = event.robot.last_user
	end

	if entity and trainHandler(entity, player) then
		return
	end

	if (entity.type == "inserter" and string.find(entity.name, "RTThrower-")) then
		local OnDestroyNumber = script.register_on_object_destroyed(entity)
		storage.CatapultList[OnDestroyNumber] = {entity=entity, targets={}, BurnerSelfRefuelCompensation=0.2, IsElectric=false, InSpace=false, RangeAdjustable=false}
		local properties = storage.CatapultList[OnDestroyNumber]
		storage.ThrowerProcessing[NextThrowerGroup()][OnDestroyNumber] = properties

		if (string.find(entity.name, "RTThrower-") and entity.name ~= "RTThrower-PrimerThrower" and entity.force.technologies["RTFocusedFlinging"].researched == true) then
			properties.RangeAdjustable = true
		end

		if (entity.surface.platform or string.find(entity.surface.name, " Orbit") or string.find(entity.surface.name, " Field") or string.find(entity.surface.name, " Belt")) then
			properties.InSpace = true
		end

		if (entity.burner == nil and #entity.fluidbox == 0 and entity.electric_buffer_size ~= nil and entity.electric_buffer_size > 0) then
			properties.BurnerSelfRefuelCompensation = 0
			properties.IsElectric = true
		elseif (entity.name == "RTThrower-PrimerThrower") then
			properties.BurnerSelfRefuelCompensation = -0.1
		end

		if (entity.name == "RTThrower-EjectorHatchRT") then
			properties.sprite = rendering.draw_animation
				{
					animation = "EjectorHatchFrames",
					surface = entity.surface,
					target = entity,
					animation_offset = storage.EjectorPointing[entity.direction],
					render_layer = 131,
					animation_speed = 0,
					only_in_alt_mode = false
				}
		elseif (entity.name == "RTThrower-FilterEjectorHatchRT") then
			properties.sprite = rendering.draw_animation
				{
					animation = "FilterEjectorHatchFrames",
					surface = entity.surface,
					target = entity,
					animation_offset = storage.EjectorPointing[entity.direction],
					render_layer = 131,
					animation_speed = 0,
					only_in_alt_mode = false
				}
		elseif (entity.name == "RTThrower-PrimerThrower") then
			
			entity.inserter_stack_size_override = 1
			local sherlock = entity.surface.create_entity
			{
				name = "RTPrimerThrowerDetector",
				position = entity.position,
				direction = storage.PrimerThrowerPointing[entity.direction],
				force = entity.force,
				create_build_effect_smoke = false
			}
			sherlock.destructible = false
			properties.entangled = {}
			properties.entangled.detector = sherlock
			local OnDestroyNumber2 = script.register_on_object_destroyed(sherlock)
			storage.PrimerThrowerLinks[OnDestroyNumber2] = {thrower = entity, ready = false}--, box = box}
		end

	elseif (entity.name == "PlayerLauncher") then
		entity.active = false

	elseif (string.find(entity.name, "BouncePlate") and not string.find(entity.name, "Train")) then
		storage.BouncePadList[script.register_on_object_destroyed(entity)] = {entity=entity, arrow=nil}
		local PouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(entity)]
		local ShowRange = settings.global["RTShowRange"].value
		if (entity.name == "DirectedBouncePlate") then
			local HomeOnThe = entity.get_or_create_control_behavior().get_section(1).get_slot(1).min or 10
			if (entity.orientation == 0) then
				direction = "UD"
				xflip = 1
				yflip = 1
			elseif (entity.orientation == 0.25) then
				direction = "RL"
				xflip = 1
				yflip = 1
			elseif (entity.orientation == 0.5) then
				direction = "UD"
				xflip = 1
				yflip = -1
			elseif (entity.orientation == 0.75) then
				direction = "RL"
				xflip = -1
				yflip = 1
			end
			PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = xflip*HomeOnThe/10,
					y_scale = yflip*HomeOnThe/10,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0},
					visible = ShowRange
				}
			PouncePadProperties.ShowArrow = ShowRange
			entity.get_or_create_control_behavior().get_section(1).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=HomeOnThe})
		elseif (entity.name == "RTBouncePlate"
		or entity.name == "SignalBouncePlate"
		or entity.name == "DirectorBouncePlate") then
			local HomeOnThe = entity.get_or_create_control_behavior().get_section(1).get_slot(1).min or 10
			PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = entity.surface,
					target = entity,
					x_scale = HomeOnThe/10,
					y_scale = HomeOnThe/10,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0},
					visible = ShowRange
				}
			PouncePadProperties.ShowArrow = ShowRange
			-- link trackers with director plates on build or blueprint build
			if (entity.name == "DirectorBouncePlate" and entity.get_or_create_control_behavior().sections_count == 1) then
				entity.get_or_create_control_behavior().add_section()
				entity.get_or_create_control_behavior().add_section()
				entity.get_or_create_control_behavior().add_section()
				entity.get_or_create_control_behavior().add_section()
				entity.get_or_create_control_behavior().get_section(5).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=HomeOnThe})
			else
				entity.get_or_create_control_behavior().get_section(1).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=HomeOnThe})
			end

		elseif (entity.name == "PrimerBouncePlate") then
			PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0},
					visible = ShowRange
				}
			PouncePadProperties.ShowArrow = ShowRange
		elseif (entity.name == "PrimerSpreadBouncePlate") then
			PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerSpreadRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0},
					visible = ShowRange
				}
			PouncePadProperties.ShowArrow = ShowRange
		end
	------- make train ramp stuff unrotatable just in case
	--[[ elseif (entity.name == "RTTrainRamp" or entity.name == "RTTrainRampNoSkip" or entity.name == "RTMagnetTrainRamp" or entity.name == "RTMagnetTrainRampNoSkip") then
		entity.rotatable = false ]]

	elseif (string.find(entity.name, "RTPrimerThrowerShooter-")) then
		local time = 2
		if (storage.clock[game.tick+time] == nil) then
			storage.clock[game.tick+time] = {}
		end
		if (storage.clock[game.tick+time].destroy == nil) then
			storage.clock[game.tick+time].destroy = {}
		end
		storage.clock[game.tick+time].destroy[entity.unit_number] = entity

	elseif (entity.name == "RTZiplineTerminal") then
		local OnDestroyNumber = script.register_on_object_destroyed(entity)
		storage.ZiplineTerminals[OnDestroyNumber] = {entity=entity, name=game.backer_names[math.random(1, #game.backer_names)]}
		local tag = entity.force.add_chart_tag(entity.surface, {position=entity.position, text=storage.ZiplineTerminals[OnDestroyNumber].name, icon={type="item", name="RTZiplineTerminalItem"}})
		storage.ZiplineTerminals[OnDestroyNumber].tag = tag

	elseif (entity.name == "RTTrapdoorSwitch") then
		local TriggerDestroyNumber = script.register_on_object_destroyed(entity)
		if (storage.DestructionLinks[TriggerDestroyNumber] == nil) then
			storage.DestructionLinks[TriggerDestroyNumber] = {}
		end
		if (entity.rail_layer == defines.rail_layer.ground) then
			local detector = entity.surface.create_entity
			{
				name = "RTTrainDetector",
				position = entity.position,
				force = "neutral", -- makes it deal collision damage even if friendly fire is off
				create_build_effect_smoke = false,
				raise_built = true
			}
		elseif (entity.rail_layer == defines.rail_layer.elevated) then
			local detector = entity.surface.create_entity
			{
				name = "RTTrainDetectorElevated",
				position = entity.position,
				force = "neutral", -- makes it deal collision damage even if friendly fire is off
				create_build_effect_smoke = false,
				raise_built = true
			}
		end
	elseif (entity.name == "RTTrainDetector" or entity.name == "RTTrainDetectorElevated") then -- used when a trapdoor switch is built or rezzed
		local switch = entity.surface.find_entities_filtered({name="RTTrapdoorSwitch", position=entity.position})[1]
		if (switch) then
			storage.DestructionLinks[script.register_on_object_destroyed(switch)] = {entity} -- Trapdoor switches will only ever have 1 linked detector so this is a list of 1
		else
			entity.destroy()
		end
		
	elseif (entity.name == "RTTrapdoorWagon") then
		storage.TrapdoorWagonsClosed[script.register_on_object_destroyed(entity)] = {entity=entity, OpenIndicator=nil}
		-- draw a red circle to show the trapdoor starts closed
		storage.TrapdoorWagonsClosed[script.register_on_object_destroyed(entity)].OpenIndicator = rendering.draw_sprite
			{
				sprite = "RTTrapdoorWagonClosed",
				target = entity,
				surface = entity.surface,
				only_in_alt_mode = true
			}
	elseif (string.find(entity.name, '^RT') and string.find(entity.name, "BeltRamp")) then
		local ranges = {["RTBeltRamp"]=10, ["RTfastBeltRamp"]=20, ["RTexpressBeltRamp"]=30, ["RTturboBeltRamp"]=40}
		local speeds = {["RTBeltRamp"]=0.18, ["RTfastBeltRamp"]=0.18, ["RTexpressBeltRamp"]=0.25, ["RTturboBeltRamp"]=0.25}
		storage.BeltRamps[script.register_on_object_destroyed(entity)] = {entity=entity, range=(ranges[entity.name] or 10), speed=(speeds[entity.name] or 0.18), InSpace=false, PlayerTrigger=nil}
		if (entity.surface.platform or string.find(entity.surface.name, " Orbit") or string.find(entity.surface.name, " Field") or string.find(entity.surface.name, " Belt")) then
			storage.BeltRamps[script.register_on_object_destroyed(entity)].InSpace = true
		end
		local trigger = entity.surface.create_entity
		{
			name = "RTBeltRampPlayerTrigger",
			position = OffsetPosition(entity.position, {-0.3*storage.OrientationUnitComponents[entity.orientation].x, -0.3*storage.OrientationUnitComponents[entity.orientation].y})
		}
		trigger.destructible = false
		storage.BeltRamps[script.register_on_object_destroyed(entity)].PlayerTrigger = trigger

	elseif (entity.name == "RTVacuumHatch") then
		storage.VacuumHatches[script.register_on_object_destroyed(entity)] = {entity=entity, output=nil}
		local properties = storage.VacuumHatches[script.register_on_object_destroyed(entity)]
		properties.output = entity.surface.find_entities_filtered
		({
			collision_mask = "object",
			position = OffsetPosition(entity.position, {-1*storage.OrientationUnitComponents[entity.orientation].x, -1*storage.OrientationUnitComponents[entity.orientation].y}),
			limit = 1
		})[1]

	elseif (event.ghost or entity.name == "entity-ghost") then -- ghosts from dying and ghosts from blueprints
		local ghost = event.ghost or entity
		local RampList = {RTTrainRamp=true, RTTrainRampNoSkip=true, RTMagnetTrainRamp=true, RTMagnetTrainRampNoSkip=true, RTImpactUnloader=true, RTTrapdoorSwitch=true, RTSwitchTrainRamp=true, RTSwitchTrainRampNoSkip=true, RTMagnetSwitchTrainRamp=true, RTMagnetSwitchTrainRampNoSkip=true}
		if (RampList[ghost.ghost_name]) then
			local SixteenDirNudge = 1
			ghost.teleport(OffsetPosition(ghost.position, {-TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ghost.direction][1]*SixteenDirNudge, -TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ghost.direction][2]*SixteenDirNudge}))
		end

	elseif (entity.name == "RTItemCannon") then
		storage.ItemCannons[script.register_on_object_destroyed(entity)] = {entity=entity, LaserPointer=false}
		local chest = entity.surface.create_entity
		{
			name = "RTItemCannonChest",
			position = entity.position,
			force = entity.force,
			create_build_effect_smoke = false
		}
		chest.destructible = false
		storage.ItemCannons[script.register_on_object_destroyed(entity)].chest = chest
	end
end

return entity_built

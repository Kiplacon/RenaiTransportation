local trainHandler = require("__RenaiTransportation__/script/trains/entity_built")

local function entity_built(event)
	local entity = event.created_entity or event.entity or event.destination

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

	if trainHandler(entity, player) then
		return
	end

	if (entity.type == "inserter" and string.find(entity.name, "RTThrower-")) then
		local OnDestroyNumber = script.register_on_object_destroyed(entity)
		storage.CatapultList[OnDestroyNumber] = {entity=entity, targets={}, BurnerSelfRefuelCompensation=0.2, IsElectric=false, InSpace=false, RangeAdjustable=false}
		local properties = storage.CatapultList[OnDestroyNumber]

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
			storage.CatapultList[OnDestroyNumber].sprite = rendering.draw_animation
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
			storage.CatapultList[OnDestroyNumber].sprite = rendering.draw_animation
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
			storage.CatapultList[OnDestroyNumber].entangled = {}
			storage.CatapultList[OnDestroyNumber].entangled.detector = sherlock
			local OnDestroyNumber2 = script.register_on_object_destroyed(sherlock)
			storage.PrimerThrowerLinks[OnDestroyNumber2] = {thrower = entity, ready = false}--, box = box}
		end

	elseif (entity.name == "PlayerLauncher") then
		entity.operable = false
		entity.active = false

	elseif (string.find(entity.name, "BouncePlate") and not string.find(entity.name, "Train")) then
		storage.BouncePadList[script.register_on_object_destroyed(entity)] = {TheEntity = entity}
		local PouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(entity)]
		ShowRange = settings.global["RTShowRange"].value
		if (entity.name == "DirectedBouncePlate"
		or entity.name == "DirectedBouncePlate5"
		or entity.name == "DirectedBouncePlate15") then
			--entity.operable = false
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
			if (entity.name == "DirectedBouncePlate5") then
				xflip = xflip*0.5
				yflip = yflip*0.5
			elseif (entity.name == "DirectedBouncePlate15") then
				xflip = xflip*1.5
				yflip = yflip*1.5
			end
			PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = xflip,
					y_scale = yflip,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0},
					visible = ShowRange
				}
		elseif (entity.name == "BouncePlate"
		or entity.name == "BouncePlate5"
		or entity.name == "BouncePlate15"
		or entity.name == "SignalBouncePlate"
		or entity.name == "DirectorBouncePlate") then
			local xs = 1
			local ys = 1
			if (entity.name == "BouncePlate5") then
				xs = 0.5
				ys = 0.5
			elseif (entity.name == "BouncePlate15") then
				xs = 1.5
				ys = 1.5
			end
			PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = entity.surface,
					target = entity,
					x_scale = xs,
					y_scale = ys,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0},
					visible = ShowRange
				}
			-- link trackers with director plates on build or blueprint build
			if (entity.name == "DirectorBouncePlate") then
				entity.get_or_create_control_behavior().add_section()
				entity.get_or_create_control_behavior().add_section()
				entity.get_or_create_control_behavior().add_section()
				--[[ for i = 1, 10 do
					if (entity.get_or_create_control_behavior().get_section(1).get_slot(i).value == nil)then
						entity.get_or_create_control_behavior().get_section(1).set_slot(i, {value={type="virtual", name="DirectorBouncePlateUp"}})
					end
				end
				for i = 11, 20 do
					if (entity.get_or_create_control_behavior().get_section(1).get_slot(i).value == nil)then
						entity.get_or_create_control_behavior().get_section(1).set_slot(i, {value={type="virtual", name="DirectorBouncePlateRight"}, count=0})
					end
				end
				for i = 21, 30 do
					if (entity.get_or_create_control_behavior().get_section(1).get_slot(i).value == nil)then
						entity.get_or_create_control_behavior().get_section(1).set_slot(i, {value={type="virtual", name="DirectorBouncePlateDown"}, count=0})
					end
				end
				for i = 31, 40 do
					if (entity.get_or_create_control_behavior().get_section(1).get_slot(i).value == nil)then
						entity.get_or_create_control_behavior().get_section(1).set_slot(i, {value={type="virtual", name="DirectorBouncePlateLeft"}, count=0})
					end
				end ]]
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
		end
	------- make train ramp stuff unrotatable just in case
	elseif (entity.name == "RTTrainRamp" or entity.name == "RTTrainRampNoSkip" or entity.name == "RTMagnetTrainRamp" or entity.name == "RTMagnetTrainRampNoSkip") then
		entity.rotatable = false

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
	end
end

return entity_built

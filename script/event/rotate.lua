local function rotate(event)
	local entity = event.entity
	local EntityDestroyNumber = script.register_on_object_destroyed(entity)
	if (settings.startup["RTThrowersSetting"].value == true) then
		if ((entity.name == "DirectedBouncePlate")
		and storage.BouncePadList[EntityDestroyNumber] ~= nil) then
			local CantSeeMe = storage.BouncePadList[EntityDestroyNumber].arrow.visible
			local alt = storage.BouncePadList[EntityDestroyNumber].arrow.only_in_alt_mode
			local HomeOnThe = entity.get_or_create_control_behavior().get_section(1).get_slot(1).min
			storage.BouncePadList[EntityDestroyNumber].arrow.destroy()
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
			storage.BouncePadList[EntityDestroyNumber].arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = entity.surface,
					target = entity,
					--time_to_live = 240,
					only_in_alt_mode = alt,
					visible = CantSeeMe,
					x_scale = xflip*HomeOnThe/10,
					y_scale = yflip*HomeOnThe/10,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif ((entity.name == "RTThrower-EjectorHatchRT" or entity.name == "RTThrower-FilterEjectorHatchRT") and storage.CatapultList[EntityDestroyNumber] ~= nil and storage.CatapultList[EntityDestroyNumber].sprite) then
			storage.CatapultList[EntityDestroyNumber].sprite.animation_offset = storage.EjectorPointing[entity.direction]
		elseif (entity.name == "RTVacuumHatch") then
			local properties = storage.VacuumHatches[script.register_on_object_destroyed(entity)]
			properties.output = entity.surface.find_entities_filtered
			({
				collision_mask = "object",
				position = OffsetPosition(entity.position, {-1*storage.OrientationUnitComponents[entity.orientation].x, -1*storage.OrientationUnitComponents[entity.orientation].y}),
				limit = 1
			})[1]
			properties.ParticleAnimation.orientation = entity.orientation
			properties.ParticleAnimation.target = {entity=entity, offset={3*storage.OrientationUnitComponents[entity.orientation].x, 3*storage.OrientationUnitComponents[entity.orientation].y}}
			if (properties.arrow) then
				properties.arrow.orientation = (entity.orientation+0.5)%1
				properties.arrow.target = {entity=entity, offset={-0.75*storage.OrientationUnitComponents[entity.orientation].x, -0.75*storage.OrientationUnitComponents[entity.orientation].y}}
			end
		elseif (string.find(entity.name, '^RT') and string.find(entity.name, "BeltRamp") and storage.BeltRamps[EntityDestroyNumber].arrow) then
			local CantSeeMe = storage.BeltRamps[EntityDestroyNumber].arrow.visible
			local alt = storage.BeltRamps[EntityDestroyNumber].arrow.only_in_alt_mode
			local HomeOnThe = storage.BeltRamps[EntityDestroyNumber].range
			storage.BeltRamps[EntityDestroyNumber].arrow.destroy()
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
			storage.BeltRamps[EntityDestroyNumber].arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = entity.surface,
					target = entity,
					--time_to_live = 240,
					only_in_alt_mode = alt,
					visible = CantSeeMe,
					x_scale = xflip*HomeOnThe/10,
					y_scale = yflip*HomeOnThe/10,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		end

		if (storage.ThrowerPaths[EntityDestroyNumber] ~= nil) then -- if the rotated thing is part of a throw path
			ResetPathComponentOverflowTracking(entity)
		end
		if (storage.CatapultList[EntityDestroyNumber]) then
			ResetThrowerOverflowTracking(entity)
			AdjustThrowerArrow(entity)
		end

		
	end

	if (settings.startup["RTBounceSetting"].value == true) then
		-- I could probably just rotate the detector instead of replacing it but w/e lmao
		if (entity.name == "RTThrower-PrimerThrower") then
			local PrimerThrowerProperties = storage.CatapultList[script.register_on_object_destroyed(entity)]
			local sherlock = entity.surface.create_entity
			{
				name = "RTPrimerThrowerDetector",
				position = entity.position,
				direction = storage.PrimerThrowerPointing[entity.direction],
				force = entity.force,
				create_build_effect_smoke = false
			}
			sherlock.destructible = false
			storage.PrimerThrowerLinks[PrimerThrowerProperties.entangled.detector.unit_number] = nil
			PrimerThrowerProperties.entangled.detector.destroy()
			PrimerThrowerProperties.entangled.detector = sherlock
			local OnDestroyNumber = script.register_on_object_destroyed(sherlock)
			storage.PrimerThrowerLinks[OnDestroyNumber] = {thrower = entity, ready = false}--, box = box}
		end
	end

	if (settings.startup["RTItemCannonSetting"].value == true) then
		if (entity.name == "RTItemCannon") then
			storage.ItemCannons[script.register_on_object_destroyed(entity)].mask.direction = entity.direction
		end
	end
end

return rotate

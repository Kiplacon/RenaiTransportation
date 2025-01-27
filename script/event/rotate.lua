local function rotate(event)
	local EntityDestroyNumber = script.register_on_object_destroyed(event.entity)
	if ((event.entity.name == "DirectedBouncePlate" or event.entity.name == "DirectedBouncePlate5" or event.entity.name == "DirectedBouncePlate15")
	and storage.BouncePadList[EntityDestroyNumber] ~= nil) then
		local CantSeeMe = storage.BouncePadList[EntityDestroyNumber].arrow.visible
		storage.BouncePadList[EntityDestroyNumber].arrow.destroy()
		if (event.entity.orientation == 0) then
			direction = "UD"
			xflip = 1
			yflip = 1
		elseif (event.entity.orientation == 0.25) then
			direction = "RL"
			xflip = 1
			yflip = 1
		elseif (event.entity.orientation == 0.5) then
			direction = "UD"
			xflip = 1
			yflip = -1
		elseif (event.entity.orientation == 0.75) then
			direction = "RL"
			xflip = -1
			yflip = 1
		end
		if (event.entity.name == "DirectedBouncePlate5") then
			xflip = xflip*0.5
			yflip = yflip*0.5
		elseif (event.entity.name == "DirectedBouncePlate15") then
			xflip = xflip*1.5
			yflip = yflip*1.5
		end
		storage.BouncePadList[EntityDestroyNumber].arrow = rendering.draw_sprite
			{
				sprite = "RTDirectedRangeOverlay"..direction,
				surface = event.entity.surface,
				target = event.entity,
				--time_to_live = 240,
				only_in_alt_mode = true,
				visible = CantSeeMe,
				x_scale = xflip,
				y_scale = yflip,
				tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
			}

	elseif ((event.entity.name == "RTThrower-EjectorHatchRT" or event.entity.name == "RTThrower-FilterEjectorHatchRT") and storage.CatapultList[EntityDestroyNumber] ~= nil) then
		storage.CatapultList[EntityDestroyNumber].sprite.animation_offset = storage.EjectorPointing[event.entity.direction]
	end

	if (storage.ThrowerPaths[EntityDestroyNumber] ~= nil) then -- if the rotated thing is part of a throw path
		ResetPathComponentOverflowTracking(event.entity)
	end
	if (storage.CatapultList[EntityDestroyNumber]) then
		ResetThrowerOverflowTracking(event.entity)
	end

	-- I could probably just rotate the detector instead of replacing it but w/e lmao
	if (event.entity.name == "RTThrower-PrimerThrower") then
		local PrimerThrowerProperties = storage.CatapultList[script.register_on_object_destroyed(event.entity)]
		local sherlock = event.entity.surface.create_entity
		{
			name = "RTPrimerThrowerDetector",
			position = event.entity.position,
			direction = storage.PrimerThrowerPointing[event.entity.direction],
			force = event.entity.force,
			create_build_effect_smoke = false
		}
		sherlock.destructible = false
		storage.PrimerThrowerLinks[PrimerThrowerProperties.entangled.detector.unit_number] = nil
		PrimerThrowerProperties.entangled.detector.destroy()
		PrimerThrowerProperties.entangled.detector = sherlock
		local OnDestroyNumber = script.register_on_object_destroyed(sherlock)
		storage.PrimerThrowerLinks[OnDestroyNumber] = {thrower = event.entity, ready = false}--, box = box}
		
	end
end

return rotate

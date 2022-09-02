local function rotate(event)
	if ((event.entity.name == "DirectedBouncePlate" or event.entity.name == "DirectedBouncePlate5" or event.entity.name == "DirectedBouncePlate15")
	and global.BouncePadList[event.entity.unit_number] ~= nil) then
		CantSeeMe = rendering.get_visible(global.BouncePadList[event.entity.unit_number].arrow)
		rendering.destroy(global.BouncePadList[event.entity.unit_number].arrow)
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
		global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
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

	elseif (event.entity.name == "RTThrower-EjectorHatchRT" and global.CatapultList[event.entity.unit_number] ~= nil) then
		rendering.set_animation_offset(global.CatapultList[event.entity.unit_number].sprite, global.EjectorPointing[event.entity.direction])
	end

	if (global.ThrowerPaths[event.entity.unit_number] ~= nil) then -- if the rotated thing is part of a throw path
		for ThrowerUN, TrackedItems in pairs(global.ThrowerPaths[event.entity.unit_number]) do -- go through all the throwers/item pairs this thing was a part of
			if (global.CatapultList[ThrowerUN]) then -- valid check
				for item, sugma in pairs(TrackedItems) do
					global.CatapultList[ThrowerUN].targets[item] = nil -- reset the thrower/item pair
				end
			end
		end
		global.ThrowerPaths[event.entity.unit_number] = {} -- reset this thing being part of any thrower paths
	end

	if (global.CatapultList[event.entity.unit_number]) then
		global.CatapultList[event.entity.unit_number].targets = {}
		for componentUN, PathsItsPartOf in pairs(global.ThrowerPaths) do
			for ThrowerUN, TrackedItems in pairs(PathsItsPartOf) do
				if (ThrowerUN == event.entity.unit_number) then
					global.ThrowerPaths[componentUN][ThrowerUN] = {}
				end
			end
		end
	end

	if (event.entity.name == "RTThrower-PrimerThrower") then
		local sherlock = event.entity.surface.create_entity
		{
			name = "RTPrimerThrowerDetector",
			position = event.entity.position,
			direction = global.PrimerThrowerPointing[event.entity.direction],
			force = event.entity.force,
			create_build_effect_smoke = false
		}
		sherlock.destructible = false
		global.PrimerThrowerLinks[global.CatapultList[event.entity.unit_number].entangled.detector.unit_number] = nil
		global.CatapultList[event.entity.unit_number].entangled.detector.destroy()
		global.CatapultList[event.entity.unit_number].entangled.detector = sherlock
		global.PrimerThrowerLinks[sherlock.unit_number] = {thrower = event.entity, ready = false}--, box = box}
		script.register_on_entity_destroyed(sherlock)
	end
end

return rotate

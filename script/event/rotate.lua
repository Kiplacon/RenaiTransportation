local function rotate(event)
	if (event.entity.name == "DirectedBouncePlate" and global.BouncePadList[event.entity.unit_number] ~= nil) then
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

	if (global.ThrowerPaths[event.entity.unit_number] ~= nil) then
		for ThrowerUN, TrackedItems in pairs(global.ThrowerPaths[event.entity.unit_number]) do
			if (global.CatapultList[ThrowerUN]) then
				for item, sugma in pairs(TrackedItems) do
					global.CatapultList[ThrowerUN].targets[item] = nil
				end
			end
		end
		global.ThrowerPaths[event.entity.unit_number] = {}
	end
end

return rotate

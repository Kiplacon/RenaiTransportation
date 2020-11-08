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
	end
end

return rotate

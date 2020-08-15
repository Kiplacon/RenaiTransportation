if (global.BouncePadList == nil) then
	global.BouncePadList = {}		
end

for each, surfacez in pairs(game.surfaces) do
	for every, thing in pairs(surfacez.find_entities()) do
		if (string.find(thing.name, "BouncePlate") and not string.find(thing.name, "Train")) then
			global.BouncePadList[thing.unit_number] = {entity = thing}
			if (thing.name == "DirectedBouncePlate") then
				thing.operable = false
				if (thing.orientation == 0) then
					direction = "UD"
					xflip = 1
					yflip = 1
				elseif (thing.orientation == 0.25) then
					direction = "RL"
					xflip = 1
					yflip = 1
				elseif (thing.orientation == 0.5) then
					direction = "UD"
					xflip = 1
					yflip = -1
				elseif (thing.orientation == 0.75) then
					direction = "RL"
					xflip = -1
					yflip = 1
				end
				global.BouncePadList[thing.unit_number].arrow = rendering.draw_sprite
					{
						sprite = "RTDirectedRangeOverlay"..direction,
						surface = thing.surface,
						target = thing,
						only_in_alt_mode = true,
						x_scale = xflip,
						y_scale = yflip,
						tint = {r = 1, g = 1, b = 1, a = 1}
					}			
			elseif (thing.name == "BouncePlate") then
				rendering.draw_sprite
					{
						sprite = "RTRangeOverlay",
						surface = thing.surface,
						target = thing,
						only_in_alt_mode = true,
						tint = {r = 1, g = 0, b = 0, a = 1} --red
					}
			elseif (thing.name == "SignalBouncePlate") then
				rendering.draw_sprite
					{
						sprite = "RTRangeOverlay",
						surface = thing.surface,
						target = thing,
						only_in_alt_mode = true,
						tint = {r = 0, g = 1, b = 0, a = 1} --green
					}
			elseif (thing.name == "PrimerBouncePlate") then
				rendering.draw_sprite
					{
						sprite = "RTPrimerRangeOverlay",
						surface = thing.surface,
						target = thing,
						only_in_alt_mode = true,
						x_scale = 4,
						y_scale = 4,
						tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
					}
			elseif (thing.name == "PrimerSpreadBouncePlate") then
				rendering.draw_sprite
					{
						sprite = "RTPrimerSpreadRangeOverlay",
						surface = thing.surface,
						target = thing,
						only_in_alt_mode = true,
						x_scale = 4,
						y_scale = 4,
						tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
					}
			end
		end
	end	
end
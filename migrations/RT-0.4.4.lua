global.BouncePadList = {}	
for each, surfacez in pairs(game.surfaces) do
	for every, thing in pairs(surfacez.find_entities()) do
		if (string.find(thing.name, "BouncePlate") and not string.find(thing.name, "Train")) then
			nametag = thing.name
			spot = thing.position
			UseThe = thing.force
			layer = thing.surface
			tilt = thing.direction
			thing.destroy()
			NewPad = layer.create_entity
				({
				name = nametag,
				position = spot,
				direction = tilt,
				force = UseThe
				})
			global.BouncePadList[NewPad.unit_number] = {TheEntity = NewPad}
			if (NewPad.name == "DirectedBouncePlate") then
				NewPad.operable = false
				if (NewPad.orientation == 0) then
					direction = "UD"
					xflip = 1
					yflip = 1
				elseif (NewPad.orientation == 0.25) then
					direction = "RL"
					xflip = 1
					yflip = 1
				elseif (NewPad.orientation == 0.5) then
					direction = "UD"
					xflip = 1
					yflip = -1
				elseif (NewPad.orientation == 0.75) then
					direction = "RL"
					xflip = -1
					yflip = 1
				end
				global.BouncePadList[NewPad.unit_number].arrow = rendering.draw_sprite
					{
						sprite = "RTDirectedRangeOverlay"..direction,
						surface = NewPad.surface,
						target = NewPad,
						only_in_alt_mode = true,
						x_scale = xflip,
						y_scale = yflip,
						tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
					}			
			elseif (NewPad.name == "BouncePlate") then
				global.BouncePadList[NewPad.unit_number].arrow = rendering.draw_sprite
					{
						sprite = "RTRangeOverlay",
						surface = NewPad.surface,
						target = NewPad,
						only_in_alt_mode = true,
						tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
					}
			elseif (NewPad.name == "SignalBouncePlate") then
				global.BouncePadList[NewPad.unit_number].arrow = rendering.draw_sprite
					{
						sprite = "RTRangeOverlay",
						surface = NewPad.surface,
						target = NewPad,
						only_in_alt_mode = true,
						tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
					}
			elseif (NewPad.name == "PrimerBouncePlate") then
				global.BouncePadList[NewPad.unit_number].arrow = rendering.draw_sprite
					{
						sprite = "RTPrimerRangeOverlay",
						surface = NewPad.surface,
						target = NewPad,
						only_in_alt_mode = true,
						x_scale = 4,
						y_scale = 4,
						tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
					}
			elseif (NewPad.name == "PrimerSpreadBouncePlate") then
				global.BouncePadList[NewPad.unit_number].arrow = rendering.draw_sprite
					{
						sprite = "RTPrimerSpreadRangeOverlay",
						surface = NewPad.surface,
						target = NewPad,
						only_in_alt_mode = true,
						x_scale = 4,
						y_scale = 4,
						tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
					}
			end
		end
	end	
end
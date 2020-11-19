local function entity_built(event)
	local entity = event.created_entity or event.entity or event.destination

	if (string.find(entity.name, "RTThrower-")) then
		global.CatapultList[entity.unit_number] = {entity = entity, target = "nothing"}

	elseif (entity.name == "PlayerLauncher") then
		entity.operable = false
		entity.active = false

	elseif (entity.name == "RTMagnetTrainRamp" or entity.name == "RTMagnetTrainRampNoSkip") then
		global.MagnetRamps[entity.unit_number] = {entity = entity, tiles = {}}
		script.register_on_entity_destroyed(entity)
		local SUCC = entity.surface.create_entity
				({
				name = "RTMagnetRampDrain",
				position = {entity.position.x, entity.position.y-0.25}, --required setting for rendering, doesn't affect spawn
				direction = entity.direction,
				force = entity.force
				})
		SUCC.electric_buffer_size = 1000000
		SUCC.power_usage = 0
		SUCC.destructible = false
		global.MagnetRamps[entity.unit_number].power = SUCC

	elseif (string.find(entity.name, "BouncePlate") and not string.find(entity.name, "Train")) then
		global.BouncePadList[entity.unit_number] = {TheEntity = entity}
		if (entity.name == "DirectedBouncePlate") then
			entity.operable = false
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
			global.BouncePadList[entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = xflip,
					y_scale = yflip,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (entity.name == "BouncePlate") then
			global.BouncePadList[entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (entity.name == "SignalBouncePlate") then
			global.BouncePadList[entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (entity.name == "PrimerBouncePlate") then
			global.BouncePadList[entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		elseif (entity.name == "PrimerSpreadBouncePlate") then
			global.BouncePadList[entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerSpreadRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		end
	end
end

return entity_built

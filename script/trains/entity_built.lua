local function handleMagnetRampBuilt(entity)
	global.MagnetRamps[entity.unit_number] = {entity = entity, tiles = {}}
	script.register_on_entity_destroyed(entity)
	local SUCC = entity.surface.create_entity({
		name = "RTMagnetRampDrain",
		position = {entity.position.x, entity.position.y-0.25}, --required setting for rendering, doesn't affect spawn
		direction = entity.direction,
		force = entity.force
	})
	SUCC.electric_buffer_size = 1000000
	SUCC.power_usage = 0
	SUCC.destructible = false
	global.MagnetRamps[entity.unit_number].power = SUCC
end

local function handleTrainRampPlacerBuilt(entity, player)
	-- Swap the placer out for the real thing
	local ramp = entity.surface.create_entity({
		name = string.gsub(entity.name, '-placer', ''),
		position = entity.position,
		direction = entity.direction,
		force = entity.force,
		raise_built = true,
		create_build_effect_smoke = false,
		player = player
	})

	if not ramp then
		local dst = player or game
		dst.print('Unable to build ramp - please report this as a bug')
	else
		entity.destroy({raise_destroy = true})
	end
end

local function on_entity_built(entity, player)
	game.print(entity.name)
	if (string.find(entity.name, '^RT') and string.find(entity.name, 'TrainRamp') and string.find(entity.name, '-placer$')) then
		handleTrainRampPlacerBuilt(entity)
		game.print('Swapped')
		return true
	elseif (entity.name == "RTMagnetTrainRamp" or entity.name == "RTMagnetTrainRampNoSkip") then
		handleMagnetRampBuilt(entity)
		return true
	end

	return false
end

return on_entity_built

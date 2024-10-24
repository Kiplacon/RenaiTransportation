local math2d = require('math2d')
local util = require('util')
local constants = require('constants')
local magnetRampsStuff = require("__RenaiTransportation__/script/trains/magnet_ramps")

local function handleMagnetRampBuilt(entity)
	local OnDestroyNumber = script.register_on_object_destroyed(entity)
	storage.MagnetRamps[OnDestroyNumber] = {entity = entity, tiles = {}}
	entity.rotatable = false
	local SUCC = entity.surface.create_entity({
		name = "RTMagnetRampDrain",
		position = {entity.position.x, entity.position.y-0.25}, --required setting for rendering, doesn't affect spawn
		direction = entity.direction,
		force = entity.force
	})
	SUCC.electric_buffer_size = 1000000
	SUCC.power_usage = 0
	SUCC.destructible = false
	storage.MagnetRamps[OnDestroyNumber].power = SUCC
	magnetRampsStuff.setRange(
			storage.MagnetRamps[OnDestroyNumber],
			nil,
			player
		)
end

local function handleTrainRampPlacerBuilt(entity, player)
	-- Swap the placer out for the real thing

	local ramp = entity.surface.create_entity({
		name = string.gsub(entity.name, '-placer', ''),
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = entity.direction,
		force = entity.force,
		raise_built = true,
		--create_build_effect_smoke = false,
		player = player
	})

	if not ramp then
		local dst = player or game
		dst.print({"magnet-ramp-stuff.unable"})
	else
		entity.destroy({raise_destroy = true})
	end
end

local function on_entity_built(entity, player)
	if (string.find(entity.name, '^RT') and (string.find(entity.name, 'TrainRamp') or string.find(entity.name, 'ImpactUnloader')) and string.find(entity.name, '-placer$')) then
		handleTrainRampPlacerBuilt(entity)
		return true
	elseif (entity.name == "RTMagnetTrainRamp" or entity.name == "RTMagnetTrainRampNoSkip") then
		handleMagnetRampBuilt(entity)
		return true
	end

	return false
end

return on_entity_built

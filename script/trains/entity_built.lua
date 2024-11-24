local math2d = require('math2d')
local util = require('util')
local constants = require('constants')
local magnetRampsStuff = require("__RenaiTransportation__/script/trains/magnet_ramps")

local function handleMagnetRampBuilt(entity, player)
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
		if (entity.rail_layer == defines.rail_layer.elevated) then
			if (ramp.name == "RTTrainRamp") then
				local ElevatedRamp
				if ramp.direction == 4 then
					ElevatedRamp = ramp.surface.create_entity({
						name = "RTTrainRamp-ElevatedLeft",
						position = ramp.position,
						force = ramp.force,
						raise_built = true,
						player = player
					})
				elseif ramp.direction == 12 then
					ElevatedRamp = ramp.surface.create_entity({
						name = "RTTrainRamp-ElevatedRight",
						position = ramp.position,
						force = ramp.force,
						raise_built = true,
						player = player
					})
				elseif ramp.direction == 8 then
					ElevatedRamp = ramp.surface.create_entity({
						name = "RTTrainRamp-ElevatedUp",
						position = ramp.position,
						force = ramp.force,
						raise_built = true,
						player = player
					})
				elseif ramp.direction == 0 then
					ElevatedRamp = ramp.surface.create_entity({
						name = "RTTrainRamp-ElevatedDown",
						position = ramp.position,
						force = ramp.force,
						raise_built = true,
						player = player
					})
				end
				ramp.destroy()
				if (ElevatedRamp) then
					local RailDestryoNumber = script.register_on_object_destroyed(entity.get_connected_rails()[1])
					if (storage.DestructionLinks[RailDestryoNumber] == nil) then
						storage.DestructionLinks[RailDestryoNumber] = {}
					end
					table.insert(storage.DestructionLinks[RailDestryoNumber], ElevatedRamp)
				end
			end
		end
		entity.destroy({raise_destroy = true})
	end
end

local function on_entity_built(entity, player)
	if (string.find(entity.name, '^RT') and (string.find(entity.name, 'TrainRamp') or string.find(entity.name, 'ImpactUnloader')) and string.find(entity.name, '-placer$')) then
		handleTrainRampPlacerBuilt(entity)
		return true
	elseif (entity.name == "RTMagnetTrainRamp" or entity.name == "RTMagnetTrainRampNoSkip") then
		handleMagnetRampBuilt(entity, player)
		return true
	end

	return false
end

return on_entity_built

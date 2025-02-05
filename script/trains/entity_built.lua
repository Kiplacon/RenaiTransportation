local math2d = require('math2d')
local util = require('util')
local constants = require('constants')
local magnetRampsStuff = require("__RenaiTransportation__/script/trains/magnet_ramps")

local function RampSetup(entity, player)
	local surface = entity.surface
	local name = entity.name
	local direction = entity.direction
	local force = entity.force
	local RailLayer
	if (entity.type == "rail-signal") then
		RailLayer = entity.rail_layer
	else
		RailLayer = defines.rail_layer.ground
	end
	local BlockerName = "RTTrainRampCollisionBox"
	if (RailLayer == defines.rail_layer.elevated) then
		BlockerName = "RTElevatedTrainRampCollisionBox"
	end
	local blocker = surface.create_entity({
		name = BlockerName,
		position = entity.position,
		direction = direction,
		force = force,
		raise_built = false,
		player = player,
		rail_layer = RailLayer
	})
	if (RailLayer == defines.rail_layer.elevated) then
		local rail
		if (entity.get_connected_rails()[1]) then
			rail = entity.get_connected_rails()[1]
		else
			rail = surface.find_entities_filtered
			({
				position = entity.position,
				collision_mask = {"elevated_rail"},
				force = entity.force
			})[1]
		end
		local RailDestroyNumber = script.register_on_object_destroyed(rail)
		if (storage.DestructionLinks[RailDestroyNumber] == nil) then
			storage.DestructionLinks[RailDestroyNumber] = {}
		end
		table.insert(storage.DestructionLinks[RailDestroyNumber], entity)
		rendering.draw_sprite
		{
			sprite = name..direction,
			target = entity,
			surface = surface,
			render_layer = "elevated-object"
		}
	end
	local RampDestroyNumber = script.register_on_object_destroyed(entity)
	if (storage.DestructionLinks[RampDestroyNumber] == nil) then
		storage.DestructionLinks[RampDestroyNumber] = {}
	end
	table.insert(storage.DestructionLinks[RampDestroyNumber], blocker)
end

local function handleMagnetRampBuilt(entity, player)
	local OnDestroyNumber = script.register_on_object_destroyed(entity)
	storage.MagnetRamps[OnDestroyNumber] = {entity = entity, tiles = {}}
	entity.rotatable = false
	local SUCC = entity.surface.create_entity({
		name = "RTMagnetRampDrain",
		position = OffsetPosition({entity.position.x, entity.position.y}, {-0.8*constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction][1], -0.8*constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction][2]}),
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
	RampSetup(entity, player)
end

local function handleTrainRampPlacerBuilt(entity, player)
	-- Swap the placer out for the real thing
	local surface = entity.surface
	local name = string.gsub(entity.name, '-placer', '')
	local direction = entity.direction
	local force = entity.force
	local rail_layer = entity.rail_layer
	local ramp = surface.create_entity({
		name = name,
		position = math2d.position.add(entity.position, constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = direction,
		force = force,
		raise_built = true,
		player = player,
		rail_layer = rail_layer
	})

	if not ramp then
		local dst = player or game
		dst.print({"magnet-ramp-stuff.unable"})
	else
		RampSetup(ramp, player)
		entity.destroy({raise_destroy = true})
	end
end

local function on_entity_built(entity, player)
	if (string.find(entity.name, '^RT') and (string.find(entity.name, 'TrainRamp') or string.find(entity.name, 'ImpactUnloader'))) then
		if (string.find(entity.name, '-placer$')) then
			handleTrainRampPlacerBuilt(entity, player)
		elseif (entity.name == "RTMagnetTrainRamp" or entity.name == "RTMagnetTrainRampNoSkip") then
			handleMagnetRampBuilt(entity, player)
		end
		return true
	end

	return false
end

return on_entity_built

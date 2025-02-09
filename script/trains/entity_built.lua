local math2d = require('math2d')
local constants = require('constants')
local magnetRampsStuff = require("__RenaiTransportation__/script/trains/magnet_ramps")

function RampSetup(entity, player)
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
		force = "neutral", -- important so it works when friendly fire is off
		raise_built = false,
		player = player,
		rail_layer = RailLayer
	})
	if (RailLayer == defines.rail_layer.elevated) then
		local rail = surface.find_entities_filtered
			({
				position = entity.position,
				collision_mask = {"elevated_rail"},
				limit = 1,
				radius = 0.25
			})[1]
		if (rail) then
			local RailDestroyNumber = script.register_on_object_destroyed(rail)
			if (storage.DestructionLinks[RailDestroyNumber] == nil) then
				storage.DestructionLinks[RailDestroyNumber] = {}
			end
			table.insert(storage.DestructionLinks[RailDestroyNumber], entity)
		end
		rendering.draw_sprite
		{
			sprite = name..direction,
			target = entity,
			surface = surface,
			render_layer = "elevated-object"
		}
	else
		rendering.draw_sprite
		{
			sprite = name..direction,
			target = entity,
			surface = surface,
			render_layer = "object"
		}
	end
	local RampDestroyNumber = script.register_on_object_destroyed(entity)
	--[[ if (storage.DestructionLinks[RampDestroyNumber] == nil) then
		storage.DestructionLinks[RampDestroyNumber] = {}
	end
	table.insert(storage.DestructionLinks[RampDestroyNumber], blocker) ]]
	storage.TrainRamps[RampDestroyNumber] = {entity=entity, blocker=blocker}
	entity.rotatable = false
end

local function handleMagnetRampBuilt(entity, player)
	local OnDestroyNumber = script.register_on_object_destroyed(entity)
	storage.TrainRamps[OnDestroyNumber].tiles = {}
	local SUCC = entity.surface.create_entity({
		name = "RTMagnetRampDrain",
		position = OffsetPosition({entity.position.x, entity.position.y}, {-0.8*constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction][1], -0.8*constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction][2]}),
		direction = entity.direction,
		force = entity.force
	})
	SUCC.electric_buffer_size = 1000000
	SUCC.power_usage = 0
	SUCC.destructible = false
	storage.TrainRamps[OnDestroyNumber].power = SUCC
	magnetRampsStuff.setRange(
			storage.TrainRamps[OnDestroyNumber],
			nil,
			player
		)
	
end

function handleTrainRampPlacerBuilt(entity, player)
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
		raise_built = false,
		player = player,
		rail_layer = rail_layer
	})

	if not ramp then
		local dst = player or game
		dst.print({"magnet-ramp-stuff.unable"})
	else
		RampSetup(ramp, player)
		if (name == "RTMagnetTrainRamp" or name == "RTMagnetTrainRampNoSkip") then
			handleMagnetRampBuilt(ramp, player)
		end
		entity.destroy({raise_destroy = true})
	end
end

local function on_entity_built(entity, player)
	if (string.find(entity.name, '^RT') and (string.find(entity.name, 'TrainRamp') or string.find(entity.name, 'ImpactUnloader'))) then
		if (string.find(entity.name, '-placer$')) then
			handleTrainRampPlacerBuilt(entity, player)
		else -- non placers, ie ramps placed by blueprint
			RampSetup(entity, player)
			if (entity.name == "RTMagnetTrainRamp" or entity.name == "RTMagnetTrainRampNoSkip") then
				handleMagnetRampBuilt(entity, player)
			end
		end
		return true
	end

	return false
end

return on_entity_built

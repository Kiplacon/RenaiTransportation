local math2d = require('math2d')
local magnetRampsStuff = require("__RenaiTransportation__/script/trains/magnet_ramps")

local IgnoreRampSetup = {
	RTTrapdoorSwitch = true
}

function RampSetup(entity, RampType, MagRange) -- RampType = "TrainRamp" or "ImpactUnloader"
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
	if (RailLayer == defines.rail_layer.elevated) then
		local RenderLayer = "elevated-object"
		if (string.find(name, 'TrapdoorSwitch')) then
			RenderLayer = "elevated-lower-object"
		end
		---@diagnostic disable-next-line: newline-call
		local rail = entity.get_connected_rails()[1]
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
			target = {entity=entity, },
			surface = surface,
			render_layer = RenderLayer
		}
	else
		--[[ if (string.find(name, "Impact") ~= nil) then
			rendering.draw_sprite_clouds
			{
				sprite = name..direction,
				target = entity,
				surface = surface,
				render_layer = "object"
			}
		end ]]
	end
	
	local BlockerName = "RTTrainRampCollisionBox"
	if (RailLayer == defines.rail_layer.elevated) then
		BlockerName = "RTElevatedTrainRampCollisionBox"
	end
	if (string.find(name, 'TrapdoorSwitch')) then
		BlockerName = "RTRailSignalBlocker"
	end
	local blocker = surface.create_entity({
		name = BlockerName,
		position = math2d.position.add(entity.position, {1.5*TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction][1], 1.5*TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction][2]}),
		direction = direction,
		force = "neutral", -- important so it works when friendly fire is off
		raise_built = false,
		rail_layer = RailLayer
	})
	local CollisionDetectorNumber = script.register_on_object_destroyed(blocker)
	storage.TrainCollisionDetectors[CollisionDetectorNumber] = {entity=blocker, ramp=entity, RampType=RampType, ScheduleSkip=(string.find(name, "NoSkip")==nil)}
	
	local RampDestroyNumber = script.register_on_object_destroyed(entity)
	storage.TrainRamps[RampDestroyNumber] = {entity=entity, blocker=blocker, RampType=RampType, ScheduleSkip=(string.find(name, "NoSkip")==nil)}
	entity.rotatable = false
	local SixteenDirNudge = 1
	--[[ if (entity.direction%2 == 0) then
		SixteenDirNudge = 1.5
	end ]]
	entity.teleport(OffsetPosition(entity.position, {TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction][1]*SixteenDirNudge, TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction][2]*SixteenDirNudge}))
end

function handleMagnetRampBuilt(entity, player, MigrationRange)
	local OnDestroyNumber = script.register_on_object_destroyed(entity)
	storage.TrainRamps[OnDestroyNumber].tiles = {}
	local SUCC = entity.surface.create_entity({
		name = "RTMagnetRampDrain",
		position = OffsetPosition({entity.position.x, entity.position.y}, {-1.2*TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction][1], -1.2*TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction][2]}),
		direction = entity.direction,
		force = entity.force
	})
	SUCC.electric_buffer_size = 1000000
	SUCC.power_usage = 0
	SUCC.destructible = false
	storage.TrainRamps[OnDestroyNumber].power = SUCC
	magnetRampsStuff.setRange(
			storage.TrainRamps[OnDestroyNumber],
			MigrationRange,
			player
		)
	
end

local function handleTrainRampPlacerBuilt(entity, player)
	-- Swap the placer out for the real thing
	local name = string.gsub(entity.name, '-placer', '')
	local FourTwentyRaiseIt = false
	if (IgnoreRampSetup[name]) then
		FourTwentyRaiseIt = true
	end
	local position = entity.position
	local surface = entity.surface
	local direction = entity.direction
	local force = entity.force
	local rail_layer = entity.rail_layer
	entity.destroy({raise_destroy = true})
	local ramp = surface.create_entity({
		name = name,
		position = position, --math2d.position.add(position, TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[entity.direction]),
		direction = direction,
		force = force,
		raise_built = FourTwentyRaiseIt,
		player = player,
		rail_layer = rail_layer,
		create_build_effect_smoke = true
	})

	if not ramp then
		local dst = player or game
		dst.print({"magnet-ramp-stuff.unable"})
	elseif (FourTwentyRaiseIt == false) then -- prevents running RampSetup twice, here and in on_entity_built
		local RampType = "TrainRamp"
		if (string.find(name, 'ImpactUnloader')) then
			RampType = "ImpactUnloader"
		elseif (string.find(name, 'TrapdoorSwitch')) then
			RampType = "TrapdoorSwitch"
		end
		RampSetup(ramp, RampType)
		if (name == "RTMagnetTrainRamp" or name == "RTMagnetTrainRampNoSkip" or name == "RTMagnetSwitchTrainRamp" or name == "RTMagnetSwitchTrainRampNoSkip") then
			handleMagnetRampBuilt(ramp, player)
		end
	end
end

local function on_entity_built(entity, player)
	if (string.find(entity.name, '^RT') and (string.find(entity.name, 'TrainRamp') or string.find(entity.name, 'ImpactUnloader') or string.find(entity.name, 'TrapdoorSwitch'))) then
		if (string.find(entity.name, '-placer$')) then
			handleTrainRampPlacerBuilt(entity, player)
			return true
		else -- non placers, ie ramps placed by blueprint
			local RampType = "TrainRamp"
			if (string.find(entity.name, 'ImpactUnloader')) then
				RampType = "ImpactUnloader"
			elseif (string.find(entity.name, 'TrapdoorSwitch')) then
				RampType = "TrapdoorSwitch"
			end
			RampSetup(entity, RampType)
			if (entity.name == "RTMagnetTrainRamp" or entity.name == "RTMagnetTrainRampNoSkip" or entity.name == "RTMagnetSwitchTrainRamp" or entity.name == "RTMagnetSwitchTrainRampNoSkip") then
				handleMagnetRampBuilt(entity, player)
			end
		end
	end
	return false
end

return on_entity_built

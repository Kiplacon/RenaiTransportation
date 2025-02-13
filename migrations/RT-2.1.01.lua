if (storage.FlyingItems) then
	for each, FlyingItem in pairs(storage.FlyingItems) do
		if (FlyingItem.sprite) then -- from impact unloader/space throw
			if (type(FlyingItem.sprite) == "number" and rendering.get_object_by_id(FlyingItem.sprite) ~= nil) then
				rendering.get_object_by_id(FlyingItem.sprite).destroy()
			else
				FlyingItem.sprite.destroy()
			end
		end
		if (FlyingItem.shadow) then -- from impact unloader/space throw
			if (type(FlyingItem.shadow) == "number" and rendering.get_object_by_id(FlyingItem.shadow) ~= nil) then
				rendering.get_object_by_id(FlyingItem.shadow).destroy()
			else
				FlyingItem.shadow.destroy()
			end
		end
	end
	storage.FlyingItems = {}
end

if (storage.CatapultList) then
	if (storage.ThrowerProcessing == nil) then
		local ProcessingGroups = 3
		storage.ThrowerProcessing = {}
		for i = 1, ProcessingGroups do
			storage.ThrowerProcessing[i] = {}
		end
		local group = 1
		for ThrowerDestroyNumber, properties in pairs(storage.CatapultList) do
			storage.ThrowerProcessing[group][ThrowerDestroyNumber] = properties
			group = group + 1
			if (group > ProcessingGroups) then
				group = 1
			end
		end
	end
end

if (storage.MagnetRamps) then
	storage.MagnetRamps = nil
end
if (storage.TrainRamps == nil) then
	storage.TrainRamps = {}
end
if (storage.TrainCollisionDetectors == nil) then
	storage.TrainCollisionDetectors = {}
end

local math2d = require('math2d')
local constants = require('__RenaiTransportation__/script/trains/constants')

for _, RampName in pairs({"RTTrainRamp", "RTTrainRampNoSkip", "RTImpactUnloader"}) do
	local RampType = "TrainRamp"
	if (RampName == "RTImpactUnloader") then
		RampType = "ImpactUnloader"
	end
	for _, surface in pairs(game.surfaces) do
		local ramps = surface.find_entities_filtered
		{
			name = RampName
		}
		for _, ramp in pairs(ramps) do
			local NewRamp = surface.create_entity({
				name = ramp.name,
				position = math2d.position.add(ramp.position, {0.65*constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ramp.direction][1], 0.65*constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ramp.direction][2]}),
				direction = ramp.direction,
				force = ramp.force,
				raise_built = true,
				--player = ramp.player,
				rail_layer = ramp.rail_layer
			})
			RampSetup(NewRamp, RampType)
			ramp.destroy()
		end
	end
end
for _, irection in pairs({{"Up", defines.direction.south}, {"Down", defines.direction.north}, {"Left", defines.direction.east}, {"Right", defines.direction.west}}) do
	for _, varient in pairs({"", "NoSkip"}) do
		for _, surface in pairs(game.surfaces) do
			local ramps = surface.find_entities_filtered
			{
				name = "RTTrainRamp-Elevated"..irection[1]..varient
			}
			for _, ramp in pairs(ramps) do
				ramp.teleport(math2d.position.add(ramp.position, {0.65*constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[irection[2]][1], 0.65*constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[irection[2]][2]}))
				local NewRamp = surface.create_entity
				{
					name = "RTTrainRamp"..varient,
					position = ramp.position,
					direction = irection[2],
					rail_layer = defines.rail_layer.elevated,
					force = ramp.force,
				}
				RampSetup(NewRamp, "TrainRamp")
				ramp.destroy()
			end
		end
	end
end
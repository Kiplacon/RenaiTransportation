if aai_vehicle_exclusions then
    table.insert(aai_vehicle_exclusions, "RTPropCar")
end

if (data.raw.tree.lickmaw and data.raw.capsule.RTLickmawBalls) then
	table.insert(data.raw.tree.lickmaw.minable.results, {type="item", name="RTLickmawBalls", amount=1})
end

-- allows the train ramps and such to actaully load since all "rail signals" need to collide with each other
data:extend({
	{
		type = "collision-layer",
		name = "RTRampsAndPlacers"
	},
})
for each, signal in pairs(data.raw["rail-signal"]) do
    if (signal.collision_mask == nil) then
        signal.collision_mask = {layers={floor=true, item=true, rail=true, water_tile=true, is_lower_object=true}} -- the defaults which for some reason aren't readable if it defaults to the defaults
    end
    if (signal.elevated_collision_mask == nil) then
        signal.elevated_collision_mask = {layers={elevated_rail=true}} -- the defaults which for some reason aren't readable if it defaults to the defaults
    end
    signal.collision_mask.layers["RTRampsAndPlacers"] = true
    signal.elevated_collision_mask.layers["RTRampsAndPlacers"] = true
end
for each, signal in pairs(data.raw["rail-chain-signal"]) do
    if (signal.collision_mask == nil) then
        signal.collision_mask = {layers={floor=true, item=true, rail=true, water_tile=true, is_lower_object=true}} -- the defaults which for some reason aren't readable if it defaults to the defaults
    end
    if (signal.elevated_collision_mask == nil) then
        signal.elevated_collision_mask = {layers={elevated_rail=true}} -- the defaults which for some reason aren't readable if it defaults to the defaults
    end
    signal.collision_mask.layers["RTRampsAndPlacers"] = true
    signal.elevated_collision_mask.layers["RTRampsAndPlacers"] = true
end

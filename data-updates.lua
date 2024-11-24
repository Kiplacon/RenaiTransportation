if aai_vehicle_exclusions then
    table.insert(aai_vehicle_exclusions, "RTPropCar")
end
if (data.raw.tree.lickmaw) then
    table.insert(data.raw.tree.lickmaw.minable.results, {type="item", name="RTLickmawBalls", amount=1})
    data:extend({
		{
			type = "item",
			name = "RTLickmawBalls",
			icon = "__RenaiTransportation__/graphics/LickmawBALLS.png",
			icon_size = 64,
			subgroup = "agriculture-processes",
			weight = 1000,
			order = "sawcon",
			stack_size = 69
		}
	})
end
function sound_variations(filename_string, variations, volume_parameter, modifiers_parameter)
	local result = {}
	for i = 1,variations do
	  result[i] = { filename = filename_string .. "-" .. i .. ".ogg", volume = volume_parameter or 0.5 }
	  if modifiers_parameter then
		result[i].modifiers = modifiers_parameter
	  end
	end
	return result
  end

if aai_vehicle_exclusions then
    table.insert(aai_vehicle_exclusions, "RTPropCar")
end
if (data.raw.tree.lickmaw) then
	table.insert(data.raw.tree.lickmaw.minable.results, {type="item", name="RTLickmawBalls", amount=1})
end
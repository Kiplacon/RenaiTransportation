if (settings.startup["RTThrowersSetting"].value == true and storage.CatapultList) then
	for ThrowerDestroyNumber, properties in pairs(storage.CatapultList) do
		if (properties.entity and properties.entity.valid) then
			local ThrowerName = properties.entity.name
			if properties.NormalRange == nil then
				properties.NormalRange = math.sqrt(RealMaxRange(ThrowerName).x^2 + RealMaxRange(ThrowerName).y^2)
			end
		end
	end
end
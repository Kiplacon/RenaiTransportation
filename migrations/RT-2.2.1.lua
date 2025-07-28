if (settings.startup["RTThrowersSetting"].value == true and storage.CatapultList) then
	for ThrowerDestroyNumber, properties in pairs(storage.CatapultList) do
		local ThrowerName = properties.entity.name
		if properties.NormalRange == nil then
			properties.NormalRange = math.sqrt(prototypes.entity[ThrowerName].inserter_drop_position[1]^2 + prototypes.entity[ThrowerName].inserter_drop_position[2]^2)
		end
	end
end
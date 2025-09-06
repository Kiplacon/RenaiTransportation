if (settings.startup["RTThrowersSetting"].value == true and storage.CatapultList) then
	for ThrowerDestroyNumber, properties in pairs(storage.CatapultList) do
		if (properties.entity and properties.entity.valid and properties.entity.name == "RTThrower-EjectorHatchRT") then
			SetThrowerRange(properties.entity, 20, true)
		end
	end
end
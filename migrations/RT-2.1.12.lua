if (settings.startup["RTThrowersSetting"].value == true and storage.CatapultList) then
	for ThrowerDestroyNumber, properties in pairs(storage.CatapultList) do
		local ThingHovering = properties.entity
		if properties.range == nil then
			properties.range = math.floor(math.abs(ThingHovering.drop_position.x-ThingHovering.position.x + ThingHovering.drop_position.y-ThingHovering.position.y))
		end
	end
end
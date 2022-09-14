for each, surfacez in pairs(game.surfaces) do
	for every, thing in pairs(surfacez.find_entities()) do
		if (thing.name == "RTZiplineTerminal") then
			script.register_on_entity_destroyed(thing)
		end
	end
end

for each, surfacez in pairs(game.surfaces) do
	for every, thing in pairs(surfacez.find_entities()) do
		if (thing.name == "RTTrainRamp" or thing.name == "RTTrainRampNoSkip" or thing.name == "RTMagnetTrainRamp" or thing.name == "RTMagnetTrainRampNoSkip") then
			thing.rotatable = false
		end
	end
end
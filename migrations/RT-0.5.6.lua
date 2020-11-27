if global.FlyingTrains then
	for number, properties in pairs(global.FlyingTrains) do
		if (properties.leader ~= nil) then
			global.FlyingTrains[properties.leader].followerID = number
		end
	end
end

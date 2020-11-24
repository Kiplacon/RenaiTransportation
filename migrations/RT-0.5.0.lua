if global.CatapultList then
	for ID, thrower in pairs(global.CatapultList) do
		global.CatapultList[ID] = {entity = thrower, target = "nothing"}
	end
end

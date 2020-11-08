local function config_changed()
	if (global.CatapultList == nil) then
		global.CatapultList = {}
	end

	global.OrientationUnitComponents = {}
	global.OrientationUnitComponents[0] = {x = 0, y = -1, name = "up"}
	global.OrientationUnitComponents[0.25] = {x = 1, y = 0, name = "right"}
	global.OrientationUnitComponents[0.5] = {x = 0, y = 1, name = "down"}
	global.OrientationUnitComponents[0.75] = {x = -1, y = 0, name = "left"}
	global.OrientationUnitComponents[1] = {x = 0, y = -1, name = "up"}

	if (global.AllPlayers == nil) then
		global.AllPlayers = {}
	end

	for PlayerID, PlayerLuaData in pairs(game.players) do
		if (global.AllPlayers[PlayerID] == nil) then
			global.AllPlayers[PlayerID] = {}
		end
	end

	if (global.FlyingTrains == nil) then
		global.FlyingTrains = {}
	end

	if (global.MagnetRamps == nil) then
		global.MagnetRamps = {}
	end

	if (global.BouncePadList == nil) then
		global.BouncePadList = {}
	end
end

return config_changed

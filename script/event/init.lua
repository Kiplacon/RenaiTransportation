local function on_int()
	if (global.CatapultList == nil) then
		global.CatapultList = {}
	end

	if (global.AllPlayers == nil) then
		global.AllPlayers = {}
	end

	if (global.OrientationUnitComponents == nil) then
		global.OrientationUnitComponents = {}
		global.OrientationUnitComponents[0] = {x = 0, y = -1, name = "up"}
		global.OrientationUnitComponents[0.25] = {x = 1, y = 0, name = "right"}
		global.OrientationUnitComponents[0.5] = {x = 0, y = 1, name = "down"}
		global.OrientationUnitComponents[0.75] = {x = -1, y = 0, name = "left"}
		global.OrientationUnitComponents[1] = {x = 0, y = -1, name = "up"}
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
	
	if (global.FastestFuel == nil) then
		global.FastestFuel = "nuclear-fuel"
	end
	for ItemName, info in pairs(game.item_prototypes) do 
		if (info.fuel_top_speed_multiplier 
		and info.fuel_top_speed_multiplier > game.item_prototypes[global.FastestFuel].fuel_top_speed_multiplier) then
			global.FastestFuel = ItemName
		end
	end
	
	if (global.About2Jump == nil) then
		global.About2Jump = {}
	end	
end

return on_int

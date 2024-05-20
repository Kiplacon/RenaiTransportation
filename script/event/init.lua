local function on_int()
	if (global.CatapultList == nil) then
		global.CatapultList = {}
	end

	if (global.savedVehicleWagons == nil) then -- used for Vehicle Wagons 2 compatability
		global.savedVehicleWagons = {}
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

	if (global.Dir2Ori == nil) then
		global.Dir2Ori = {}
		global.Dir2Ori[4] = 0.5
		global.Dir2Ori[6] = 0.75
		global.Dir2Ori[0] = 0
		global.Dir2Ori[2] = 0.25
		global.Dir2Ori[4] = 0.5
	end

	if (global.EjectorPointing == nil) then
		global.EjectorPointing = {}
		global.EjectorPointing[0] = 2
		global.EjectorPointing[2] = 3
		global.EjectorPointing[4] = 0
		global.EjectorPointing[6] = 1
	end

	if (global.PrimerThrowerPointing == nil) then
		global.PrimerThrowerPointing = {}
		global.PrimerThrowerPointing[0] = 4
		global.PrimerThrowerPointing[2] = 6
		global.PrimerThrowerPointing[4] = 0
		global.PrimerThrowerPointing[6] = 2
	end

	if (global.PrimerThrowerLinks == nil) then
		global.PrimerThrowerLinks = {}
	end

	for PlayerID, PlayerLuaData in pairs(game.players) do
		if (global.AllPlayers[PlayerID] == nil) then
			global.AllPlayers[PlayerID] = {state="default", PlayerLauncher={}, zipline={}, RangeAdjusting=false, SettingRampRange={SettingRange=false}, GUI={}, preferences={}}
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
	-- trains
	if (global.About2Jump == nil) then
		global.About2Jump = {}
	end
	-- thrown item tracking for overflow prevention
	if (global.OnTheWay == nil) then
		global.OnTheWay = {}
	end
	-- thrown item properties and animation
	global.FlightNumber = 1
	global.FlyingItems = {}

--[[ 	if (game.surfaces["RTStasisRealm"] == nil) then
		game.create_surface("RTStasisRealm",
		{
			peaceful_mode = true,
			water = "none",
			starting_area = "none",
			autoplace_controls = {},
			default_enable_all_autoplace_controls = false,
			cliff_settings = {name = "cliff", cliff_elevation_0 = 0, richness = 0}
		})
	end ]]

	global.DataTrackerLinks = {}

	global.ThrowerPaths = {}

	global.clock = {}

	global.ZiplineTerminals = {}

	global.HoverGFX = {}

	-- Ultracube=specific globals
	if game.active_mods["Ultracube"] then
		local ultracube_globals = require("script.ultracube.globals")
		ultracube_globals.setup_prototypes()
	end
end

return on_int

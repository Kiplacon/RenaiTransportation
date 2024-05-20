local ultracube_globals = require("script.ultracube.cube_global_handling")

local function config_changed()
	if (global.CatapultList == nil) then
		global.CatapultList = {}
	else
		for catapultID, properties in pairs(global.CatapultList) do
			if (properties.entity.valid) then
				if (properties.entity.electric_buffer_size == nil) then
					properties.IsElectric = false
				else
					properties.IsElectric = true
				end
			else
				global.CatapultList[catapultID] = nil
			end
		end
	end

	if (global.savedVehicleWagons == nil) then -- used for Vehicle Wagons 2 compatability
		global.savedVehicleWagons = {}
	end

	global.OrientationUnitComponents = {}
	global.OrientationUnitComponents[0] = {x = 0, y = -1, name = "up"}
	global.OrientationUnitComponents[0.25] = {x = 1, y = 0, name = "right"}
	global.OrientationUnitComponents[0.5] = {x = 0, y = 1, name = "down"}
	global.OrientationUnitComponents[0.75] = {x = -1, y = 0, name = "left"}
	global.OrientationUnitComponents[1] = {x = 0, y = -1, name = "up"}

	global.Dir2Ori = {}
	global.Dir2Ori[4] = 0.5
	global.Dir2Ori[6] = 0.75
	global.Dir2Ori[0] = 0
	global.Dir2Ori[2] = 0.25
	global.Dir2Ori[4] = 0.5

	global.EjectorPointing = {}
	global.EjectorPointing[0] = 2
	global.EjectorPointing[2] = 3
	global.EjectorPointing[4] = 0
	global.EjectorPointing[6] = 1

	global.PrimerThrowerPointing = {}
	global.PrimerThrowerPointing[0] = 4
	global.PrimerThrowerPointing[2] = 6
	global.PrimerThrowerPointing[4] = 0
	global.PrimerThrowerPointing[6] = 2

	if (global.PrimerThrowerLinks == nil) then
		global.PrimerThrowerLinks = {}
	end

	if (global.AllPlayers == nil) then
		global.AllPlayers = {}
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

	if (game.item_prototypes[global.FastestFuel] == nil or global.FastestFuel == nil) then
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
	-- thrown item tracking for overflow prevention
	if (global.OnTheWay == nil) then
		global.OnTheWay = {}
	end
	-- thrown item properties and animation
	if (global.FlightNumber == nil) then
		global.FlightNumber = 1
	end
	if (global.FlyingItems == nil) then
		global.FlyingItems = {}
	end

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

	if (global.DataTrackerLinks == nil) then
		global.DataTrackerLinks = {}
	end

	if (global.ThrowerPaths == nil) then
		global.ThrowerPaths = {}
	end

	if (global.clock == nil) then
		global.clock = {}
	end

	if (global.ZiplineTerminals == nil) then
		global.ZiplineTerminals = {}
	end

	if (global.HoverGFX == nil) then
		global.HoverGFX = {}
	end
	
	-- Ultracube-specific globals
	if game.active_mods["Ultracube"] then
		-- Prototype data should be reset on config change just in case Ultracube has updated to add new types
		ultracube_globals.setup_prototypes()
	elseif global.Ultracube then -- Ultracube used to be active before config change
		global.Ultracube = nil
	end
end

return config_changed

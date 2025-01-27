local ultracube_globals = require("script.ultracube.cube_global_handling")

local function on_int()
	storage.CatapultList = {}

	-- used for Vehicle Wagons 2 compatability
	storage.savedVehicleWagons = {}

	storage.AllPlayers = {}

	storage.OrientationUnitComponents = {}
	storage.OrientationUnitComponents[0] = {x = 0, y = -1, name = "up"}
	storage.OrientationUnitComponents[0.25] = {x = 1, y = 0, name = "right"}
	storage.OrientationUnitComponents[0.5] = {x = 0, y = 1, name = "down"}
	storage.OrientationUnitComponents[0.75] = {x = -1, y = 0, name = "left"}
	storage.OrientationUnitComponents[1] = {x = 0, y = -1, name = "up"}

	storage.OrientationNumberToDefinition = {}
	local slice = 0.0625 -- 1/16 from 0 to 1
	storage.OrientationNumberToDefinition[slice*0] = defines.direction.north
	storage.OrientationNumberToDefinition[slice*1] = defines.direction.northnortheast
	storage.OrientationNumberToDefinition[slice*2] = defines.direction.northeast
	storage.OrientationNumberToDefinition[slice*3] = defines.direction.eastnortheast
	storage.OrientationNumberToDefinition[slice*4] = defines.direction.east
	storage.OrientationNumberToDefinition[slice*5] = defines.direction.eastsoutheast
	storage.OrientationNumberToDefinition[slice*6] = defines.direction.southeast
	storage.OrientationNumberToDefinition[slice*7] = defines.direction.southsoutheast
	storage.OrientationNumberToDefinition[slice*8] = defines.direction.south
	storage.OrientationNumberToDefinition[slice*9] = defines.direction.southsouthwest
	storage.OrientationNumberToDefinition[slice*10] = defines.direction.southwest
	storage.OrientationNumberToDefinition[slice*11] = defines.direction.westsouthwest
	storage.OrientationNumberToDefinition[slice*12] = defines.direction.west
	storage.OrientationNumberToDefinition[slice*13] = defines.direction.westnorthwest
	storage.OrientationNumberToDefinition[slice*14] = defines.direction.northwest
	storage.OrientationNumberToDefinition[slice*15] = defines.direction.northnorthwest

	storage.Dir2Ori = {}
	storage.Dir2Ori[0] = 0
	storage.Dir2Ori[2] = 0.125
	storage.Dir2Ori[4] = 0.25
	storage.Dir2Ori[6] = 0.375
	storage.Dir2Ori[8] = 0.5
	storage.Dir2Ori[10] = 0.625
	storage.Dir2Ori[12] = 0.75
	storage.Dir2Ori[14] = 0.875
	storage.Dir2Ori[16] = 0

	storage.EjectorPointing = {}
	storage.EjectorPointing[0] = 2
	storage.EjectorPointing[4] = 3
	storage.EjectorPointing[8] = 0
	storage.EjectorPointing[12] = 1

	storage.PrimerThrowerPointing = {}
	storage.PrimerThrowerPointing[0] = 8
	storage.PrimerThrowerPointing[4] = 12
	storage.PrimerThrowerPointing[8] = 0
	storage.PrimerThrowerPointing[12] = 4

	storage.PrimerThrowerLinks = {}

	for PlayerID, PlayerLuaData in pairs(game.players) do
		if (storage.AllPlayers[PlayerID] == nil) then
			storage.AllPlayers[PlayerID] = {state="default", PlayerLauncher={}, zipline={}, RangeAdjusting=false, SettingRampRange={SettingRange=false}, GUI={}, preferences={}}
		end
	end

	storage.FlyingTrains = {}

	storage.MagnetRamps = {}

	storage.BouncePadList = {}

	storage.FastestFuel = "nuclear-fuel"
	for ItemName, info in pairs(prototypes.item) do
		if (info.fuel_top_speed_multiplier
		and info.fuel_top_speed_multiplier > prototypes.item[storage.FastestFuel].fuel_top_speed_multiplier) then
			storage.FastestFuel = ItemName
		end
	end
	-- trains
	storage.About2Jump = {}
	-- thrown item tracking for overflow prevention
	storage.OnTheWay = {}
	-- thrown item properties and animation
	storage.FlightNumber = 1
	storage.FlyingItems = {}
	storage.CustomPathFlyingItemSprites = {}

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

	storage.ThrowerPaths = {}

	storage.clock = {}

	storage.ZiplineTerminals = {}

	storage.HoverGFX = {}

	storage.DestructionLinks = {}

	storage.TrapdoorWagonsOpen = {}
	storage.TrapdoorWagonsClosed = {}

	-- Ultracube=specific globals
	if script.active_mods["Ultracube"] then
		ultracube_globals.setup_prototypes()
	end
end

return on_int

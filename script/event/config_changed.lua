local ultracube_globals = require("script.ultracube.cube_global_handling")

local function config_changed()
	if (storage.CatapultList == nil) then
		storage.CatapultList = {}
	else
		for catapultID, properties in pairs(storage.CatapultList) do
			if (properties.entity.valid) then
				if (properties.entity.electric_buffer_size == nil) then
					properties.IsElectric = false
				else
					properties.IsElectric = true
				end
			else
				storage.CatapultList[catapultID] = nil
			end
		end
	end

	if (storage.CatapultGroup == nil) then
		storage.CatapultGroup = 1
	end
	if (storage.ThrowerGroups == nil) then
		storage.ThrowerGroups = 3
	end
	if (storage.ThrowerProcessing == nil) then
		storage.ThrowerProcessing = {{}, {}, {}}
	end

	if (storage.savedVehicleWagons == nil) then -- used for Vehicle Wagons 2 compatability
		storage.savedVehicleWagons = {}
	end

	storage.OrientationUnitComponents = {}
	storage.OrientationUnitComponents[0] = {x = 0, y = -1, name = "up"}
	storage.OrientationUnitComponents[0.25] = {x = 1, y = 0, name = "right"}
	storage.OrientationUnitComponents[0.5] = {x = 0, y = 1, name = "down"}
	storage.OrientationUnitComponents[0.75] = {x = -1, y = 0, name = "left"}
	storage.OrientationUnitComponents[1] = {x = 0, y = -1, name = "up"}

	storage.OrientationNumberToDefinition = {}
	local slice = 0.0625
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

	storage.InsertInventory =
	{
		["agricultural-tower"] = {defines.inventory.agricultural_tower_input, defines.inventory.fuel},
		["ammo-turret"] = {defines.inventory.turret_ammo, defines.inventory.fuel},
		["artillery-turret"] = {defines.inventory.artillery_turret_ammo, defines.inventory.fuel},
		["artillery-wagon"] = {defines.inventory.artillery_wagon_ammo, defines.inventory.fuel},
		["assembling-machine"] = {defines.inventory.crafter_input, defines.inventory.fuel},
		["beacon"] = {defines.inventory.beacon_modules},
		["boiler"] = {defines.inventory.fuel},
		["burner-generator"] = {defines.inventory.fuel},
		["cargo-landing-pad"] = {defines.inventory.cargo_landing_pad_main},
		["cargo-wagon"] = {defines.inventory.cargo_wagon},
		["container"] = {defines.inventory.chest},
		["furnace"] = {defines.inventory.crafter_input, defines.inventory.fuel},
		["fusion-reactor"] = {defines.inventory.fuel},
		["infinity-container"] = {defines.inventory.chest},
		["lab"] = {defines.inventory.lab_input},
		["linked-container"] = {defines.inventory.chest},
		["locomotive"] = {defines.inventory.fuel},
		["logistic-container"] = {defines.inventory.chest},
		["proxy-container"] = {defines.inventory.proxy_main},
		["reactor"] = {defines.inventory.fuel},
		["roboport"] = {defines.inventory.roboport_robot},
		["rocket-silo"] = {defines.inventory.crafter_input},
	}

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

	if (storage.PrimerThrowerLinks == nil) then
		storage.PrimerThrowerLinks = {}
	end

	if (storage.AllPlayers == nil) then
		storage.AllPlayers = {}
	end

	for PlayerID, PlayerLuaData in pairs(game.players) do
		if (storage.AllPlayers[PlayerID] == nil) then
			storage.AllPlayers[PlayerID] = {state="default", PlayerLauncher={}, zipline={}, RangeAdjusting=false, SettingRampRange={SettingRange=false}, GUI={}, preferences={}}
		end
	end

	if (storage.FlyingTrains == nil) then
		storage.FlyingTrains = {}
	end

	if (storage.TrainRamps == nil) then
		storage.TrainRamps = {}
	end
	if (storage.TrainCollisionDetectors == nil) then
		storage.TrainCollisionDetectors = {}
	end

	if (storage.BouncePadList == nil) then
		storage.BouncePadList = {}
	end

	if (prototypes.item[storage.FastestFuel] == nil or storage.FastestFuel == nil) then
		storage.FastestFuel = "nuclear-fuel"
	end

	for ItemName, info in pairs(prototypes.item) do
		if (info.fuel_top_speed_multiplier
		and info.fuel_top_speed_multiplier > prototypes.item[storage.FastestFuel].fuel_top_speed_multiplier) then
			storage.FastestFuel = ItemName
		end
	end

	if (storage.About2Jump == nil) then
		storage.About2Jump = {}
	end
	-- thrown item tracking for overflow prevention
	if (storage.OnTheWay == nil) then
		storage.OnTheWay = {}
	end
	-- thrown item properties and animation
	if (storage.FlightNumber == nil) then
		storage.FlightNumber = 1
	end
	if (storage.FlyingItems == nil) then
		storage.FlyingItems = {}
	end
	if (storage.CustomPathFlyingItemSprites == nil) then
		storage.CustomPathFlyingItemSprites = {}
	end

	if (storage.ThrowerPaths == nil) then
		storage.ThrowerPaths = {}
	end

	if (storage.clock == nil) then
		storage.clock = {}
	end

	if (storage.ZiplineTerminals == nil) then
		storage.ZiplineTerminals = {}
	end

	if (storage.HoverGFX == nil) then
		storage.HoverGFX = {}
	end

	if (storage.DestructionLinks == nil) then
		storage.DestructionLinks = {}
	end

	if (storage.TrapdoorWagonsOpen == nil) then
		storage.TrapdoorWagonsOpen = {}
	end
	if (storage.TrapdoorWagonsClosed == nil) then
		storage.TrapdoorWagonsClosed = {}
	end
	if (storage.TrapdoorWagons) then
		storage.TrapdoorWagons = nil
	end

	if (storage.BeltRamps == nil) then
		storage.BeltRamps = {}
	end

	if (storage.VacuumHatches == nil) then
		storage.VacuumHatches = {}
	end
	
	if (storage.ItemCannons == nil) then
		storage.ItemCannons = {}
	end
	storage.ItemCannonSpeed = 3
	storage.ItemCannonRange = 200
	storage.ChuteOrientationComponents = {}
	storage.ChuteOrientationComponents[0] = {x = 1, y = -1, direction=defines.direction.northeast}
	storage.ChuteOrientationComponents[0.25] = {x = 1, y = 1, direction=defines.direction.southeast}
	storage.ChuteOrientationComponents[0.5] = {x = -1, y = 1, direction=defines.direction.southwest}
	storage.ChuteOrientationComponents[0.75] = {x = -1, y = -1, direction=defines.direction.northwest}
	storage.ChuteOrientationComponents[1] = {x = 1, y = -1, direction=defines.direction.northeast}
	
	-- Ultracube-specific globals
	if script.active_mods["Ultracube"] then
		-- Prototype data should be reset on config change just in case Ultracube has updated to add new types
		ultracube_globals.setup_prototypes()
	elseif storage.Ultracube then -- Ultracube used to be active before config change
		storage.Ultracube = nil
	end
end

return config_changed

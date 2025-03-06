if script.active_mods["Ultracube"] then CubeFlyingItems = require("script.ultracube.cube_flying_items") end
if script.active_mods["Ultracube"] then CubeFlyingTrains = require("script.ultracube.cube_flying_trains") end

local TrainRamps = {
	RTTrainRamp = "lickmaw",
	RTTrainRampNoSkip = 69,
	RTMagnetTrainRamp = 420,
	RTMagnetTrainRampNoSkip = 1337,
	["RTTrainRamp-ElevatedUp"] = 4,
	["RTTrainRamp-ElevatedDown"] = 20,
	["RTTrainRamp-ElevatedLeft"] = 60,
	["RTTrainRamp-ElevatedRight"] = 9,
}

local NonMagneticRamps = {
	RTTrainRamp = "lickmaw",
	RTTrainRampNoSkip = 69,
	["RTTrainRamp-ElevatedUp"] = 4,
	["RTTrainRamp-ElevatedDown"] = 20,
	["RTTrainRamp-ElevatedLeft"] = 60,
	["RTTrainRamp-ElevatedRight"] = 9,
}

local MagneticRamps = {
	RTMagnetTrainRamp = 420,
	RTMagnetTrainRampNoSkip = 1337,
}

local SkippingRamps = {
	RTTrainRamp = "lickmaw",
	RTMagnetTrainRamp = 420,
	["RTTrainRamp-ElevatedUp"] = 4,
	["RTTrainRamp-ElevatedDown"] = 20,
	["RTTrainRamp-ElevatedLeft"] = 60,
	["RTTrainRamp-ElevatedRight"] = 9,
}

local NonSkippingRamps = {
	RTTrainRampNoSkip = 69,
	RTMagnetTrainRampNoSkip = 1337,
}

local GroundToElevatedMagArcShift_constant = 0.7 -- 1 is normal jump, closer to 0 pushes out the trajectory arc so the train at the landing tick is higher
local ElevatedRangeShift_constant = 0.85 -- 0 is normal jump, closer to 1 shortens the jump so that there's time/space for the train to fall to ground level

local function entity_damaged(event)
	if ( -- train ramps
		event.cause
		and (event.cause.type == "locomotive"
			or event.cause.type == "cargo-wagon"
			or event.cause.type == "fluid-wagon"
			or event.cause.type == "artillery-wagon")
		and (event.entity.name == "RTTrainRampCollisionBox"
			or event.entity.name == "RTElevatedTrainRampCollisionBox")
		and storage.TrainCollisionDetectors[script.register_on_object_destroyed(event.entity)].RampType ~= "ImpactUnloader"
		and (math.abs(event.entity.orientation-event.cause.orientation) == 0.5
			or math.abs(event.entity.orientation-event.cause.orientation) == 0)
		and (
				(event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0) --down
				or (event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0) --left
				or (event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0) --up
				or (event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0) --right
			)
	) then
		local carriage = event.cause
		local elevated = (event.entity.name == "RTElevatedTrainRampCollisionBox")
		local ramp = storage.TrainCollisionDetectors[script.register_on_object_destroyed(event.entity)].ramp
		local HeightOffset = 0
		if (elevated) then
			HeightOffset = -3
		end
		--game.print(elevated)
		local SpookyGhost = ramp.surface.create_entity
			({
				name = "RTPropCar",
				position = carriage.position,
				force = carriage.force
			})
		SpookyGhost.orientation = carriage.orientation
		SpookyGhost.operable = false
		SpookyGhost.speed = 0.8*carriage.speed
		SpookyGhost.destructible = false

		local base = carriage.name
		local way = storage.OrientationUnitComponents[carriage.orientation].name

		if (helpers.is_valid_sprite_path("RT"..base..way)) then
			image = "RT"..base..way
		else
			image = "RT"..carriage.type..way
		end
		if (helpers.is_valid_sprite_path("RT"..base.."Mask"..way)) then
			mask = "RT"..base.."Mask"..way
		else
			mask = "RTNoMask"
		end

		if (carriage.type == "locomotive") then
			maskhue = carriage.color or {r = 255, g = 0, b = 0, a = 255}
		else
			maskhue = carriage.color
		end

		local OwTheEdge = rendering.draw_sprite
			{
				sprite = "GenericShadow",
				tint = {a = 90},
				target = {entity=SpookyGhost, offset={0,HeightOffset}},
				surface = SpookyGhost.surface,
				orientation = carriage.orientation,
				x_scale = 0.25,
				y_scale = 0.5,
				render_layer = "air-object"
			}
		local TrainImage = rendering.draw_sprite
			{
			sprite = image,
			target = {entity=SpookyGhost, offset={0,HeightOffset}},
			surface = SpookyGhost.surface,
			render_layer = "air-object",
			}
		local Mask = rendering.draw_sprite
			{
			sprite = mask,
			tint =  maskhue,
			target = {entity=SpookyGhost, offset={0,HeightOffset}},
			surface = SpookyGhost.surface,
			render_layer = "air-object"
			}
		if (math.random(1000) == 420) then
			TrainImage.destroy()
			TrainImage = rendering.draw_animation
				{
					animation = "RTHoojinTime",
					target = {entity=SpookyGhost, offset={0,HeightOffset}},
					surface = SpookyGhost.surface,
					orientation = -0.25,
					animation_speed = 0.5,
					render_layer = "air-object",
				}
			Mask.destroy()
			Mask = rendering.draw_sprite
				{
					sprite = "RTBlank",
					tint =  maskhue,
					target = {entity=SpookyGhost, offset={0,HeightOffset}},
					surface = SpookyGhost.surface,
					--x_scale = 0.5,
					--y_scale = 0.5,
					render_layer = "air-object"
				}
			SpookyGhost.surface.create_entity
				{
					name="RTSaysYourCrosshairIsTooLow",
					target=SpookyGhost,
					position={420,69}
				}
		end

		storage.FlyingTrains[SpookyGhost.unit_number] = {}
		local FlyingTrainProperties = storage.FlyingTrains[SpookyGhost.unit_number]
		FlyingTrainProperties.GuideCar = SpookyGhost
		if (carriage.get_driver() ~= nil) then
			--FlyingTrainProperties.passenger = carriage.get_driver()
			SpookyGhost.set_passenger(carriage.get_driver())
		end
		FlyingTrainProperties.name = carriage.name
		FlyingTrainProperties.type = carriage.type
		FlyingTrainProperties.LaunchTick = game.tick
		if (elevated) then
			FlyingTrainProperties.elevated = 3
			FlyingTrainProperties.height = 3
			FlyingTrainProperties.VerticalSpeed = 1
		end
		local MagnetRampProperties = storage.TrainRamps[script.register_on_object_destroyed(ramp)]
		if (MagneticRamps[ramp.name] and MagnetRampProperties and MagnetRampProperties.range ~= 0 and MagnetRampProperties.power.energy/MagnetRampProperties.power.electric_buffer_size >= 0.95) then
			local ElevatedRangeShift = 1
			local GroundToElevatedMagArcShift = 1
			if (ramp.get_or_create_control_behavior().circuit_condition.first_signal and ramp.get_or_create_control_behavior().circuit_condition.first_signal.name) then
				if (ramp.get_or_create_control_behavior().circuit_condition.first_signal.name == "DirectorBouncePlateUp") then
					GroundToElevatedMagArcShift = GroundToElevatedMagArcShift_constant
				elseif (ramp.get_or_create_control_behavior().circuit_condition.first_signal.name == "DirectorBouncePlateDown") then
					ElevatedRangeShift = ElevatedRangeShift_constant
				end
			end
			FlyingTrainProperties.LandTick = math.ceil((game.tick + math.abs((MagnetRampProperties.range*ElevatedRangeShift)/(0.8*carriage.speed))))
			FlyingTrainProperties.MagnetComp = math.ceil(game.tick + 130*math.abs(carriage.speed))-FlyingTrainProperties.LandTick
			FlyingTrainProperties.GroundToElevatedMagArcShift = GroundToElevatedMagArcShift
			FlyingTrainProperties.MakeFX = "yes"
			--game.print("power")

		elseif (MagneticRamps[ramp.name] and MagnetRampProperties and MagnetRampProperties.range ~= 0 and MagnetRampProperties.power.energy/MagnetRampProperties.power.electric_buffer_size < 0.95) then
			FlyingTrainProperties.MakeFX = "NoEnergy"
			--game.print("no power")
			FlyingTrainProperties.LandTick = math.ceil(game.tick + 130*math.abs(carriage.speed))

		elseif (elevated) then -- elevated jumps
			FlyingTrainProperties.LandTick = math.ceil(game.tick + 130*math.abs(carriage.speed))

		else
			FlyingTrainProperties.LandTick = math.ceil(game.tick + 130*math.abs(carriage.speed)) -- remember to adjust follower calculation too
		end

		FlyingTrainProperties.AirTime = FlyingTrainProperties.LandTick - FlyingTrainProperties.LaunchTick
		--game.print(FlyingTrainProperties.AirTime)
		FlyingTrainProperties.TrainImageID = TrainImage
		FlyingTrainProperties.MaskID = Mask
		FlyingTrainProperties.speed = carriage.speed
		FlyingTrainProperties.SpecialName = carriage.backer_name
		FlyingTrainProperties.color = maskhue
		FlyingTrainProperties.orientation = carriage.orientation
		--FlyingTrainProperties.RampOrientation = ramp.orientation
		FlyingTrainProperties.ShadowID = OwTheEdge
		FlyingTrainProperties.ManualMode = carriage.train.manual_mode
		FlyingTrainProperties.length = #carriage.train.carriages

		for number, properties in pairs(storage.FlyingTrains) do -- carriages jumping before the ends land
			if (properties.LandedTrain ~= nil and properties.LandedTrain.valid and carriage.unit_number == properties.LandedTrain.unit_number) then
				FlyingTrainProperties.ManualMode = properties.ManualMode
				FlyingTrainProperties.length = properties.length
			end
		end

		local SearchBox
		if (ramp.orientation == 0) then --ramp down
			FlyingTrainProperties.RampOrientation = 0
			SearchBox =
				{
					{carriage.position.x-1,carriage.position.y-6},
					{carriage.position.x+1,carriage.position.y-4}
				}
		elseif (ramp.orientation == 0.25) then -- ramp left
			FlyingTrainProperties.RampOrientation = 0.25
			SearchBox =
				{
					{carriage.position.x+4,carriage.position.y-1},
					{carriage.position.x+6,carriage.position.y+1}
				}
		elseif (ramp.orientation == 0.50) then -- ramp up
			FlyingTrainProperties.RampOrientation = 0.5
			SearchBox =
				{
					{carriage.position.x-1,carriage.position.y+4},
					{carriage.position.x+1,carriage.position.y+6}
				}
		elseif (ramp.orientation == 0.75) then -- ramp right
			FlyingTrainProperties.RampOrientation = 0.75
			SearchBox =
				{
					{carriage.position.x-6,carriage.position.y-1},
					{carriage.position.x-4,carriage.position.y+1}
				}
		end

		--[[ rendering.draw_rectangle{
			color = {1,1,0},
			left_top = SearchBox[1],
			right_bottom = SearchBox[2],
			surface = carriage.surface,
			time_to_live = 10,
		} ]]

		--game.print(FlyingTrainProperties.RampOrientation)
		FlyingTrainProperties.follower = SpookyGhost.surface.find_entities_filtered
			{
			area = SearchBox,
			type = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"},
			limit = 1
			}[1]

		--[[ if (FlyingTrainProperties.follower ~= nil) then
		rendering.draw_circle
			{
			color = {r = 234, g = 17, b = 0, a = 100},
			radius = 1,
			filled = true,
			target = FlyingTrainProperties.follower,
			surface = SpookyGhost.surface
			}
		end ]]

		FlyingTrainProperties.schedule = carriage.train.schedule
		if (SkippingRamps[ramp.name] and FlyingTrainProperties.schedule ~= nil) then
			if (FlyingTrainProperties.schedule.current == table_size(FlyingTrainProperties.schedule.records)) then
				FlyingTrainProperties.schedule.current = 1
			else
				FlyingTrainProperties.schedule.current = FlyingTrainProperties.schedule.current+1
			end
		elseif (NonSkippingRamps[ramp.name] and FlyingTrainProperties.schedule ~= nil) then
			FlyingTrainProperties.destinationStation = carriage.train.path_end_stop
			FlyingTrainProperties.adjustDestinationLimit = carriage.train.path_end_stop -- manual trains don't have this, it will be nill
			if (FlyingTrainProperties.adjustDestinationLimit and carriage.train.path_end_stop.trains_limit > 0 and carriage.train.path_end_stop.trains_limit < 4294967295) then -- apparently 4294967295 means train limit is disabled
				-- Artifically reserve the station by decrementing the available blocks
				carriage.train.path_end_stop.trains_limit = carriage.train.path_end_stop.trains_limit - 1
			end
		end

		--| Follower/leader tracking
		for number, properties in pairs(storage.FlyingTrains) do
			if (properties.follower and properties.follower.valid and carriage.unit_number == properties.follower.unit_number) then
				FlyingTrainProperties.leader = number
				storage.FlyingTrains[number].followerID = SpookyGhost.unit_number
				FlyingTrainProperties.schedule = storage.FlyingTrains[number].schedule
				FlyingTrainProperties.ManualMode = storage.FlyingTrains[number].ManualMode
				FlyingTrainProperties.destinationStation = storage.FlyingTrains[number].destinationStation
				FlyingTrainProperties.adjustDestinationLimit = storage.FlyingTrains[number].adjustDestinationLimit
				if (MagneticRamps[ramp.name] and MagnetRampProperties and storage.FlyingTrains[number].MagnetComp ~= nil and (storage.FlyingTrains[number].MakeFX == "yes" or storage.FlyingTrains[number].MakeFX == "followerY")) then
					-- all this has to be repeated from the original mag ramp handling for some reason, when i dont repeat it there are dysyncs (in data no like a crash)
					local ElevatedRangeShift = 1
					local GroundToElevatedMagArcShift = 1
					if (ramp.get_or_create_control_behavior().circuit_condition.first_signal and ramp.get_or_create_control_behavior().circuit_condition.first_signal.name) then
						if (ramp.get_or_create_control_behavior().circuit_condition.first_signal.name == "DirectorBouncePlateUp") then
							GroundToElevatedMagArcShift = GroundToElevatedMagArcShift_constant
						elseif (ramp.get_or_create_control_behavior().circuit_condition.first_signal.name == "DirectorBouncePlateDown") then
							ElevatedRangeShift = ElevatedRangeShift_constant
						end
					end
					FlyingTrainProperties.LandTick = math.ceil((game.tick + math.abs((MagnetRampProperties.range*ElevatedRangeShift)/(0.8*storage.FlyingTrains[number].speed))))
					FlyingTrainProperties.MagnetComp = storage.FlyingTrains[number].MagnetComp
					FlyingTrainProperties.GroundToElevatedMagArcShift = GroundToElevatedMagArcShift
					FlyingTrainProperties.MakeFX = "followerY"
				else
					FlyingTrainProperties.LandTick = math.ceil(game.tick + 130*math.abs(storage.FlyingTrains[number].speed))
					FlyingTrainProperties.MagnetComp = nil
					FlyingTrainProperties.MakeFX = "followerN"
				end

				FlyingTrainProperties.AirTime = storage.FlyingTrains[number].AirTime
				FlyingTrainProperties.length = storage.FlyingTrains[number].length

				-- Adjust follower's jump position to match leader's, should help with followers landing in the exact same spot as the leader and account for any speed differences after the leader jumps
				SpookyGhost.teleport(storage.FlyingTrains[number].JumpStartPosition)
				

				---==========================
				if (FlyingTrainProperties.speed>0) then
					SpookyGhost.speed = 0.8*math.abs(storage.FlyingTrains[number].speed)
					FlyingTrainProperties.speed = math.abs(storage.FlyingTrains[number].speed)
				else
					SpookyGhost.speed = -0.8*math.abs(storage.FlyingTrains[number].speed)
					FlyingTrainProperties.speed = -math.abs(storage.FlyingTrains[number].speed)
				end
				--game.print(game.tick.." shifted "..SpookyGhost.speed)
			end
		end

		--| Record jump start position
		FlyingTrainProperties.JumpStartPosition = SpookyGhost.position
		--game.print(game.tick.." JumpStartPosition: "..serpent.block(FlyingTrainProperties.JumpStartPosition))

		--| Magnet Ramp GFX
		if (MagneticRamps[ramp.name] and MagnetRampProperties and MagnetRampProperties.range ~= 0 and FlyingTrainProperties.MakeFX == "yes") then
			MagnetRampProperties.power.energy = 0
			if (FlyingTrainProperties.MagnetComp < 0) then
				polarity = "RTPush"
				vroom = 0.75
				shade = {r = 1, g = 0.2, b = 0.2, a = 0}
			else
				polarity = "RTPull"
				vroom = 0.75
				shade = {r = 0.4, g = 0.4, b = 1, a = 0}
			end

			for each, railtile in pairs(MagnetRampProperties.tiles) do
				rendering.draw_animation
					{
						animation = polarity,
						target = {railtile.position.x, railtile.position.y-1.65},
						--target_offset = {0,-1.65},
						animation_speed = vroom,
						animation_offset = math.random(0,99),
						tint = shade,
						surface = ramp.surface,
						x_scale = 0.3,
						y_scale = 0.8,
						time_to_live = math.abs(FlyingTrainProperties.AirTime+((5.9*FlyingTrainProperties.length)/(0.8*carriage.speed)))
					}
			end

		elseif (MagneticRamps[ramp.name] and MagnetRampProperties and MagnetRampProperties.range ~= 0 and FlyingTrainProperties.MakeFX == "NoEnergy") then
			for each, guy in pairs(game.connected_players) do
				guy.add_custom_alert(MagnetRampProperties.entity, {type = "item", name = "RTMagnetTrainRampItem"}, "A Magnet Ramp was used without a full buffer!", true)
			end

		end
		-- record stuff based on wagon type
		if (carriage.type == "locomotive" and carriage.burner) then
			if (storage.About2Jump[carriage.unit_number] ~= nil) then
				FlyingTrainProperties.CurrentlyBurning = storage.About2Jump[carriage.unit_number].BurningFuel
				storage.About2Jump[carriage.unit_number] = nil
			else
				FlyingTrainProperties.CurrentlyBurning = carriage.burner.currently_burning
			end
			FlyingTrainProperties.RemainingFuel = carriage.burner.remaining_burning_fuel
			
			-- Ultracube irreplaceables handling for burner
			if storage.Ultracube then -- Mod is active
				-- Remove all irreplaceables (if any) from fuel/burnt inventory + currently_burning and create ownership tokens for each
				-- The items must be removed so that they aren't destroyed with the locomotive, as Ultracube will spill them if that happens, and in this case 'duplicating' them
				local FlyingTrain = FlyingTrainProperties
				CubeFlyingTrains.create_tokens_for_inventory(FlyingTrain, carriage.burner.inventory, defines.inventory.fuel)
				CubeFlyingTrains.create_tokens_for_inventory(FlyingTrain, carriage.burner.burnt_result_inventory, defines.inventory.burnt_result)
				CubeFlyingTrains.create_token_for_burning(FlyingTrain) -- Must be called after FlyingTrain.RemainingFuel has been set, see cube_flying_trains.lua
			end
			
			FlyingTrainProperties.FuelInventory = carriage.burner.inventory.get_contents()
			FlyingTrainProperties.BurntFuelInventory = carriage.burner.burnt_result_inventory.get_contents()
		elseif (carriage.type == "cargo-wagon") then
			-- Ultracube irreplaceables handling
			if storage.Ultracube then -- Mod is active
				-- Remove all irreplaceables (if any) from cargo wagon's inventory and create ownership tokens for each
				-- The items must be removed so that they aren't destroyed with the wagon, as Ultracube will spill them if that happens, and in this case 'duplicating' them
				local FlyingTrain = FlyingTrainProperties
				local inventory = carriage.get_inventory(defines.inventory.cargo_wagon)
				CubeFlyingTrains.create_tokens_for_inventory(FlyingTrain, inventory, defines.inventory.cargo_wagon)
			end
			-- record inventory and filters
			local inventory = carriage.get_inventory(defines.inventory.cargo_wagon)
			local cargo = {}
			for i = 1, #inventory do
				local stack = inventory[i]
				if (stack.valid_for_read and stack.item_number) then
					local CloudStorage = game.create_inventory(1)
					CloudStorage.insert(stack)
					table.insert(cargo, CloudStorage)
				elseif (stack.valid_for_read) then
					table.insert(cargo, {name=stack.name, count=stack.count, health=stack.health, quality=stack.quality, spoil_percent=stack.spoil_percent})
				end
			end
			FlyingTrainProperties.cargo = cargo
			FlyingTrainProperties.bar = carriage.get_inventory(defines.inventory.cargo_wagon).get_bar()
			FlyingTrainProperties.filter = {}
			for i = 1, #carriage.get_inventory(defines.inventory.cargo_wagon) do
				FlyingTrainProperties.filter[i] = carriage.get_inventory(defines.inventory.cargo_wagon).get_filter(i)
			end
			-- ArmoredTrains support
			if (remote.interfaces.ArmoredTrains and remote.interfaces.ArmoredTrains.SendTurretList) then
				local list = remote.call("ArmoredTrains", "SendTurretList")
				if (list ~= nil) then
					local turret = nil
					for each, link in pairs(list) do
						if (link.entity.unit_number == carriage.unit_number) then
							turret = link.proxy
							break
						end
					end
					if (turret ~= nil) then
						FlyingTrainProperties.ammo = turret.get_inventory(defines.inventory.turret_ammo).get_contents()
					end
				end
			end
			-- Trapdoor wagon
			local DestroyNumber = script.register_on_object_destroyed(carriage)
			if (storage.TrapdoorWagonsOpen[DestroyNumber]) then
				FlyingTrainProperties.trapdoor = true
			end
			storage.TrapdoorWagonsOpen[DestroyNumber] = nil -- nil both cause it'll only be one or the other
			storage.TrapdoorWagonsClosed[DestroyNumber] = nil
		elseif (carriage.type == "fluid-wagon") then
			FlyingTrainProperties.fluids = carriage.get_fluid_contents()
		elseif (carriage.type == "artillery-wagon") then
			FlyingTrainProperties.artillery = carriage.get_inventory(defines.inventory.artillery_wagon_ammo).get_contents()
		end
		-- temporarily set all trains to burn the fastest fuel so it can keep up with the initial speed
		if (FlyingTrainProperties.leader == nil) then
			for each, karriage in pairs(carriage.train.carriages) do
				if (karriage.burner) then
					storage.About2Jump[karriage.unit_number] = {}
					storage.About2Jump[karriage.unit_number].BurningFuel = karriage.burner.currently_burning
					karriage.burner.currently_burning = prototypes.item[storage.FastestFuel]
				end
			end
		end
		-- record the equipment grid
		if (carriage.grid ~= nil) then
			FlyingTrainProperties.gridd = {}
			for j = 0, carriage.grid.height-1 do
				for i = 0, carriage.grid.width-1 do
					if (carriage.grid.get({i,j})) then
						table.insert(FlyingTrainProperties.gridd, {xpos = i, ypos = j, EquipName = carriage.grid.get({i,j}).name})
					end
				end
			end
		end
		-- VehicleWagons2 support
		if remote.interfaces.VehicleWagon2 and remote.interfaces.VehicleWagon2.get_wagon_data then
			storage.savedVehicleWagons[carriage.unit_number] = remote.call("VehicleWagon2", "get_wagon_data", carriage) -- returns nil if not a vehicle wagon
			FlyingTrainProperties.WagonUnitNumber = carriage.unit_number
			script.raise_event(defines.events.script_raised_destroy, {entity=carriage, cloned=true})
			carriage.destroy({ raise_destroy = false })
		else
			carriage.destroy({ raise_destroy = true })
		end

	elseif ((event.entity.name == "RTTrainRampCollisionBox"
			or event.entity.name == "RTElevatedTrainRampCollisionBox")
		and storage.TrainCollisionDetectors[script.register_on_object_destroyed(event.entity)].RampType == "ImpactUnloader"
		and event.cause
		and (event.cause.type == "locomotive" or event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon" or event.cause.type == "artillery-wagon")
		) then
		local carriage = event.cause
		local elevated = (event.entity.name == "RTElevatedTrainRampCollisionBox")
		local ramp = storage.TrainCollisionDetectors[script.register_on_object_destroyed(event.entity)].ramp
		local HeightOffset = 0
		if (elevated) then
			HeightOffset = -3
		end
		if (carriage.train and carriage.train.cargo_wagons and math.abs(carriage.train.speed) > 0.125) then
			wagons = #carriage.train.cargo_wagons
			for each, wagon in pairs(carriage.train.cargo_wagons) do
				if (wagon.name == "RTImpactWagon") then
					local LaunchedPortion = math.min(math.abs(wagon.speed)/0.75, 1)
					local WagonInventory = wagon.get_inventory(defines.inventory.cargo_wagon)
					for i = 1, #WagonInventory do
						local stack = WagonInventory[i]
						if (stack.valid_for_read) then
							local LaunchedAmount = math.ceil(stack.count*LaunchedPortion)
							local GroupSize = math.ceil((stack.count/17)*wagons) -- each stack will launch out as maximum 17 projectiles per wagon
							--[[ local xUnit = (math.acos(math.cos(2*math.pi*(wagon.orientation+0.25)))/(0.5*math.pi)) - 1
							local yUnit = (math.acos(math.cos(2*math.pi*(wagon.orientation)))/(0.5*math.pi)) - 1 ]]
							
							for _ = 1, math.floor(LaunchedAmount/GroupSize) do
								local AngleSpread = math.random(-60,60)*0.001
								local xUnit = math.cos(2*math.pi*(wagon.orientation-0.25+AngleSpread))
								local yUnit = math.sin(2*math.pi*(wagon.orientation-0.25+AngleSpread))
								local ForwardSpread = math.random(1000,4000)*0.01 + (-2*HeightOffset)
								--local HorizontalSpread = math.random(-35,35)*ForwardSpread*0.01
								local TargetX = wagon.position.x + (ForwardSpread*wagon.speed*xUnit)-- + (HorizontalSpread*wagon.speed*yUnit)
								local TargetY = wagon.position.y + (ForwardSpread*wagon.speed*yUnit)-- + (HorizontalSpread*wagon.speed*xUnit)
								local distance = math.sqrt((TargetX-wagon.position.x)^2 + (TargetY-wagon.position.y)^2)
								local speed = math.abs(wagon.speed) * (distance/(35*math.abs(wagon.speed))) * math.random(45,100)*0.01
								local arc = 0.3236*distance^-0.404 -- lower number is higher arc
								local space = false
								if (wagon.surface.platform or string.find(wagon.surface.name, " Orbit") or string.find(wagon.surface.name, " Field") or string.find(wagon.surface.name, " Belt")) then
									arc = 99999999999999
									TargetX = TargetX + (xUnit*wagon.speed * 200)
									TargetY = TargetY + (yUnit*wagon.speed * 200)
									distance = math.sqrt((TargetX-wagon.position.x)^2 + (TargetY-wagon.position.y)^2)
									space = true
								end
								local AirTime = math.floor(distance/speed) + (-6*HeightOffset)
								local vector = {x=TargetX-wagon.position.x, y=TargetY-wagon.position.y}
								local path = {}
								local random1 = math.random(-10, 10)*0.1
								local random2 = math.random(-20, 5)*0.1
								for j = 1, AirTime do
									local progress = j/AirTime
									path[j] =
									{
										x = wagon.position.x+random1+(progress*vector.x),
										y = wagon.position.y+random2+(progress*vector.y) + (HeightOffset*(1-progress)),
										height = progress * (1-progress) / arc
									}
								end
								InvokeThrownItem({
									type = "CustomPath",
									render_layer = "elevated-higher-object",
									stack = stack,
									ThrowFromStackAmount = GroupSize,
									start = wagon.position,
									target = {x=TargetX, y=TargetY},
									path = path,
									AirTime = AirTime,
									space = space,
									surface=wagon.surface,
								})
							end
							local remainder = LaunchedAmount-(math.floor(LaunchedAmount/GroupSize)*GroupSize)
							if (remainder > 0) then
								local AngleSpread = math.random(-55,55)*0.001
								local xUnit = math.cos(2*math.pi*(wagon.orientation-0.25+AngleSpread))
								local yUnit = math.sin(2*math.pi*(wagon.orientation-0.25+AngleSpread))
								local ForwardSpread = math.random(1000,4000)*0.01 + (-2*HeightOffset)
								--local HorizontalSpread = math.random(-35,35)*ForwardSpread*0.01
								local TargetX = wagon.position.x + (ForwardSpread*wagon.speed*xUnit) --+ (HorizontalSpread*wagon.speed*yUnit)
								local TargetY = wagon.position.y + (ForwardSpread*wagon.speed*yUnit) --+ (HorizontalSpread*wagon.speed*xUnit)
								local distance = math.sqrt((TargetX-wagon.position.x)^2 + (TargetY-wagon.position.y)^2)
								local speed = math.abs(wagon.speed) * (distance/(35*math.abs(wagon.speed))) * math.random(45,100)*0.01
								local arc = 0.3236*distance^-0.404 -- lower number is higher arc
								local space = false
								if (wagon.surface.platform or string.find(wagon.surface.name, " Orbit") or string.find(wagon.surface.name, " Field") or string.find(wagon.surface.name, " Belt")) then
									arc = 99999999999999
									TargetX = TargetX + (xUnit*wagon.speed * 200)
									TargetY = TargetY + (yUnit*wagon.speed * 200)
									distance = math.sqrt((TargetX-wagon.position.x)^2 + (TargetY-wagon.position.y)^2)
									space = true
								end
								local AirTime = math.floor(distance/speed) + (-5*HeightOffset)
								local vector = {x=TargetX-wagon.position.x, y=TargetY-wagon.position.y}
								local path = {}
								local random1 = math.random(-10, 10)*0.1
								local random2 = math.random(-20, 5)*0.1
								for j = 1, AirTime do
									local progress = j/AirTime
									path[j] =
									{
										x = wagon.position.x+random1+(progress*vector.x),
										y = wagon.position.y+random2+(progress*vector.y) + (HeightOffset*(1-progress)),
										height = progress * (1-progress) / arc
									}
								end
								InvokeThrownItem({
									type = "CustomPath",
									render_layer = "elevated-higher-object",
									stack = stack,
									ThrowFromStackAmount = remainder,
									start = wagon.position,
									target = {x=TargetX, y=TargetY},
									path = path,
									AirTime = AirTime,
									space = space,
									surface=wagon.surface,
								})
							end
						end
					end
				end
			end
			if (carriage.train.schedule and carriage.train.manual_mode == false) then
				local stor = carriage.train.schedule
				if (carriage.train.schedule.current == table_size(carriage.train.schedule.records)) then
					stor.current = 1
				else
					stor.current = stor.current + 1
				end
				carriage.train.schedule = stor
			end
		end

	elseif (event.entity.name == "RTTrainDetector") then
		local detector = event.entity
		-- toggle the trapdoor on the wagon if it was hit by a trapdoor wagon
		local last
		if (event.cause and event.cause.valid and event.cause.name == "RTTrapdoorWagon") then
			ToggleTrapdoorWagon(event.cause)
			last = event.cause.unit_number
		end
		-- start trying to res the detector
		local time = game.tick+1
		if (storage.clock[time] == nil) then
			storage.clock[time] = {}
		end
		if (storage.clock[time].rez == nil) then
			storage.clock[time].rez = {}
		end
		local info = {name=detector.name, position=detector.position, force="neutral", surface=detector.surface, LastToggled=last}
		table.insert(storage.clock[time].rez, info)
		-- remove the now broken detector from the destruction link of its trigger
		--[[ local switch = detector.surface.find_entities_filtered({name="RTTrapdoorSwitch", position=detector.position})[1]
		if (switch) then
			storage.DestructionLinks[script.register_on_object_destroyed(switch)] = {}
		end ]]

	elseif ( -- character hit by vehicle
	event.cause
	and (event.cause.type == "locomotive"
		or event.cause.type == "cargo-wagon"
		or event.cause.type == "fluid-wagon"
		or event.cause.type == "artillery-wagon"
		or event.cause.type == "car")
	and event.entity.type == "character"
	and string.find(event.cause.name, "RTGhost") == nil
	and event.entity.health > 0
	and event.entity.player
	) then
		local character = event.entity
		local player = event.entity.player
		local PlayerProperties = storage.AllPlayers[player.index]
		PlayerProperties.state = "jumping"
		local OG, shadow = SwapToGhost(player)
		-- unit vector between vehicle and character
		local x = event.entity.position.x - event.cause.position.x
		local y = event.entity.position.y - event.cause.position.y
		local distance = math.sqrt(x^2 + y^2)
		local xUnit = x/distance
		local yUnit = y/distance
		-- launch the character based on the vehicle's speed and direction
		local speed = math.abs(event.cause.speed)
		local AirTime = math.max(1, math.floor(speed*45))
		local TargetX = event.entity.position.x + (xUnit*speed*AirTime)
		local TargetY = event.entity.position.y + (yUnit*speed*AirTime)
		local vector = {x=TargetX-event.entity.position.x, y=TargetY-event.entity.position.y}
		local MaxHeight = event.cause.speed
		local path = {}
		for j = 0, AirTime do
			local progress = j/AirTime
			path[j] =
			{
				x = character.position.x+(progress*vector.x),
				y = character.position.y+(progress*vector.y),
				height = 4*(progress * (1-progress)) * MaxHeight
			}
		end
		local FlyingItem = InvokeThrownItem({
			type = "PlayerGuide",
			player = player,
			shadow = shadow,
			AirTime = AirTime,
			SwapBack = OG,
			IAmSpeed = player.character.character_running_speed_modifier,
			path = path,
			start = player.position,
			target={x=TargetX, y=TargetY},
			surface=player.surface,
		})
		PlayerProperties.PlayerLauncher.tracker = FlyingItem.FlightNumber
		if (storage.OrientationUnitComponents[character.orientation]) then
			PlayerProperties.PlayerLauncher.direction = storage.OrientationUnitComponents[character.orientation].name
		else
			local rand = {"up", "down", "left", "right"}
			PlayerProperties.PlayerLauncher.direction = rand[math.random(1,4)]
		end
		player.play_sound
		{
			path = "RTImpactPlayerLaunch",
		}
	end
end

return entity_damaged
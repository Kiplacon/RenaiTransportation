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

local function entity_damaged(event)
	if ( -- train ramps
		(TrainRamps[event.entity.name] ~= nil)
		and event.cause
		and (event.cause.type == "locomotive"
			or event.cause.type == "cargo-wagon"
			or event.cause.type == "fluid-wagon"
			or event.cause.type == "artillery-wagon")
		and (math.abs(event.entity.orientation-event.cause.orientation) == 0.5
			or math.abs(event.entity.orientation-event.cause.orientation) == 0
			or string.find(event.entity.name, "-Elevated")~=nil)
		and (
				(((event.entity.name == "RTTrainRamp-ElevatedDown" or (string.find(event.entity.name, "-Elevated")==nil and event.entity.orientation == 0)) and event.entity.position.y-event.cause.position.y>0) --down
				or ((event.entity.name == "RTTrainRamp-ElevatedLeft" or (string.find(event.entity.name, "-Elevated")==nil and event.entity.orientation == 0.25)) and event.entity.position.x-event.cause.position.x<0) --left
				or ((event.entity.name == "RTTrainRamp-ElevatedUp" or (string.find(event.entity.name, "-Elevated")==nil and event.entity.orientation == 0.5)) and event.entity.position.y-event.cause.position.y<0) --up
				or ((event.entity.name == "RTTrainRamp-ElevatedRight" or (string.find(event.entity.name, "-Elevated")==nil and event.entity.orientation == 0.75)) and event.entity.position.x-event.cause.position.x>0) --right
				)
			)
	) then
		local elevated = (string.find(event.entity.name, "-Elevated") ~= nil)
		local HeightOffset = 0
		if (elevated) then
			HeightOffset = -3
		end
		--game.print(elevated)
		local SpookyGhost = event.entity.surface.create_entity
			({
				name = "RTPropCar",
				position = event.cause.position,
				force = event.cause.force
			})
		SpookyGhost.orientation = event.cause.orientation
		SpookyGhost.operable = false
		SpookyGhost.speed = 0.8*event.cause.speed
		SpookyGhost.destructible = false

		local base = event.cause.name
		local way = storage.OrientationUnitComponents[event.cause.orientation].name

		if (helpers.is_valid_sprite_path("RT"..base..way)) then
			image = "RT"..base..way
		else
			image = "RT"..event.cause.type..way
		end
		if (helpers.is_valid_sprite_path("RT"..base.."Mask"..way)) then
			mask = "RT"..base.."Mask"..way
		else
			mask = "RTNoMask"
		end

		if (event.cause.type == "locomotive") then
			maskhue = event.cause.color or {r = 255, g = 0, b = 0, a = 255}
		else
			maskhue = event.cause.color
		end

		local OwTheEdge = rendering.draw_sprite
			{
				sprite = "GenericShadow",
				tint = {a = 90},
				target = {entity=SpookyGhost, offset={0,HeightOffset}},
				surface = SpookyGhost.surface,
				orientation = event.cause.orientation,
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
					target={entity=SpookyGhost, offset={0,HeightOffset}},
					position={420,69}
				}
		end

		storage.FlyingTrains[SpookyGhost.unit_number] = {}
		local FlyingTrainProperties = storage.FlyingTrains[SpookyGhost.unit_number]
		FlyingTrainProperties.GuideCar = SpookyGhost
		if (event.cause.get_driver() ~= nil) then
			--FlyingTrainProperties.passenger = event.cause.get_driver()
			SpookyGhost.set_passenger(event.cause.get_driver())
		end
		FlyingTrainProperties.name = event.cause.name
		FlyingTrainProperties.type = event.cause.type
		FlyingTrainProperties.LaunchTick = game.tick
		if (elevated) then
			FlyingTrainProperties.elevated = 3
			FlyingTrainProperties.height = 3
			FlyingTrainProperties.VerticalSpeed = 1
		end
		local MagnetRampProperties = storage.MagnetRamps[script.register_on_object_destroyed(event.entity)]
		if (MagneticRamps[event.entity.name] and MagnetRampProperties and MagnetRampProperties.range ~= 0 and MagnetRampProperties.power.energy/MagnetRampProperties.power.electric_buffer_size >= 0.95) then
			FlyingTrainProperties.LandTick = math.ceil(game.tick + math.abs(MagnetRampProperties.range/(0.8*event.cause.speed)))
			FlyingTrainProperties.MagnetComp = math.ceil(game.tick + 130*math.abs(event.cause.speed))-FlyingTrainProperties.LandTick
			FlyingTrainProperties.MakeFX = "yes"
			--game.print("power")

		elseif (MagneticRamps[event.entity.name] and MagnetRampProperties and MagnetRampProperties.range ~= 0 and MagnetRampProperties.power.energy/MagnetRampProperties.power.electric_buffer_size < 0.95) then
			FlyingTrainProperties.MakeFX = "NoEnergy"
			--game.print("no power")
			FlyingTrainProperties.LandTick = math.ceil(game.tick + 130*math.abs(event.cause.speed))

		elseif (elevated) then -- elevated jumps
			FlyingTrainProperties.LandTick = math.ceil(game.tick + 130*math.abs(event.cause.speed))

		else
			FlyingTrainProperties.LandTick = math.ceil(game.tick + 130*math.abs(event.cause.speed)) -- remember to adjust follower calculation too
		end

		FlyingTrainProperties.AirTime = FlyingTrainProperties.LandTick - FlyingTrainProperties.LaunchTick
		--game.print(FlyingTrainProperties.AirTime)
		FlyingTrainProperties.TrainImageID = TrainImage
		FlyingTrainProperties.MaskID = Mask
		FlyingTrainProperties.speed = event.cause.speed
		FlyingTrainProperties.SpecialName = event.cause.backer_name
		FlyingTrainProperties.color = maskhue
		FlyingTrainProperties.orientation = event.cause.orientation
		--FlyingTrainProperties.RampOrientation = event.entity.orientation
		FlyingTrainProperties.ShadowID = OwTheEdge
		FlyingTrainProperties.ManualMode = event.cause.train.manual_mode
		FlyingTrainProperties.length = #event.cause.train.carriages

		for number, properties in pairs(storage.FlyingTrains) do -- carriages jumping before the ends land
			if (properties.LandedTrain ~= nil and properties.LandedTrain.valid and event.cause.unit_number == properties.LandedTrain.unit_number) then
				FlyingTrainProperties.ManualMode = properties.ManualMode
				FlyingTrainProperties.length = properties.length
			end
		end

		local SearchBox
		if (event.entity.name == "RTTrainRamp-ElevatedDown" or (elevated == false and event.entity.orientation == 0)) then --ramp down
			FlyingTrainProperties.RampOrientation = 0
			SearchBox =
				{
					{event.cause.position.x-1,event.cause.position.y-6},
					{event.cause.position.x+1,event.cause.position.y-4}
				}
		elseif (event.entity.name == "RTTrainRamp-ElevatedLeft" or (elevated == false and event.entity.orientation == 0.25)) then -- ramp left
			FlyingTrainProperties.RampOrientation = 0.25
			SearchBox =
				{
					{event.cause.position.x+4,event.cause.position.y-1},
					{event.cause.position.x+6,event.cause.position.y+1}
				}
		elseif (event.entity.name == "RTTrainRamp-ElevatedUp" or (elevated == false and event.entity.orientation == 0.50)) then -- ramp up
			FlyingTrainProperties.RampOrientation = 0.5
			SearchBox =
				{
					{event.cause.position.x-1,event.cause.position.y+4},
					{event.cause.position.x+1,event.cause.position.y+6}
				}
		elseif (event.entity.name == "RTTrainRamp-ElevatedRight" or (elevated == false and event.entity.orientation == 0.75)) then -- ramp right
			FlyingTrainProperties.RampOrientation = 0.75
			SearchBox =
				{
					{event.cause.position.x-6,event.cause.position.y-1},
					{event.cause.position.x-4,event.cause.position.y+1}
				}
		end

		--[[ rendering.draw_rectangle{
			color = {1,1,0},
			left_top = SearchBox[1],
			right_bottom = SearchBox[2],
			surface = event.cause.surface,
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

		FlyingTrainProperties.schedule = event.cause.train.schedule
		if (SkippingRamps[event.entity.name] and FlyingTrainProperties.schedule ~= nil) then
			if (FlyingTrainProperties.schedule.current == table_size(FlyingTrainProperties.schedule.records)) then
				FlyingTrainProperties.schedule.current = 1
			else
				FlyingTrainProperties.schedule.current = FlyingTrainProperties.schedule.current+1
			end
		elseif (NonSkippingRamps[event.entity.name] and FlyingTrainProperties.schedule ~= nil) then
			FlyingTrainProperties.destinationStation = event.cause.train.path_end_stop
			FlyingTrainProperties.adjustDestinationLimit = event.cause.train.path_end_stop -- manual trains don't have this, it will be nill
			if (FlyingTrainProperties.adjustDestinationLimit and event.cause.train.path_end_stop.trains_limit > 0 and event.cause.train.path_end_stop.trains_limit < 4294967295) then -- apparently 4294967295 means train limit is disabled
				-- Artifically reserve the station by decrementing the available blocks
				event.cause.train.path_end_stop.trains_limit = event.cause.train.path_end_stop.trains_limit - 1
			end
		end

		--| Follower/leader tracking
		for number, properties in pairs(storage.FlyingTrains) do
			if (properties.follower and properties.follower.valid and event.cause.unit_number == properties.follower.unit_number) then
				FlyingTrainProperties.leader = number
				storage.FlyingTrains[number].followerID = SpookyGhost.unit_number
				FlyingTrainProperties.schedule = storage.FlyingTrains[number].schedule
				FlyingTrainProperties.ManualMode = storage.FlyingTrains[number].ManualMode
				FlyingTrainProperties.destinationStation = storage.FlyingTrains[number].destinationStation
				FlyingTrainProperties.adjustDestinationLimit = storage.FlyingTrains[number].adjustDestinationLimit
				if (MagneticRamps[event.entity.name] and MagnetRampProperties and storage.FlyingTrains[number].MagnetComp ~= nil and (storage.FlyingTrains[number].MakeFX == "yes" or storage.FlyingTrains[number].MakeFX == "followerY")) then
					FlyingTrainProperties.LandTick = math.ceil(game.tick + math.abs(MagnetRampProperties.range/(0.8*storage.FlyingTrains[number].speed)))
					FlyingTrainProperties.MagnetComp = storage.FlyingTrains[number].MagnetComp
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
		if (MagneticRamps[event.entity.name] and MagnetRampProperties and MagnetRampProperties.range ~= 0 and FlyingTrainProperties.MakeFX == "yes") then
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
						surface = event.entity.surface,
						x_scale = 0.3,
						y_scale = 0.8,
						time_to_live = FlyingTrainProperties.AirTime+((5.9*FlyingTrainProperties.length)/(0.8*event.cause.speed))
					}
			end

		elseif (MagneticRamps[event.entity.name] and MagnetRampProperties and MagnetRampProperties.range ~= 0 and FlyingTrainProperties.MakeFX == "NoEnergy") then
			for each, guy in pairs(game.connected_players) do
				guy.add_custom_alert(MagnetRampProperties.entity, {type = "item", name = "RTMagnetTrainRampItem"}, "A Magnet Ramp was used without a full buffer!", true)
			end

		end
		-- record stuff based on wagon type
		if (event.cause.type == "locomotive" and event.cause.burner) then
			if (storage.About2Jump[event.cause.unit_number] ~= nil) then
				FlyingTrainProperties.CurrentlyBurning = storage.About2Jump[event.cause.unit_number].BurningFuel
				storage.About2Jump[event.cause.unit_number] = nil
			else
				FlyingTrainProperties.CurrentlyBurning = event.cause.burner.currently_burning
			end
			FlyingTrainProperties.RemainingFuel = event.cause.burner.remaining_burning_fuel
			
			-- Ultracube irreplaceables handling for burner
			if storage.Ultracube then -- Mod is active
				-- Remove all irreplaceables (if any) from fuel/burnt inventory + currently_burning and create ownership tokens for each
				-- The items must be removed so that they aren't destroyed with the locomotive, as Ultracube will spill them if that happens, and in this case 'duplicating' them
				local FlyingTrain = FlyingTrainProperties
				CubeFlyingTrains.create_tokens_for_inventory(FlyingTrain, event.cause.burner.inventory, defines.inventory.fuel)
				CubeFlyingTrains.create_tokens_for_inventory(FlyingTrain, event.cause.burner.burnt_result_inventory, defines.inventory.burnt_result)
				CubeFlyingTrains.create_token_for_burning(FlyingTrain) -- Must be called after FlyingTrain.RemainingFuel has been set, see cube_flying_trains.lua
			end
			
			FlyingTrainProperties.FuelInventory = event.cause.burner.inventory.get_contents()
			FlyingTrainProperties.BurntFuelInventory = event.cause.burner.burnt_result_inventory.get_contents()
		elseif (event.cause.type == "cargo-wagon") then
			-- Ultracube irreplaceables handling
			if storage.Ultracube then -- Mod is active
				-- Remove all irreplaceables (if any) from cargo wagon's inventory and create ownership tokens for each
				-- The items must be removed so that they aren't destroyed with the wagon, as Ultracube will spill them if that happens, and in this case 'duplicating' them
				local FlyingTrain = FlyingTrainProperties
				local inventory = event.cause.get_inventory(defines.inventory.cargo_wagon)
				CubeFlyingTrains.create_tokens_for_inventory(FlyingTrain, inventory, defines.inventory.cargo_wagon)
			end
			-- record inventory and filters
			FlyingTrainProperties.cargo = event.cause.get_inventory(defines.inventory.cargo_wagon).get_contents()
			FlyingTrainProperties.bar = event.cause.get_inventory(defines.inventory.cargo_wagon).get_bar()
			FlyingTrainProperties.filter = {}
			for i = 1, #event.cause.get_inventory(defines.inventory.cargo_wagon) do
				FlyingTrainProperties.filter[i] = event.cause.get_inventory(defines.inventory.cargo_wagon).get_filter(i)
			end
			-- ArmoredTrains support
			if (remote.interfaces.ArmoredTrains and remote.interfaces.ArmoredTrains.SendTurretList) then
				local list = remote.call("ArmoredTrains", "SendTurretList")
				if (list ~= nil) then
					local turret = nil
					for each, link in pairs(list) do
						if (link.entity.unit_number == event.cause.unit_number) then
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
			local DestroyNumber = script.register_on_object_destroyed(event.cause)
			--[[ local open = false -- assume its closed
			if (storage.TrapdoorWagonsOpen[DestroyNumber] ~= nil) then
				open = true
			end ]]
			FlyingTrainProperties.trapdoor = storage.TrapdoorWagonsOpen[DestroyNumber] or storage.TrapdoorWagonsClosed[DestroyNumber]
			storage.TrapdoorWagonsOpen[DestroyNumber] = nil -- nil both cause it'll only be one or the other
			storage.TrapdoorWagonsClosed[DestroyNumber] = nil
		elseif (event.cause.type == "fluid-wagon") then
			FlyingTrainProperties.fluids = event.cause.get_fluid_contents()
		elseif (event.cause.type == "artillery-wagon") then
			FlyingTrainProperties.artillery = event.cause.get_inventory(defines.inventory.artillery_wagon_ammo).get_contents()
		end
		-- temporarily set all trains to burn the fastest fuel so it can keep up with the initial speed
		if (FlyingTrainProperties.leader == nil) then
			for each, carriage in pairs(event.cause.train.carriages) do
				if (carriage.burner) then
					storage.About2Jump[carriage.unit_number] = {}
					storage.About2Jump[carriage.unit_number].BurningFuel = carriage.burner.currently_burning
					carriage.burner.currently_burning = prototypes.item[storage.FastestFuel]
				end
			end
		end
		-- record the equipment grid
		if (event.cause.grid ~= nil) then
			FlyingTrainProperties.gridd = {}
			for j = 0, event.cause.grid.height-1 do
				for i = 0, event.cause.grid.width-1 do
					if (event.cause.grid.get({i,j})) then
						table.insert(FlyingTrainProperties.gridd, {xpos = i, ypos = j, EquipName = event.cause.grid.get({i,j}).name})
					end
				end
			end
		end
		-- VehicleWagons2 support
		if remote.interfaces.VehicleWagon2 and remote.interfaces.VehicleWagon2.get_wagon_data then
			storage.savedVehicleWagons[event.cause.unit_number] = remote.call("VehicleWagon2", "get_wagon_data", event.cause) -- returns nil if not a vehicle wagon
			FlyingTrainProperties.WagonUnitNumber = event.cause.unit_number
			script.raise_event(defines.events.script_raised_destroy, {entity=event.cause, cloned=true})
			event.cause.destroy({ raise_destroy = false })
		else
			event.cause.destroy({ raise_destroy = true })
		end

	elseif (event.entity.name == "RTImpactUnloader"
		and event.cause
		and (event.cause.type == "locomotive" or event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon" or event.cause.type == "artillery-wagon")
		) then
		if (event.cause.train and event.cause.train.cargo_wagons and math.abs(event.cause.train.speed) > 0.125) then
			wagons = #event.cause.train.cargo_wagons
			for each, wagon in pairs(event.cause.train.cargo_wagons) do
				if (wagon.name == "RTImpactWagon") then
					local LaunchedPortion = math.abs(wagon.speed)/0.75
					if (LaunchedPortion > 1) then
						LaunchedPortion = 1
					end
					for _, stack in pairs(wagon.get_inventory(defines.inventory.cargo_wagon).get_contents()) do
						local ItemName = stack.name
						local amount = stack.count
						local ItemQuality = stack.quality
						local LaunchedAmount = math.floor(amount*LaunchedPortion)
						if (LaunchedAmount > 0) then
							local GroupSize = math.ceil((LaunchedAmount*wagons)/settings.global["RTImpactGrouping"].value)
							for _ = 1, math.floor(LaunchedAmount/GroupSize) do
								local sprite = rendering.draw_sprite
									{
										sprite = "item/"..ItemName,
										x_scale = 0.5,
										y_scale = 0.5,
										target = wagon.position,
										surface = wagon.surface
									}
								local shadow = rendering.draw_sprite
									{
										sprite = "item/"..ItemName,
										tint = {0,0,0,0.5},
										x_scale = 0.5,
										y_scale = 0.5,
										target = wagon.position,
										surface = wagon.surface
									}
								local xUnit = (math.acos(math.cos(2*math.pi*(wagon.orientation+0.25)))/(0.5*math.pi)) - 1
								local yUnit = (math.acos(math.cos(2*math.pi*(wagon.orientation)))/(0.5*math.pi)) - 1
								local ForwardSpread = math.random(100,400)*0.1
								local HorizontalSpread = math.random(-40,40)*ForwardSpread*0.01
								local x = wagon.position.x + (ForwardSpread*wagon.speed*xUnit) + (HorizontalSpread*wagon.speed*yUnit)
								local y = wagon.position.y + (ForwardSpread*wagon.speed*yUnit) + (HorizontalSpread*wagon.speed*xUnit)
								local distance = math.sqrt((x-wagon.position.x)^2 + (y-wagon.position.y)^2)
								local speed = math.abs(wagon.speed) * (distance/(35*math.abs(wagon.speed))) * math.random(45,100)*0.01
								local arc = 0.3236*distance^-0.404 -- lower number is higher arc
								local space = false
								if (wagon.surface.platform or string.find(wagon.surface.name, " Orbit") or string.find(wagon.surface.name, " Field") or string.find(wagon.surface.name, " Belt")) then
									arc = 99999999999999
									x = x + (xUnit*wagon.speed * 200)
									y = y + (yUnit*wagon.speed * 200)
									distance = math.sqrt((x-wagon.position.x)^2 + (y-wagon.position.y)^2)
									space = true
									shadow.destroy()
								end
								local AirTime = math.floor(distance/speed)
								local vector = {x=x-wagon.position.x, y=y-wagon.position.y}
								local spin = math.random(-10,10)*0.01
								local path = {}
								local random1 = math.random(-10, 10)*0.1
								local random2 = math.random(-20, 5)*0.1
								for i = 1, AirTime do
									local progress = i/AirTime
									path[i] =
									{
										x = wagon.position.x+random1+(progress*vector.x),
										y = wagon.position.y+random2+(progress*vector.y),
										height = progress * (1-progress) / arc
									}
								end
								storage.FlyingItems[storage.FlightNumber] =
									{
										sprite=sprite,
										shadow=shadow,
										speed=speed,
										spin=spin,
										item=ItemName,
										amount=GroupSize,
										quality=ItemQuality,
										target={x=x, y=y},
										ThrowerPosition={x=wagon.position.x+random1, y=wagon.position.y+random2},
										AirTime=AirTime,
										StartTick=game.tick,
										LandTick=game.tick+AirTime,
										space=space,
										surface=wagon.surface,
										path=path
									}
								if (wagon.get_inventory(defines.inventory.cargo_wagon).find_item_stack({name=ItemName, quality=ItemQuality})
								and wagon.get_inventory(defines.inventory.cargo_wagon).find_item_stack({name=ItemName, quality=ItemQuality}).item_number ~= nil) then --quality crashes
									local CloudStorage = game.create_inventory(1)
									local item, index = wagon.get_inventory(defines.inventory.cargo_wagon).find_item_stack({name=ItemName, quality=ItemQuality})
									CloudStorage.insert(item)
									item.clear()
									storage.FlyingItems[storage.FlightNumber].CloudStorage = CloudStorage
								end

								-- Ultracube irreplaceables detection & handling
								if storage.Ultracube and storage.Ultracube.prototypes.irreplaceable[ItemName] then -- Ultracube mod is active, and item is an irreplaceable
									-- Sets cube_token_id and cube_should_hint for the new FlyingItems entry
									CubeFlyingItems.create_token_for(storage.FlyingItems[storage.FlightNumber])
								end

								storage.FlightNumber = storage.FlightNumber + 1
							end
							if (LaunchedAmount-(math.floor(LaunchedAmount/GroupSize)*GroupSize) > 0) then
								local sprite = rendering.draw_sprite
									{
										sprite = "item/"..ItemName,
										x_scale = 0.5,
										y_scale = 0.5,
										target = wagon.position,
										surface = wagon.surface
									}
								local shadow = rendering.draw_sprite
									{
										sprite = "item/"..ItemName,
										tint = {0,0,0,0.5},
										x_scale = 0.5,
										y_scale = 0.5,
										target = wagon.position,
										surface = wagon.surface
									}
								local xUnit = (math.acos(math.cos(2*math.pi*(wagon.orientation+0.25)))/(0.5*math.pi)) - 1
								local yUnit = (math.acos(math.cos(2*math.pi*(wagon.orientation)))/(0.5*math.pi)) - 1
								local ForwardSpread = math.random(100,400)*0.1
								local HorizontalSpread = math.random(-40,40)*ForwardSpread*0.01
								local x = wagon.position.x + (ForwardSpread*wagon.speed*xUnit) + (HorizontalSpread*wagon.speed*yUnit)
								local y = wagon.position.y + (ForwardSpread*wagon.speed*yUnit) + (HorizontalSpread*wagon.speed*xUnit)
								local distance = math.sqrt((x-wagon.position.x)^2 + (y-wagon.position.y)^2)
								local speed = math.abs(wagon.speed) * (distance/(35*math.abs(wagon.speed))) * math.random(45,100)*0.01
								local arc = 0.3236*distance^-0.404 -- lower number is higher arc
								local space = false
								if (wagon.surface.platform or string.find(wagon.surface.name, " Orbit") or string.find(wagon.surface.name, " Field") or string.find(wagon.surface.name, " Belt")) then
									arc = 99999999999999
									x = x + (xUnit*wagon.speed * 200)
									y = y + (yUnit*wagon.speed * 200)
									distance = math.sqrt((x-wagon.position.x)^2 + (y-wagon.position.y)^2)
									space = true
									shadow.destroy()
								end
								local AirTime = math.floor(distance/speed)
								local vector = {x=x-wagon.position.x, y=y-wagon.position.y}
								local spin = math.random(-10,10)*0.01
								local path = {}
								local random1 = math.random(-10, 10)*0.1
								local random2 = math.random(-20, 5)*0.1
								for i = 1, AirTime do
									local progress = i/AirTime
									path[i] =
									{
										x = wagon.position.x+random1+(progress*vector.x),
										y = wagon.position.y+random2+(progress*vector.y),
										height = progress * (1-progress) / arc
									}
								end
								storage.FlyingItems[storage.FlightNumber] =
									{
										sprite=sprite,
										shadow=shadow,
										speed=speed,
										spin=spin,
										item=ItemName,
										amount=LaunchedAmount-(math.floor(LaunchedAmount/GroupSize)*GroupSize),
										quality=ItemQuality,
										target={x=x, y=y},
										ThrowerPosition={x=wagon.position.x+random1, y=wagon.position.y+random2},
										AirTime=AirTime,
										StartTick=game.tick,
										LandTick=game.tick+AirTime,
										space=space,
										surface=wagon.surface,
										path=path
									}
								if (wagon.get_inventory(defines.inventory.cargo_wagon).find_item_stack({name=ItemName, quality=ItemQuality})
								and wagon.get_inventory(defines.inventory.cargo_wagon).find_item_stack({name=ItemName, quality=ItemQuality}).item_number ~= nil) then
									local CloudStorage = game.create_inventory(1)
									local item, index = wagon.get_inventory(defines.inventory.cargo_wagon).find_item_stack({name=ItemName, quality=ItemQuality})
									CloudStorage.insert(item)
									item.clear()
									storage.FlyingItems[storage.FlightNumber].CloudStorage = CloudStorage
								end
								
								-- Ultracube irreplaceables detection & handling
								if storage.Ultracube and storage.Ultracube.prototypes.irreplaceable[ItemName] then -- Ultracube mod is active, and item is an irreplaceable
									-- Velocity calculation
									local velocity = {x=0,y=0}
									if storage.FlyingItems[storage.FlightNumber].AirTime >= 2 then
										local v1 = storage.FlyingItems[storage.FlightNumber].path[1]
										local v2 = storage.FlyingItems[storage.FlightNumber].path[2]
										velocity.x = v2.x - v1.x
										velocity.y = v2.y - v1.y
									end
									-- Sets cube_token_id and cube_should_hint for the new FlyingItems entry
									CubeFlyingItems.create_token_for(storage.FlyingItems[storage.FlightNumber], velocity)
								end

								storage.FlightNumber = storage.FlightNumber + 1
							end
							wagon.get_inventory(defines.inventory.cargo_wagon).remove({name = ItemName, count=LaunchedAmount, quality=ItemQuality})
						end
					end
				end
			end
			if (event.cause.train.schedule and event.cause.train.manual_mode == false) then
				local stor = event.cause.train.schedule
				if (event.cause.train.schedule.current == table_size(event.cause.train.schedule.records)) then
					stor.current = 1
				else
					stor.current = stor.current + 1
				end
				event.cause.train.schedule = stor
			end
		end

	--[[ elseif (event.entity.type == "character"
	and event.cause
	and (event.cause.type == "locomotive" or event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon" or event.cause.type == "artillery-wagon")
	) then
		CreateThrownItem(event.entity, event.entity.player, "wood", nil, event.entity.surface, {0,-1}) ]]

	elseif (event.entity.name == "RTTrainDetector") then
		local detector = event.entity
		-- toggle the trapdoor on the wagon if it was hit by a trapdoor wagon
		if (event.cause and event.cause.valid and event.cause.name == "RTTrapdoorWagon") then
			local DestroyNumber = script.register_on_object_destroyed(event.cause)
			-- properties.entity = the wagon entity
			-- properties.open = true/false
			-- properties.OpenIndicator = RenderObject
			if (storage.TrapdoorWagonsOpen[DestroyNumber] ~= nil) then
				storage.TrapdoorWagonsOpen[DestroyNumber].OpenIndicator.color = {r=1,g=0,b=0,a=1}
				storage.TrapdoorWagonsOpen[DestroyNumber].open = false
				storage.TrapdoorWagonsClosed[DestroyNumber], storage.TrapdoorWagonsOpen[DestroyNumber] = storage.TrapdoorWagonsOpen[DestroyNumber], nil
			elseif (storage.TrapdoorWagonsClosed[DestroyNumber] ~= nil) then
				storage.TrapdoorWagonsClosed[DestroyNumber].OpenIndicator.color = {r=0,g=1,b=0,a=1}
				storage.TrapdoorWagonsClosed[DestroyNumber].open = true
				storage.TrapdoorWagonsOpen[DestroyNumber], storage.TrapdoorWagonsClosed[DestroyNumber] = storage.TrapdoorWagonsClosed[DestroyNumber], nil
			end
			
		end
		-- start trying to res the detector
		local time = game.tick+1
		if (storage.clock[time] == nil) then
			storage.clock[time] = {}
		end
		if (storage.clock[time].rez == nil) then
			storage.clock[time].rez = {}
		end
		table.insert(storage.clock[time].rez, {name=detector.name, position=detector.position, force="neutral", surface=detector.surface})
		-- remove the now broken detector from the destruction link of its trigger
		local trigger = detector.surface.find_entities_filtered({name="RTTrapdoorTrigger", position=detector.position})[1]
		if (trigger) then
			storage.DestructionLinks[script.register_on_object_destroyed(trigger)] = {}
		end
	end
end

return entity_damaged
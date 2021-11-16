local function entity_damaged(event)
	--| Detect train hitting ramp
	if (
		(event.entity.name == "RTTrainRamp" or event.entity.name == "RTTrainRampNoSkip" or event.entity.name == "RTMagnetTrainRamp" or event.entity.name == "RTMagnetTrainRampNoSkip")
		and event.cause
		and (event.cause.type == "locomotive" or event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon" or event.cause.type == "artillery-wagon")
		and (math.abs(event.entity.orientation-event.cause.orientation) == 0.5
			or math.abs(event.entity.orientation-event.cause.orientation) == 0
			)
		and (event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0
			or event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0
			or event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0
			or event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0
			)
		) then

		event.entity.health = 99999999999

		SpookyGhost = event.entity.surface.create_entity
			({
				name = "RTPropCar",
				position = event.cause.position,
				force = event.cause.force
			})
		SpookyGhost.orientation = event.cause.orientation
		SpookyGhost.operable = false
		SpookyGhost.speed = 0.8*event.cause.speed
		SpookyGhost.destructible = false

		base = event.cause.name
		--mask = "NoMask"
		way = global.OrientationUnitComponents[event.cause.orientation].name

		if (game.is_valid_sprite_path("RT"..base..way)) then
			image = "RT"..base..way
		else
			image = "RT"..event.cause.type..way
		end

		if (game.is_valid_sprite_path("RT"..base.."Mask"..way)) then
			mask = "RT"..base.."Mask"..way
		else
			mask = "RTNoMask"
		end

		if (event.cause.type == "locomotive") then
			maskhue = {r = 234, g = 17, b = 0, a = 100}
		else
			maskhue = event.cause.color
		end

		if (event.cause.name == "RTPayloadWagon") then
			huehuehue = {220,125,0}
		else
			huehuehue = nil
		end

		TrainImage = rendering.draw_sprite
			{
			sprite = image,
			target = SpookyGhost,
			surface = SpookyGhost.surface,
			--x_scale = 0.5,
			--y_scale = 0.5,
			render_layer = "air-object",
			tint = huehuehue
			}
		Mask = rendering.draw_sprite
			{
			sprite = mask,
			tint =  maskhue,
			target = SpookyGhost,
			surface = SpookyGhost.surface,
			--x_scale = 0.5,
			--y_scale = 0.5,
			render_layer = "air-object"
			}
		OwTheEdge = rendering.draw_sprite
			{
			sprite = "GenericShadow",
			tint = {a = 90},
			target = SpookyGhost,
			surface = SpookyGhost.surface,
			orientation = event.cause.orientation,
			x_scale = 0.25,
			y_scale = 0.5,
			render_layer = "air-object"
			}

		global.FlyingTrains[SpookyGhost.unit_number] = {}
		global.FlyingTrains[SpookyGhost.unit_number].GuideCar = SpookyGhost
		if (event.cause.get_driver() ~= nil) then
			global.FlyingTrains[SpookyGhost.unit_number].passenger = event.cause.get_driver()
			SpookyGhost.set_passenger(event.cause.get_driver())
		end
		global.FlyingTrains[SpookyGhost.unit_number].name = event.cause.name
		global.FlyingTrains[SpookyGhost.unit_number].type = event.cause.type
		global.FlyingTrains[SpookyGhost.unit_number].LaunchTick = game.tick
		if ((event.entity.name == "RTMagnetTrainRamp" or event.entity.name == "RTMagnetTrainRampNoSkip") and global.MagnetRamps[event.entity.unit_number].range ~= nil and global.MagnetRamps[event.entity.unit_number].power.energy/global.MagnetRamps[event.entity.unit_number].power.electric_buffer_size >= 0.95) then
			global.FlyingTrains[SpookyGhost.unit_number].LandTick = math.ceil(game.tick + math.abs(global.MagnetRamps[event.entity.unit_number].range/(0.8*event.cause.speed)))
			global.FlyingTrains[SpookyGhost.unit_number].MagnetComp = math.ceil(game.tick + 130*math.abs(event.cause.speed))-global.FlyingTrains[SpookyGhost.unit_number].LandTick
			global.FlyingTrains[SpookyGhost.unit_number].MakeFX = "yes"
			--game.print("power")

		elseif ((event.entity.name == "RTMagnetTrainRamp" or event.entity.name == "RTMagnetTrainRampNoSkip") and global.MagnetRamps[event.entity.unit_number].range ~= nil and global.MagnetRamps[event.entity.unit_number].power.energy/global.MagnetRamps[event.entity.unit_number].power.electric_buffer_size < 0.95) then
			global.FlyingTrains[SpookyGhost.unit_number].MakeFX = "NoEnergy"
			--game.print("no power")
			global.FlyingTrains[SpookyGhost.unit_number].LandTick = math.ceil(game.tick + 130*math.abs(event.cause.speed))

		else
			global.FlyingTrains[SpookyGhost.unit_number].LandTick = math.ceil(game.tick + 130*math.abs(event.cause.speed)) -- remember to adjust follower calculation too
		end



		global.FlyingTrains[SpookyGhost.unit_number].AirTime = global.FlyingTrains[SpookyGhost.unit_number].LandTick - global.FlyingTrains[SpookyGhost.unit_number].LaunchTick
		--game.print(global.FlyingTrains[SpookyGhost.unit_number].AirTime)
		global.FlyingTrains[SpookyGhost.unit_number].TrainImageID = TrainImage
		global.FlyingTrains[SpookyGhost.unit_number].MaskID = Mask
		global.FlyingTrains[SpookyGhost.unit_number].speed = event.cause.speed
		global.FlyingTrains[SpookyGhost.unit_number].SpecialName = event.cause.backer_name
		global.FlyingTrains[SpookyGhost.unit_number].color = event.cause.color or {r = 234, g = 17, b = 0, a = 100}
		global.FlyingTrains[SpookyGhost.unit_number].orientation = event.cause.orientation
		global.FlyingTrains[SpookyGhost.unit_number].RampOrientation = event.entity.orientation
		global.FlyingTrains[SpookyGhost.unit_number].ShadowID = OwTheEdge
		global.FlyingTrains[SpookyGhost.unit_number].ManualMode = event.cause.train.manual_mode
		global.FlyingTrains[SpookyGhost.unit_number].length = #event.cause.train.carriages
		global.FlyingTrains[SpookyGhost.unit_number].destinationStation = event.cause.train.path_end_stop
		global.FlyingTrains[SpookyGhost.unit_number].adjustDestinationLimit = event.cause.train.path_end_stop -- manual trains don't have this, it will be nill

		if (global.FlyingTrains[SpookyGhost.unit_number].adjustDestinationLimit and event.cause.train.path_end_stop.trains_limit > 0 and event.cause.train.path_end_stop.trains_limit < 4294967295) then -- apparently 4294967295 means train limit is disabled
			-- Artifically reserve the station by decrementing the available blocks
			event.cause.train.path_end_stop.trains_limit = event.cause.train.path_end_stop.trains_limit - 1
		end

		for number, properties in pairs(global.FlyingTrains) do -- carriages jumping before the ends land
			if (properties.LandedTrain ~= nil and properties.LandedTrain.valid and event.cause.unit_number == properties.LandedTrain.unit_number) then
				global.FlyingTrains[SpookyGhost.unit_number].ManualMode = properties.ManualMode
				global.FlyingTrains[SpookyGhost.unit_number].length = properties.length
			end
		end

		if (event.entity.orientation == 0) then --ramp down
			SearchBox =
				{
					{event.cause.position.x-1,event.cause.position.y-6},
					{event.cause.position.x+1,event.cause.position.y-4}
				}
		elseif (event.entity.orientation == 0.25) then -- ramp left
			SearchBox =
				{
					{event.cause.position.x+4,event.cause.position.y-1},
					{event.cause.position.x+6,event.cause.position.y+1}
				}
		elseif (event.entity.orientation == 0.50) then -- ramp up
			SearchBox =
				{
					{event.cause.position.x-1,event.cause.position.y+4},
					{event.cause.position.x+1,event.cause.position.y+6}
				}
		elseif (event.entity.orientation == 0.75) then -- ramp right
			SearchBox =
				{
					{event.cause.position.x-6,event.cause.position.y-1},
					{event.cause.position.x-4,event.cause.position.y+1}
				}
		end
		global.FlyingTrains[SpookyGhost.unit_number].follower = SpookyGhost.surface.find_entities_filtered
			{
			area = SearchBox,
			type = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"},
			limit = 1
			}[1]

		-- if (global.FlyingTrains[SpookyGhost.unit_number].follower ~= nil) then
		-- rendering.draw_circle
			-- {
			-- color = {r = 234, g = 17, b = 0, a = 100},
			-- radius = 1,
			-- filled = true,
			-- target = global.FlyingTrains[SpookyGhost.unit_number].follower,
			-- surface = SpookyGhost.surface
			-- }
		-- end

		global.FlyingTrains[SpookyGhost.unit_number].schedule = event.cause.train.schedule
		if ((event.entity.name == "RTTrainRamp" or event.entity.name == "RTMagnetTrainRamp") and global.FlyingTrains[SpookyGhost.unit_number].schedule ~= nil) then
			if (global.FlyingTrains[SpookyGhost.unit_number].schedule.current == table_size(global.FlyingTrains[SpookyGhost.unit_number].schedule.records)) then
			global.FlyingTrains[SpookyGhost.unit_number].schedule.current = 1
			else
			global.FlyingTrains[SpookyGhost.unit_number].schedule.current = global.FlyingTrains[SpookyGhost.unit_number].schedule.current+1
			end
		end

		--| Follower/leader tracking
		for number, properties in pairs(global.FlyingTrains) do
			if (properties.follower and properties.follower.valid and event.cause.unit_number == properties.follower.unit_number) then
				global.FlyingTrains[SpookyGhost.unit_number].leader = number
				global.FlyingTrains[number].followerID = SpookyGhost.unit_number
				global.FlyingTrains[SpookyGhost.unit_number].schedule = global.FlyingTrains[number].schedule
				global.FlyingTrains[SpookyGhost.unit_number].ManualMode = global.FlyingTrains[number].ManualMode
				if ((event.entity.name == "RTMagnetTrainRamp" or event.entity.name == "RTMagnetTrainRampNoSkip") and global.FlyingTrains[number].MagnetComp ~= nil and (global.FlyingTrains[number].MakeFX == "yes" or global.FlyingTrains[number].MakeFX == "followerY")) then
					global.FlyingTrains[SpookyGhost.unit_number].LandTick = math.ceil(game.tick + math.abs(global.MagnetRamps[event.entity.unit_number].range/(0.8*event.cause.speed)))
					global.FlyingTrains[SpookyGhost.unit_number].MagnetComp = global.FlyingTrains[number].MagnetComp
					global.FlyingTrains[SpookyGhost.unit_number].MakeFX = "followerY"
				else
					global.FlyingTrains[SpookyGhost.unit_number].LandTick = math.ceil(game.tick + 130*math.abs(global.FlyingTrains[number].speed))
					global.FlyingTrains[SpookyGhost.unit_number].MagnetComp = nil
					global.FlyingTrains[SpookyGhost.unit_number].MakeFX = "followerN"
				end

				global.FlyingTrains[SpookyGhost.unit_number].AirTime = global.FlyingTrains[number].AirTime
				global.FlyingTrains[SpookyGhost.unit_number].length = global.FlyingTrains[number].length
				if (global.FlyingTrains[SpookyGhost.unit_number].speed>0) then
					SpookyGhost.speed = 0.8*math.abs(global.FlyingTrains[number].speed)
					global.FlyingTrains[SpookyGhost.unit_number].speed = math.abs(global.FlyingTrains[number].speed)
				else
					SpookyGhost.speed = -0.8*math.abs(global.FlyingTrains[number].speed)
					global.FlyingTrains[SpookyGhost.unit_number].speed = -math.abs(global.FlyingTrains[number].speed)
				end

			end
		end

		if ((event.entity.name == "RTMagnetTrainRamp" or event.entity.name == "RTMagnetTrainRampNoSkip") and global.MagnetRamps[event.entity.unit_number].range ~= nil and global.FlyingTrains[SpookyGhost.unit_number].MakeFX == "yes") then
			global.MagnetRamps[event.entity.unit_number].power.energy = 0
			if (global.FlyingTrains[SpookyGhost.unit_number].MagnetComp < 0) then
				polarity = "RTPush"
				vroom = 0.75
				shade = {r = 1, g = 0.2, b = 0.2, a = 0}
			else
				polarity = "RTPull"
				vroom = 0.75
				shade = {r = 0.4, g = 0.4, b = 1, a = 0}
			end

			for each, railtile in pairs(global.MagnetRamps[event.entity.unit_number].tiles) do
				rendering.draw_animation
					{
						animation = polarity,
						target = railtile,
						target_offset = {0,-1.65},
						animation_speed = vroom,
						animation_offset = math.random(0,99),
						tint = shade,
						surface = event.entity.surface,
						x_scale = 0.3,
						y_scale = 0.8,
						time_to_live = global.FlyingTrains[SpookyGhost.unit_number].AirTime+((5.9*global.FlyingTrains[SpookyGhost.unit_number].length)/(0.8*event.cause.speed))
					}
			end

		elseif ((event.entity.name == "RTMagnetTrainRamp" or event.entity.name == "RTMagnetTrainRampNoSkip") and global.MagnetRamps[event.entity.unit_number].range ~= nil and global.FlyingTrains[SpookyGhost.unit_number].MakeFX == "NoEnergy") then
			for each, guy in pairs(game.connected_players) do
				guy.add_custom_alert(global.MagnetRamps[event.entity.unit_number].entity, {type = "item", name = "RTMagnetTrainRampItem"}, "A Magnet Ramp was used without a full buffer!", true)
			end

		end

		if (event.cause.type == "locomotive" and event.cause.burner) then
			if (global.About2Jump[event.cause.unit_number] ~= nil) then
				global.FlyingTrains[SpookyGhost.unit_number].CurrentlyBurning = global.About2Jump[event.cause.unit_number].BurningFuel
				global.About2Jump[event.cause.unit_number] = nil
			else
				global.FlyingTrains[SpookyGhost.unit_number].CurrentlyBurning = event.cause.burner.currently_burning
			end
			global.FlyingTrains[SpookyGhost.unit_number].RemainingFuel = event.cause.burner.remaining_burning_fuel
			global.FlyingTrains[SpookyGhost.unit_number].FuelInventory = event.cause.get_fuel_inventory().get_contents()
		elseif (event.cause.type == "cargo-wagon") then
			global.FlyingTrains[SpookyGhost.unit_number].cargo = event.cause.get_inventory(defines.inventory.cargo_wagon).get_contents()
			global.FlyingTrains[SpookyGhost.unit_number].bar = event.cause.get_inventory(defines.inventory.cargo_wagon).get_bar()
			global.FlyingTrains[SpookyGhost.unit_number].filter = {}
			for i = 1, #event.cause.get_inventory(defines.inventory.cargo_wagon) do
				global.FlyingTrains[SpookyGhost.unit_number].filter[i] = event.cause.get_inventory(defines.inventory.cargo_wagon).get_filter(i)
			end
		elseif (event.cause.type == "fluid-wagon") then
			global.FlyingTrains[SpookyGhost.unit_number].fluids = event.cause.get_fluid_contents()
		elseif (event.cause.type == "artillery-wagon") then
			global.FlyingTrains[SpookyGhost.unit_number].artillery = event.cause.get_inventory(defines.inventory.artillery_wagon_ammo).get_contents()
		end

		if (global.FlyingTrains[SpookyGhost.unit_number].leader == nil) then
			for each, carriage in pairs(event.cause.train.carriages) do
				if (carriage.burner) then
					global.About2Jump[carriage.unit_number] = {}
					global.About2Jump[carriage.unit_number].BurningFuel = carriage.burner.currently_burning
					carriage.burner.currently_burning = game.item_prototypes[global.FastestFuel]
				end
			end
		end

		if (event.cause.grid ~= nil) then
			global.FlyingTrains[SpookyGhost.unit_number].gridd = {}
			for j = 0, event.cause.grid.height-1 do
				for i = 0, event.cause.grid.width-1 do
					if (event.cause.grid.get({i,j})) then
						table.insert(global.FlyingTrains[SpookyGhost.unit_number].gridd, {xpos = i, ypos = j, EquipName = event.cause.grid.get({i,j}).name})
					end
				end
			end
		end

		if remote.interfaces.VehicleWagon2 and remote.interfaces.VehicleWagon2.get_wagon_data then
		  global.savedVehicleWagons[event.cause.unit_number] = remote.call("VehicleWagon2", "get_wagon_data", event.cause) -- returns nil if not a vehicle wagon
		  global.FlyingTrains[SpookyGhost.unit_number].WagonUnitNumber = event.cause.unit_number
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
					for ItemName, amount in pairs(wagon.get_inventory(defines.inventory.cargo_wagon).get_contents()) do
						local LaunchedAmount = math.floor(amount*LaunchedPortion)
						if (LaunchedAmount > 0) then
							local GroupSize = math.ceil((LaunchedAmount*wagons)/settings.global["RTImpactGrouping"].value)
							for i = 1, math.floor(LaunchedAmount/GroupSize) do
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
								local	x = wagon.position.x + (ForwardSpread*wagon.speed*xUnit) + (HorizontalSpread*wagon.speed*yUnit)
								local y = wagon.position.y + (ForwardSpread*wagon.speed*yUnit) + (HorizontalSpread*wagon.speed*xUnit)
								local distance = math.sqrt((x-wagon.position.x)^2 + (y-wagon.position.y)^2)
								local speed = math.abs(wagon.speed) * (distance/(35*math.abs(wagon.speed))) * math.random(45,100)*0.01
								local arc = -(0.3236*distance^-0.404) -- lower number is higher arc
								local AirTime = math.floor(distance/speed)
								local vector = {x=x-wagon.position.x, y=y-wagon.position.y}
								local spin = math.random(-10,10)*0.01
								global.FlyingItems[global.FlightNumber] = {sprite=sprite, shadow=shadow, speed=speed, arc=arc, spin=spin, item=ItemName, amount=GroupSize, target={x=x, y=y}, start={x=wagon.position.x+(math.random(-10, 10)*0.1), y=wagon.position.y+(math.random(-10, 10)*0.1)}, AirTime=AirTime, StartTick=game.tick, LandTick=game.tick+AirTime, vector=vector}
								global.FlightNumber = global.FlightNumber + 1
							end
							if (LaunchedAmount%GroupSize ~= 0) then
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
								local	x = wagon.position.x + (ForwardSpread*wagon.speed*xUnit) + (HorizontalSpread*wagon.speed*yUnit)
								local y = wagon.position.y + (ForwardSpread*wagon.speed*yUnit) + (HorizontalSpread*wagon.speed*xUnit)
								local distance = math.sqrt((x-wagon.position.x)^2 + (y-wagon.position.y)^2)
								local speed = math.abs(wagon.speed) * (distance/(35*math.abs(wagon.speed))) * math.random(45,100)*0.01
								local arc = -(0.3236*distance^-0.404) -- lower number is higher arc
								local AirTime = math.floor(distance/speed)
								local vector = {x=x-wagon.position.x, y=y-wagon.position.y}
								local spin = math.random(-10,10)*0.01
								global.FlyingItems[global.FlightNumber] = {sprite=sprite, shadow=shadow, speed=speed, arc=arc, spin=spin, item=ItemName, amount=LaunchedAmount%GroupSize, target={x=x, y=y}, start={x=wagon.position.x+(math.random(-10, 10)*0.1), y=wagon.position.y+(math.random(-10, 10)*0.1)}, AirTime=AirTime, StartTick=game.tick, LandTick=game.tick+AirTime, vector=vector}
								global.FlightNumber = global.FlightNumber + 1
							end
							wagon.get_inventory(defines.inventory.cargo_wagon).remove({name = ItemName, count=LaunchedAmount})
						end
					end
					--wagon.get_inventory(defines.inventory.cargo_wagon).clear()
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
			event.cause.health = event.cause.health - (event.cause.prototype.max_health/8)
			if (event.cause.health <= 0) then
				event.cause.die()
			end
		end
	end
end

return entity_damaged

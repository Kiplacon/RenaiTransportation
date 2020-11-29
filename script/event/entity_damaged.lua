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

		base = event.cause.type
		mask = "NoMask"
		way = global.OrientationUnitComponents[event.cause.orientation].name
		huehuehue = nil
		
		if (event.cause.type == "locomotive") then
			mask = "locomotiveMask"..way
		elseif (event.cause.name == "RTPayloadWagon") then
			huehuehue = {220,125,0}
		--elseif (event.cause.type == "cargo-wagon") then
		--elseif (event.cause.type == "fluid-wagon") then
		--elseif (event.cause.type == "artillery-wagon") then
		end

		TrainImage = rendering.draw_sprite
			{
			sprite = "RT"..base..way,
			target = SpookyGhost,
			surface = SpookyGhost.surface,
			x_scale = 0.5,
			y_scale = 0.5,
			render_layer = "air-object",
			tint = huehuehue
			}
		Mask = rendering.draw_sprite
			{
			sprite = "RT"..mask,
			tint = event.cause.color or {r = 234, g = 17, b = 0, a = 100},
			target = SpookyGhost,
			surface = SpookyGhost.surface,
			x_scale = 0.5,
			y_scale = 0.5,
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
			global.FlyingTrains[SpookyGhost.unit_number].CurrentlyBurning = event.cause.burner.currently_burning
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

		event.cause.destroy({ raise_destroy = true })
	end
end

return entity_damaged

local Animation = require("animation")

local temporaryPathingCondition = {
	type = "item_count",
	compare_type = "and",
	condition = {
		comparator = "=",
	  	first_signal = {type="item", name="RTPropCarItem" },
		constant = 69
	}
}

local function reEnableSchedule(train, schedule, destinationStation)
	schedule = table.deepcopy(schedule)
	if (destinationStation and destinationStation.valid and destinationStation.trains_limit and destinationStation.connected_rail) then
		tempStation = {
			rail = destinationStation.connected_rail,
			wait_conditions = { temporaryPathingCondition },
			temporary = true
		}

		table.insert(schedule.records, schedule.current, tempStation)
		train.schedule = schedule
	else
		-- set the schedule but don't enable it
		train.schedule = schedule
	end
end

local function finalizeLandedTrain(PropUnitNumber, properties)
	-- undo station reservation
	if properties.adjustDestinationLimit then
		properties.destinationStation.trains_limit = properties.destinationStation.trains_limit + 1
	end

	-- Remove temporary pathing station, if present
	local schedule = properties.LandedTrain.train.schedule
	if schedule and schedule.current then
		local dst = schedule.records[schedule.current]

		if dst and dst.wait_conditions then
			local firstWaitCond = dst.wait_conditions[1]

			if firstWaitCond.condition and firstWaitCond.condition.first_signal and firstWaitCond.condition.first_signal.name == 'RTPropCarItem' then
				local newSchedule = table.deepcopy(schedule)
				table.remove(newSchedule.records, newSchedule.current)
				properties.LandedTrain.train.schedule = newSchedule
				properties.LandedTrain.train.go_to_station(newSchedule.current)
			end
		end
	end

	global.FlyingTrains[PropUnitNumber] = nil
end

local function on_tick(event)
	--| Trains
	----------------- train flight ----------------
	for PropUnitNumber, properties in pairs(global.FlyingTrains) do

		if (properties.GuideCar and properties.GuideCar.valid) then
			properties.GuideCar.destructible = false
		end

		--|| Follower speed comp
		if (properties.follower and properties.follower.valid) then
			if (properties.follower.train.speed>0) then
				properties.follower.train.speed = math.abs(properties.speed)
			elseif (properties.follower.train.speed<=0) then
				properties.follower.train.speed = -math.abs(properties.speed)
			end
		end

		--|| Landing
		if (game.tick == properties.LandTick) then
			--||| Bounce Pad
			TrainLandedOn = properties.GuideCar.surface.find_entities_filtered
				{
					name = {"RTTrainBouncePlate", "RTTrainDirectedBouncePlate"},
					position = properties.GuideCar.position,
					radius = 1.5,
					collision_mask = "object-layer"
				}[1] -- in theory only one thing should be detected in the object layer this way
			if (TrainLandedOn ~= nil and TrainLandedOn.name == "RTTrainBouncePlate") then
				properties.LaunchTick = game.tick
				properties.LandTick = math.ceil(game.tick + 130*math.abs(properties.speed))
				properties.GuideCar.teleport(TrainLandedOn.position)
				TrainLandedOn.surface.create_particle
					({
					name = "RTTrainBouncePlateParticle",
					position = TrainLandedOn.position,
					movement = {0,0},
					height = 0,
					vertical_speed = 0.2,
					frame_speed = 1
					})
				TrainLandedOn.surface.play_sound
					{
						path = "bounce",
						position = TrainLandedOn.position,
						volume = 2
					}

			elseif (TrainLandedOn ~= nil and TrainLandedOn.name == "RTTrainDirectedBouncePlate") then
				properties.GuideCar.teleport(TrainLandedOn.position)
				properties.RampOrientation = TrainLandedOn.orientation+0.5
				if (properties.GuideCar.speed > 0) then
					properties.GuideCar.orientation = TrainLandedOn.orientation
					properties.orientation = TrainLandedOn.orientation
				elseif (properties.GuideCar.speed < 0) then
					properties.GuideCar.orientation = TrainLandedOn.orientation+0.5
					properties.orientation = TrainLandedOn.orientation+0.5
				end

				if (properties.orientation >= 1) then
					properties.orientation = properties.orientation-1
				end
				if (properties.RampOrientation >= 1) then
					properties.RampOrientation = properties.RampOrientation-1
				end

				base = properties.type
				mask = "NoMask"
				way = global.OrientationUnitComponents[properties.orientation].name
				if (base == "locomotive") then
					mask = "locomotiveMask"..way
				--elseif (base == "cargo-wagon") then
				--elseif (base == "fluid-wagon") then
				--elseif (base == "artillery-wagon") then
				end
				rendering.destroy(properties.TrainImageID)
				rendering.destroy(properties.MaskID)
				rendering.destroy(properties.ShadowID)
				properties.TrainImageID = rendering.draw_sprite
					{
					sprite = "RT"..base..way,
					target = properties.GuideCar,
					surface = properties.GuideCar.surface,
					x_scale = 0.5,
					y_scale = 0.5,
					render_layer = "air-object"
					}
				properties.MaskID = rendering.draw_sprite
					{
					sprite = "RT"..mask,
					tint = properties.color or {r = 234, g = 17, b = 0, a = 100},
					target = properties.GuideCar,
					surface = properties.GuideCar.surface,
					x_scale = 0.5,
					y_scale = 0.5,
					render_layer = "air-object"
					}
				properties.ShadowID = rendering.draw_sprite
					{
					sprite = "GenericShadow",
					tint = {a = 90},
					target = properties.GuideCar,
					surface = properties.GuideCar.surface,
					orientation = properties.orientation,
					x_scale = 0.25,
					y_scale = 0.4,
					render_layer = "air-object"
					}

				properties.LaunchTick = game.tick
				properties.LandTick = math.ceil(game.tick + 130*math.abs(properties.speed))
				TrainLandedOn.surface.create_particle
					({
					name = "RTTrainBouncePlateParticle",
					position = TrainLandedOn.position,
					movement = {0,0},
					height = 0,
					vertical_speed = 0.2,
					frame_speed = 1
					})
				TrainLandedOn.surface.play_sound
					{
						path = "bounce",
						position = TrainLandedOn.position,
						volume = 2
					}

			--||| Try to reform train
			else
				NewTrain = properties.GuideCar.surface.create_entity
					({
						name = properties.name,
						position = properties.GuideCar.position,
						direction = properties.orientation, -- i think this does nothing
						force = properties.GuideCar.force,
						raise_built = true
					})
				global.FlyingTrains[PropUnitNumber].LandedTrain = NewTrain
				--|||| Success
				if (NewTrain ~= nil) then
					if (properties.passenger ~= nil) then
						if (properties.passenger.is_player()) then
							NewTrain.set_driver(properties.passenger)
						else
							NewTrain.set_driver(properties.passenger.player)
						end
					end

					AngleChange = math.abs(NewTrain.orientation-properties.orientation) -- a new train will be made if there's enough rail, direction doesn't matter
					if (AngleChange > 0.5) then
						AngleChange = 1 - AngleChange
					end
					if (AngleChange <= 0.125) then
					-- it's good
					elseif (AngleChange >= 0.375) then
						NewTrain.disconnect_rolling_stock(defines.rail_direction.front)
						NewTrain.disconnect_rolling_stock(defines.rail_direction.back)
						NewTrain.rotate()
						NewTrain.connect_rolling_stock(defines.rail_direction.front)
						NewTrain.connect_rolling_stock(defines.rail_direction.back)
					else -- AngleChange is between 0.125 and 0.375, which is a rail ~90 degrees off from original launch. doesn't make sense so destroy
						NewTrain.die()
						for urmum, lol in pairs(properties.GuideCar.surface.find_entities_filtered({position = properties.GuideCar.position, radius = 7})) do
							if (lol.valid and lol.is_entity_with_health == true and lol.health ~= nil) then
								lol.damage(1000, "neutral", "explosion")
							elseif (lol.valid and lol.name == "cliff") then
								lol.destroy({do_cliff_correction = true, raise_destroy = true})
							end
						end
					end

					if (NewTrain.valid) then
						if properties.leader == nil and NewTrain.type ~= "locomotive" then
							local bb = NewTrain.prototype.collision_box
							local length = bb.right_bottom.y - bb.left_top.y

							length = length + 3 -- Add connection distance

							local delta = {x = 0, y = 0}
							local direction

							-- Face the loco the direction the ramp is facing and
							-- calculate its offset (down and to the right are positive)
							if (properties.RampOrientation == 0) then
								direction = defines.direction.south
								delta.y = length
							elseif (properties.RampOrientation == 0.25) then
								direction = defines.direction.west
								delta.x = -length
							elseif (properties.RampOrientation == 0.50) then
								direction = defines.direction.north
								delta.y = -length
							elseif (properties.RampOrientation == 0.75) then
								direction = defines.direction.east
								delta.x = length
							end

							-- game.print("Creating ghost loco offset by " .. serpent.block(delta) .. " direction " .. direction)

							-- if it fails, that means there's a problem that the train is about to hit
							-- so don't worry about it
							local ghostLoco = NewTrain.surface.create_entity
							({
								name = 'RT-ghostLocomotive',
								position = {x = NewTrain.position.x + delta.x, y = NewTrain.position.y + delta.y},
								direction = direction,
								force = NewTrain.force,
								raise_built = false
							})

						elseif NewTrain.type == 'locomotive' then
							for _, stock in pairs(NewTrain.train.carriages) do
								if stock.name == 'RT-ghostLocomotive' then stock.destroy() end
							end
						end

						-- this order of setting speed -> manual mode -> schedule is very important, other orders mess up a lot more

						if (properties.leader == nil) then
							if ((properties.ghostLoco ~= nil and properties.ghostLoco.valid == true and properties.RampOrientation == properties.ghostLoco.orientation)
							or (properties.RampOrientation == properties.orientation))then
								NewTrain.train.speed = -math.abs(properties.speed)
							else
								NewTrain.train.speed = math.abs(properties.speed)
							end
						else
							if (NewTrain.train.speed>=0) then
								NewTrain.train.speed = math.abs(properties.speed)
							else
								NewTrain.train.speed = -math.abs(properties.speed)
							end
						end

						if (
							(properties.leader == nil) or
							(properties.follower == nil and properties.length == #NewTrain.train.carriages) or
							(#NewTrain.train.locomotives.front_movers > 0 and NewTrain.train.speed > 0) or
							(#NewTrain.train.locomotives.back_movers > 0 and NewTrain.train.speed < 0)
						) then
							NewTrain.train.manual_mode = properties.ManualMode -- Trains are default created in manual mode
						end

						if (NewTrain.train.schedule == nil and properties.schedule ~= nil) then
							reEnableSchedule(NewTrain.train, properties.schedule, properties.destinationStation)
						end

						if (properties.gridd ~= nil and NewTrain.grid ~= nil) then
							for each, equip in pairs(properties.gridd) do
								NewTrain.grid.put
									{
										name = equip.EquipName,
										position = {equip.xpos, equip.ypos}
									}
							end
						end

						if (NewTrain.type == "locomotive") then
							NewTrain.color = properties.color
							NewTrain.backer_name = properties.SpecialName
							if (NewTrain.burner) then
								NewTrain.burner.currently_burning = properties.CurrentlyBurning
								NewTrain.burner.remaining_burning_fuel = properties.RemainingFuel
								for FuelName, quantity in pairs(properties.FuelInventory) do
									NewTrain.get_fuel_inventory().insert({name = FuelName, count = quantity})
								end
							end
						elseif (NewTrain.type == "cargo-wagon") then
							NewTrain.get_inventory(defines.inventory.cargo_wagon).set_bar(properties.bar)
							for i, filter in pairs(properties.filter) do
								NewTrain.get_inventory(defines.inventory.cargo_wagon).set_filter(i, filter)
							end
							for ItemName, quantity in pairs(properties.cargo) do
								NewTrain.get_inventory(defines.inventory.cargo_wagon).insert({name = ItemName, count = quantity})
							end
						elseif (NewTrain.type == "fluid-wagon") then
							for FluidName, quantity in pairs(properties.fluids) do
								NewTrain.insert_fluid({name = FluidName, amount = quantity})
							end
						elseif (NewTrain.type == "artillery-wagon") then
							for ItemName, quantity in pairs(properties.artillery) do
								NewTrain.get_inventory(defines.inventory.artillery_wagon_ammo).insert({name = ItemName, count = quantity})
							end
						end
					end
					properties.GuideCar.destroy()

				--|||| Failure
				else
					if (properties.GuideCar.surface.find_tiles_filtered{position = properties.GuideCar.position, radius = 1, limit = 1, collision_mask = "player-layer"}[1] == nil) then
						properties.GuideCar.surface.create_entity
							({
								name = "big-scorchmark",
								position = properties.GuideCar.position
							})
					end

					local key, value = next(game.entity_prototypes[properties.name].corpses)
					rip = properties.GuideCar.surface.create_entity
						({
							name = key or "locomotive-remnants",
							position = properties.GuideCar.position,
							force = properties.GuideCar.force
						})
					rip.color = properties.color
					rip.orientation = properties.orientation

					boom = properties.GuideCar.surface.create_entity
						({
							name = "locomotive-explosion",
							position = properties.GuideCar.position
						})

					for each, guy in pairs(game.connected_players) do
						guy.add_alert(rip,defines.alert_type.entity_destroyed)
					end

					for urmum, lol in pairs(boom.surface.find_entities_filtered({position = boom.position, radius = 7})) do
						if (lol.valid and lol.train ~= nil) then
							-- destroy ghost locos just to be safe
							for _, stock in pairs(lol.train.carriages) do
								if stock.name == 'RT-ghostLocomotive' then stock.destroy() end
							end
						end
						if (lol.valid and lol.is_entity_with_health == true and lol.health ~= nil) then
							lol.damage(1000, "neutral", "explosion")
						elseif (lol.valid and lol.name == "cliff") then
							lol.destroy({do_cliff_correction = true,  raise_destroy = true})
						end
					end
					
					if (properties.name == "RTPayloadWagon") then
						if (properties.cargo["explosives"] ~= nil) then
							CrashSpread = 100 + 2*properties.cargo["explosives"]
						else
							CrashSpread = 100
						end
						for ItemName, quantity in pairs(properties.cargo) do
							if (game.entity_prototypes[ItemName.."-projectileFromRenaiTransportationPrimed"]) then
								if (quantity > game.item_prototypes[ItemName].stack_size) then
									quantity = game.item_prototypes[ItemName].stack_size
								end
								if (CrashSpread > 400) then
									CrashSpread = 400
								end								
								for i = 1, quantity do
									local xshift = math.random(-CrashSpread,CrashSpread)/10
									local yshift = math.random(-math.sqrt((CrashSpread^2)-(xshift*10)^2),math.sqrt((CrashSpread^2)-(xshift*10)^2))/10								
										properties.GuideCar.surface.create_entity
											({
											name = ItemName.."-projectileFromRenaiTransportationPrimed",
											position = properties.GuideCar.position, --required setting for rendering, doesn't affect spawn
											source_position = properties.GuideCar.position,
											target_position = {properties.GuideCar.position.x + xshift, properties.GuideCar.position.y + yshift},
											force = properties.GuideCar.force
											})		
								end
							end
						end					
					end
					
					properties.GuideCar.destroy()
					--global.FlyingTrains[PropUnitNumber] = nil

				end
			end
		--|| Animating Train
		elseif (game.tick < properties.LandTick) then
			Animation.updateRendering(properties)

		--|| Landing speed control
		elseif (game.tick > properties.LandTick and properties.LandedTrain and properties.LandedTrain.valid) then
			if (properties.follower and properties.followerID and global.FlyingTrains[properties.followerID] and global.FlyingTrains[properties.followerID].LandedTrain == nil) then
				--game.print("not all here")
				if (properties.LandedTrain.train.speed>0) then
					properties.LandedTrain.train.speed = math.abs(properties.speed)
				elseif (properties.LandedTrain.train.speed<0) then
					properties.LandedTrain.train.speed = -math.abs(properties.speed)
				else
				end
			elseif (#properties.LandedTrain.train.carriages == properties.length or game.tick > properties.LandTick+300) then
				--game.print("all here")
				finalizeLandedTrain(PropUnitNumber, properties)
			end

		-- elseif (game.tick > properties.LandTick and properties.follower and properties.LandedTrain and properties.LandedTrain.valid) then
			-- if (#properties.LandedTrain.train.carriages ~= properties.length) then
				-- --game.print("not all here")
				-- if (properties.LandedTrain.train.speed>0) then
					-- properties.LandedTrain.train.speed = math.abs(properties.speed)
				-- elseif (properties.LandedTrain.train.speed<0) then
					-- properties.LandedTrain.train.speed = -math.abs(properties.speed)
				-- else
				-- end
			-- elseif (#properties.LandedTrain.train.carriages == properties.length or game.tick > properties.LandTick+240) then
				-- --game.print("all here")
				-- global.FlyingTrains[PropUnitNumber] = nil
			-- end

		elseif (game.tick > properties.LandTick) then -- for any trains already in the air when the speed control update was released or other catch all failsafes
			finalizeLandedTrain(PropUnitNumber, properties)
		end
	end
end

return on_tick

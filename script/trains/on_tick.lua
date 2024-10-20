if script.active_mods["Ultracube"] then CubeFlyingTrains = require("script.ultracube.cube_flying_trains") end

local Animation = require("animation")

local temporaryPathingCondition = {
	type = "item_count",
	compare_type = "and",
	condition = {
		comparator = "=",
	  	first_signal = {type="item", name="RTPropCarItem" },
		constant = 69 -- nice
	}
}

local function reEnableSchedule(train, schedule, destinationStation, properties) -- happens for the first carriage
	schedule = table.deepcopy(schedule)
	-- first landed gets new schedule, check stop, if it has a limit, add the temp
	-- at last carriage to land, if the stop limit was reduced, increase it again. Then delete temp and route to end or vice versa
	if (destinationStation and destinationStation.valid and destinationStation.trains_limit ~= 4294967295 and destinationStation.connected_rail) then -- NoSkip ramp pathing to a station with a train limit
		tempStation = {
			rail = destinationStation.connected_rail,
			wait_conditions = { temporaryPathingCondition },
			temporary = true
		}
		table.insert(schedule.records, schedule.current, tempStation)
		train.schedule = schedule
	else
		train.schedule = schedule
		if (train.path_end_stop and train.path_end_stop.valid and train.path_end_stop.trains_limit ~= 4294967295 and train.path_end_stop.connected_rail) then
			tempStation = {
				rail = train.path_end_stop.connected_rail,
				wait_conditions = { temporaryPathingCondition },
				temporary = true
			}
			local newSchedule = table.deepcopy(train.schedule)
			table.insert(newSchedule.records, newSchedule.current, tempStation)
			train.schedule = newSchedule
		end
	end
end

local function finalizeLandedTrain(PropUnitNumber, properties) -- happens when the last carriage of a train lands
	if (properties.adjustDestinationLimit and properties.destinationStation and properties.destinationStation.valid) then -- happens after a non-skip jump
		--game.print("has adjust data")
		if (properties.destinationStation.trains_limit == 4294967295) then -- train limits not used
			-- do nothing
		else
			properties.destinationStation.trains_limit = properties.destinationStation.trains_limit + 1
		end
	end

	if properties.LandedTrain and properties.LandedTrain.valid then
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
	end

	storage.FlyingTrains[PropUnitNumber] = nil
	--game.print("Train jump complete")
end

local function on_tick(event)
	--| Trains
	----------------- train flight ----------------
	for PropUnitNumber, properties in pairs(storage.FlyingTrains) do
		local GuideCar = properties.GuideCar
		if (GuideCar and GuideCar.valid) then
			GuideCar.destructible = false
		end

		--|| Follower speed comp
		if (properties.follower and properties.follower.valid) then
			if (properties.follower.train.speed>0) then
				properties.follower.train.speed = math.abs(properties.speed)
			elseif (properties.follower.train.speed<0) then
				properties.follower.train.speed = -math.abs(properties.speed)
			elseif (properties.follower.train.speed==0) then --This could happen if a jumping train gets hit by another train before the rest of it jumps
				storage.FlyingTrains[PropUnitNumber].follower = nil
			end
		-- elseif (properties.follower and not properties.follower.valid) then -- if the following wagon gets destroyed before it jumps or something?
			-- storage.FlyingTrains[PropUnitNumber].follower = nil
		end

		--|| Landing
		if (game.tick == properties.LandTick) then
			--game.print(game.tick.." land at position "..serpent.block(GuideCar.position))
			--||| Bounce Pad
			--[[ rendering.draw_circle{
				color = {1,1,1},
				radius = 3,
				target = GuideCar.position,
				surface = GuideCar.surface
			} ]]
			TrainLandedOn = GuideCar.surface.find_entities_filtered
				{
					name = {"RTTrainBouncePlate", "RTTrainDirectedBouncePlate"},
					position = GuideCar.position,
					radius = 3,
				}[1] -- in theory only one thing should be detected in the object layer this way
			if (TrainLandedOn ~= nil and TrainLandedOn.name == "RTTrainBouncePlate") then
				--game.print(game.tick..": "..GuideCar.position.x..","..GuideCar.position.y)
				if (properties.MagnetComp ~= nil) then
					properties.MagnetComp = nil
				end
				properties.LaunchTick = game.tick
				properties.LandTick = math.ceil(game.tick + 130*math.abs(properties.speed))
				properties.AirTime = properties.LandTick - properties.LaunchTick
				GuideCar.teleport(TrainLandedOn.position)
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

				-- Ultracube handling: Update position and also newly set/extended AirTime for timeout
				if storage.Ultracube and properties.Ultracube then -- Mod is active and this FlyingTrain is one that contains Ultracube irreplaceables
					CubeFlyingTrains.position_update(properties)
				end

			elseif (TrainLandedOn ~= nil and TrainLandedOn.name == "RTTrainDirectedBouncePlate") then
				--game.print(game.tick..": "..GuideCar.position.x..","..GuideCar.position.y)
				GuideCar.teleport(TrainLandedOn.position)
				properties.RampOrientation = TrainLandedOn.orientation+0.5
				if (GuideCar.speed > 0) then
					GuideCar.orientation = TrainLandedOn.orientation
					properties.orientation = TrainLandedOn.orientation
				elseif (GuideCar.speed < 0) then
					GuideCar.orientation = TrainLandedOn.orientation+0.5
					properties.orientation = TrainLandedOn.orientation+0.5
				end

				if (properties.orientation >= 1) then
					properties.orientation = properties.orientation-1
				end
				if (properties.RampOrientation >= 1) then
					properties.RampOrientation = properties.RampOrientation-1
				end

				base = properties.name
				way = storage.OrientationUnitComponents[properties.orientation].name
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

				properties.TrainImageID.destroy()
				properties.MaskID.destroy()
				properties.ShadowID.destroy()
				properties.ShadowID = rendering.draw_sprite
					{
						sprite = "GenericShadow",
						tint = {a = 90},
						target = GuideCar,
						surface = GuideCar.surface,
						orientation_target = GuideCar,
						x_scale = 0.25,
						y_scale = 0.5,
						render_layer = "air-object"
					}
				properties.TrainImageID = rendering.draw_sprite
					{
						sprite = image,
						target = GuideCar,
						surface = GuideCar.surface,
						orientation_target = GuideCar,
						render_layer = "air-object",
					}
				properties.MaskID = rendering.draw_sprite
					{
						sprite = mask,
						tint =  properties.color,
						target = GuideCar,
						surface = GuideCar.surface,
						orientation_target = GuideCar,
						render_layer = "air-object"
					}

				if (properties.MagnetComp ~= nil) then
					properties.MagnetComp = nil
				end
				properties.LaunchTick = game.tick
				properties.LandTick = math.ceil(game.tick + 130*math.abs(properties.speed))
				properties.AirTime = properties.LandTick - properties.LaunchTick
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

				-- Ultracube handling: Update position and also newly set/extended AirTime for timeout
				if storage.Ultracube and properties.Ultracube then -- Mod is active and this FlyingTrain is one that contains Ultracube irreplaceables
					CubeFlyingTrains.position_update(properties)
				end

			--||| Try to reform train
			else
				local NewTrain = GuideCar.surface.create_entity
					({
						name = properties.name,
						position = GuideCar.position,
						direction = storage.OrientationNumberToDefinition[properties.orientation], -- i think this does nothing
						force = GuideCar.force,
						raise_built = true
					})
				storage.FlyingTrains[PropUnitNumber].LandedTrain = NewTrain
				--|||| Success
				if (NewTrain ~= nil) then

					if (remote.interfaces.VehicleWagon2 and remote.interfaces.VehicleWagon2.set_wagon_data and storage.savedVehicleWagons[properties.WagonUnitNumber]) then
						remote.call("VehicleWagon2", "set_wagon_data", NewTrain, storage.savedVehicleWagons[properties.WagonUnitNumber])
					end

					if (properties.passenger ~= nil) then
						NewTrain.set_driver(properties.passenger)
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
						for urmum, lol in pairs(GuideCar.surface.find_entities_filtered({position = GuideCar.position, radius = 7})) do
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
						-- in 2.0, setting manua mode before speed works better, old way causes stuttering when following carriages reconnect
						if (properties.schedule ~= nil) then
							reEnableSchedule(NewTrain.train, properties.schedule, properties.destinationStation, properties)
						end

						if (
							(properties.leader == nil) or
							(properties.follower == nil and properties.length == #NewTrain.train.carriages) or
							(#NewTrain.train.locomotives.front_movers > 0 and NewTrain.train.speed > 0) or
							(#NewTrain.train.locomotives.back_movers > 0 and NewTrain.train.speed < 0)
						) then
							NewTrain.train.manual_mode = properties.ManualMode -- TrainreEnableSchedules are default created in manual mode, and connecting a new carriage switches back to manual
						end

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
								-- Ultracube handling
								if storage.Ultracube then
									remote.call("Ultracube", "reset_ultralocomotion_fuel", NewTrain) -- If locomotive was burning ultralocomotion fuel before launch, resets it on landing
									
									-- Ultracube irreplaceables handling for fuel/burnt slots & currently burning
									if properties.Ultracube then -- Ultracube is active and this locomotive has irreplaceables in it
										if properties.Ultracube.tokens[defines.inventory.fuel] then -- There were irreplaceables in the fuel inventory
											CubeFlyingTrains.release_and_insert(properties, NewTrain.burner.inventory, defines.inventory.fuel, NewTrain)
										end
										if properties.Ultracube.tokens[defines.inventory.burnt_result] then -- There were irreplaceables in the fuel inventory
											CubeFlyingTrains.release_and_insert(properties, NewTrain.burner.burnt_result_inventory, defines.inventory.burnt_result, NewTrain)
										end
										if properties.Ultracube.RemainingFuel then -- There was a burning irreplaceable
											CubeFlyingTrains.release_burning(properties, NewTrain.burner, NewTrain)
										end
									end
								end
								
								for each, stack in pairs(properties.FuelInventory) do
									NewTrain.burner.inventory.insert({name = stack.name, count = stack.count})
								end
								for each, stack in pairs(properties.BurntFuelInventory) do
									NewTrain.burner.burnt_result_inventory.insert({name = stack.name, count = stack.count})
								end
								
							end
						elseif (NewTrain.type == "cargo-wagon") then
							NewTrain.get_inventory(defines.inventory.cargo_wagon).set_bar(properties.bar)
							for i, filter in pairs(properties.filter) do
								NewTrain.get_inventory(defines.inventory.cargo_wagon).set_filter(i, filter)
							end

							-- Ultracube handling: insert irreplaceables that were previously in the cargo wagon and release tokens
							if storage.Ultracube and properties.Ultracube then -- Ultracube is active and this cargo wagon has irreplaceables in it
								local inventory = NewTrain.get_inventory(defines.inventory.cargo_wagon)
								CubeFlyingTrains.release_and_insert(properties, inventory, defines.inventory.cargo_wagon, NewTrain)
							end

							for each, stack in pairs(properties.cargo) do
								NewTrain.get_inventory(defines.inventory.cargo_wagon).insert({name = stack.name, count = stack.count})
							end
							if (remote.interfaces.ArmoredTrains and remote.interfaces.ArmoredTrains.SendTurretList and properties.ammo) then
								local list = remote.call("ArmoredTrains", "SendTurretList")
								local turret = nil
								if (list ~= nil) then
									for each, link in pairs(list) do
										if (link.entity.unit_number == NewTrain.unit_number) then
											turret = link.proxy
											break
										end
									end
									if (turret ~= nil) then
										for item, count in pairs(properties.ammo) do
											turret.get_inventory(defines.inventory.turret_ammo).insert({name=item, count=count})
										end
									end
								end
							end
						elseif (NewTrain.type == "fluid-wagon") then
							for FluidName, quantity in pairs(properties.fluids) do
								NewTrain.insert_fluid({name = FluidName, amount = quantity})
							end
						elseif (NewTrain.type == "artillery-wagon") then
							for eacg, stack in pairs(properties.artillery) do
								NewTrain.get_inventory(defines.inventory.artillery_wagon_ammo).insert({name = stack.name, count = stack.count})
							end
						end
					end
					GuideCar.destroy()

				--|||| Failure
				else
					if (GuideCar.surface.find_tiles_filtered{position = GuideCar.position, radius = 1, limit = 1, collision_mask = "player"}[1] == nil) then
						GuideCar.surface.create_entity
							({
								name = "big-scorchmark",
								position = GuideCar.position
							})
					end

					if (prototypes.entity[properties.name].corpses) then
						local key, value = next(prototypes.entity[properties.name].corpses)
						rip = GuideCar.surface.create_entity
							({
								name = key or "locomotive-remnants",
								position = GuideCar.position,
								force = GuideCar.force,
								direction = storage.OrientationNumberToDefinition[GuideCar.orientation]
							})
						rip.color = properties.color
					end

					local boom = GuideCar.surface.create_entity
						({
							name = "locomotive-explosion",
							position = GuideCar.position
						})

					for each, guy in pairs(game.connected_players) do
						guy.add_alert(boom, defines.alert_type.entity_destroyed)
					end

					if (remote.interfaces.VehicleWagon2 and storage.savedVehicleWagons[properties.WagonUnitNumber] and remote.interfaces.VehicleWagon2.kill_wagon_data) then --Vehicle wagon destroy message
						remote.call("VehicleWagon2", "kill_wagon_data", storage.savedVehicleWagons[properties.WagonUnitNumber])
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
						local CrashSpread = 100
						for each, stack in pairs(properties.cargo) do
							local ItemName = stack.name
							local quantity = stack.count
							if (ItemName == "explosives") then
								CrashSpread = 100 + 2*quantity
								break
							end
						end
						for each, stack in pairs(properties.cargo) do
							local ItemName = stack.name
							local quantity = stack.count
							if (prototypes.entity[ItemName.."-projectileFromRenaiTransportationPrimed"]) then
								if (quantity > prototypes.item[ItemName].stack_size) then
									quantity = prototypes.item[ItemName].stack_size
								end
								if (CrashSpread > 400) then
									CrashSpread = 400
								end
								for i = 1, quantity do
									local xshift = math.random(-CrashSpread,CrashSpread)/10
									local yshift = math.random(-math.sqrt((CrashSpread^2)-(xshift*10)^2),math.sqrt((CrashSpread^2)-(xshift*10)^2))/10
										GuideCar.surface.create_entity
											({
											name = ItemName.."-projectileFromRenaiTransportationPrimed",
											position = GuideCar.position, --required setting for rendering, doesn't affect spawn
											source_position = GuideCar.position,
											target_position = {GuideCar.position.x + xshift, GuideCar.position.y + yshift},
											force = GuideCar.force
											})
								end
							end
						end
					end

					GuideCar.destroy()
					--game.print("D")
					--storage.FlyingTrains[PropUnitNumber] = nil

				end
			end
		--|| Animating Train
		elseif (game.tick < properties.LandTick) then
			local height, VerticalSpeed = Animation.updateRendering(properties)

			--game.print(height..": "..VerticalSpeed)
			-- hitting or landing on elevated rails
			if (properties.altered == nil and height >= 1.2 and height <= 3.5 and VerticalSpeed > 0) then -- estimated height of elevated rails
				--upward arc
				local rails = GuideCar.surface.find_entities_filtered{
					position = GuideCar.position,
					radius = 3,
					collision_mask = "elevated_rail"
				}
				if (#rails > 0) then
					local boom = GuideCar.surface.create_entity
					({
						name = "locomotive-explosion",
						position = GuideCar.position
					})
					for each, guy in pairs(game.connected_players) do
						guy.add_alert(boom, defines.alert_type.entity_destroyed)
					end
					for urmum, lol in pairs(boom.surface.find_entities_filtered({position = boom.position, radius = 7})) do
						if (lol.valid and lol.is_entity_with_health == true and lol.health ~= nil) then
							lol.damage(1000, "neutral", "explosion")
						elseif (lol.valid and lol.name == "cliff") then
							lol.destroy({do_cliff_correction = true,  raise_destroy = true})
						end
					end
					if (prototypes.entity[properties.name].corpses) then
						local key, value = next(prototypes.entity[properties.name].corpses)
						rip = GuideCar.surface.create_entity
							({
								name = key or "locomotive-remnants",
								position = GuideCar.position,
								force = GuideCar.force,
								direction = GuideCar.direction
							})
						rip.color = properties.color
					end
					GuideCar.destroy()
					storage.FlyingTrains[PropUnitNumber] = nil
				end
			elseif (properties.altered == nil and height >= 3.25 and height <= 4.5 and VerticalSpeed < 0) then
				-- downward arc
				local rails = GuideCar.surface.find_entities_filtered{
					position = GuideCar.position,
					radius = 3,
					collision_mask = "elevated_rail"
				}
				if (#rails > 0) then
					local gravity = 1/250
					local LandingRunwayDistance = math.abs(GuideCar.speed)*(VerticalSpeed+math.sqrt((VerticalSpeed^2) - 2*gravity*(3-height)))/gravity -- "Landing strip" length needed for the touchdown animation
					local XLandOffset = 0 --LandingRunwayDistance*storage.OrientationUnitComponents[GuideCar.orientation].x
					local YLandOffset = 0 --LandingRunwayDistance*storage.OrientationUnitComponents[GuideCar.orientation].y
					local TestTrain = GuideCar.surface.create_entity
						({
							name = properties.name,
							position = {GuideCar.position.x+XLandOffset, GuideCar.position.y+YLandOffset},
							direction = storage.OrientationNumberToDefinition[properties.orientation], -- i think this does nothing
							raise_built = false
						})
					local PrepareForLanding = false
					if (TestTrain ~= nil) then
						for each, rail in pairs(TestTrain.train.get_rails()) do
							if (rail.prototype.collision_mask.layers["elevated_rail"]) then
								PrepareForLanding = true
								break
							end
						end
						if (PrepareForLanding == true) then
							local T_Minus = math.ceil(LandingRunwayDistance/math.abs(GuideCar.speed))
							properties.LandTick = game.tick + T_Minus
							properties.AirTime = properties.LandTick - properties.LaunchTick
							properties.shift = height
							properties.ElevatedLandingStart = game.tick
							properties.SpinMagnitude = 0.03 -- makes landing rotation more shallow to match the earlier landing
							properties.SpinSpeed = 9 -- makes landing rotation more shallow to match the earlier landing
						end
						TestTrain.destroy()
						properties.altered = 42069
					end
				end
			end

			-- Ultracube position handling
			if storage.Ultracube and properties.Ultracube then -- Mod is active and this FlyingTrain is one that contains Ultracube irreplaceables
				CubeFlyingTrains.position_update(properties)
			end

		--|| Landing speed control
		elseif (game.tick > properties.LandTick and properties.LandedTrain and properties.LandedTrain.valid) then
			-- if there is a following wagon that hasn't landed yet
			if (properties.follower and properties.followerID and storage.FlyingTrains[properties.followerID] and storage.FlyingTrains[properties.followerID].LandedTrain == nil) then
				--game.print("not all here")
				if (properties.LandedTrain.train.speed>0) then
					properties.LandedTrain.train.speed = math.abs(properties.speed)
				elseif (properties.LandedTrain.train.speed<0) then
					properties.LandedTrain.train.speed = -math.abs(properties.speed)
				else
				end

			-- if there is a following wagon that has landed
			elseif (properties.follower and properties.followerID and storage.FlyingTrains[properties.followerID] and storage.FlyingTrains[properties.followerID].LandedTrain ~= nil) then
				storage.FlyingTrains[PropUnitNumber] = nil

			-- if there is not following wagon aka the last wagon of the train
			elseif (properties.follower == nil) then
				finalizeLandedTrain(PropUnitNumber, properties)

			-- timed failsafe. Should never happen but who knows
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
				-- storage.FlyingTrains[PropUnitNumber] = nil
			-- end

		elseif (game.tick > properties.LandTick) then -- for any trains already in the air when the speed control update was released or other catch all failsafes
			finalizeLandedTrain(PropUnitNumber, properties)
		end
	end
end

return on_tick

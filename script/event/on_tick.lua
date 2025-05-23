local handle_players = require("__RenaiTransportation__.script.players.on_tick")
local handle_trains = require("__RenaiTransportation__.script.trains.on_tick")
local handle_items = require("__RenaiTransportation__.script.event.FlyingItems")
local handle_throwers = require("__RenaiTransportation__.script.event.on_tick_throwers")
local handle_belt_ramps = require("script.event.on_tick_BeltRamps")
local handle_vacuum_hatches = require("script.event.on_tick_VacuumHatches")
local handle_item_cannons = require("script.event.on_tick_ItemCannons")

local function on_tick(event)
	handle_players(event)
	handle_trains(event)
	handle_items(event)
	handle_throwers(event)
	handle_belt_ramps(event)
	handle_vacuum_hatches(event)
	handle_item_cannons(event)
	
	if (storage.clock[game.tick]) then
		--=== destroy
		if (storage.clock[game.tick].destroy) then
			-- storage.clock[game.tick].destroy = {entity1, entity2, entity3, ...}
			for each, entity in pairs(storage.clock[game.tick].destroy) do
				if (entity.valid) then
					entity.destroy()
				end
			end
		end
		-- ressurect
		if (storage.clock[game.tick].rez) then
			for i, RezSpecs in pairs(storage.clock[game.tick].rez) do
				-- RezSpecs.name
				-- RezSpecs.position
				-- RezSpecs.force
				-- RezSpecs.surface
				-- RezSpecs.raise_built
				-- RezSpecs.smoke
				-- RezSpecs.LastToggled = unit_number of trapdoor wagon last toggled
				if (RezSpecs.surface.can_place_entity{name=RezSpecs.name, position=RezSpecs.position, force=RezSpecs.force} == true) then
					local rezzd = RezSpecs.surface.create_entity
					{
						name = RezSpecs.name,
						position = RezSpecs.position,
						force = RezSpecs.force,
						create_build_effect_smoke = RezSpecs.smoke or false,
						raise_built = RezSpecs.raise_built or true
					}
				else
					-- try rez again next tick
					if (storage.clock[game.tick+1] == nil) then
						storage.clock[game.tick+1] = {}
					end
					if (storage.clock[game.tick+1].rez == nil) then
						storage.clock[game.tick+1].rez = {}
					end
					if (RezSpecs.LastToggled) then -- need this incase the wagon goes so fast that the next trapdoor wagon moves over the rez point before the detector gets a chance to respawn
						local blocking = RezSpecs.surface.find_entities_filtered
						{
							name = "RTTrapdoorWagon",
							position = RezSpecs.position,
							limit = 1
						}[1]
						if (blocking and blocking.unit_number ~= RezSpecs.LastToggled) then
							--game.print("Debug: "..blocking.unit_number.."   "..RezSpecs.LastToggled) triggered, confirmed works
							ToggleTrapdoorWagon(blocking)
							RezSpecs.LastToggled = blocking.unit_number
						end
					end
					table.insert(storage.clock[game.tick+1].rez, RezSpecs)
				end
			end
		end
		-- revert hatch mining speed debuff
		if (storage.clock[game.tick].MiningSpeedRevert) then
			for _, revert in pairs(storage.clock[game.tick].MiningSpeedRevert) do
				if (revert.character and revert.character.valid) then
					revert.character.character_mining_speed_modifier = revert.back
				end
			end
		end
		storage.clock[game.tick] = nil
	end

	
end

return on_tick
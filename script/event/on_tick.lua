local handle_players = require("__RenaiTransportation__.script.players.on_tick")
local handle_trains = require("__RenaiTransportation__.script.trains.on_tick")
local handle_items = require("__RenaiTransportation__.script.event.FlyingItems")

local function on_tick(event)
	handle_players(event)
	handle_trains(event)
	handle_items(event)
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
				if (RezSpecs.surface.can_place_entity{name=RezSpecs.name, position=RezSpecs.position, force=RezSpecs.force} == true) then
					local rezzd = RezSpecs.surface.create_entity
					{
						name = RezSpecs.name,
						position = RezSpecs.position,
						force = RezSpecs.force,
						create_build_effect_smoke = RezSpecs.smoke or false,
						raise_built = RezSpecs.raise_built or true
					}
					--[[ if (RezSpecs.name == "RTTrainDetector") then
						local trigger = RezSpecs.surface.find_entities_filtered({name="RTTrapdoorTrigger", position=RezSpecs.position})[1]
						if (trigger) then
							storage.DestructionLinks[script.register_on_object_destroyed(trigger)] = {rezzd} -- Trapdoor triggers will only ever have 1 linked detector so this is a list of 1
						end
					end ]]
				else
					-- try rez again next tick
					if (storage.clock[game.tick+1] == nil) then
						storage.clock[game.tick+1] = {}
					end
					if (storage.clock[game.tick+1].rez == nil) then
						storage.clock[game.tick+1].rez = {}
					end
					table.insert(storage.clock[game.tick+1].rez, storage.clock[game.tick].rez[i])
				end
			end
		end
		storage.clock[game.tick] = nil
	end
end

return on_tick
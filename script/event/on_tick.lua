local handle_players = require("__RenaiTransportation__.script.players.on_tick")
local handle_trains = require("__RenaiTransportation__.script.trains.on_tick")
local handle_items = require("__RenaiTransportation__.script.event.FlyingItems")

local function on_tick(event)
	handle_players(event)
	handle_trains(event)
	handle_items(event)
end

return on_tick

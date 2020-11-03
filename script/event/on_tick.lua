local handle_players = require("__RenaiTransportation__.script.players.on_tick")
local handle_trains = require("__RenaiTransportation__.script.trains.on_tick")

local function on_tick(event)
	handle_players(event)
	handle_trains(event)
end

return on_tick

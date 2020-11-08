local function player_created(event)
	if (global.AllPlayers[event.player_index] == nil) then
		global.AllPlayers[event.player_index] = {}
	end
end

return player_created

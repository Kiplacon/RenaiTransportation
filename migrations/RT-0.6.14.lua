for PlayerID, PlayerLuaData in pairs(game.players) do
	if (global.AllPlayers and global.AllPlayers[PlayerID] and global.AllPlayers[PlayerID].sliding and global.AllPlayers[PlayerID].sliding == true) then
		global.AllPlayers[PlayerID].StartingSurface = game.get_player(PlayerID).surface
	end
end
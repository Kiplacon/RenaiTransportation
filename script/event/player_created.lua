local function player_created(event)
	if (global.AllPlayers[event.player_index] == nil) then
		global.AllPlayers[event.player_index] = {state="default", PlayerLauncher={}, zipline={}, RangeAdjusting=false, SettingRampRange={SettingRange=false}, GUI={}, preferences={}, HoverGraphic=0}
	end
end

return player_created

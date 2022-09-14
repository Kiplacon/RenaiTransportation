for each, FlyingItem in pairs(global.FlyingItems) do
	if (FlyingItem.player) then
		SwapBackFromGhost(FlyingItem.player, FlyingItem)
		if (FlyingItem.sprite) then
			rendering.destroy(FlyingItem.sprite)
			rendering.destroy(FlyingItem.shadow)
		end
		global.FlyingItems[each] = nil
	end
end

for ThePlayer, TheirProperties in pairs(global.AllPlayers) do
	local player = game.players[ThePlayer]
	if (player.character and string.find(player.character.name, "RTGhost")) then
		SwapBackFromGhost(player)
		player.character_running_speed_modifier = 0
	end
	player.teleport(player.surface.find_non_colliding_position("character", {player.position.x, player.position.y+2}, 0, 0.01))
	global.AllPlayers[ThePlayer] = {state="default", PlayerLauncher={}, zipline={}, RangeAdjusting=false, SettingRampRange={SettingRange=false}, GUI={}}
end

for each, world in pairs(game.surfaces) do
	for every, ZiplinePart in pairs(world.find_entities_filtered{name = {"RTZipline", "RTZiplinePowerDrain"}}) do
		ZiplinePart.destroy()
	end
end

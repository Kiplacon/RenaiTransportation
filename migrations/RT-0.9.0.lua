-- clearing for the overflow prevention update
global.OnTheWay = {}
global.FlyingItems = {}
for catapultID, properties in pairs(global.CatapultList) do
	properties.ImAlreadyTracer = "traced"
end
for PlayerID, PlayerLuaData in pairs(game.players) do
	global.AllPlayers[PlayerID] = {}
end

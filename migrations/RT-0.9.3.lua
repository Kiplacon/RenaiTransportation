-- clearing for the overflow prevention update
for catapultID, properties in pairs(global.CatapultList) do
	properties.ImAlreadyTracer = "traced"
	properties.target = nil
	properties.targets = {}
end

for each, FlyingItem in pairs(global.FlyingItems) do
	if (FlyingItem.tracing ~= nil) then
		rendering.destroy(FlyingItem.sprite)
		rendering.destroy(FlyingItem.shadow)
		global.FlyingItems[each] = nil
	end
end

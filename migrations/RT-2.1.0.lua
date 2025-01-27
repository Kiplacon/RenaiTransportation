if (storage.FlyingItems) then
	for each, FlyingItem in pairs(storage.FlyingItems) do
		if (FlyingItem.sprite) then -- from impact unloader/space throw
			if (type(FlyingItem.sprite) == "number" and rendering.get_object_by_id(FlyingItem.sprite) ~= nil) then
				rendering.get_object_by_id(FlyingItem.sprite).destroy()
			else
				FlyingItem.sprite.destroy()
			end
		end
		if (FlyingItem.shadow) then -- from impact unloader/space throw
			if (type(FlyingItem.shadow) == "number" and rendering.get_object_by_id(FlyingItem.shadow) ~= nil) then
				rendering.get_object_by_id(FlyingItem.shadow).destroy()
			else
				FlyingItem.shadow.destroy()
			end
		end
	end
	storage.FlyingItems = {}
end
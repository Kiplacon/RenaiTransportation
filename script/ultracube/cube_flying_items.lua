local cube_flying_items = {}

function cube_flying_items.release_and_insert(FlyingItem, ThingLandedOn)
	if remote.call("Ultracube", "release_ownership_token", FlyingItem.cube_token_id) then -- Item hasn't been forcibly recovered
		ThingLandedOn.insert({name=FlyingItem.item, count=FlyingItem.amount})
		-- handle entiy_hint if needed
		if FlyingItem.cube_should_hint then
			remote.call("Ultracube", "hint_entity", ThingLandedOn)
		end
	end
end

-- Triggers Ultracube's forced recovery when something has gone Very Wrong
function cube_flying_items.panic(FlyingItem)
	remote.call("Ultracube", "update_ownership_token",
		FlyingItem.cube_token_id,
		0, -- Force a timeout immediately after this update
		{
			surface = FlyingItem.surface,
			position = FlyingItem.start, -- Return to the position the FlyingItem was presumable thrown from
		}
	)
end

return cube_flying_items
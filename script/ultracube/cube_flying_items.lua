local cube_flying_items = {}

-- Release ownership token and if it hasn't expired insert the item stack into ThingLandedOn
function cube_flying_items.release_and_insert(FlyingItem, ThingLandedOn)
	local item_stack = remote.call("Ultracube", "release_ownership_token", FlyingItem.cube_token_id)
	if item_stack then -- Item hasn't been forcibly recovered
		ThingLandedOn.insert(item_stack)
		-- handle entiy_hint if needed
		if FlyingItem.cube_should_hint then
			remote.call("Ultracube", "hint_entity", ThingLandedOn)
		end
	end
end

-- Release ownership token and if it hasn't expired spill the item stack at FlyingItem's target position
function cube_flying_items.release_and_spill(FlyingItem, ThingLandedOn)
	local item_stack = remote.call("Ultracube", "release_ownership_token", FlyingItem.cube_token_id)
	if item_stack then -- Item hasn't been forcibly recovered
		local force_name = nil
		if (settings.global["RTSpillSetting"].value == "Spill and Mark") then
			force_name = "player"
		end
		local spilt = FlyingItem.surface.spill_item_stack(FlyingItem.target, item_stack, nil, force_name, true)
		if FlyingItem.cube_should_hint then
			if #spilt >= 1 then
				remote.call("Ultracube", "hint_entity", spilt[1])
			elseif ThingLandedOn then -- Spilled onto a transport belt
				remote.call("Ultracube", "hint_entity", ThingLandedOn)
			end
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
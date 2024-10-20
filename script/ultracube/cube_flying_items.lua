local cube_flying_items = {}

-- Create an ownership token and attach it to the FlyingItem
function cube_flying_items.create_token_for(FlyingItem, velocity)
	FlyingItem.cube_token_id = remote.call("Ultracube", "create_ownership_token",
		FlyingItem.item,
		FlyingItem.amount,
		FlyingItem.AirTime+1, -- Timeout before Ultracube forces recovery. AirTime+1 as that's the exact tick where if there hasn't been an update call something must have gone wrong
		{
			surface = FlyingItem.surface,
			position = FlyingItem.start, -- Render position (what the camera follows and where explosions are emitted)
			spill_position = FlyingItem.start,
			velocity = velocity -- Vector for altering the explosion animation
		}
	)
	FlyingItem.cube_should_hint = storage.Ultracube.prototypes.cube[FlyingItem.item] -- True if in set, otherwise Nil
end

-- Used to update the ownership token for a FlyingItem that has a sprite and path
function cube_flying_items.item_with_sprite_update(FlyingItem, duration)
	local position = FlyingItem.path[duration] -- Ground position at current tick along its path
	local height = FlyingItem.path[duration].height -- How high 'above' the ground the sprite is
	remote.call("Ultracube", "update_ownership_token",
		FlyingItem.cube_token_id,
		nil, -- Timeout already set on creation. If the train was somehow going fast enough to fling something into the air longer than Ultracube's timeout limit, it's probably best to just let it be forcibly recovered
		{
			position = {x=position.x, y=position.y + height}, -- Render position in-air
			height = height -- Used for modifying Ultracube explosion animation. Not related to where the camera follows nor the explosion's position
		}
	)
end

-- Used to update token for items using the stream projectile
function cube_flying_items.item_with_stream_update(FlyingItem)
	local delta = (game.tick-FlyingItem.StartTick)/FlyingItem.AirTime -- 0-1 float corresponding to how far along the item should be between starting and finishing position
	-- Vector from start position to end position scaled by delta to get vector for distance traveled, and then added to start position to get a rough 'ground' position
	-- As far as I can tell figuring out the position of the particle in the stream entity would require calculating the physics for it from scratch, so this is probably the best we can get.
	local position = {
		x = delta * (FlyingItem.target.x - FlyingItem.start.x) + FlyingItem.start.x,
		y = delta * (FlyingItem.target.y - FlyingItem.start.y) + FlyingItem.start.y
	}
	remote.call("Ultracube", "update_ownership_token",
		FlyingItem.cube_token_id,
		nil, -- Timeout already set on creation or latest bounce
		{
			position = position, 
		}
	)
end

-- Used to update the ownership token for a FlyingItem after it lands on a bounce pad of any kind
function cube_flying_items.bounce_update(FlyingItem)
	remote.call("Ultracube", "update_ownership_token",
		FlyingItem.cube_token_id,
		FlyingItem.AirTime+1, -- Bounce will increase total air time so update the timeout to add the new air time
		{
			surface = FlyingItem.surface,
			position = FlyingItem.start, -- Render position
			spill_position = FlyingItem.start -- Spill position on forced recovery
			-- TODO: Velocity parameter?
		}
	)
end

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

-- Release ownership token and if it hasn't expired and spill the item stack at FlyingItem's target position
function cube_flying_items.release_and_spill(FlyingItem, ThingLandedOn)
	local item_stack = remote.call("Ultracube", "release_ownership_token", FlyingItem.cube_token_id)
	if item_stack then -- Item hasn't been forcibly recovered
		local force_name = nil
		if (settings.global["RTSpillSetting"].value == "Spill and Mark") then
			force_name = "player"
		end
		local spilt = FlyingItem.surface.spill_item_stack
			{
				position = FlyingItem.target,
				stack = item_stack,
				force = force_name
			}
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
			spill_position = FlyingItem.start, -- Return to the position the FlyingItem was presumable thrown from
		}
	)
end

return cube_flying_items
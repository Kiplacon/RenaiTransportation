local cube_flying_items = {}

-- Sets some additional properties normally not computed for ReskinnedStreams but are used to track the cube
local function add_missing_stream_properties(FlyingItem)
	if FlyingItem.type == "ReskinnedStream" then
		local StartX = FlyingItem.ThrowerPosition.x or FlyingItem.ThrowerPosition[1]
		local StartY = FlyingItem.ThrowerPosition.y or FlyingItem.ThrowerPosition[2]
		local TargetX = FlyingItem.target.x
		local TargetY = FlyingItem.target.y
		local speed = FlyingItem.speed or 0.18
		local distance = math.sqrt((TargetX-StartX)*(TargetX-StartX) + (TargetY-StartY)*(TargetY-StartY))
		FlyingItem.AirTime = math.ceil(distance / speed) + 2  -- takes some extra ticks for the stream to be destroyed
		FlyingItem.StartTick = game.tick

		if storage.Ultracube.prototypes.cube[FlyingItem.item] then
			-- kinda expensive, but gives us a nice arc for the cube effects / cubecam
			local vector = {x=TargetX-StartX, y=TargetY-StartY}
			local path = {}
			local MaxHeight = 0.0004*(distance*distance)/(speed*speed)
			for j = 0, FlyingItem.AirTime do
					local progress = j/FlyingItem.AirTime
					path[j] =
					{
							x = StartX+(progress*vector.x),
							y = StartY+(progress*vector.y),
							height = 4*MaxHeight*(progress - (progress*progress))
					}
			end
			FlyingItem.path = path
		end
	end
end


-- Create an ownership token and attach it to the FlyingItem
-- If the FlyingItem already has a token, updates it instead
function cube_flying_items.create_token_for(FlyingItem, velocity)
	add_missing_stream_properties(FlyingItem)
	FlyingItem.cube_token_id = remote.call("Ultracube", "create_ownership_token",
		FlyingItem.item,
		FlyingItem.amount,
		FlyingItem.AirTime+1, -- Timeout before Ultracube forces recovery. AirTime+1 as that's the exact tick where if there hasn't been an update call something must have gone wrong
		{
			surface = FlyingItem.surface,
			position = FlyingItem.ThrowerPosition, -- Render position (what the camera follows and where explosions are emitted)
			spill_position = FlyingItem.ThrowerPosition,
			velocity = velocity -- Vector for altering the explosion animation
		}
	)
	FlyingItem.cube_should_hint = storage.Ultracube.prototypes.cube[FlyingItem.item] -- True if in set, otherwise Nil
end

-- Used to update the ownership token for a FlyingItem that has a path
function cube_flying_items.item_with_path_update(FlyingItem, duration)
	local position = FlyingItem.path[duration] -- Ground position at current tick along its path
	local height = FlyingItem.path[duration].height -- How high 'above' the ground the sprite is
	-- Compute velocity based on position in next or previous tick
	local velocity
	if FlyingItem.path[duration-1] then
		local vspeed = height - FlyingItem.path[duration-1].height
		velocity = {
			x = position.x - FlyingItem.path[duration-1].x,
			y = position.y - FlyingItem.path[duration-1].y - vspeed, -- minus vspeed because +y is south
		}
	elseif FlyingItem.path[duration+1] then
		local vspeed = FlyingItem.path[duration+1].height - height
		velocity = {
			x = FlyingItem.path[duration+1].x - position.x,
			y = FlyingItem.path[duration+1].y - position.y - vspeed, -- minus vspeed because +y is south
		}
	end
	remote.call("Ultracube", "update_ownership_token",
		FlyingItem.cube_token_id,
		nil, -- Timeout already set on creation. If the train was somehow going fast enough to fling something into the air longer than Ultracube's timeout limit, it's probably best to just let it be forcibly recovered
		{
			position = {x=position.x, y=position.y - height}, -- Render position in-air (minus height because +y is south)
			velocity = velocity,
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
		x = delta * (FlyingItem.target.x - FlyingItem.ThrowerPosition.x) + FlyingItem.ThrowerPosition.x,
		y = delta * (FlyingItem.target.y - FlyingItem.ThrowerPosition.y) + FlyingItem.ThrowerPosition.y
	}
	remote.call("Ultracube", "update_ownership_token",
		FlyingItem.cube_token_id,
		nil, -- Timeout already set on creation or latest bounce
		{
			position = position,
		}
	)
end

-- Used to update token for ItemShell projectiles
function cube_flying_items.item_with_shell_update(FlyingItem)
	-- Vector for distance traveled in 1 tick
	local velocity = {
		x = (FlyingItem.target.x - FlyingItem.ThrowerPosition.x) / FlyingItem.AirTime,
		y = (FlyingItem.target.y - FlyingItem.ThrowerPosition.y) / FlyingItem.AirTime,
	}
	-- Start position plus velocity vector scaled by ticks since FlyingItem.StartTick
	local DeltaTick = game.tick - FlyingItem.StartTick
	local position = {
		x = FlyingItem.ThrowerPosition.x + DeltaTick * velocity.x,
		y = FlyingItem.ThrowerPosition.y + DeltaTick * velocity.y,
	}
	remote.call("Ultracube", "update_ownership_token",
		FlyingItem.cube_token_id,
		nil, -- Timeout already set on creation or latest bounce
		{
			position = position,
			velocity = velocity,
		}
	)
end

-- Used to update and transfer the ownership token for a FlyingItem after it lands on a bounce pad of any kind
function cube_flying_items.bounce_update(bouncing, NewFlyingItem)
	add_missing_stream_properties(NewFlyingItem)
	NewFlyingItem.cube_token_id = bouncing.cube_token_id
	NewFlyingItem.cube_should_hint = bouncing.cube_should_hint
	bouncing.cube_token_id = nil
	bouncing.cube_should_hint = nil

	remote.call("Ultracube", "update_ownership_token",
		NewFlyingItem.cube_token_id,
		NewFlyingItem.AirTime+1, -- Bounce will increase total air time so update the timeout to add the new air time
		{
			surface = NewFlyingItem.surface,
			position = NewFlyingItem.ThrowerPosition, -- Render position
			spill_position = NewFlyingItem.ThrowerPosition -- Spill position on forced recovery
			-- TODO: Velocity parameter?
		}
	)
end

-- Find the FlyingItem associated with a specific projectile entity and release its token without inserting the item back into the world
-- If the token hasn't expired returns the associated item and count; in this case a new ownership token must be created in the same tick
function cube_flying_items.release_for_projectile(projectile)
	if projectile then
		for _, FlyingItem in pairs(storage.FlyingItems) do
			if FlyingItem.projectile == projectile then
				local cube_token_id = FlyingItem.cube_token_id
				FlyingItem.cube_token_id = nil
				return remote.call("Ultracube", "release_ownership_token", cube_token_id)
			end
		end
	end
	log("Warning: Could not find an Ultracube ownership token for " .. serpent.line(projectile))
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
			spill_position = FlyingItem.ThrowerPosition, -- Return to the position the FlyingItem was presumable thrown from
		}
	)
end

return cube_flying_items
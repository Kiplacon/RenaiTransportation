local cube_flying_trains = {}

-- Creates data for initial token creation and sets FlyingTrain.Ultracube.prev_pos for velocity calculation
local function _create_token_init_data(FlyingTrain)
	local data = {
		surface=FlyingTrain.GuideCar.surface,
		position=FlyingTrain.GuideCar.position,
		spill_position = FlyingTrain.GuideCar.position
		-- Velocity will be set on second tick in air
	}
	if not FlyingTrain.Ultracube.prev_pos then
		FlyingTrain.Ultracube.prev_pos = FlyingTrain.GuideCar.position
	end
	return data
end

-- Creates tokens for any FlyingTrain that could have irreplaceables in its inventory (cargo wagons and locomotive fuel)
--[[
	All FlyingTrains have their originals destroyed with raise_destroy being true.
	Ultracube listens for anything being destroyed with an inventory, and if that inventory contains irreplaceables it spills them nearby.
	So to prevent any 'duplication' all irreplaceables must be removed from the inventory before the parent entity is destroyed.
]]--
function cube_flying_trains.create_tokens_for_inventory(FlyingTrain, inventory, inv_type)
	for prototype, _ in pairs(storage.Ultracube.prototypes.irreplaceable) do
		local count = inventory.get_item_count(prototype)
		if count > 0 then
			inventory.remove({name=prototype, count=count})
			if FlyingTrain.Ultracube == nil then
				FlyingTrain.Ultracube = {tokens={}, do_hint=false}
				FlyingTrain.Ultracube.tokens[inv_type] = {}
			end
			local token = remote.call("Ultracube", "create_ownership_token",
				prototype,
				count,
				FlyingTrain.AirTime+1,
				_create_token_init_data(FlyingTrain)
			)
			local index = #FlyingTrain.Ultracube.tokens[inv_type]+1
			FlyingTrain.Ultracube.tokens[inv_type][index] = token
			if storage.Ultracube.prototypes.cube[prototype] then
				FlyingTrain.Ultracube.do_hint = true
			end
		end
	end
end

function cube_flying_trains.create_token_for_burning(FlyingTrain)
	if FlyingTrain.CurrentlyBurning and storage.Ultracube.prototypes.irreplaceable[FlyingTrain.CurrentlyBurning.name.name] then -- There is a currently burning item for this FlyingTrain and it is an irreplaceable
		if FlyingTrain.Ultracube == nil then
			FlyingTrain.Ultracube = {tokens={}, do_hint=false}
		end
		FlyingTrain.Ultracube.tokens["currently_burning"] = {
			remote.call("Ultracube", "create_ownership_token",
				FlyingTrain.CurrentlyBurning.name.name,
				1, -- There can only ever be one item burning,
				FlyingTrain.AirTime+1,
				_create_token_init_data(FlyingTrain)
			)
		}
		if storage.Ultracube.prototypes.cube[FlyingTrain.CurrentlyBurning.name.name] then
			FlyingTrain.Ultracube.do_hint = true
		end

		-- Set up FlyingTrain data so that landing code will act as if nothing was burning in case Ultracube recalls the irreplaceable and it shouldn't be "put back in" the burner
		FlyingTrain.CurrentlyBurning = nil
		FlyingTrain.Ultracube.RemainingFuel = FlyingTrain.RemainingFuel -- Save remaining fuel for re-applying once token is released successfully
		FlyingTrain.RemainingFuel = 0
	end
end

function cube_flying_trains.position_update(FlyingTrain)
	local target = FlyingTrain.TrainImageID.target
	local position = target.position or FlyingTrain.GuideCar.position
	local offset = target.entity_offset
	if target.entity_offset then
		if target.entity_offset.x == nil then
			offset = {
				x=target.entity_offset[1],
				y=target.entity_offset[2]
			}
		end
		position.x = position.x + offset.x
		position.y = position.y + offset.y
	end
	local velocity = {x=position.x - FlyingTrain.Ultracube.prev_pos.x, y=position.y - FlyingTrain.Ultracube.prev_pos.y}
	for inv_type, tokens in pairs(FlyingTrain.Ultracube.tokens) do
		for _, token_id in ipairs(tokens) do
			remote.call("Ultracube", "update_ownership_token",
				token_id,
				FlyingTrain.LandTick - game.tick + 1, -- Update timeout for bounce pads and any really long jumps that go over Ultracube's normal limit
				{
					position = position,
					velocity=velocity
				}
			)
		end
	end
	FlyingTrain.Ultracube.prev_pos = position
end

-- For trapdoor wagons: releases the ownership token at Ultracube.tokens[inv_type][index] and recreates it with `count` fewer items, if any items are remaining
-- If the token hasn't expired returns the associated item and count; in this case a new ownership token must be created in the same tick
function cube_flying_trains.release_for_trapdoor(FlyingTrain, inv_type, index, count)
	local token = FlyingTrain.Ultracube.tokens[inv_type] and FlyingTrain.Ultracube.tokens[inv_type][index]
	if not token then
		return nil
	end

	local stack = remote.call("Ultracube", "release_ownership_token", token)
	if not stack then
		table.remove(FlyingTrain.Ultracube.tokens[inv_type], index)
		return nil
	else
		if stack.count > count then
			FlyingTrain.Ultracube.tokens[inv_type][index] = remote.call("Ultracube", "create_ownership_token",
				stack.name,
				stack.count - count,
				FlyingTrain.LandTick - game.tick + 1,
				_create_token_init_data(FlyingTrain)
			)
			stack.count = count
		else
			table.remove(FlyingTrain.Ultracube.tokens[inv_type], index)
		end
		return stack
	end
end

-- Inserts all irreplaceables associated with the given FlyingTrain into the given inventory, and sends hint_entity to Ultracube if relevant
--[[
	There doesn't appear to be an efficient way to maintain inventory order, 
	but this will respect any filtered slots so long as the inventory has had them set before calling this function.
]]
function cube_flying_trains.release_and_insert(FlyingTrain, inventory, inv_type, hint_entity)
	local has_hinted_already = false
	for _, token in ipairs(FlyingTrain.Ultracube.tokens[inv_type]) do
		local item_stack = remote.call("Ultracube", "release_ownership_token", token)
		if item_stack then -- Item hasn't been forcibly recovered
			inventory.insert(item_stack)
			-- If there's an item in the cargo wagon that needs hinting, and we're actually inserting item(s), call the hint function once
			if FlyingTrain.Ultracube.do_hint and not has_hinted_already then
				remote.call("Ultracube", "hint_entity", hint_entity)
				has_hinted_already = true
			end
		end
	end
end

-- Releases token for burning item, and applies it to the given Burner, updating remaining fuel with amount stored by create_token_for_burning
function cube_flying_trains.release_burning(FlyingTrain, Burner, hint_entity)
	local token = FlyingTrain.Ultracube.tokens["currently_burning"][1]
	local item = remote.call("Ultracube", "release_ownership_token", token)
	if item then -- Item hasn't been forcibly recovered
		Burner.currently_burning = prototypes.item[item.name]
		Burner.remaining_burning_fuel = FlyingTrain.Ultracube.RemainingFuel
	end
end

return cube_flying_trains
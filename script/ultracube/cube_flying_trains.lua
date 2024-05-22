local cube_flying_trains = {}

-- Creates tokens for any FlyingTrain that could have irreplaceables in its inventory (Currently just cargo wagons)
--[[
	All FlyingTrains have their originals destroyed with raise_destroy being true.
	Ultracube listens for anything being destroyed with an inventory, and if that inventory contains irreplaceables it spills them nearby.
	So to prevent any 'duplication' all irreplaceables must be removed from the inventory before the parent entity is destroyed.
]]--
function cube_flying_trains.create_tokens_for_cargo(FlyingTrain, Inventory)
function cube_flying_trains.create_tokens_for_cargo(FlyingTrain, inventory)
	for prototype, _ in pairs(global.Ultracube.prototypes.irreplaceable) do
		local count = inventory.get_item_count(prototype)
		if count > 0 then
			inventory.remove({name=prototype, count=count})
			if FlyingTrain.Ultracube == nil then
				FlyingTrain.Ultracube = {tokens={}, do_hint=false}
			end
			local token = remote.call("Ultracube", "create_ownership_token",
				prototype,
				count,
				FlyingTrain.AirTime+1,
				{
					surface=FlyingTrain.GuideCar.surface,
					position=FlyingTrain.GuideCar.position,
					spill_position = FlyingTrain.GuideCar.position
					-- TODO: Velocity vector?
				}
			)
			local index = #FlyingTrain.Ultracube.tokens+1
			FlyingTrain.Ultracube.tokens[index] = token
			if global.Ultracube.prototypes.cube[prototype] then
				FlyingTrain.Ultracube.do_hint = true
			end
		end
	end
end

function cube_flying_trains.position_update(FlyingTrain)
	local target = rendering.get_target(FlyingTrain.TrainImageID)
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
	for _, token_id in ipairs(FlyingTrain.Ultracube.tokens) do
		remote.call("Ultracube", "update_ownership_token",
			token_id,
			FlyingTrain.LandTick - game.tick + 1, -- Update timeout for bounce pads and any really long jumps that go over Ultracube's normal limit
			{position = position}
			-- TODO: Velocity?
		)
	end
end

-- Inserts all irreplaceables associated with the given FlyingTrain into the given inventory, and sends hint_entity to Ultracube if relevant
--[[
	There doesn't appear to be an efficient way to maintain inventory order, 
	but this will respect any filtered slots so long as the inventory has had them set before calling this function.
]]
function cube_flying_trains.release_and_insert(FlyingTrain, inventory, hint_entity)
	local has_hinted_already = false
	for _, token in ipairs(FlyingTrain.Ultracube.tokens) do
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

return cube_flying_trains
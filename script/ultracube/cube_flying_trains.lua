local cube_flying_trains = {}

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
			FlyingTrain.LandTick - game.tick + 1,
			{position = position},
			-- TODO: Velocity?
		)
	end
end

return cube_flying_trains
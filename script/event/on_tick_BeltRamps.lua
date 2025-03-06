local function BeltRamps(event)
    for _, BeltRampProperties in pairs(storage.BeltRamps) do
		if (BeltRampProperties.entity.valid) then
            local BeltRamp = BeltRampProperties.entity
            local range = BeltRampProperties.range
			local line = BeltRamp.get_transport_line(game.tick%2 + 1)
			if (#line>0) then
				local start = line.get_line_item_position(1)
				local StartShiftTileCenter = {x=math.floor(start.x)+0.5, y=math.floor(start.y)+0.5}
				InvokeThrownItem({
					type = "ReskinnedStream",
					stack = line[1],
					ThrowFromStackAmount = 1,
					start = start,
					target = OffsetPosition(StartShiftTileCenter, {range*storage.OrientationUnitComponents[BeltRamp.orientation].x, range*storage.OrientationUnitComponents[BeltRamp.orientation].y}),
					speed = BeltRampProperties.speed,
					surface = BeltRamp.surface,
					space = false,
				})
			end
		end
	end
end

return BeltRamps
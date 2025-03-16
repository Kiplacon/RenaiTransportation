local function BeltRamps(event)
    for _, BeltRampProperties in pairs(storage.BeltRamps) do
		if (BeltRampProperties.entity.valid) then
            local BeltRamp = BeltRampProperties.entity
            local range = BeltRampProperties.range
			local line = BeltRamp.get_transport_line(game.tick%2 + 1)
			if (#line>0) then
				local start = line.get_line_item_position(1)
				local StartShiftTileCenter = {x=math.floor(start.x)+0.5, y=math.floor(start.y)+0.5}
				if (BeltRampProperties.InSpace) then
					local DiagonalShift = 100
					if (BeltRamp.orientation == 0.5) then
						DiagonalShift = 0
					end
					local x = BeltRamp.position.x + (storage.OrientationUnitComponents[BeltRamp.orientation].x * 100) + math.random(-10, 10)
					local y = BeltRamp.position.y + (storage.OrientationUnitComponents[BeltRamp.orientation].y * 100) - DiagonalShift + math.random(-10, 10)
					distance = math.sqrt((x-start.x)^2 + (y-start.y)^2)
					AirTime = math.max(1, math.floor(distance/BeltRampProperties.speed))
					local vector = {x=x-start.x, y=y-start.y}
					local path = {}
					for i = 1, AirTime do
						local progress = i/AirTime
						path[i] =
						{
							x = start.x+(progress*vector.x),
							y = start.y+(progress*vector.y),
							height = 0
						}
					end
					InvokeThrownItem({
						type = "CustomPath",
						stack = line[1],
						ThrowFromStackAmount = 1,
						start = start,
						target={x=x, y=y},
						surface=BeltRamp.surface,
						space = true,
						path = path,
						AirTime = AirTime,
					})
				else
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
end

return BeltRamps
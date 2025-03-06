local function werew(event)
    if (game.tick%3 == 0) then
		for _, VacuumHatchStuff in pairs(storage.VacuumHatches) do
			if (VacuumHatchStuff.entity.valid and VacuumHatchStuff.entity.energy > 0) then
				local VacuumHatch = VacuumHatchStuff.entity
				if (VacuumHatchStuff.ToSucc == nil or #VacuumHatchStuff.ToSucc == 0) then
					local XShift = 3*storage.OrientationUnitComponents[VacuumHatch.orientation].x
					local YShift = 3*storage.OrientationUnitComponents[VacuumHatch.orientation].y
					local spills = VacuumHatch.surface.find_entities_filtered({
						type="item-entity",
						area={{VacuumHatch.position.x-2.5+XShift, VacuumHatch.position.y-2.5+YShift}, {VacuumHatch.position.x+2.5+XShift, VacuumHatch.position.y+2.5+YShift}}
					})
					for i = #spills, 2, -1 do
						local j = math.random(i)
						spills[i], spills[j] = spills[j], spills[i]
					end
					VacuumHatchStuff.ToSucc = spills
				else
					for i, item in pairs(VacuumHatchStuff.ToSucc) do
						if (item.valid) then
							local stack = item.stack
							InvokeThrownItem({
								type = "ReskinnedStream",
								stack = stack,
								speed = 0.18,
								start = item.position,
								target = VacuumHatch.position,
								surface = VacuumHatch.surface
							})
							VacuumHatchStuff.ToSucc[i] = nil
							break
                        else
                            VacuumHatchStuff.ToSucc[i] = nil
						end
					end
				end
			end
		end
	end
end

return werew
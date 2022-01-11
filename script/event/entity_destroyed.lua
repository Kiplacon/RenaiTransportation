local function entity_destroyed(event)
	if (global.MagnetRamps[event.unit_number]) then
		for each, tile in pairs(global.MagnetRamps[event.unit_number].tiles) do
			tile.destroy()
		end
		global.MagnetRamps[event.unit_number].power.destroy()
		global.MagnetRamps[event.unit_number] = nil
	end

	if (global.OnTheWay[event.unit_number]) then
		global.OnTheWay[event.unit_number] = nil
	end

	if (global.DataTrackerLinks[event.unit_number] ~= nil) then
		global.DataTrackerLinks[event.unit_number].tracker.destroy()
		global.DataTrackerLinks[event.unit_number] = nil
	end

	if (global.ThrowerPaths[event.unit_number] ~= nil) then
		for ThrowerUN, TrackedItems in pairs(global.ThrowerPaths[event.unit_number]) do
			if (global.CatapultList[ThrowerUN]) then
				for item, ligma in pairs(TrackedItems) do
					global.CatapultList[ThrowerUN].targets[item] = nil
				end
			end
		end
		global.ThrowerPaths[event.unit_number] = nil
	end
end

return entity_destroyed

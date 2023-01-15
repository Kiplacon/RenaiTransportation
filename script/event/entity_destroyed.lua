local function entity_destroyed(event)
	if (global.CatapultList[event.unit_number]) then
		if (global.CatapultList[event.unit_number].entangled) then
			for each, entity in pairs(global.CatapultList[event.unit_number].entangled) do
				entity.destroy()
			end
		end
		if (global.HoverGFX[event.unit_number]) then
			global.HoverGFX[event.unit_number] = nil
		end
		global.CatapultList[event.unit_number] = nil
	end

	if (global.PrimerThrowerLinks[event.unit_number]) then
		global.PrimerThrowerLinks[event.unit_number] = nil
	end

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

	if (global.ZiplineTerminals[event.unit_number] ~= nil) then
		if (global.ZiplineTerminals[event.unit_number].tag.valid) then
			global.ZiplineTerminals[event.unit_number].tag.destroy()
		end
		for each, player in pairs(game.players) do
			if (player.gui.center.RTZiplineTerminalGUI and player.gui.center.RTZiplineTerminalGUI.tags.ID == event.unit_number) then
				player.gui.center.RTZiplineTerminalGUI.destroy()
			end
		end
		global.ZiplineTerminals[event.unit_number] = nil
	end
end

return entity_destroyed

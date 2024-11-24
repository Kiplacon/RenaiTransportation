local function entity_destroyed(event)
	if (storage.CatapultList[event.registration_number]) then
		if (storage.CatapultList[event.registration_number].entangled) then
			for each, entity in pairs(storage.CatapultList[event.registration_number].entangled) do
				entity.destroy()
			end
		end
		if (storage.HoverGFX[event.registration_number]) then
			storage.HoverGFX[event.registration_number] = nil
		end
		storage.CatapultList[event.registration_number] = nil
	end

	if (storage.PrimerThrowerLinks[event.registration_number]) then
		storage.PrimerThrowerLinks[event.registration_number] = nil
	end

	if (storage.MagnetRamps[event.registration_number]) then
		for each, tile in pairs(storage.MagnetRamps[event.registration_number].tiles) do
			tile.destroy()
		end
		storage.MagnetRamps[event.registration_number].power.destroy()
		storage.MagnetRamps[event.registration_number] = nil
	end

	if (storage.OnTheWay[event.registration_number]) then
		storage.OnTheWay[event.registration_number] = nil
	end

	if (storage.ThrowerPaths[event.registration_number] ~= nil) then
		for ThrowerUN, TrackedItems in pairs(storage.ThrowerPaths[event.registration_number]) do
			if (storage.CatapultList[ThrowerUN]) then
				for item, ligma in pairs(TrackedItems) do
					storage.CatapultList[ThrowerUN].targets[item] = nil
				end
			end
		end
		storage.ThrowerPaths[event.registration_number] = nil
	end

	if (storage.ZiplineTerminals[event.registration_number] ~= nil) then
		if (storage.ZiplineTerminals[event.registration_number].tag.valid) then
			storage.ZiplineTerminals[event.registration_number].tag.destroy()
		end
		for each, player in pairs(game.players) do
			if (player.gui.center.RTZiplineTerminalGUI and player.gui.center.RTZiplineTerminalGUI.tags.ID == event.registration_number) then
				player.gui.center.RTZiplineTerminalGUI.destroy()
			end
		end
		storage.ZiplineTerminals[event.registration_number] = nil
	end

	if (storage.DestructionLinks[event.registration_number]) then
		for each, entity in pairs(storage.DestructionLinks[event.registration_number]) do
			if (entity.valid) then
				entity.destroy()
			end
		end
	end
end

return entity_destroyed

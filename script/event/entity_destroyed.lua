local function entity_destroyed(event)
	if (global.MagnetRamps[event.unit_number]) then
		for each, tile in pairs(global.MagnetRamps[event.unit_number].tiles) do
			tile.destroy()
		end
		global.MagnetRamps[event.unit_number].power.destroy()
		global.MagnetRamps[event.unit_number] = nil
	end
end

return entity_destroyed

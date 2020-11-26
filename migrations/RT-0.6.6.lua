-- Factorio 1.1
-- We have to migrate magnet ramp globals because we changed the
-- type of the ramps, since, in 1.1, rail signal boxes are hardcoded.
--
-- When factorio loads an old save, it sees the type has changed
-- and recreates the entites of that type. This is a problem, as
-- we're storing the old entities in a global variable, but the
-- stored entity references are invalid and can't even be _read_ :(
-- If we don't fix this, the game will crash the first time anything
-- interacts with a magnet ramp via the globals.
--
-- So we have to basically fix the entire global array, but without
-- knowing what the old entities that were in it actually were, or where they were,
-- or how they relate to the replacement entities factorio created as
-- a result of the "upgrade", or anything like that!
--
-- This may seem impossible, but since we're the heroes of this story,
-- we'll manage to pull a miracle out of out asses at the last second
-- and save the day...
--
-- First, since the global array is useless to us, we'll blow it away.
-- Next we'll get rid of any magnet tiles, since the entity they were
-- linked to is no longer around.
--
-- Now, we'll inspect all the new magnet ramp entities factorio generated
-- for us. This will tell us the ramp type, position, and orientation of
-- the old ramp. The only thing missing is the range, but that was stored
-- in the globals array, hidden behind the (unobtainable) old ramp ID.
--
-- We seem to have hit a wall that would make Gorbachev blush. But here comes
-- that ass-pulling moment, where we claw the range back from the icey depths
-- of cybernetic oblivion.
--
-- What we do is look next to the ramp for the _old_ ramp's power buffer, which
-- wasn't touched by the game. We can do some math on the amount of energy the
-- buffer can store to figure out what the range of the old ramp was. Hallelujah!
--
-- We can now trash the old power buffer and the migrated ramp. In their place
-- we'll create a brand new ramp, complete with all the trappings, and
-- stick that into the globals. And then hope really hard no one hits an edge case.

local util = require('util')
local magnetRamps = require("__RenaiTransportation__/script/trains/magnet_ramps")

global.AllPlayers = global.AllPlayers or {}
global.MagnetRamps = {} -- RIP

for _, player in pairs(global.AllPlayers) do
	-- Reset references to ramps
	player.SettingRange = nil
end

function handleMagnetRampBuilt(entity)
	-- version of the event handler that doesn't alter globals
	script.register_on_entity_destroyed(entity)
	local SUCC = entity.surface.create_entity({
		name = "RTMagnetRampDrain",
		position = {entity.position.x, entity.position.y-0.25}, --required setting for rendering, doesn't affect spawn
		direction = entity.direction,
		force = entity.force
	})
	SUCC.electric_buffer_size = 1000000
	SUCC.power_usage = 0
	SUCC.destructible = false
	return SUCC
end

local function locateBuffer(ramp)
	return ramp.surface.find_entity(
		'RTMagnetRampDrain',
		{ ramp.position.x, ramp.position.y - 0.25 }
	)
end

local migrated

local function migrateRamp(surface, oldRamp)
	local buffer = locateBuffer(oldRamp)

	local range = 0
	if buffer then range = buffer.electric_buffer_size / 200000 end

	local creationParameters = {
		name = oldRamp.name,
		position = oldRamp.position,
		direction = oldRamp.direction,
		force = oldRamp.force,
		create_build_effect_smoke = false,
		raise_built = false
	}
	
	oldRamp.destroy()
	buffer.destroy()

	local migratedRamp = { tiles = {}}
	
	migratedRamp.entity = surface.create_entity(creationParameters)
	
	if migratedRamp.entity == nil then
		game.print('Failed to migrate ' .. creationParameters.name .. ' at ' .. util.positiontostr(creationParameters.position))
	else
		migratedRamp.power = handleMagnetRampBuilt(migratedRamp.entity)
		migratedRamp.power.energy = migratedRamp.power.electric_buffer_size
		if range ~= 0 then magnetRamps.setRange(migratedRamp, range) end

		global.MagnetRamps[migratedRamp.entity.unit_number] = migratedRamp
		migrated = migrated + 1
	end
end

for name, surface in pairs(game.surfaces) do
	for _, tile in pairs(surface.find_entities_filtered({name='RTMagnetRail'})) do
		tile.destroy()
	end

	for _, oldRamp in pairs(surface.find_entities_filtered({name="RTMagnetTrainRamp"})) do
		migrateRamp(surface, oldRamp)
	end
	
	for _, oldRamp in pairs(surface.find_entities_filtered({name="RTMagnetTrainRampNoSkip"})) do
		migrateRamp(surface, oldRamp)
	end
end

game.print("Successfully migrated " .. migrated .. " magnet ramps")

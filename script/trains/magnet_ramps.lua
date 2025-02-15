local math2d = require('math2d')

local magnetRamps = {}
--get_or_create_control_behavior().circuit_condition = {constant = 5}
--get_or_create_control_behavior().circuit_condition.constant
magnetRamps.setRange = function (RampProperties, range, player, message, rail, LastSignal)
	if (range == nil) then -- new ramp or ghost built
		local CurrentRange = RampProperties.entity.get_or_create_control_behavior().circuit_condition.constant
		if (CurrentRange > 0) then -- new ramps won't have a range set
			range = CurrentRange-6
			RampProperties.range = CurrentRange
		else -- ghosts will have range/elevated modifiers copied on them
			RampProperties.range = 0
		end
	else -- range adjusted by player or swap between schedule skipping
		RampProperties.range = range + 6 -- +3 compensates for half the length of the train
		local signal = "DirectorBouncePlateRight"
		if (rail) then
			if (RampProperties.entity.rail_layer == defines.rail_layer.elevated and rail.name ~= "elevated-straight-rail") then
				signal = "DirectorBouncePlateDown"
			end
			if (RampProperties.entity.rail_layer == defines.rail_layer.ground and rail.name == "elevated-straight-rail") then
				signal = "DirectorBouncePlateUp"
			end
		end
		if (LastSignal and LastSignal.first_signal) then
			signal = LastSignal.first_signal.name
		end
		RampProperties.entity.get_or_create_control_behavior().circuit_condition =
			{
				constant = RampProperties.range,
				first_signal = {type = "virtual", name = signal},
			}
	end

	if (range ~= nil) then -- setup new magnet rail tiles and adjust power buffer 
		if RampProperties.rangeID then RampProperties.rangeID.destroy() end
		for each, tile in pairs(RampProperties.tiles) do tile.destroy() end
		RampProperties.tiles = {}

		local orientationComponent = storage.OrientationUnitComponents[RampProperties.entity.orientation]

		for i = 1, range do
			local offset = math2d.position.multiply_scalar(orientationComponent, -i)
			local centerPosition = math2d.position.add(RampProperties.entity.position, offset)

			local a, b = makeMagRampSection(centerPosition, RampProperties.entity.surface, RampProperties.entity.orientation)
			table.insert(RampProperties.tiles, a)
			table.insert(RampProperties.tiles, b)
		end
		RampProperties.power.electric_buffer_size = 200000 * range

		if player and message and message == true then
			player.print({"magnet-ramp-stuff.set", range, util.format_number(RampProperties.power.electric_buffer_size, true)})
		end
	end
end

function makeMagRampSection(centerPosition, surface, orientation)
	local offsets = {
		a = math2d.position.rotate_vector({ 0.9, 0 }, 360 * orientation),
		b = math2d.position.rotate_vector({-0.1, 0 }, 360 * orientation),
	}

	local a = surface.create_entity({
		name = "RTMagnetRail",
		position = math2d.position.add(centerPosition, offsets.a),
		create_build_effect_smoke = true
	})
	a.destructible = false

	local b = surface.create_entity({
		name = "RTMagnetRail",
		position = math2d.position.add(centerPosition, offsets.b),
		create_build_effect_smoke = true
	})
	b.destructible = false

	return a, b
end

return magnetRamps

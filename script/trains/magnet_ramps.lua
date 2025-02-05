local math2d = require('math2d')

local magnetRamps = {}
--get_or_create_control_behavior().circuit_condition = {constant = 5}
--get_or_create_control_behavior().circuit_condition.constant
magnetRamps.setRange = function (ramp, range, player, message)
	local CurrentSetting = ramp.entity.get_or_create_control_behavior().circuit_condition.constant
	if (range == nil) then
		if (CurrentSetting > 0) then
			range = CurrentSetting-3
			ramp.range = CurrentSetting
		else
			ramp.range = 0
		end
	else
		ramp.range = range + 3
		ramp.entity.get_or_create_control_behavior().circuit_condition = {constant = ramp.range}
	end

	if (range ~= nil) then
		if ramp.rangeID then ramp.rangeID.destroy() end
		for each, tile in pairs(ramp.tiles) do tile.destroy() end
		ramp.tiles = {}

		local orientationComponent = storage.OrientationUnitComponents[ramp.entity.orientation]

		for i = 1, range do
			local offset = math2d.position.multiply_scalar(orientationComponent, -i)
			local centerPosition = math2d.position.add(ramp.entity.position, offset)

			local a, b = makeMagRampSection(centerPosition, ramp.entity.surface, ramp.entity.orientation)
			table.insert(ramp.tiles, a)
			table.insert(ramp.tiles, b)
		end
		ramp.power.electric_buffer_size = 200000 * range

		if player and message and message == true then
			player.print({"magnet-ramp-stuff.set", range, util.format_number(ramp.power.electric_buffer_size, true)})
		end
	end
end

function makeMagRampSection(centerPosition, surface, orientation)
	local offsets = {
		a = math2d.position.rotate_vector({ 0.5, 0.1 }, 360 * orientation),
		b = math2d.position.rotate_vector({-0.5, 0.1 }, 360 * orientation),
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

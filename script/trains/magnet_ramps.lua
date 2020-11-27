local math2d = require('math2d')

local magnetRamps = {}

magnetRamps.setRange = function (ramp, range, player)
	ramp.range = range + 6

	if ramp.rangeID then rendering.destroy(ramp.rangeID) end
	for each, tile in pairs(ramp.tiles) do tile.destroy() end
	ramp.tiles = {}

	ramp.rangeID = rendering.draw_sprite{
		sprite = "RTMagnetTrainRampRange",
		surface = ramp.entity.surface,
		orientation = ramp.entity.orientation+0.25,
		target = ramp.entity,
		target_offset = {
				global.OrientationUnitComponents[ramp.entity.orientation+0.25].x-(range+1)/2*global.OrientationUnitComponents[ramp.entity.orientation].x,
				global.OrientationUnitComponents[ramp.entity.orientation+0.25].y-(range+1)/2*global.OrientationUnitComponents[ramp.entity.orientation].y
			},
		only_in_alt_mode = true,
		x_scale = range / 2,
		y_scale = 0.5,
		tint = {r = 0.5, g = 0.5, b = 0, a = 0.5}
	}

	local orientationComponent = global.OrientationUnitComponents[ramp.entity.orientation]

	for i = 1, range do
		local offset = math2d.position.multiply_scalar(orientationComponent, -i)
		local centerPosition = math2d.position.add(ramp.entity.position, offset)

		local a, b = makeMagRampSection(centerPosition, ramp.entity.surface, ramp.entity.orientation)
		table.insert(ramp.tiles, a)		
		table.insert(ramp.tiles, b)		
	end
	ramp.power.electric_buffer_size = 200000 * range

	if player then
		player.print("Set Range: " .. range .. " tiles. Required power: " .. util.format_number(ramp.power.electric_buffer_size, true) .. "J")
	end
end

function makeMagRampSection(centerPosition, surface, orientation)
	local offsets = {
		a = math2d.position.rotate_vector({ 0.5, 0 }, 360 * orientation),
		b = math2d.position.rotate_vector({ 1.5, 0 }, 360 * orientation),
	}

	local a = surface.create_entity({
		name = "RTMagnetRail",
		position = math2d.position.add(centerPosition, offsets.a),
		create_build_effect_smoke = true
	})
	rendering.draw_sprite{
			sprite = "RTMagnetRailSprite",
			x_scale = 0.5,
			y_scale = 0.5,
			surface = surface,
			target = a,
			render_layer = "80"
		}
	a.destructible = false

	local b = surface.create_entity({
		name = "RTMagnetRail",
		position = math2d.position.add(centerPosition, offsets.b),
		create_build_effect_smoke = true
	})
	rendering.draw_sprite{
			sprite = "RTMagnetRailSprite",
			x_scale = 0.5,
			y_scale = 0.5,
			surface = surface,
			target = b,
			render_layer = "80"
		}
	b.destructible = false

	return a, b
end

return magnetRamps

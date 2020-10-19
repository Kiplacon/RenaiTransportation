local baseLoco = data.raw['locomotive']['locomotive']

data:extend{
	{
		type = "locomotive",
		name = "RT-ghostLocomotive",
		icon = baseLoco.icon,
		icon_size = 64, icon_mipmaps = 4,
		flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "hidden", "not-selectable-in-game"},
		collision_box = baseLoco.collision_box,
		max_health = 1,
		weight = 0.000000001,
		max_speed = 999,
		max_power = "1J",
		braking_power = "1J",
		reversing_power_modifier = 0,
		friction = 0.00000000001,
		air_resistance = 0.000000000001, -- this is a percentage of current speed that will be subtracted
		connection_distance = 3,
		joint_distance = 4,
		energy_source = {type = "void"},
		vertical_selection_shift = -0.5,
		energy_per_hit_point = 0,
		pictures = {
			direction_count = 1,
			filename = "__core__/graphics/empty.png",
			width = 1,
			height = 1
		}
	}
}

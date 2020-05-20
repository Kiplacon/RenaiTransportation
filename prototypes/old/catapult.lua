data:extend({
	{ -------- The catapult entity-----------
		type = "container",
		name = "Catapult",
		icon = "__Kupo__/graphics/Catapult/icon.png",
		icon_size = 32, --icon_mipmaps = 4,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.1, result = "CatapultItem"},
		max_health = 69,
		corpse = "small-remnants",
		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		--damaged_trigger_effect = hit_effects.entity(),
		inventory_size = 1,
		open_sound = { filename = "__base__/sound/metallic-chest-open.ogg" },
		close_sound = { filename = "__base__/sound/metallic-chest-close.ogg" },
		picture =
		{
		  layers =
		  {
			{
			  filename = "__Kupo__/graphics/Catapult/icon.png",
			  priority = "extra-high",
			  width = 32,
			  height = 32,
			  shift = util.by_pixel(0.5, -2),
			  ---[[
			  hr_version =
			  {
				filename = "__Kupo__/graphics/Catapult/Catapult.png",
				priority = "extra-high",
				width = 64,
				height = 64,
				shift = util.by_pixel(0.5, -2),
				scale = 0.5
			  }--]]
			},
			{
			  filename = "__base__/graphics/entity/wooden-chest/wooden-chest-shadow.png",
			  priority = "extra-high",
			  width = 52,
			  height = 20,
			  shift = util.by_pixel(10, 6.5),
			  draw_as_shadow = true,
			  hr_version =
			  {
				filename = "__base__/graphics/entity/wooden-chest/hr-wooden-chest-shadow.png",
				priority = "extra-high",
				width = 104,
				height = 40,
				shift = util.by_pixel(10, 6.5),
				draw_as_shadow = true,
				scale = 0.5
			  }
			}
		  }
		},
		circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
		circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
		circuit_wire_max_distance = default_circuit_wire_max_distance
	},
	
	{ --------- The catapult item -------------
		type = "item",
		name = "CatapultItem",
		icon = "__Kupo__/graphics/Catapult/icon.png",
		icon_size = 32, --icon_mipmaps = 4,
		subgroup = "storage",
		order = "a[items]-a[wooden-chest]",
		place_result = "Catapult",
		stack_size = 50
	},
	
	{ --------- The catapult recipie ----------
		type = "recipe",
		name = "CatapultRecipie",
		enabled = true,
		energy_required = 1,
		ingredients = {{"stone", 1}},
		result = "CatapultItem"
	}
})
data:extend({
	{ --------- Bounce plate entity --------------
		type = "constant-combinator",
		name = "DirectorBouncePlate",
		icon = "__RenaiTransportation__/graphics/BouncePlates/DirectorBouncePlate/DirectorPlateIcon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation", "hide-alt-info"},
		minable = {mining_time = 0.2, result = "DirectorBouncePlate"},
		max_health = 200,
		corpse = "small-remnants",
        dying_explosion = "iron-chest-explosion",
		collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		collision_mask = BouncePadMask,
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		sprites =
			{
			layers =
				{
					{
						filename = "__RenaiTransportation__/graphics/BouncePlates/DirectorBouncePlate/shadow.png",
						priority = "medium",
						width = 66,
						height = 76,
						shift = util.by_pixel(8, -0.5),
						scale = 0.5
					},
					{
						filename = "__RenaiTransportation__/graphics/BouncePlates/DirectorBouncePlate/DirectorPlate.png",
						priority = "medium",
						width = 66,
						height = 76,
						shift = util.by_pixel(-0.5, -0.5),
						scale = 0.5
					}
				}
			},
		activity_led_sprites = {filename = "__RenaiTransportation__/graphics/nothing.png", size = 1},
		activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
		circuit_wire_connection_points = {{wire={}, shadow={}},{wire={}, shadow={}},{wire={}, shadow={}},{wire={}, shadow={}}},
		radius_visualisation_specification =
			{
				sprite =
					{
						filename = "__RenaiTransportation__/graphics/testalt.png",
						size = 640
					},
				draw_on_selection = false,
				distance = 10
			}
	},

	{ --------- The Bounce plate item -------------
		type = "item",
		name = "DirectorBouncePlate",
		icon = "__RenaiTransportation__/graphics/BouncePlates/DirectorBouncePlate/DirectorPlateIcon.png",
		icon_size = 64,
		subgroup = "RT",
		order = "a-b",
		place_result = "DirectorBouncePlate",
		stack_size = 50
	},

	{ --------- The Bounce plate recipe ----------
		type = "recipe",
		name = "DirectorBouncePlate",
		enabled = false,
		energy_required = 1,
		ingredients =
			{
				{type="item", name="RTBouncePlate", amount=1},
				{type="item", name="advanced-circuit", amount=2}
			},
		results = {
			{type="item", name="DirectorBouncePlate", amount=1}
		}
	},
})

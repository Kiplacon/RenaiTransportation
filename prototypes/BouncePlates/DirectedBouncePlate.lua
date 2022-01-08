ConnectionPoints =
    {
      shadow =
      {
        red = util.by_pixel(12, 14),
        green = util.by_pixel(5, 14)
      },
      wire =
      {
        red = util.by_pixel(11, 13),
        green = util.by_pixel(5, 12)
      }
    }

data:extend({

	{
		type = "sprite",
		name = "RTDirectedRangeOverlayRL",
		filename = "__RenaiTransportation__/graphics/testRL.png",
		size = 640
	},

	{
		type = "sprite",
		name = "RTDirectedRangeOverlayUD",
		filename = "__RenaiTransportation__/graphics/testUD.png",
		size = 640
	},

	{ --------- Bounce plate entity --------------
		type = "simple-entity-with-owner",
		name = "DirectedBouncePlate",
		icon = "__RenaiTransportation__/graphics/BouncePlates/DirectedBouncePlate/DirectedPlateIconn.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.2, result = "DirectedBouncePlateItem"},
		max_health = 200,
	    collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		--item_slot_count = 18,
		--circuit_wire_max_distance = 9,
		picture =
			{
			  sheets =
			  {
				{
					filename = "__RenaiTransportation__/graphics/BouncePlates/DirectedBouncePlate/DirectedPlateShadow.png",
					priority = "medium",
					width = 64,
					height = 64,
					shift = util.by_pixel(14,-0.5),
					scale = 0.5
				},
				{
					filename = "__RenaiTransportation__/graphics/BouncePlates/DirectedBouncePlate/DirectedPlate.png",
					priority = "medium",
					width = 64,
					height = 64,
					scale = 0.5
				}
			  }
			},
		activity_led_sprites =
			{
				filename = "__RenaiTransportation__/graphics/nothing.png",
				priority = "medium",
				width = 32,
				height = 32,
				shift = util.by_pixel(-0.5, -0.5),
				scale = 0.5
			},
		activity_led_light_offsets =
			{
			  {0.296875, -0.40625},
			  {0.25, -0.03125},
			  {-0.296875, -0.078125},
			  {-0.21875, -0.46875}
			},
		circuit_wire_connection_points =
		  {
			ConnectionPoints,
			ConnectionPoints,
			ConnectionPoints,
			ConnectionPoints
		  },
		radius_visualisation_specification =
			{
				sprite =
					{
						filename = "__RenaiTransportation__/graphics/testalt.png",
						size = 640
					},
				draw_on_selection = true,
				distance = 10
			}
	},

	{ --------- The Bounce plate item -------------
		type = "item",
		name = "DirectedBouncePlateItem",
		icon = "__RenaiTransportation__/graphics/BouncePlates/DirectedBouncePlate/DirectedPlateIconn.png",
		icon_size = 64, --icon_mipmaps = 4,
		subgroup = "RT",
		order = "a-a",
		place_result = "DirectedBouncePlate",
		stack_size = 50
	},

	{ --------- The Bounce plate recipie ----------
		type = "recipe",
		name = "DirectedBouncePlateRecipie",
		enabled = false,
		energy_required = 1,
		ingredients =
			{
				{"iron-plate", 5},
				{"automation-science-pack", 1}
			},
		result = "DirectedBouncePlateItem"
	}
})

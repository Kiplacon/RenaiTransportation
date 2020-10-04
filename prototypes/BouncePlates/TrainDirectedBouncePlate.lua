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

	{ --------- Bounce plate entity --------------
		type = "constant-combinator",
		name = "RTTrainDirectedBouncePlate",
		icon = "__RenaiTransportation__/graphics/BouncePlates/TrainBouncePlate/DirectedTrainPlate.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.5, result = "RTTrainDirectedBouncePlateItem"},
		max_health = 400,
	    collision_box = {{-1.75, -1.75}, {1.75, 1.75}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-2, -2}, {2, 2}},
		fast_replaceable_group = "TrainBouncers",
		item_slot_count = 18,
		circuit_wire_max_distance = 9,
		sprites = 
			{ 
			  sheets =
			  {
				{
					filename = "__RenaiTransportation__/graphics/BouncePlates/DirectedBouncePlate/DirectedPlateShadow.png",
					priority = "medium",
					width = 64,
					height = 64,
					shift = util.by_pixel(55,-2),
					scale = 2
				},
				{
					filename = "__RenaiTransportation__/graphics/BouncePlates/DirectedBouncePlate/DirectedPlate.png",
					priority = "medium",
					width = 64,
					height = 64,
					scale = 2
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
						filename = "__RenaiTransportation__/graphics/test2.png",
						size = 640
					},
				draw_on_selection = true,
				distance = 40
			}
	},
	
	{ --------- The Bounce plate item -------------
		type = "item",
		name = "RTTrainDirectedBouncePlateItem",
		icon = "__RenaiTransportation__/graphics/BouncePlates/TrainBouncePlate/DirectedTrainPlate.png",
		icon_size = 64, --icon_mipmaps = 4,
		subgroup = "RT",
		order = "i-a",
		place_result = "RTTrainDirectedBouncePlate",
		stack_size = 50
	},
	
	{ --------- The Bounce plate recipie ----------
		type = "recipe",
		name = "RTTrainDirectedBouncePlateRecipie",
		enabled = false,
		energy_required = 1,
		ingredients = 
			{
				{"iron-plate", 50},
				{"steel-plate", 30},
				{"automation-science-pack", 10}
			},
		result = "RTTrainDirectedBouncePlateItem"
	}
})
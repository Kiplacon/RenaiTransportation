data:extend({

	{ --------- Bounce plate entity --------------
		type = "simple-entity-with-owner",
		name = "RTTrainBouncePlate",
		icon = "__RenaiTransportation__/graphics/BouncePlates/TrainBouncePlate/TrainPlate.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.5, result = "RTTrainBouncePlateItem"},
		max_health = 400,
	    collision_box = {{-1.75, -1.25}, {1.75, 1.75}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-2, -1.75}, {2, 2}},
		fast_replaceable_group = "TrainBouncers",
		picture = 
			{
				layers =
					{
						{
							filename = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/shadow.png",
							priority = "medium",
							width = 66,
							height = 76,
							shift = util.by_pixel(33, -0.5),
							scale = 2
						},
						{
							filename = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/Plate.png",
							priority = "medium",
							width = 66,
							height = 76,
							shift = util.by_pixel(-0.5, -0.5),
							scale = 2
						}
					}
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
		name = "RTTrainBouncePlateItem",
		icon = "__RenaiTransportation__/graphics/BouncePlates/TrainBouncePlate/TrainPlate.png",
		icon_size = 64, --icon_mipmaps = 4,
		subgroup = "RT",
		order = "i",
		place_result = "RTTrainBouncePlate",
		stack_size = 50
	},
	
	{ --------- The Bounce plate recipe ----------
		type = "recipe",
		name = "RTTrainBouncePlateRecipe",
		enabled = false,
		energy_required = 1,
		ingredients = 
			{
				{type="item", name="iron-plate", amount=40},
				{type="item", name="steel-plate", amount=20},
				{type="item", name="automation-science-pack", amount=10}
			},
		results = {
			{type="item", name="RTTrainBouncePlateItem", amount=1}
		}
	},
	
	{ --------- bounce effect ----------
		type = "optimized-particle",
		name = "RTTrainBouncePlateParticle",
		life_time = 16,
		render_layer = "higher-object-above",
		pictures =
			{
			  filename = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/Particle.png",
			  --width = 64,
			  --height = 64,
			  size = 32,
			  priority = "extra-high",
			  line_length = 4, -- frames per row
			  frame_count = 4, -- total frames
			  animation_speed = 0.5,
			  scale = 4
			}
	}
})
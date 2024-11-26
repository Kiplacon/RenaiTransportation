data:extend({

	{ --------- Bounce plate entity --------------
		type = "simple-entity-with-owner",
		name = "PrimerBouncePlate",
		icon = "__RenaiTransportation__/graphics/BouncePlates/PrimerBouncePlate/PrimerPlateIconn.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.2, result = "PrimerBouncePlateItem"},
		max_health = 200,
	    collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		picture = 
			{
				filename = "__RenaiTransportation__/graphics/BouncePlates/PrimerBouncePlate/PrimerPlate.png",
				priority = "medium",
				width = 66,
				height = 76,
				shift = util.by_pixel(-0.5, -0.5),
				scale = 0.5
			},
		radius_visualisation_specification =
			{
				sprite = 
					{
						filename = "__RenaiTransportation__/graphics/PrimeRange.png",
						size = 640
					},
				draw_on_selection = true,
				distance = 40
			}
	},
	
	{ --------- The Bounce plate item -------------
		type = "item",
		name = "PrimerBouncePlateItem",
		icon = "__RenaiTransportation__/graphics/BouncePlates/PrimerBouncePlate/PrimerPlateIconn.png",
		icon_size = 64, --icon_mipmaps = 4,
		subgroup = "RT",
		order = "a-b",
		place_result = "PrimerBouncePlate",
		stack_size = 50
	},
	
	{ --------- The Bounce plate recipe ----------
		type = "recipe",
		name = "PrimerBouncePlateRecipe",
		enabled = false,
		energy_required = 1,
		ingredients = 
			{
				{type="item", name="BouncePlateItem", amount=1},
				{type="item", name="electronic-circuit", amount=2},
				{type="item", name="coal", amount=5}
			},
		results = {
			{type="item", name="PrimerBouncePlateItem", amount=1}
		}
	},
	
	{ --------- bounce effect ----------
		type = "optimized-particle",
		name = "PrimerBouncePlateParticle",
		life_time = 8,	
		pictures =
			{
			  filename = "__RenaiTransportation__/graphics/BouncePlates/PrimerBouncePlate/PrimerParticle.png",
			  --width = 64,
			  --height = 64,
			  size = 32,
			  priority = "extra-high",
			  line_length = 4, -- frames per row
			  frame_count = 4, -- total frames
			  animation_speed = 0.5
			}
	}
})

------ Adds the fast thrower to appropriate research -------	
table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="PrimerBouncePlateRecipe"})	
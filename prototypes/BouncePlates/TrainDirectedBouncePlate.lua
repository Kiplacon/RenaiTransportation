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
		type = "simple-entity-with-owner",
		name = "RTTrainDirectedBouncePlate",
		icon = "__RenaiTransportation__/graphics/BouncePlates/TrainBouncePlate/DirectedTrainPlate.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.5, result = "RTTrainDirectedBouncePlateItem"},
		max_health = 400,
	    collision_box = {{-1.75, -1.75}, {1.75, 1.75}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-2, -2}, {2, 2}},
		fast_replaceable_group = "TrainBouncers",
		picture = 
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
				{type="item", name="iron-plate", amount=50},
				{type="item", name="steel-plate", amount=30},
				{type="item", name="automation-science-pack", amount=10}
			},
		results = {
			{type="item", name="RTTrainDirectedBouncePlateItem", amount=1}
		}
	}
})
data:extend({
	{
		type = "sprite",
		name = "RTPrimerRangeOverlay",
		filename = renaiEntity .. "PrimerBouncePlate/PrimeRange.png",
		size = 640
	},
	{
		type = "sprite",
		name = "RTPrimerSpreadRangeOverlay",
		filename = renaiEntity .. "PrimerBouncePlate/PrimeSpreadRange.png",
		size = 640
	},
	
	{ --------- Bounce plate entity --------------
		type = "simple-entity-with-owner",
		name = "PrimerBouncePlate",
		icon = renaiIcons .. "PrimerPlateIconn.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.2, result = "PrimerBouncePlate"},
		max_health = 200,
		corpse = "small-remnants",
        dying_explosion = "iron-chest-explosion",
		collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		collision_mask = BouncePadMask,
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		picture =
		{
			layers =
			{
				{
					filename = renaiEntity .. "PrimerBouncePlate/Plate_shadow.png",
					priority = "medium",
					width = 66,
					height = 76,
					shift = util.by_pixel(8, -0.5),
				  draw_as_shadow = true,
					scale = 0.5
				},
				{
					filename = renaiEntity .. "PrimerBouncePlate/PrimerPlate.png",
					priority = "medium",
					width = 66,
					height = 76,
					shift = util.by_pixel(-0.5, -0.5),
					scale = 0.5
				},
			}
		},
		radius_visualisation_specification =
			{
				sprite = 
					{
						filename = renaiEntity .. "PrimerBouncePlate/PrimeRange.png",
						size = 640
					},
				draw_on_selection = false,
				distance = 40
			}
	},
	{ --------- The Bounce plate item -------------
		type = "item",
		name = "PrimerBouncePlate",
		icon = renaiIcons .. "PrimerPlateIconn.png",
		icon_size = 64,
		subgroup = "RT",
		order = "a-b",
		place_result = "PrimerBouncePlate",
		stack_size = 50
	},
	{ --------- The Bounce plate recipe ----------
		type = "recipe",
		name = "PrimerBouncePlate",
		enabled = false,
		energy_required = 1,
		ingredients = 
			{
				{type="item", name="RTBouncePlate", amount=1},
				{type="item", name="electronic-circuit", amount=2},
				{type="item", name="coal", amount=5}
			},
		results = {
			{type="item", name="PrimerBouncePlate", amount=1}
		}
	},
	
	{ --------- bounce effect ----------
		type = "optimized-particle",
		name = "PrimerBouncePlateParticle",
		life_time = 8,
		render_layer = "higher-object-above",		
		pictures =
			{
				filename = renaiEntity .. "PrimerBouncePlate/PrimerParticle.png",
				--width = 64,
				--height = 64,
				size = 32,
				priority = "extra-high",
				line_length = 4, -- frames per row
				frame_count = 4, -- total frames
				animation_speed = 0.5
			}
	},
	--------------------------- Spread mode -------------
	{ --------- Spread mode entity --------------
		type = "simple-entity-with-owner",
		name = "PrimerSpreadBouncePlate",
		icon = renaiIcons .. "PrimerPlateIconn.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.2, result = "PrimerBouncePlate"},
		placeable_by = {item = "PrimerBouncePlate", count = 1},
		max_health = 200,
		corpse = "small-remnants",
        dying_explosion = "iron-chest-explosion",
		collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		collision_mask = BouncePadMask,
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		picture = 
		{
			layers =
			{
				{
					filename = renaiEntity .. "BouncePlate/Plate_shadow.png",
					priority = "medium",
					width = 66,
					height = 76,
					shift = util.by_pixel(8, -0.5),
					draw_as_shadow = true,
					scale = 0.5
				},
				{
					filename = renaiEntity .. "PrimerBouncePlate/PrimerSpreadPlate.png",
					priority = "medium",
					width = 66,
					height = 76,
					shift = util.by_pixel(-0.5, -0.5),
					scale = 0.5
				}
			}
		},
		radius_visualisation_specification =
		{
			sprite = 
			{
				filename = renaiEntity .. "PrimerBouncePlate/PrimeSpreadRange.png",
				size = 640
			},
			draw_on_selection = true,
			distance = 40
		}
	},

	{
		type = "technology",
		name = "PrimerPlateTech",
		icon = renaiTechIcons .. "PrimerPlateIconn.png",
		icon_size = 256,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "PrimerBouncePlate"
			}
		},
		prerequisites = {"se-no", "military-2"},
		unit =
		{
			count = 25,
			ingredients =
			{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1}
			},
			time = 25
		}
	},
})
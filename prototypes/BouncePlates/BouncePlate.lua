data:extend({

	{
		type = "sprite",
		name = "RTRangeOverlay",
		filename = "__RenaiTransportation__/graphics/test.png",
		size = 640
	},

	{ --------- Bounce plate entity --------------
		type = "simple-entity-with-owner",
		name = "BouncePlate",
		icon = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/PlateIconn.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.2, result = "BouncePlateItem"},
		max_health = 200,
	    collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		picture =
			{
			layers =
				{
					{
						filename = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/shadow.png",
						priority = "medium",
						width = 66,
						height = 76,
						shift = util.by_pixel(8, -0.5),
						scale = 0.5
					},
					{
						filename = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/Plate.png",
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
						filename = "__RenaiTransportation__/graphics/testalt.png",
						size = 640
					},
				draw_on_selection = true,
				distance = 10
			}
	},

	{ --------- The Bounce plate item -------------
		type = "item",
		name = "BouncePlateItem",
		icon = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/PlateIconn.png",
		icon_size = 64, --icon_mipmaps = 4,
		subgroup = "RT",
		order = "a",
		place_result = "BouncePlate",
		stack_size = 50
	},

	{ --------- The Bounce plate recipie ----------
		type = "recipe",
		name = "BouncePlateRecipie",
		enabled = true,
		energy_required = 1,
		ingredients =
			{
				{type="item", name="iron-plate", amount=4},
				{type="item", name="automation-science-pack", amount=1}
			},
		results = {
			{type="item", name="BouncePlateItem", amount=1}
		}
	},

	{ --------- bounce effect ----------
		type = "optimized-particle",
		name = "BouncePlateParticle",
		life_time = 8,
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
			  animation_speed = 0.5
			}
	}
})

local colors = {
	red = {255,0,0,255},
	green = {0,255,0,255},
	orange = {233,138,22,255},
	blue = {0,0,255,255},
	yellow = {255,255,0,255}
}
for color, tint in pairs(colors) do
	data:extend({
		{ --------- colorless bounce effect ----------
			type = "optimized-particle",
			name = "BouncePlateParticle"..color,
			life_time = 8,
			render_layer = "higher-object-above",
			pictures =
				{
				  filename = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/Particle2.png",
				  tint = tint,
				  size = 32,
				  priority = "extra-high",
				  line_length = 4, -- frames per row
				  frame_count = 4, -- total frames
				  animation_speed = 0.5
				}
		}
	})
end


data:extend({

	{ --------- Bounce plate entity 5 --------------
		type = "simple-entity-with-owner",
		name = "BouncePlate5",
		icon = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/PlateIconn.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.2, result = "BouncePlateItem"},
		placeable_by = {item="BouncePlateItem", count=1},
		max_health = 200,
	   collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		picture =
			{
			layers =
				{
					{
						filename = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/shadow.png",
						priority = "medium",
						width = 66,
						height = 76,
						shift = util.by_pixel(8, -0.5),
						scale = 0.5
					},
					{
						filename = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/Plate.png",
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
						filename = "__RenaiTransportation__/graphics/testalt.png",
						size = 640
					},
				draw_on_selection = true,
				distance = 5
			}
	},
	{ --------- Bounce plate entity 15 --------------
		type = "simple-entity-with-owner",
		name = "BouncePlate15",
		icon = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/PlateIconn.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.2, result = "BouncePlateItem"},
		placeable_by = {item="BouncePlateItem", count=1},
		max_health = 200,
		collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		picture =
			{
			layers =
				{
					{
						filename = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/shadow.png",
						priority = "medium",
						width = 66,
						height = 76,
						shift = util.by_pixel(8, -0.5),
						scale = 0.5
					},
					{
						filename = "__RenaiTransportation__/graphics/BouncePlates/BouncePlate/Plate.png",
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
						filename = "__RenaiTransportation__/graphics/testalt.png",
						size = 640
					},
				draw_on_selection = true,
				distance = 15
			}
	},

})

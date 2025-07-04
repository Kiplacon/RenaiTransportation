data:extend({

	{
		type = "sprite",
		name = "RTRangeOverlay",
		filename = "__RenaiTransportation__/graphics/test.png",
		size = 640
	},
	{ --------- Bounce plate entity --------------
		type = "constant-combinator",
		name = "RTBouncePlate",
		icon = renaiIcons .. "BouncePlate.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation", "hide-alt-info"},
		minable = {mining_time = 0.2, result = "RTBouncePlate"},
		max_health = 200,
		corpse = "small-remnants",
        dying_explosion = "iron-chest-explosion",
		collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		collision_mask = BouncePadMask,
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		activity_led_sprites = {filename = "__RenaiTransportation__/graphics/nothing.png", size = 1},
		activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
		circuit_wire_connection_points = {{wire={}, shadow={}},{wire={}, shadow={}},{wire={}, shadow={}},{wire={}, shadow={}}},
		sprites =
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
					filename = renaiEntity .. "BouncePlate/Plate.png",
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
				filename = "__RenaiTransportation__/graphics/testalt2.png",
				size = 1280
			},
			draw_on_selection = false,
			distance = 10
		}
	},

	{ --------- The Bounce plate item -------------
		type = "item",
		name = "RTBouncePlate",
		icon = renaiIcons .. "BouncePlate.png",
		icon_size = 64,
		subgroup = "RT",
		order = "a",
		place_result = "RTBouncePlate",
		stack_size = 50
	},

	{ --------- The Bounce plate recipe ----------
		type = "recipe",
		name = "RTBouncePlate",
		enabled = true,
		energy_required = 1,
		ingredients =
			{
				{type="item", name="iron-plate", amount=4},
				{type="item", name="automation-science-pack", amount=1}
			},
		results = {
			{type="item", name="RTBouncePlate", amount=1}
		}
	},

	{ --------- bounce effect ----------
		type = "optimized-particle",
		name = "BouncePlateParticle",
		life_time = 8,
		render_layer = "higher-object-above",
		pictures =
			{
				filename = renaiEntity .. "BouncePlate/Particle.png",
				size = 32,
				priority = "extra-high",
				line_length = 4, -- frames per row
				frame_count = 4, -- total frames
				animation_speed = 0.5
			}
	},
	{ --------- bounce effect ----------
		type = "optimized-particle",
		name = "RTTestParticle",
		life_time = 60*5,
		render_layer = "under-elevated",
		pictures =
			{
				filename = renaiEntity .. "meme/LickmawBALLS.png",
				size = 64,
				scale = 0.3,
				priority = "high",
				line_length = 1, -- frames per row
				frame_count = 1, -- total frames
			},
		shadows =
			{
				filename = renaiEntity .. "meme/LickmawBALLS.png",
				size = 64,
				scale = 0.3,
				priority = "high",
				line_length = 1, -- frames per row
				frame_count = 1, -- total frames
			},
		draw_shadow_when_on_ground = false,
		--regular_trigger_effect = {type="script", effect_id="RTTestProjectileRegularEffect"}, -- while in flight
		--regular_trigger_effect_frequency = 30, -- how ofter while in flight
		ended_in_water_trigger_effect = {type="script", effect_id="RTTestProjectileWaterEffect"}, -- the particle is destroyed when it hits the water regardless if this is defined or not
		ended_on_ground_trigger_effect = {type="script", effect_id="RTTestProjectileGroundEffect"}, -- destroys the particle once it hits the ground in addition to the effect
		--movement_modifier_when_on_ground = 0 -- > 1 means it speeds up when on the ground, 0 means it stops, < 1 means it slows down
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
				  filename = renaiEntity .. "BouncePlate/Particle2.png",
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
		icon = renaiIcons .. "BouncePlate.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		hidden = true,
		minable = {mining_time = 0.2, result = "RTBouncePlate"},
		placeable_by = {item="RTBouncePlate", count=1},
		max_health = 200,
	   	collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
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
					filename = renaiEntity .. "BouncePlate/Plate.png",
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
				filename = "__RenaiTransportation__/graphics/testalt2.png",
				size = 1280
			},
			draw_on_selection = true,
			distance = 5
		}
	},
	{ --------- Bounce plate entity 15 --------------
		type = "simple-entity-with-owner",
		name = "BouncePlate15",
		icon = renaiIcons .. "BouncePlate.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		hidden = true,
		minable = {mining_time = 0.2, result = "RTBouncePlate"},
		placeable_by = {item="RTBouncePlate", count=1},
		max_health = 200,
		collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
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
					filename = renaiEntity .. "BouncePlate/Plate.png",
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
				filename = "__RenaiTransportation__/graphics/testalt2.png",
				size = 1280
			},
			draw_on_selection = true,
			distance = 15
		}
	},

})

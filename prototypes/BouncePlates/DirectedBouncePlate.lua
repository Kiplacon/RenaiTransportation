data:extend({

	{
		type = "sprite",
		name = "RTDirectedRangeOverlayRL",
		filename = "__RenaiTransportation__/graphics/testRL2.png",
		size = 1280,
      scale = 0.5
	},

	{
		type = "sprite",
		name = "RTDirectedRangeOverlayUD",
		filename = "__RenaiTransportation__/graphics/testUD2.png",
		size = 1280,
      scale = 0.5
	},

	{ --------- Bounce plate entity --------------
		type = "constant-combinator",
		name = "DirectedBouncePlate",
		icon = renaiIcons .. "DirectedPlateIconn.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation", "hide-alt-info"},
		minable = {mining_time = 0.2, result = "DirectedBouncePlate"},
		max_health = 200,
      corpse = "small-remnants",
      dying_explosion = "iron-chest-explosion",
      collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
      collision_mask = BouncePadMask,
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
      activity_led_sprites = emptypic,
		activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
		circuit_wire_connection_points = {{wire={}, shadow={}},{wire={}, shadow={}},{wire={}, shadow={}},{wire={}, shadow={}}},
		sprites =
			{
            sheets =
            {
               {
                  filename = renaiEntity .. "DirectedBouncePlate/DirectedPlateShadow.png",
                  priority = "medium",
                  width = 64,
                  height = 64,
                  shift = util.by_pixel(14,-0.5),
                  draw_as_shadow = true,
                  scale = 0.5
               },
               {
                  filename = renaiEntity .. "DirectedBouncePlate/DirectedPlate.png",
                  priority = "medium",
                  width = 64,
                  height = 64,
                  scale = 0.5
               }
            }
			},
		radius_visualisation_specification =
			{
				sprite =
					{
						filename = "__RenaiTransportation__/graphics/testalt2.png",
						size = 1280,
                  scale = 0.5,
					},
				draw_on_selection = false,
				distance = 10
			}
	},
   { --------- left for migration
      type = "simple-entity-with-owner",
      name = "DirectedBouncePlate5",
      icon = renaiIcons .. "DirectedPlateIconn.png",
      icon_size = 64,
      flags = {"placeable-neutral", "player-creation"},
      hidden = true,
      max_health = 200,
      collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      fast_replaceable_group = "bouncers",
      picture =
         {
            sheets =
            {
               {
                  filename = renaiEntity .. "DirectedBouncePlate/DirectedPlateShadow.png",
                  priority = "medium",
                  width = 64,
                  height = 64,
                  shift = util.by_pixel(14,-0.5),
                  draw_as_shadow = true,
                  scale = 0.5
               },
               {
                  filename = renaiEntity .. "DirectedBouncePlate/DirectedPlate.png",
                  priority = "medium",
                  width = 64,
                  height = 64,
                  scale = 0.5
               }
            }
         },
   },
   { --------- left for migration
      type = "simple-entity-with-owner",
      name = "DirectedBouncePlate15",
      icon = renaiIcons .. "DirectedPlateIconn.png",
      icon_size = 64,
      flags = {"placeable-neutral", "player-creation"},
      hidden = true,
      minable = {mining_time = 0.2, result = "DirectedBouncePlate"},
      placeable_by = {item="DirectedBouncePlate", count=1},
      max_health = 200,
      collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      fast_replaceable_group = "bouncers",
      picture =
         {
            sheets =
            {
               {
                  filename = renaiEntity .. "DirectedBouncePlate/DirectedPlateShadow.png",
                  priority = "medium",
                  width = 64,
                  height = 64,
                  shift = util.by_pixel(14,-0.5),
                  draw_as_shadow = true,
                  scale = 0.5
               },
               {
                  filename = renaiEntity .. "DirectedBouncePlate/DirectedPlate.png",
                  priority = "medium",
                  width = 64,
                  height = 64,
                  scale = 0.5
               }
            }
         },
   },
	{ --------- The Bounce plate item -------------
		type = "item",
		name = "DirectedBouncePlate",
		icon = renaiIcons .. "DirectedPlateIconn.png",
		icon_size = 64,
		subgroup = "RT",
		order = "a-a",
		place_result = "DirectedBouncePlate",
		stack_size = 50
	},

	{ --------- The Bounce plate recipe ----------
		type = "recipe",
		name = "DirectedBouncePlate",
		enabled = false,
		energy_required = 1,
		ingredients =
			{
				{type="item", name="iron-plate", amount=5},
				{type="item", name="automation-science-pack", amount=1}
			},
      results = {
			{type="item", name="DirectedBouncePlate", amount=1}
		}
	}
})

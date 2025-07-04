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
		type = "constant-combinator",
		name = "DirectedBouncePlate",
		icon = "__RenaiTransportation__/graphics/BouncePlates/DirectedBouncePlate/DirectedPlateIconn.png",
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
      activity_led_sprites = {filename = "__RenaiTransportation__/graphics/nothing.png", size = 1},
		activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
		circuit_wire_connection_points = {{wire={}, shadow={}},{wire={}, shadow={}},{wire={}, shadow={}},{wire={}, shadow={}}},
		sprites =
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
   { --------- left for migration
      type = "simple-entity-with-owner",
      name = "DirectedBouncePlate5",
      icon = "__RenaiTransportation__/graphics/BouncePlates/DirectedBouncePlate/DirectedPlateIconn.png",
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
   },
   { --------- left for migration
      type = "simple-entity-with-owner",
      name = "DirectedBouncePlate15",
      icon = "__RenaiTransportation__/graphics/BouncePlates/DirectedBouncePlate/DirectedPlateIconn.png",
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
   },
	{ --------- The Bounce plate item -------------
		type = "item",
		name = "DirectedBouncePlate",
		icon = "__RenaiTransportation__/graphics/BouncePlates/DirectedBouncePlate/DirectedPlateIconn.png",
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

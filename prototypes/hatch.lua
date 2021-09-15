data:extend({

{
type = "simple-entity-with-owner",
name = "HatchRT",
icon = "__RenaiTransportation__/graphics/hatch/icon.png",
icon_size = 16,
flags = {"placeable-neutral", "player-creation", "not-rotatable"},
collision_mask = {"layer-51"},
collision_box = {{-0.35, -0.3}, {0.35, 0.55}},
selection_box = {{-0.35, -0.3}, {0.35, 0.55}},
selection_priority = 255,
minable = {mining_time = 0.2, result = "HatchRTItem"},
render_layer = "higher-object-under",
picture =
	{
		filename = "__RenaiTransportation__/graphics/hatch/hatch.png",
		width = 28,
		height = 42,
		scale = 0.75
	}
},

{ --------- The hatch item -------------
	type = "item",
	name = "HatchRTItem",
	icon = "__RenaiTransportation__/graphics/hatch/icon.png",
	icon_size = 64, --icon_mipmaps = 4,
	subgroup = "RT",
	order = "f",
	place_result = "HatchRT",
	stack_size = 50
},

{ --------- The hatch recipie ----------
	type = "recipe",
	name = "HatchRTRecipe",
	enabled = false,
	energy_required = 1,
	ingredients =
		{
			{"pipe-to-ground", 1},
			{"pipe", 1},
			{"copper-plate", 2}
		},
	result = "HatchRTItem"
}
})

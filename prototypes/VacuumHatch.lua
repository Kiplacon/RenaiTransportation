data:extend({
---- vacuum hatch ----
{
	type = "simple-entity-with-owner",
	name = "RTVacuumHatch",
	icon = "__RenaiTransportation__/graphics/hatch/vacuumhatchicon.png",
	icon_size = 64,
	flags = {"placeable-neutral", "player-creation",  "not-rotatable"},
	collision_mask = {layers={["RTHatches"]=true}},
	collision_box = {{-0.35, -0.3}, {0.35, 0.55}},
	selection_box = {{-0.35, -0.3}, {0.35, 0.55}},
	selection_priority = 255,
	minable = {mining_time = 0.2, result = "RTVacuumHatchItem"},
	render_layer = "arrow",
	picture =
		{
			filename = "__RenaiTransportation__/graphics/hatch/vacuumhatch.png",
			width = 28,
			height = 42,
			scale = 0.75
		},
	radius_visualisation_specification = {
		sprite = {
			filename = "__RenaiTransportation__/graphics/TrainRamp/range.png",
			size = 64,
			tint = {163, 73, 164}
		},
		draw_on_selection = true,
		distance = 4
	}
},
{ --------- The vacuum hatch recipe ----------
	type = "recipe",
	name = "RTVacuumHatchRecipe",
	enabled = false,
	energy_required = 1,
	ingredients =
		{
			{type="item", name="HatchRTItem", amount=1},
			{type="item", name="pump", amount=1},
			{type="item", name="electronic-circuit", amount=2}
		},
	results = {
		{type="item", name="RTVacuumHatchItem", amount=1}
	}

},
{ --------- The vacuum hatch item -------------
	type = "item",
	name = "RTVacuumHatchItem",
	icon = "__RenaiTransportation__/graphics/hatch/vacuumhatchicon.png",
	icon_size = 64,
	subgroup = "RT",
	order = "f-c",
	place_result = "RTVacuumHatch",
	stack_size = 50
},

})

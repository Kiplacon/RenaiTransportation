data:extend({
---- vacuum hatch ----
{
	type = "electric-energy-interface",
	name = "RTVacuumHatch",
	icon = "__RenaiTransportation__/graphics/hatch/vacuumhatchicon.png",
	icon_size = 64,
	flags = {"placeable-neutral", "player-creation"},
	max_health = 150,
	--collision_mask = {layers={["RTHatches"]=true}},
	collision_box = {{-0.49, -0.49}, {0.49, 0.49}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	--selection_priority = 255,
	minable = {mining_time = 0.5, result = "RTVacuumHatchItem"},
	energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			buffer_capacity = "3kJ",
		},
	energy_usage = "200kW",
	gui_mode = "none",
	pictures =
	{
		sheet=
		{
			filename = "__RenaiTransportation__/graphics/hatch/vacuumhatch.png",
			size = 64,
			scale = 0.5
		},
	},
	--render_layer = "arrow",
	radius_visualisation_specification = {
		sprite = {
			filename = "__RenaiTransportation__/graphics/TrainRamp/range.png",
			size = 64,
			tint = {1, 0.5, 0}
		},
		draw_on_selection = true,
		distance = 2.5,
		offset = {0, -3},
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

{
	type = "sprite",
	name = "VacuumHatchConnectorup",
	filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-N.png",
	width = 71,
	height = 38,
	shift = {0, 0.5},
	scale = 0.5
},
{
	type = "sprite",
	name = "VacuumHatchConnectorright",
	filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-E.png",
	width = 42,
	height = 76,
	shift = {-0.5, 0},
	scale = 0.5
},
{
	type = "sprite",
	name = "VacuumHatchConnectordown",
	filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-S.png",
	width = 88,
	height = 61,
	shift = {0, -0.5},
	scale = 0.5
},
{
	type = "sprite",
	name = "VacuumHatchConnectorleft",
	filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-W.png",
	width = 39,
	height = 73,
	shift = {0.5, 0},
	scale = 0.5
},
})

data:extend({
---- vacuum hatch ----
{
	type = "electric-energy-interface",
	name = "RTVacuumHatch",
	icon = "__RenaiTransportation__/graphics/hatch/vacuumhatchicon.png",
	icon_size = 64,
	flags = {"placeable-neutral", "player-creation"},
	max_health = 150,
	corpse = "medium-remnants",
	dying_explosion = "iron-chest-explosion",
	--collision_mask = {layers={["RTHatches"]=true}},
	collision_box = {{-0.49, -0.49}, {0.49, 0.49}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	--selection_priority = 255,
	minable = {mining_time = 0.5, result = "RTVacuumHatch"},
	energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			buffer_capacity = "25J", -- for some reason this helps the animation play slow enough to actually see
			drain = "5kW",
		},
	energy_usage = "200kW",
	gui_mode = "none",
	animations =
	{
		north =
		{
			filename = "__RenaiTransportation__/graphics/hatch/VacuumHatchN.png",
			frame_count = 4,
			line_length = 4,
			size = 80,
			scale = 0.6,
			animation_speed = 0.01
		},
		east =
		{
			filename = "__RenaiTransportation__/graphics/hatch/VacuumHatchE.png",
			frame_count = 4,
			line_length = 4,
			size = 80,
			scale = 0.6,
			animation_speed = 0.01
		},
		south =
		{
			filename = "__RenaiTransportation__/graphics/hatch/VacuumHatchS.png",
			frame_count = 4,
			line_length = 4,
			size = 80,
			scale = 0.6,
			animation_speed = 0.01
		},
		west =
		{
			filename = "__RenaiTransportation__/graphics/hatch/VacuumHatchW.png",
			frame_count = 4,
			line_length = 4,
			size = 80,
			scale = 0.6,
			animation_speed = 0.01
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
	name = "RTVacuumHatch",
	enabled = false,
	energy_required = 1,
	ingredients =
		{
			{type="item", name="HatchRT", amount=1},
			{type="item", name="pump", amount=1},
			{type="item", name="electronic-circuit", amount=2}
		},
	results = {
		{type="item", name="RTVacuumHatch", amount=1}
	}

},
{ --------- The vacuum hatch item -------------
	type = "item",
	name = "RTVacuumHatch",
	icon = "__RenaiTransportation__/graphics/hatch/vacuumhatchicon.png",
	icon_size = 64,
	subgroup = "RT",
	order = "f-c",
	place_result = "RTVacuumHatch",
	stack_size = 50
},

{
	type = "animation",
	name = "VacuumHatchSucc",
	filename = "__RenaiTransportation__/graphics/hatch/VacuumHatchParticles.png",
	size = {160, 142},
	frame_count = 105,
	line_length = 5,
	animation_speed = 1
},

{
	type = "technology",
	name = "RTVacuumHatchTech",
	icon = "__RenaiTransportation__/graphics/tech/VacuumHatchTech.png",
	icon_size = 128,
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "RTVacuumHatch"
		},
	},
	prerequisites = {"HatchRTTech", "advanced-circuit"},
	unit =
	{
		count = 100,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1}
		},
		time = 30
	}
},
})

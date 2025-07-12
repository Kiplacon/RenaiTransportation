local animspeed = 0.03

data:extend({
---- vacuum hatch ----
{
	type = "electric-energy-interface",
	name = "RTVacuumHatch",
	icon = renaiIcons .. "vacuumhatchicon.png",
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
			layers = {
				{
					filename = renaiEntity .. "VacuumHatch/VacuumHatchN.png",
					repeat_count = 16,
					width = 128,
					height = 128,
					scale = 0.5,
					animation_speed = animspeed
				},
				{
					filename = renaiEntity .. "VacuumHatch/VacuumHatchVertiAnim.png",
					frame_count = 16,
					line_length = 8,
					width = 85,
					height = 96,
					scale = 0.5,
					shift = util.by_pixel(0, -3),
					animation_speed = animspeed
				}
			}
		},
		east =
		{
			layers = {
				{
					filename = renaiEntity .. "VacuumHatch/VacuumHatchE.png",
					repeat_count = 16,
					width = 128,
					height = 128,
					scale = 0.5,
					animation_speed = animspeed
				},
				{
					filename = renaiEntity .. "VacuumHatch/VacuumHatchHoriAnim.png",
					frame_count = 16,
					line_length = 8,
					width = 85,
					height = 96,
					scale = 0.5,
					shift = util.by_pixel(0, -3),
					animation_speed = animspeed
				}
			}
		},
		south =
		{
			layers = {
				{
					filename = renaiEntity .. "VacuumHatch/VacuumHatchS.png",
					repeat_count = 16,
					width = 128,
					height = 128,
					scale = 0.5,
					animation_speed = animspeed
				},
				{
					filename = renaiEntity .. "VacuumHatch/VacuumHatchVertiAnim.png",
					frame_count = 16,
					line_length = 8,
					width = 85,
					height = 96,
					scale = 0.5,
					shift = util.by_pixel(0, -3),
					animation_speed = animspeed
				}
			}
		},
		west =
		{
			layers = {
				{
					filename = renaiEntity .. "VacuumHatch/VacuumHatchW.png",
					repeat_count = 16,
					width = 128,
					height = 128,
					scale = 0.5,
					animation_speed = animspeed
				},
				{
					filename = renaiEntity .. "VacuumHatch/VacuumHatchHoriAnim.png",
					frame_count = 16,
					line_length = 8,
					width = 85,
					height = 96,
					scale = 0.5,
					shift = util.by_pixel(0, -3),
					animation_speed = animspeed
				}
			}
		},
	},
	--render_layer = "arrow",
	radius_visualisation_specification = {
		sprite = {
			filename = renaiEntity .. "range.png",
			size = 64,
			tint = {1, 0.5, 0}
		},
		draw_on_selection = true,
		distance = 2.5,
		offset = {0, -3},
	},
	working_sound = {
	  match_progress_to_activity = true,
	  sound =
	  {
	    variations = sound_variations("__RenaiTransportation__/sickw0bs/vacuum", 1, 0.3, {volume_multiplier("main-menu", 2), volume_multiplier("tips-and-tricks", 1.8)}),
	    audible_distance_modifier = 0.8
	  },
	  max_sounds_per_prototype = 2,
	},
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
	icon = renaiIcons .. "vacuumhatchicon.png",
	icon_size = 64,
	subgroup = "RT",
	order = "f-c",
	place_result = "RTVacuumHatch",
	stack_size = 50
},

{
	type = "animation",
	name = "VacuumHatchSucc",
	filename = renaiEntity .. "VacuumHatch/VacuumHatchParticles.png",
	size = {160, 142},
	frame_count = 105,
	line_length = 5,
	animation_speed = 1
},

{
	type = "technology",
	name = "RTVacuumHatchTech",
	icon = renaiTechIcons .. "VacuumHatchTech.png",
	icon_size = 256,
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

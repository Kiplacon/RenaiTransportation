local nothing = {
		filename = "__RenaiTransportation__/graphics/nothing.png",
		width = 1,
		height = 1
	}

local RememberNoUnderscores = "RTHatches"

data:extend({
{
	type = "collision-layer",
	order = "51",
	name = RememberNoUnderscores
},

{
type = "simple-entity-with-owner",
name = "HatchRT",
icon = "__RenaiTransportation__/graphics/hatch/icon.png",
icon_size = 64,
flags = {"placeable-neutral", "player-creation"},
collision_mask = {layers={[RememberNoUnderscores]=true}},
collision_box = {{-0.35, -0.3}, {0.35, 0.55}},
selection_box = {{-0.35, -0.3}, {0.35, 0.55}},
selection_priority = 255,
dying_explosion = "iron-chest-explosion",
minable = {mining_time = 0.2, result = "HatchRT"},
render_layer = "under-elevated",
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
	name = "HatchRT",
	icon = "__RenaiTransportation__/graphics/hatch/icon.png",
	icon_size = 64, --icon_mipmaps = 4,
	subgroup = "RT",
	order = "f",
	place_result = "HatchRT",
	stack_size = 50
},

{ --------- The hatch recipe ----------
	type = "recipe",
	name = "HatchRT",
	enabled = false,
	energy_required = 1,
	ingredients =
		{
			{type="item", name="pipe-to-ground", amount=1},
			{type="item", name="pipe", amount=1},
			{type="item", name="copper-plate", amount=2}
		},
	results = {
		{type="item", name="HatchRT", amount=1}
	}
},

------------------ Ejector hatch ---------------------
{
	type = "inserter",
	name = "RTThrower-EjectorHatchRT",
	icon = "__RenaiTransportation__/graphics/hatch/EjeectorIccon.png",
	icon_size = 43,
	flags = {"placeable-neutral", "player-creation"},
	collision_mask = {layers={[RememberNoUnderscores]=true}},
	collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
	selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
	selection_priority = 255,
	dying_explosion = "iron-chest-explosion",
	minable = {mining_time = 0.2, result = "RTThrower-EjectorHatchRT"},
	render_layer = "under-elevated",
	filter_count = 5,
	energy_source =
	{
		type = "electric",
		usage_priority = "secondary-input",
		drain = "0.4kW"
	},
	energy_per_movement = "5kJ",
	energy_per_rotation = "5kJ",
	extension_speed = 0.03,
	rotation_speed = 0.014,
	pickup_position = {0, -0.2},
	insert_position = {0, 19.9},
	allow_custom_vectors = false,
	chases_belt_items = false,
	draw_held_item = false,
	hand_base_picture = nothing,
	hand_open_picture = nothing,
	hand_closed_picture = nothing,
	platform_picture =
	{
		sheet =
		{
			filename = "__RenaiTransportation__/graphics/hatch/EjectorHatch.png",
			priority = "extra-high",
			width = 64,
			height = 64,
			scale = 0.75
		}
	},
	circuit_wire_connection_points = circuit_connector_definitions["inserter"].points,
	circuit_connector_sprites = circuit_connector_definitions["inserter"].sprites,
	circuit_wire_max_distance = inserter_circuit_wire_max_distance,
	default_stack_control_input_signal = inserter_default_stack_control_input_signal
},

{ --------- The ejector hatch item -------------
	type = "item",
	name = "RTThrower-EjectorHatchRT",
	icon = "__RenaiTransportation__/graphics/hatch/EjeectorIccon.png",
	icon_size = 43, --icon_mipmaps = 4,
	subgroup = "RT",
	order = "f",
	place_result = "RTThrower-EjectorHatchRT",
	stack_size = 50
},

{ --------- The ejector hatch recipe ----------
	type = "recipe",
	name = "RTThrower-EjectorHatchRT",
	enabled = false,
	energy_required = 1,
	ingredients =
		{
			{type="item", name="HatchRT", amount=1},
			{type="item", name="RTBouncePlate", amount=1},
			{type="item", name="electronic-circuit", amount=2}
		},
	results = {
		{type="item", name="RTThrower-EjectorHatchRT", amount=1}
	}
},
---------- sprites because inserters dont render above a lot of things
{
	type = "animation",
	name = "EjectorHatchFrames",
	filename = "__RenaiTransportation__/graphics/hatch/EjectorHatch.png",
	size = 64,
	frame_count = 4,
	line_length = 4,
	animation_speed = 0.1,
	scale = 0.75
},

})

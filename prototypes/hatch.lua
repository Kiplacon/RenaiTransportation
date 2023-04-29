local nothing = {
		filename = "__RenaiTransportation__/graphics/nothing.png",
		width = 1,
		height = 1
	}

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
},
------------------ Ejector hatch ---------------------
{
type = "inserter",
name = "RTThrower-EjectorHatchRT",
icon = "__RenaiTransportation__/graphics/hatch/EjeectorIccon.png",
icon_size = 43,
flags = {"placeable-neutral", "player-creation"},
collision_mask = {"layer-51"},
collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
selection_priority = 255,
minable = {mining_time = 0.2, result = "RTThrower-EjectorHatchRTItem"},
render_layer = "higher-object-under",
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
	name = "RTThrower-EjectorHatchRTItem",
	icon = "__RenaiTransportation__/graphics/hatch/EjeectorIccon.png",
	icon_size = 43, --icon_mipmaps = 4,
	subgroup = "RT",
	order = "f",
	place_result = "RTThrower-EjectorHatchRT",
	stack_size = 50
},

{ --------- The ejector hatch recipie ----------
	type = "recipe",
	name = "RTThrower-EjectorHatchRTRecipe",
	enabled = false,
	energy_required = 1,
	ingredients =
		{
			{"HatchRTItem", 1},
			{"BouncePlateItem", 1},
			{"electronic-circuit", 2}
		},
	result = "RTThrower-EjectorHatchRTItem"
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
}

})

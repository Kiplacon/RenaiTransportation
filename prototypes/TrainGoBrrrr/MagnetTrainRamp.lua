local function scaleSprite(sprite, scale)
	if sprite == nil then
		return nil
	end

	local scaled = table.deepcopy(sprite)

	if sprite.layers ~= nil then
		scaled.layers = {}
		for _, layer in pairs(sprite.layers) do
			scaled.layers[_] = scaleSprite(layer, scale)
		end
	end

	scaled.hr_version = scaleSprite(sprite.hr_version, scale)
	scaled.north = scaleSprite(sprite.north, scale)
	scaled.east = scaleSprite(sprite.east, scale)
	scaled.south = scaleSprite(sprite.south, scale)
	scaled.west = scaleSprite(sprite.west, scale)
	scaled.sheet = scaleSprite(sprite.sheet, scale)

	if sprite.sheets ~= nil then
		scaled.sheets = {}
		for _, sheet in pairs(sprite.sheets) do
			scaled.sheets[_] = scaleSprite(sheet, scale)
		end
	end

	scaled.scale = scale * (sprite.scale or 1)

	return scaled
end

data:extend({ 

--------------------------------------------Magnet train ramp
{ -- range sprite
	type = "sprite",
	name = "RTMagnetTrainRampRange",
	filename = "__RenaiTransportation__/graphics/TrainRamp/range.png",
	size = 64
},

{ -- "rail" tile
type = "simple-entity-with-owner",
name = "RTMagnetRail",
icon = "__RenaiTransportation__/graphics/TrainRamp/magnetrail.png",
icon_size = 16,
flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-flammable", "no-copy-paste"},
selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
selection_priority = 0,
collision_mask = {},
render_layer = "higher-object-under",
picture = 
	{
		filename = "__RenaiTransportation__/graphics/nothing.png",
		width = 32,
		height = 32,
		scale = 0.5
	}
},

{ -- "rail" sprite because entities cant have altered render layers
	type = "sprite",
	name = "RTMagnetRailSprite",
	filename = "__RenaiTransportation__/graphics/TrainRamp/magnetrail2.png",
	size = 64
},

{ --------- ramp entity -------------
	type = "rail-signal",
	name = "RTMagnetTrainRamp",
	icon = "__RenaiTransportation__/graphics/TrainRamp/icon2.png",
	icon_size = 64,
	flags = {"placeable-neutral", "player-creation", "filter-directions", "fast-replaceable-no-build-while-moving"},
    minable = {mining_time = 0.5, result = "RTMagnetTrainRampItem"},
    max_health = 500,
	render_layer = "higher-object-under",
    --collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    --selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_box = {{-0.01, -1.6}, {1.6, 1.6}},
    selection_box = {{-0.01, -2}, {2, 2}},
	collision_mask = {"train-layer"},
	selection_priority = 100,
    animation =
    {
      filename = "__RenaiTransportation__/graphics/TrainRamp/lol4a.png",
      priority = "high",
      width = 200,
      height = 200,
      frame_count = 1,
      direction_count = 4
    },
},

{ --------- no skip ramp entity -------------
	type = "rail-signal",
	name = "RTMagnetTrainRampNoSkip",
	icon = "__RenaiTransportation__/graphics/TrainRamp/icon2.png",
	icon_size = 64,
	flags = {"placeable-neutral", "player-creation", "filter-directions", "fast-replaceable-no-build-while-moving"},
    minable = {mining_time = 0.5, result = "RTMagnetTrainRampItem"},
	placeable_by = {item = "RTMagnetTrainRampItem", count = 1},
    max_health = 500,
	render_layer = "higher-object-under",
    --collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    --selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_box = {{-0.01, -1.6}, {1.6, 1.6}},
    selection_box = {{-0.01, -2}, {2, 2}},
	collision_mask = {"train-layer"},
	selection_priority = 100,
    animation =
    {
      filename = "__RenaiTransportation__/graphics/TrainRamp/lol4b.png",
      priority = "high",
      width = 200,
      height = 200,
      frame_count = 1,
      direction_count = 4
    },
},

{ --------- ramp item -------------
	type = "item",
	name = "RTMagnetTrainRampItem",
	icon = "__RenaiTransportation__/graphics/TrainRamp/icon2.png",
	icon_size = 64,
	subgroup = "RT",
	order = "h",
	place_result = "RTMagnetTrainRamp",
	stack_size = 10
},

{ --------- ramp recipie ----------
	type = "recipe",
	name = "RTMagnetTrainRampRecipe",
	enabled = false,
	energy_required = 2,
	ingredients = 
		{
			{"RTTrainRampItem", 1},
			{"accumulator", 1},
			{"substation", 1},
			{"steel-plate", 100},
			{"advanced-circuit", 25}
		},
	result = "RTMagnetTrainRampItem"
},

{
	type = "animation",
	name = "RTPush",
	filename = "__RenaiTransportation__/graphics/TrainRamp/testhue.png",
	size = {105,169},
	frame_count = 99,
	line_length = 3
},

{
	type = "animation",
	name = "RTPull",
	filename = "__RenaiTransportation__/graphics/TrainRamp/testhuerev.png",
	size = {105,169},
	frame_count = 99,
	line_length = 3
}

})

local accumulator = data.raw.accumulator.accumulator

data:extend({
	{
		type = "electric-energy-interface",
		name = "RTMagnetRampDrain",
		icon = "__RenaiTransportation__/graphics/TrainRamp/icon2.png",
		icon_size = 64,
		flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-flammable", "no-copy-paste", "hidden", "not-rotatable"},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
		selection_priority = 101,
		--collision_mask = {},
		render_layer = "lower-object-above-shadow",
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			input_flow_limit = "4MW"
		},
		picture = scaleSprite(accumulator.picture, 0.4),
		light = accumulator.charge_light,
		animation = scaleSprite(accumulator.charge_animation, 0.4)
	}
})

--local util = require('util')

local accumulator = table.deepcopy(data.raw.accumulator.accumulator)

local function foreach_sprite_definition(sprite, func)
	if sprite.layers then
		for _, layer in pairs(sprite.layers) do
			sprite.layers[_] = foreach_sprite_definition(layer, func)
		end
	else
		func(sprite)
		if sprite.hr_version then
			sprite.hr_version = foreach_sprite_definition(sprite.hr_version, func)
		end
	end

	return sprite
end

local function scaleSprite(sprite, scale)
	return foreach_sprite_definition(table.deepcopy(sprite), function (def)
		def.scale = def.scale and (def.scale * scale) or scale
	end)
end

local function removeShift(sprite)
	return foreach_sprite_definition(table.deepcopy(sprite), function (def)
		def.shift = nil
	end)	
end

magRampEntities = {
	{ -- range sprite
		type = "sprite",
		name = "RTMagnetTrainRampRange",
		filename = renaiEntity .. "range.png",
		size = 64
	},
	
	{ -- "rail" tile
		type = "simple-entity-with-owner",
		name = "RTMagnetRail",
		icon = renaiIcons .. "magnetrail_icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-flammable", "no-copy-paste"},
		hidden = true,
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		selection_priority = 1,
		collision_mask = {layers={}},
		render_layer = "rail-stone-path",
		picture =
			{
				filename = renaiEntity .. "MagnetRail/magnetrail2.png",
				size = 64,
				scale = 0.5
			},
	},
	
	--[[ { -- "rail" sprite because entities cant have altered render layers
		type = "sprite",
		name = "RTMagnetRailSprite",
		filename = renaiEntity .. "MagnetRail/magnetrail2.png",
		size = 64,
		scale = 0.5
	}, ]]
	
	{
		type = "animation",
		name = "RTPush",
		filename = renaiEntity .. "MagnetRail/testhue.png",
		size = {105,169},
		frame_count = 99,
		line_length = 3
	},
	
	{
		type = "animation",
		name = "RTPull",
		filename = renaiEntity .. "MagnetRail/testhuerev.png",
		size = {105,169},
		frame_count = 99,
		line_length = 3
	},
	
	{
		type = "electric-energy-interface",
		name = "RTMagnetRampDrain",
		icon = renaiIcons .. "magnetrail_icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-flammable", "no-copy-paste"},
		hidden = true,
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
		selection_priority = 101,
		collision_mask = {layers={}},
		render_layer = "lower-object-above-shadow",
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			input_flow_limit = "40MW"
		},
		picture = removeShift(scaleSprite(accumulator.chargable_graphics.picture, 0.4)),
		animation = removeShift(scaleSprite(accumulator.chargable_graphics.charge_animation, 0.4)),
		light = accumulator.charge_light,
		working_sound = accumulator.working_sound
	}	
}

return magRampEntities

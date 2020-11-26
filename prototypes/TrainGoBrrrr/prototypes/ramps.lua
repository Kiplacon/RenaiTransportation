local util = require("util")

local constants = require("__RenaiTransportation__/script/trains/constants")

local function makeRampItem(name, icon, placerEntity)
	return {
		type = "item",
		name = name,
		icon = icon,
		icon_size = 64,
		subgroup = "RT",
		order = "g",
		place_result = placerEntity,
		stack_size = 10
	}
end

local function makeRampPlacerEntity(name, icon, pictureFileName, placerItem)
	return {
		type = "rail-signal",
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"filter-directions", "fast-replaceable-no-build-while-moving"},
		minable = { mining_time = 0.5, result = placerItem },-- Minable so they can get the item back if the placer swap bugs out
		render_layer = "higher-object-under",
		collision_mask = {"rail-layer", "train-layer"},
		selection_priority = 100,
		collision_box = {{-0.01, -2.35}, {2.25, 1.30}},
		animation = {
			filename = pictureFileName,
			width = 200,
			height = 200,
			frame_count = 1,
			direction_count = 4
		}
	}
end

local function makeRampEntity(name, icon, pictureFileName, placerItem)
	return {
		type = "constant-combinator", -- Simplist entity that has 4 diections of sprites
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"player-creation", "hidden", "not-rotatable", "not-on-map"},
		minable = {mining_time = 0.5, result = placerItem},
		max_health = 500,
		render_layer = "higher-object-under",
		selection_box = {{-0.01, -2}, {2, 2}},
		selection_priority = 100,
		collision_box = {{-0.01, -1.6}, {1.6, 1.6}},
		collision_mask = {"train-layer", "object-layer"},
		sprites = {
			-- Shifts are inverted because the sprites are pre-shifted to be at the ramp position already
			north = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 0,
				-- shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.north], -1)
			},
			east = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 200,
				-- shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.east], -1)
			},
			south = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 400,
				-- shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.south], -1)
			},
			west = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 600,
				-- shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.west], -1)
			},
		},
		placeable_by = { item = placerItem, count = 1 }, -- Controls `q` and blueprint behavior

		-- null out the standard combinator stuff
		item_slot_count = 0,
		activity_led_sprites = util.empty_sprite(),
		activity_led_light_offsets = {
			{0, 0},
			{0, 0},
			{0, 0},
			{0, 0}
		},
		circuit_wire_connection_points = {
			{ shadow = {}, wire = {} },
			{ shadow = {}, wire = {} },
			{ shadow = {}, wire = {} },
			{ shadow = {}, wire = {} },
		}
	}
end

local function makeRampPrototypes(baseName)
	local iconFilename = '__RenaiTransportation__/graphics/TrainRamp/' .. baseName .. '-icon.png'
	local entityPictureFilename =  '__RenaiTransportation__/graphics/TrainRamp/' .. baseName .. '.png'
	local noSkipEntityPictureFilename =  '__RenaiTransportation__/graphics/TrainRamp/' .. baseName .. 'NoSkip.png'
	local itemName = baseName .. 'Item'

	return {
		-- Make the item for the base ramp. Item actually spawns a placer entity to align
		-- with the rails
		makeRampItem(
			itemName,
			iconFilename,
			baseName .. '-placer'
		),

		-- Make the placer entity used for aligning with rails
		makeRampPlacerEntity(
			baseName .. '-placer',
			iconFilename,
			entityPictureFilename,
			itemName
		),

		-- Make the actual ramp, eg RTTrainRamp
		makeRampEntity(
			baseName,
			iconFilename,
			entityPictureFilename,
			itemName
		),

		-- Make noSkip variants of the placer and ramp

		makeRampPlacerEntity(
			baseName .. 'NoSkip-placer',
			iconFilename,
			noSkipEntityPictureFilename
		),

		makeRampEntity(
			baseName .. 'NoSkip',
			iconFilename,
			noSkipEntityPictureFilename,
			itemName
		)
	}
end

-- Normal ramp
data:extend(makeRampPrototypes("RTTrainRamp"))

-- Mag ramp
data:extend(makeRampPrototypes("RTMagnetTrainRamp"))

-- Add recipes for both items
data:extend({
	{ --------- ramp recipie ----------
		type = "recipe",
		name = "RTTrainRampRecipe",
		enabled = false,
		energy_required = 2,
		ingredients = 
			{
				{"rail", 4},
				{"steel-plate", 30},
				{"concrete", 50}
			},
		result = "RTTrainRampItem"
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
})

-- Add supporting entities for the mag ramp
data:extend({ 
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
		picture = util.empty_sprite(),
	},
	
	{ -- "rail" sprite because entities cant have altered render layers
		type = "sprite",
		name = "RTMagnetRailSprite",
		filename = "__RenaiTransportation__/graphics/TrainRamp/magnetrail2.png",
		size = 64
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
	},
	
	{
		type = "electric-energy-interface",
		name = "RTMagnetRampDrain",
		icon = "__RenaiTransportation__/graphics/TrainRamp/RTMagnetTrainRamp-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-flammable", "no-copy-paste"},
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
		picture = {
			filename = "__base__/graphics/entity/accumulator/accumulator.png",
			priority = "high",
			width = 66,
			height = 94,
			scale = 0.4
		}
	}
	
})

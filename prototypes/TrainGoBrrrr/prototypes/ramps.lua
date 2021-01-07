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
		collision_mask = {"floor-layer", "rail-layer", "item-layer", "water-tile"}, -- "water-tile" makes it compatible with Space Explotation because for some reason it changes signal collison masks and all signals have to have at least one overlapping collision mask
		selection_priority = 100,
		collision_box = {{-0.01, -2.35}, {2.25, 1.30}},
		selection_box = {{-0.01, -2.35}, {2.25, 1.30}},
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
		type = "simple-entity-with-owner", -- Simplist entity that has 4 diections of sprites
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"player-creation", "hidden", "not-rotatable", "not-on-map"},
		minable = {mining_time = 0.5, result = placerItem},
		max_health = 500,
		render_layer = "higher-object-under",
		selection_box = {{-0.01, -1.6}, {2, 2.4}},
		selection_priority = 100,
		collision_box = {{-0.01, -1.5}, {1.9, 2.4}},
		collision_mask = {"train-layer"},
		render_layer = "lower-object-above-shadow",
		picture = {
			-- Shifts are inverted because the sprites are pre-shifted to be at the ramp position already
			north = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 0,
				shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.north], -1)
			},
			east = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 200,
				shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.east], -1)
			},
			south = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 400,
				shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.south], -1)
			},
			west = {
				filename = pictureFileName,
				width = 200,
				height = 200,
				y = 600,
				shift = util.mul_shift(constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.west], -1)
			},
		},
		placeable_by = { item = placerItem, count = 1 }, -- Controls `q` and blueprint behavior

		-- null out the standard combinator stuff
		-- item_slot_count = 0,
		-- activity_led_sprites = util.empty_sprite(),
		-- activity_led_light_offsets = {
			-- {0, 0},
			-- {0, 0},
			-- {0, 0},
			-- {0, 0}
		-- },
		-- circuit_wire_connection_points = {
			-- { shadow = {}, wire = {} },
			-- { shadow = {}, wire = {} },
			-- { shadow = {}, wire = {} },
			-- { shadow = {}, wire = {} },
		-- }
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
data:extend(require('mag_ramp_entities'))


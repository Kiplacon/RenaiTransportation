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
	local PictureSet =
	{
		structure =
		{
			layers =
			{
				{
					filename = pictureFileName,
					width = 200,
					height = 200,
					frame_count = 1,
					direction_count = 4,
				}
			}
		},
		signal_color_to_structure_frame_index =
		{
			green  = 0,
			yellow = 1,
			red    = 2,
		},
		lights =
		{
			green  = { light = {intensity = 0.2, size = 4, color={r=0, g=1,   b=0 }}, shift = { 0, -0.5 }},
			yellow = { light = {intensity = 0.2, size = 4, color={r=1, g=0.5, b=0 }}, shift = { 0,  0   }},
			red    = { light = {intensity = 0.2, size = 4, color={r=1, g=0,   b=0 }}, shift = { 0,  0.5 }},
		},
		structure_align_to_animation_index =
		{
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
		}
	}
	return {
		type = "rail-signal",
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"filter-directions"},
		minable = { mining_time = 0.5, result = placerItem },-- Minable so they can get the item back if the placer swap bugs out
		render_layer = "higher-object-under",
		collision_mask = {layers={["floor"]=true, ["rail"]=true, ["item"]=true, ["water_tile"]=true, ["object"]=true}}, -- "water_tile" makes it compatible with Space Explotation because for some reason it changes signal collison masks and all signals have to have at least one overlapping collision mask
		selection_priority = 100,
		--collision_box = {{-0.01, -2.35}, {2.25, 1.30}},
		--selection_box = {{-0.01, -2.35}, {2.25, 1.30}},
		collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		ground_picture_set = PictureSet,
		elevated_picture_set = PictureSet
	}
end

local function makeRampEntity(name, icon, pictureFileName, placerItem)
	local impact = 100
	local HP = 500
	if (name == "RTImpactUnloader") then
		--impact = 95
		HP = 1500
	end
	local resists =
		{
			{
			  type = "impact",
			  percent = impact
			}
		}

	return {
		type = "constant-combinator", -- Simplist entity that has 4 diections of sprites
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"player-creation", "not-on-map"},
		hidden = true,
		minable = {mining_time = 0.5, result = placerItem},
		max_health = HP,
		selection_box = {{-0.01, -1.6}, {2, 2.4}},
		selection_priority = 100,
		collision_box = {{-0.01, -1.5}, {1.9, 2.4}},
		collision_mask = {layers={["player"]=true, ["train"]=true}},
		render_layer = "lower-object-above-shadow",
		sprites = {
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
		resistances = resists,
		-- null out the standard combinator stuff
		-- item_slot_count = 0,
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

-- Impact UNloader
data:extend(makeRampPrototypes("RTImpactUnloader"))

-- Add recipes for both items
data:extend({
	{ --------- ramp recipie ----------
		type = "recipe",
		name = "RTTrainRampRecipe",
		enabled = false,
		energy_required = 2,
		ingredients =
			{
				{type="item", name="rail", amount=4},
				{type="item", name="steel-plate", amount=30},
				{type="item", name="concrete", amount=50}
			},
		results = {
			{type="item", name="RTTrainRampItem", amount=1}
		}
	},

	{ --------- ramp recipie ----------
		type = "recipe",
		name = "RTMagnetTrainRampRecipe",
		enabled = false,
		energy_required = 2,
		ingredients =
			{
				{type="item", name="RTTrainRampItem", amount=1},
				{type="item", name="accumulator", amount=1},
				{type="item", name="substation", amount=1},
				{type="item", name="steel-plate", amount=100},
				{type="item", name="advanced-circuit", amount=25}
			},
		results = {
			{type="item", name="RTMagnetTrainRampItem", amount=1}
		}
	},

	{ --------- ramp recipie ----------
		type = "recipe",
		name = "RTImpactUnloaderRecipe",
		enabled = false,
		energy_required = 2,
		ingredients =
			{
				{type="item", name="advanced-circuit", amount=20},
				{type="item", name="steel-plate", amount=100},
				{type="item", name="refined-concrete", amount=100}
			},
		results = {
			{type="item", name="RTImpactUnloaderItem", amount=1}
		}
	}
})

-- Add supporting entities for the mag ramp
data:extend(require('mag_ramp_entities'))

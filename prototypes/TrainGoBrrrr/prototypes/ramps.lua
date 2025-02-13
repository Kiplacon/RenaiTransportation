local util = require("util")

local constants = require("__RenaiTransportation__/script/trains/constants")

local function RampPictureSets(FilePath)
	return
	{
		structure =
		{
			layers =
			{
				{
					filename = FilePath,
					size = 128,
					frame_count = 1,
					direction_count = 4,
					line_length = 4,
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
			green  = { light = {intensity = 0, size = 0, color={r=0, g=1,   b=0 }}, shift = { 0, -0.5 }},
			yellow = { light = {intensity = 0, size = 0, color={r=1, g=0.5, b=0 }}, shift = { 0,  0   }},
			red    = { light = {intensity = 0, size = 0, color={r=1, g=0,   b=0 }}, shift = { 0,  0.5 }},
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
			green  = { light = {intensity = 0, size = 4, color={r=0, g=1,   b=0 }}, shift = { 0, -0.5 }},
			yellow = { light = {intensity = 0, size = 4, color={r=1, g=0.5, b=0 }}, shift = { 0,  0   }},
			red    = { light = {intensity = 0, size = 4, color={r=1, g=0,   b=0 }}, shift = { 0,  0.5 }},
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
		flags = {"filter-directions", "not-on-map", "player-creation"},
		minable = { mining_time = 0.5, result = placerItem },-- Minable so they can get the item back if the placer swap bugs out
		render_layer = "elevated-object",
		collision_mask = {layers={["train"]=true}}, -- these masks interact with the blocker
		elevated_collision_mask = {layers={["elevated_train"]=true}},
		selection_priority = 100,
		elevated_selection_priority = 100,
		--collision_box = {{-0.01, -2.35}, {2.25, 1.30}},
		--selection_box = {{-0.01, -2.35}, {2.25, 1.30}},
		collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		ground_picture_set = PictureSet,
		elevated_picture_set = PictureSet
	}
end
local function CreateRampSprites(name, FilePath)
	data:extend({
		{ -- up
			type = "sprite",
			name = name..8,
			filename = FilePath,
			size = 128,
			x = 128*2
		},
		{ -- right
			type = "sprite",
			name = name..12,
			filename = FilePath,
			size = 128,
			x = 128*3
		},
		{ -- down
			type = "sprite",
			name = name..0,
			filename = FilePath,
			size = 128,
			x = 0
		},
		{ -- left
			type = "sprite",
			name = name..4,
			filename = FilePath,
			size = 128,
			x = 128
		},
	})
end

-- collision boxes for the ramps
for name, mask in pairs({RTTrainRampCollisionBox={layers={["train"]=true}}, RTElevatedTrainRampCollisionBox={layers={["elevated_train"]=true}}}) do
	data:extend({
		{
			type = "simple-entity-with-owner",
			name = name,
			flags = {"not-on-map", "placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-selectable-in-game"},
			hidden = true,
			max_health = 420,
			collision_box = {{-1.32, -1.9}, {1.32, 1.9}},
			collision_mask = mask,
			resistances = {
				{
					type = "impact",
					percent = 100
				},
				{
					type = "fire",
					percent = 100
				},
				{
					type = "explosion",
					percent = 100
				},
				{
					type = "physical",
					percent = 100
				},
				{
					type = "poison",
					percent = 100
				},
				{
					type = "acid",
					percent = 100
				}
			},
			picture = {
				filename = "__RenaiTransportation__/graphics/nothing.png",
				size = 1,
				priority = "very-low",
			}
		},
	})
end

for _, variant in pairs({"ImpactUnloader", "TrainRamp", "TrainRampNoSkip", "MagnetTrainRamp", "MagnetTrainRampNoSkip", "TrapdoorSwitch"}) do
	local GroundMask = {layers={["train"]=true}}
	local ElevMask = {layers={["elevated_train"]=true}}
	local CellBox = {{-1, -2}, {1, 2}}
	if (variant == "TrapdoorSwitch") then
		GroundMask = {layers={}}
		ElevMask = {layers={}}
		CellBox = {{-0.3, -0.3}, {0.3, 0.3}}
	end
	data:extend({
		{
			type = "rail-signal",
			name = "RT"..variant,
			icon = "__RenaiTransportation__/graphics/TrainRamp/icons/"..variant.."Icon.png",
			icon_size = 64,
			flags = {"player-creation", "not-on-map", "placeable-off-grid", "hide-alt-info", "not-flammable"},
			hidden = true,
			minable = {mining_time = 1, result = "RT"..variant:gsub("NoSkip", "").."Item"},
			max_health = 500,
			collision_box = {{-0.9, -1.9}, {0.9, 1.9}},
			selection_box = CellBox,
			selection_priority = 100,
			elevated_selection_priority = 100,
			collision_mask = GroundMask,
			elevated_collision_mask = ElevMask,
			ground_picture_set = RampPictureSets("__RenaiTransportation__/graphics/TrainRamp/ramps/"..variant..".png"),
			elevated_picture_set = RampPictureSets("__RenaiTransportation__/graphics/TrainRamp/ramps/"..variant..".png"),
			placeable_by = { item = "RT"..variant:gsub("NoSkip", "").."Item", count = 1 }, -- Controls `q` and blueprint behavior
			resistances = {
				{
					type = "impact",
					percent = 100
				}
			}
		},
		{
			type = "item",
			name = "RT"..variant.."Item",
			icon = "__RenaiTransportation__/graphics/TrainRamp/icons/"..variant.."Icon.png",
			icon_size = 64,
			subgroup = "RT",
			order = "g",
			place_result = "RT"..variant.."-placer",
			stack_size = 10
		},
		makeRampPlacerEntity(
				"RT"..variant.."-placer",
				"__RenaiTransportation__/graphics/TrainRamp/icons/"..variant.."Icon.png",
				"__RenaiTransportation__/graphics/TrainRamp/ramps/"..variant.."Placer.png",
				"RT"..variant.."Item"
			),
		CreateRampSprites("RT"..variant.."", "__RenaiTransportation__/graphics/TrainRamp/ramps/"..variant..".png")
	})
end
-- placeholder stuff for 2.0 -> 2.1 migration
for _, placeholder in pairs({"Up", "Down", "Left", "Right"}) do
	for _, varient in pairs({"", "NoSkip"}) do
		data:extend({
			{
				type = "simple-entity-with-owner",
				name = "RTTrainRamp-Elevated"..placeholder..varient,
				flags = {"not-on-map", "placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-selectable-in-game"},
				hidden = true,
				max_health = 420,
				picture =
				{
					filename = "__RenaiTransportation__/graphics/Untitled.png",
					size = 32,
					priority = "very-low",
				}
			}
		})
	end
end


-- Add recipes for both items
data:extend({
	{ --------- ramp recipe ----------
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
	{ --------- ramp recipe ----------
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
	{ --------- ramp recipe ----------
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
	},
	{ --------- Switch recipe ----------
		type = "recipe",
		name = "RTTrapdoorSwitchRecipe",
		enabled = true,
		energy_required = 0.1,
		ingredients =
		{
			{type="item", name="advanced-circuit", amount=10},
		},
		results = {
			{type="item", name="RTTrapdoorSwitchItem", amount=1}
		}
	},
})

-- Add supporting entities for the mag ramp
data:extend(require('mag_ramp_entities'))

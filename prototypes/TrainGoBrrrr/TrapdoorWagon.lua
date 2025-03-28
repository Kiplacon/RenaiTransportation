local OhYouLikeTrains = table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])
local color = {1,1,0}
OhYouLikeTrains.name = "RTTrapdoorWagon"
OhYouLikeTrains.icons =
{
	{
		icon = "__base__/graphics/icons/cargo-wagon.png",
		icon_size = 64,
		icon_mipmaps = 4,
		tint = color
	}
}
OhYouLikeTrains.minable = {mining_time = 0.5, result = "RTTrapdoorWagonItem"}

for _, part in pairs({"rotated", "sloped"}) do
	if OhYouLikeTrains.pictures[part] and OhYouLikeTrains.pictures[part].layers then
		for i, layer in pairs(OhYouLikeTrains.pictures[part].layers) do
			layer.tint = color
		end
	elseif OhYouLikeTrains.pictures[part] then
		OhYouLikeTrains.pictures[part].tint = color
	end
end
for _, part in pairs({"horizontal_doors", "vertical_doors"}) do
	if OhYouLikeTrains[part] and OhYouLikeTrains[part].layers then
		for i, layer in pairs(OhYouLikeTrains[part].layers) do
			layer.tint = color
		end
	elseif OhYouLikeTrains[part] then
		OhYouLikeTrains[part].tint = color
	end
end


local PictureSet =
{
	structure =
	{
		layers =
		{
			{
				filename = "__RenaiTransportation__/graphics/TrapdoorSwitch/TrapdoorSwitch.png",
				size = 128,
				frame_count = 1,
				direction_count = 16,
				scale = 0.5
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
		1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
		2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
		3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
		4,  4,  4,  4,   4,  4,  4,  4,   4,  4,  4,  4,
		5,  5,  5,  5,   5,  5,  5,  5,   5,  5,  5,  5,
		6,  6,  6,  6,   6,  6,  6,  6,   6,  6,  6,  6,
		7,  7,  7,  7,   7,  7,  7,  7,   7,  7,  7,  7,
		8,  8,  8,  8,   8,  8,  8,  8,   8,  8,  8,  8,
		9,  9,  9,  9,   9,  9,  9,  9,   9,  9,  9,  9,
		10,  10,  10,  10,   10,  10,  10,  10,   10,  10,  10,  10,
		11,  11,  11,  11,   11,  11,  11,  11,   11,  11,  11,  11,
		12,  12,  12,  12,   12,  12,  12,  12,   12,  12,  12,  12,
		13,  13,  13,  13,   13,  13,  13,  13,   13,  13,  13,  13,
		14,  14,  14,  14,   14,  14,  14,  14,   14,  14,  14,  14,
		15,  15,  15,  15,   15,  15,  15,  15,   15,  15,  15,  15,
	}
}
local PictureSetPlacer =
{
	structure =
	{
		layers =
		{
			{
				filename = "__RenaiTransportation__/graphics/TrapdoorSwitch/TrapdoorSwitchPlacer.png",
				size = 192,
				frame_count = 1,
				direction_count = 16,
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
		1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
		2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
		3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
		4,  4,  4,  4,   4,  4,  4,  4,   4,  4,  4,  4,
		5,  5,  5,  5,   5,  5,  5,  5,   5,  5,  5,  5,
		6,  6,  6,  6,   6,  6,  6,  6,   6,  6,  6,  6,
		7,  7,  7,  7,   7,  7,  7,  7,   7,  7,  7,  7,
		8,  8,  8,  8,   8,  8,  8,  8,   8,  8,  8,  8,
		9,  9,  9,  9,   9,  9,  9,  9,   9,  9,  9,  9,
		10,  10,  10,  10,   10,  10,  10,  10,   10,  10,  10,  10,
		11,  11,  11,  11,   11,  11,  11,  11,   11,  11,  11,  11,
		12,  12,  12,  12,   12,  12,  12,  12,   12,  12,  12,  12,
		13,  13,  13,  13,   13,  13,  13,  13,   13,  13,  13,  13,
		14,  14,  14,  14,   14,  14,  14,  14,   14,  14,  14,  14,
		15,  15,  15,  15,   15,  15,  15,  15,   15,  15,  15,  15,
	}
}


data:extend({
	----wagon
	OhYouLikeTrains,
	{ --------- wagon item -------------
		type = "item",
		name = "RTTrapdoorWagonItem",
		icon_size = 64,
		icons =
		{
			{
				icon = "__base__/graphics/icons/cargo-wagon.png",
				icon_mipmaps = 4,
				tint = color
			}
		},
		subgroup = "train-transport",
		order = "aj",
		place_result = "RTTrapdoorWagon",
		stack_size = 5
	},
	{
		type = "sprite",
		name = "RTTrapdoorWagonOpen",
		filename = "__RenaiTransportation__/graphics/TrapdoorSwitch/open.png",
		size = 100,
		scale = 0.5
	},
	{
		type = "sprite",
		name = "RTTrapdoorWagonClosed",
		filename = "__RenaiTransportation__/graphics/TrapdoorSwitch/closed.png",
		size = 100,
		scale = 0.5
	},
	{
        type = "sound",
        name = "RTTrapdoorOpenSound",
        filename = "__RenaiTransportation__/sickw0bs/TrapdoorOpen.ogg",
		volume = 0.5
    },
	{
        type = "sound",
        name = "RTTrapdoorCloseSound",
        filename = "__RenaiTransportation__/sickw0bs/TrapdoorClose.ogg",
		volume = 0.3
    }
})


---------- Trapdoor switch and detector
data:extend({
{ -- actual collision detector
	type = "simple-entity-with-owner",
	name = "RTTrainDetector",
	icon = '__RenaiTransportation__/graphics/Untitled.png',
	icon_size = 32,
	flags = {"placeable-neutral", "placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-flammable", "no-copy-paste"},
	max_health = 1,
	selection_box = nil,
	collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
	collision_mask = {layers={["train"]=true}},
	--[[ picture = {
		filename = '__RenaiTransportation__/graphics/Untitled.png',
		width = 32,
		height = 32,
		scale = 0.25
	}, ]]
},
{ -- actual collision detector
	type = "simple-entity-with-owner",
	name = "RTTrainDetectorElevated",
	icon = '__RenaiTransportation__/graphics/Untitled.png',
	icon_size = 32,
	flags = {"placeable-neutral", "placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-flammable", "no-copy-paste"},
	max_health = 1,
	selection_box = nil,
	collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
	collision_mask = {layers={["elevated_train"]=true}},
	--[[ picture = {
		filename = '__RenaiTransportation__/graphics/Untitled.png',
		tint = {r=0, g=0, b=1},
		width = 32,
		height = 32,
		scale = 0.25
	}, ]]
},
{ -- Switch entity
	type = "rail-signal",
	name = "RTTrapdoorSwitch",
	icon = "__RenaiTransportation__/graphics/TrapdoorSwitch/TrapdoorSwitchIcon.png",
	icon_size = 64,
	flags = {"filter-directions", "not-on-map", "player-creation", "building-direction-16-way", "hide-alt-info", "not-flammable"},
	minable = { mining_time = 0.5, result = "RTTrapdoorSwitchItem" },-- Minable so they can get the item back if the placer swap bugs out
	max_health = 100,
	collision_mask = {layers={}}, -- these masks interact with the blocker
	elevated_collision_mask = {layers={}},
	selection_priority = 100,
	elevated_selection_priority = 100,
	collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	selection_box = {{-0.3, -0.5}, {0.7, 0.5}},
	ground_picture_set = PictureSet,
	elevated_picture_set = PictureSet,
	placeable_by = { item = "RTTrapdoorSwitchItem", count = 1 },
},
{ -- switch placer entity
	type = "rail-signal",
	name = "RTTrapdoorSwitch-placer",
	icon = "__RenaiTransportation__/graphics/TrapdoorSwitch/TrapdoorSwitchIcon.png",
	icon_size = 64,
	flags = {"filter-directions", "not-on-map", "player-creation", "building-direction-16-way"},
	minable = { mining_time = 0.5, result = "RTTrapdoorSwitchItem" },-- Minable so they can get the item back if the placer swap bugs out
	render_layer = "elevated-object",
	collision_mask = {layers={["train"]=true}}, -- these masks interact with the blocker
	elevated_collision_mask = {layers={["elevated_train"]=true}},
	selection_priority = 100,
	elevated_selection_priority = 100,
	collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	ground_picture_set = PictureSetPlacer,
	elevated_picture_set = PictureSetPlacer
},
{
	type = "item",
	name = "RTTrapdoorSwitchItem",
	icon = "__RenaiTransportation__/graphics/TrapdoorSwitch/TrapdoorSwitchIcon.png",
	icon_size = 64,
	subgroup = "RT",
	order = "g",
	place_result = "RTTrapdoorSwitch-placer",
	stack_size = 10
},
{
	type = "sound",
	name = "RTTrapdoorSwitchSound",
	filename = "__RenaiTransportation__/sickw0bs/TrapdoorSwitch.ogg",
	volume = 0.5
},
{
	type = "virtual-signal",
	name = "StationTrapdoorWagonSignal",
	icon = "__RenaiTransportation__/graphics/TrapdoorSignal.png",
	icon_size = 64,
},
})
for i = 0, 15 do
	data:extend({
	{ -- down
		type = "sprite",
		name = "RTTrapdoorSwitch"..i,
		filename = "__RenaiTransportation__/graphics/TrapdoorSwitch/TrapdoorSwitch.png",
		size = 128,
		y = 128*i,
		scale = 0.5
	},
	})
end



if (data.raw.item["tungsten-plate"] and data.raw.tool["metallurgic-science-pack"]) then
	data:extend({
		{ --------- wagon recipe ----------
			type = "recipe",
			name = "RTTrapdoorWagonRecipe",
			enabled = false,
			energy_required = 1,
			ingredients =
				{
					{type="item", name="iron-gear-wheel", amount=4},
					{type="item", name="iron-stick", amount=2},
					{type="item", name="tungsten-plate", amount=20},
					{type="item", name="cargo-wagon", amount=1}
				},
			results = {
				{type="item", name="RTTrapdoorWagonItem", amount=1}
			}
		},
		{ --------- Switch recipe ----------
			type = "recipe",
			name = "RTTrapdoorSwitchRecipe",
			enabled = false,
			energy_required = 0.1,
			ingredients =
			{
				{type="item", name="electronic-circuit", amount=2},
				{type="item", name="tungsten-plate", amount=2},
				{type="item", name="iron-plate", amount=5},
			},
			results = {
				{type="item", name="RTTrapdoorSwitchItem", amount=1}
			}
		},
		{ --- wagon tech
			type = "technology",
			name = "RTTrapdoorWagonTech",
			icon = "__RenaiTransportation__/graphics/tech/TrapdoorWagonTech.png",
			icon_size = 128,
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "RTTrapdoorWagonRecipe"
				},
				{
					type = "unlock-recipe",
					recipe = "RTTrapdoorSwitchRecipe"
				},
			},
			prerequisites = {"se-no", "railway", "tungsten-steel", "circuit-network"},
			unit =
			{
				count = 500,
				ingredients =
				{
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"space-science-pack", 1},
					{"metallurgic-science-pack", 1},
				},
				time = 60
			}
		},
	})
	--- ramp switch tech
	if (settings.startup["RTTrapdoorSetting"].value == true) then
		data:extend({
			{
				type = "technology",
				name = "RTSwitchRampTech",
				icon = "__RenaiTransportation__/graphics/tech/SwitchRampTech.png",
				icon_size = 128,
				effects =
				{
					{
						type = "unlock-recipe",
						recipe = "RTMagnetSwitchTrainRampRecipe"
					},
					{
						type = "unlock-recipe",
						recipe = "RTSwitchTrainRampRecipe"
					},
				},
				prerequisites = {"RTMagnetTrainRamps", "RTTrapdoorWagonTech"},
				unit =
				{
					count = 300,
					ingredients =
					{
						{"automation-science-pack", 1},
						{"logistic-science-pack", 1},
						{"chemical-science-pack", 1},
						{"space-science-pack", 1},
						{"metallurgic-science-pack", 1},
					},
					time = 30
				}
			}
		})
	end
else
	data:extend({
		{ --------- wagon recipe ----------
			type = "recipe",
			name = "RTTrapdoorWagonRecipe",
			enabled = false,
			energy_required = 1,
			ingredients =
				{
					{type="item", name="iron-gear-wheel", amount=4},
					{type="item", name="iron-stick", amount=2},
					{type="item", name="advanced-circuit", amount=20},
					{type="item", name="cargo-wagon", amount=1}
				},
			results = {
				{type="item", name="RTTrapdoorWagonItem", amount=1}
			}
		},
		{ --------- Switch recipe ----------
			type = "recipe",
			name = "RTTrapdoorSwitchRecipe",
			enabled = false,
			energy_required = 0.1,
			ingredients =
			{
				{type="item", name="electronic-circuit", amount=2},
				{type="item", name="steel-plate", amount=2},
				{type="item", name="iron-plate", amount=5},
			},
			results = {
				{type="item", name="RTTrapdoorSwitchItem", amount=1}
			}
		},
		{ --- wagon tech
			type = "technology",
			name = "RTTrapdoorWagonTech",
			icon = "__RenaiTransportation__/graphics/tech/TrapdoorWagonTech.png",
			icon_size = 128,
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "RTTrapdoorWagonRecipe"
				},
				{
					type = "unlock-recipe",
					recipe = "RTTrapdoorSwitchRecipe"
				},
			},
			prerequisites = {"se-no", "railway", "circuit-network"},
			unit =
			{
				count = 500,
				ingredients =
				{
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
				},
				time = 60
			}
		},
	})
	--- ramp switch tech
	if (settings.startup["RTTrapdoorSetting"].value == true) then
		data:extend({
			{
				type = "technology",
				name = "RTSwitchRampTech",
				icon = "__RenaiTransportation__/graphics/tech/SwitchRampTech.png",
				icon_size = 128,
				effects =
				{
					{
						type = "unlock-recipe",
						recipe = "RTMagnetSwitchTrainRampRecipe"
					},
					{
						type = "unlock-recipe",
						recipe = "RTSwitchTrainRampRecipe"
					},
				},
				prerequisites = {"RTMagnetTrainRamps", "RTTrapdoorWagonTech"},
				unit =
				{
					count = 300,
					ingredients =
					{
						{"automation-science-pack", 1},
						{"logistic-science-pack", 1},
						{"chemical-science-pack", 1},
					},
					time = 30
				}
			}
		})
	end
end
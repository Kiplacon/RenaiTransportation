for _, variants in pairs(
	{
		{"TrainRamp", "a"}, {"TrainRampNoSkip", "aa"}, {"MagnetTrainRamp", "b"}, {"MagnetTrainRampNoSkip", "ba"},
		{"SwitchTrainRamp", "gc"}, {"SwitchTrainRampNoSkip", "gcc"}, {"MagnetSwitchTrainRamp", "gd"}, {"MagnetSwitchTrainRampNoSkip", "gdd"}
	}) do
	local variant = variants[1]
	local order = variants[2]
	local GroundMask = {layers={["train"]=true}}
	local ElevMask = {layers={["elevated_train"]=true}}
	local CellBox = {{-0.5, -2}, {1.5, 2}}
	local hidden = (string.find(variant, "NoSkip") ~= nil)
	data:extend({
		{
			type = "rail-signal",
			name = "RT"..variant,
			icon = renaiIcons .. "ramp_" .. variant .. "Icon.png",
			icon_size = 64,
			flags = {"player-creation", "not-on-map", "placeable-off-grid", "hide-alt-info", "not-flammable"},
			hidden = true,
			minable = {mining_time = 1, result = "RT"..variant:gsub("NoSkip", "")},
			max_health = 500,
			corpse = "medium-remnants",
			dying_explosion = "medium-explosion",
			collision_box = {{-0.9, -1.9}, {0.9, 1.9}},
			selection_box = CellBox,
			selection_priority = 100,
			elevated_selection_priority = 100,
			collision_mask = GroundMask,
			elevated_collision_mask = ElevMask,
			ground_picture_set = RampPictureSets(variant),
			elevated_picture_set = RampPictureSets(variant),
			placeable_by = { item = "RT"..variant:gsub("NoSkip", ""), count = 1 }, -- Controls `q` and blueprint behavior
			resistances = {
				{
					type = "impact",
					percent = 100
				}
			}
		},
		{
			type = "item",
			name = "RT"..variant,
			icon = renaiIcons .. "ramp_" .. variant .. "Icon.png",
			icon_size = 64,
			subgroup = "RTTrainStuff",
			hidden = hidden,
			order = order,
			place_result = "RT"..variant.."-placer",
			stack_size = 10
		},
		makeRampPlacerEntity(
				"RT"..variant.."-placer",
				renaiIcons .. "ramp_" .. variant .. "Icon.png",
				renaiEntity .."Train_ramps/TrainRamp_Placer.png",
				"RT"..variant
			),
		CreateRampSprites("RT"..variant.."", variant)
	})
end


-- Add recipes for both items
data:extend({
	{ --------- ramp recipe ----------
		type = "recipe",
		name = "RTTrainRamp",
		enabled = false,
		energy_required = 2,
		ingredients =
			{
				{type="item", name="rail", amount=4},
				{type="item", name="steel-plate", amount=30},
				{type="item", name="concrete", amount=50}
			},
		results = {
			{type="item", name="RTTrainRamp", amount=1}
		}
	},
	{ --------- ramp recipe ----------
		type = "recipe",
		name = "RTMagnetTrainRamp",
		enabled = false,
		energy_required = 2,
		ingredients =
			{
				{type="item", name="RTTrainRamp", amount=1},
				{type="item", name="accumulator", amount=1},
				{type="item", name="substation", amount=1},
				{type="item", name="steel-plate", amount=100},
				{type="item", name="advanced-circuit", amount=25}
			},
		results = {
			{type="item", name="RTMagnetTrainRamp", amount=1}
		}
	},
	{
		type = "technology",
		name = "RTFlyingFreight",
		icon = renaiTechIcons .. "FlyingFreight.png",
		icon_size = 256,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "RTTrainRamp"
			}
		},
		prerequisites = {"se-no", "railway", "concrete"},
		unit =
		{
			count = 200,
			ingredients =
			{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1}
			},
			time = 30
		}
	},
	{
		type = "technology",
		name = "RTMagnetTrainRamps",
		icon = renaiTechIcons .. "MagnetFreight.png",
		icon_size = 256,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "RTMagnetTrainRamp"
			}
		},
		prerequisites = {"RTFlyingFreight", "electric-energy-accumulators", "electric-energy-distribution-2"},
		unit =
		{
			count = 250,
			ingredients =
			{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1}
			},
			time = 45
		}
	},
})

if (settings.startup["RTTrapdoorSetting"].value == true) then
	data:extend({
		{ --------- switch ramp recipe ----------
			type = "recipe",
			name = "RTSwitchTrainRamp",
			enabled = false,
			energy_required = 2,
			ingredients =
				{
					{type="item", name="RTTrainRamp", amount=1},
					{type="item", name="RTTrapdoorSwitch", amount=1}
				},
			results = {
				{type="item", name="RTSwitchTrainRamp", amount=1}
			}
		},
		{ --------- magnet switch ramp recipe ----------
			type = "recipe",
			name = "RTMagnetSwitchTrainRamp",
			enabled = false,
			energy_required = 2,
			ingredients =
				{
					{type="item", name="RTMagnetTrainRamp", amount=1},
					{type="item", name="RTTrapdoorSwitch", amount=1}
				},
			results = {
				{type="item", name="RTMagnetSwitchTrainRamp", amount=1}
			}
		},
	})
end

-- Add supporting entities for the mag ramp
data:extend(require('mag_ramp_entities'))

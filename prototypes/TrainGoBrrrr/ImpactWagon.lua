local OhYouLikeTrains = table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])
local color = {100,100,100}
OhYouLikeTrains.name = "RTImpactWagon"
OhYouLikeTrains.icons =
{
	{
		icon = "__base__/graphics/icons/cargo-wagon.png",
		icon_size = 64,
		icon_mipmaps = 4,
		tint = color
	}
}
OhYouLikeTrains.minable = {mining_time = 0.5, result = "RTImpactWagon"}

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

local NameEveryTrainStation = table.deepcopy(data.raw["train-stop"]["train-stop"])
NameEveryTrainStation.name = "RTImpactUnloader"


data:extend({
----wagon
OhYouLikeTrains,

{ --------- wagon item -------------
	type = "item",
	name = "RTImpactWagon",
	icon_size = 64,
	icons =
	{
		{
			icon = "__base__/graphics/icons/cargo-wagon.png",
			icon_mipmaps = 4,
			tint = color
		}
	},
	subgroup = "RTTrainStuff",
	order = "e",
	place_result = "RTImpactWagon",
	stack_size = 5
},
{ --------- wagon recipe ----------
	type = "recipe",
	name = "RTImpactWagon",
	enabled = false,
	energy_required = 1,
	ingredients =
		{
			{type="item", name="advanced-circuit", amount=10},
			{type="item", name="steel-plate", amount=50},
			{type="item", name="cargo-wagon", amount=1}
		},
	results = {
		{type="item", name="RTImpactWagon", amount=1}
	}
},

{ --------- impact recipe ----------
	type = "recipe",
	name = "RTImpactUnloader",
	enabled = false,
	energy_required = 2,
	ingredients =
		{
			{type="item", name="advanced-circuit", amount=20},
			{type="item", name="steel-plate", amount=100},
			{type="item", name="refined-concrete", amount=100}
		},
	results = {
		{type="item", name="RTImpactUnloader", amount=1}
	}
},
{
	type = "technology",
	name = "RTImpactTech",
	icon = "__RenaiTransportation__/graphics/tech/Impact.png",
	icon_size = 128,
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "RTImpactWagon"
		},
		{
			type = "unlock-recipe",
			recipe = "RTImpactUnloader"
		}
	},
	prerequisites = {"se-no", "railway", "concrete", "advanced-circuit"},
	unit =
	{
		count = 200,
		ingredients =
		{
		{"automation-science-pack", 1},
		{"logistic-science-pack", 1}
		},
		time = 45
	}
},
})


for _, variants in pairs(
	{
		{"ImpactUnloader", "c"},
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
			icon = "__RenaiTransportation__/graphics/TrainRamp/icons/"..variant.."Icon.png",
			icon_size = 64,
			flags = {"player-creation", "not-on-map", "placeable-off-grid", "hide-alt-info", "not-flammable"},
			hidden = true,
			minable = {mining_time = 1, result = "RT"..variant:gsub("NoSkip", "")},
			max_health = 500,
			collision_box = {{-0.9, -1.9}, {0.9, 1.9}},
			selection_box = CellBox,
			selection_priority = 100,
			elevated_selection_priority = 100,
			collision_mask = GroundMask,
			elevated_collision_mask = ElevMask,
			ground_picture_set = RampPictureSets("__RenaiTransportation__/graphics/TrainRamp/ramps/"..variant..".png"),
			elevated_picture_set = RampPictureSets("__RenaiTransportation__/graphics/TrainRamp/ramps/"..variant..".png"),
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
			icon = "__RenaiTransportation__/graphics/TrainRamp/icons/"..variant.."Icon.png",
			icon_size = 64,
			subgroup = "RTTrainStuff",
			hidden = hidden,
			order = order,
			place_result = "RT"..variant.."-placer",
			stack_size = 10
		},
		makeRampPlacerEntity(
				"RT"..variant.."-placer",
				"__RenaiTransportation__/graphics/TrainRamp/icons/"..variant.."Icon.png",
				"__RenaiTransportation__/graphics/TrainRamp/ramps/"..variant.."Placer.png",
				"RT"..variant
			),
		CreateRampSprites("RT"..variant.."", "__RenaiTransportation__/graphics/TrainRamp/ramps/"..variant..".png")
	})
end
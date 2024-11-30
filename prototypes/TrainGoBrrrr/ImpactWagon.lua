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
OhYouLikeTrains.minable = {mining_time = 0.5, result = "RTImpactWagonItem"}
--OhYouLikeTrains.inventory_size = 8

OhYouLikeTrains.pictures.rotated.layers[1].tint = color
OhYouLikeTrains.pictures.rotated.layers[2].tint = color
OhYouLikeTrains.pictures.rotated.layers[3].tint = color

OhYouLikeTrains.horizontal_doors.layers[1].tint = color
OhYouLikeTrains.horizontal_doors.layers[2].tint = color

OhYouLikeTrains.vertical_doors.layers[1].tint = color
OhYouLikeTrains.vertical_doors.layers[2].tint = color

local NameEveryTrainStation = table.deepcopy(data.raw["train-stop"]["train-stop"])
NameEveryTrainStation.name = "RTImpactUnloader"


data:extend({
----wagon
OhYouLikeTrains,

{ --------- wagon item -------------
	type = "item",
	name = "RTImpactWagonItem",
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
	place_result = "RTImpactWagon",
	stack_size = 5
},

{ --------- wagon recipe ----------
	type = "recipe",
	name = "RTImpactWagonRecipe",
	enabled = false,
	energy_required = 1,
	ingredients =
		{
			{type="item", name="advanced-circuit", amount=10},
			{type="item", name="steel-plate", amount=50},
			{type="item", name="cargo-wagon", amount=1}
		},
	results = {
		{type="item", name="RTImpactWagonItem", amount=1}
	}
},

-- -------------- Impact unloader
-- NameEveryTrainStation,
--
-- { --------- impact unloader item ----------
-- 	type = "item",
-- 	name = "RTImpactUnloaderItem",
-- 	icon = '__RenaiTransportation__/graphics/TrainRamp/RTImpactUnloader-icon.png',
-- 	icon_size = 64,
-- 	subgroup = "RT",
-- 	order = "g",
-- 	place_result = "RTImpactUnloader",
-- 	stack_size = 10
-- },
-- { --------- impact unloader recipe ----------
-- 	type = "recipe",
-- 	name = "RTImpactUnloaderRecipe",
-- 	enabled = false,
-- 	energy_required = 2,
-- 	ingredients =
-- 		{
-- 			{"steel-plate", 100},
-- 			{"refined-concrete", 100}
-- 		},
-- 	result = "RTImpactUnloaderItem"
-- }

})

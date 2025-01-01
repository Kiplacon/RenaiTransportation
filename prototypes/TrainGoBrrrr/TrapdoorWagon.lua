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
OhYouLikeTrains.minable = {mining_time = 0.5, result = "RTImpactWagonItem"}
--OhYouLikeTrains.inventory_size = 8

OhYouLikeTrains.pictures.rotated.layers[1].tint = color
OhYouLikeTrains.pictures.rotated.layers[2].tint = color
OhYouLikeTrains.pictures.rotated.layers[3].tint = color

OhYouLikeTrains.horizontal_doors.layers[1].tint = color
OhYouLikeTrains.horizontal_doors.layers[2].tint = color

OhYouLikeTrains.vertical_doors.layers[1].tint = color
OhYouLikeTrains.vertical_doors.layers[2].tint = color

local NameEveryTrainStation =
{
	type = "simple-entity-with-owner",
	name = "RTTrapdoorTrigger",
	flags = {"placeable-off-grid"},
	minable = {mining_time = 0.5, result = "RTTrapdoorTriggerItem"},
	max_health = 500,
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
	collision_mask = {layers={["elevated_train"]=true, ["train"]=true}},
	render_layer = "elevated-object",
	picture = {
		filename = '__RenaiTransportation__/graphics/LickmawBALLS.png',
		width = 64,
		height = 64,
		scale = 0.5
	},
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

{ --------- wagon recipe ----------
	type = "recipe",
	name = "RTTrapdoorWagonRecipe",
	enabled = true,
	energy_required = 1,
	ingredients =
		{
			{type="item", name="advanced-circuit", amount=10},
			{type="item", name="steel-plate", amount=50},
			{type="item", name="cargo-wagon", amount=1}
		},
	results = {
		{type="item", name="RTTrapdoorWagonItem", amount=1}
	}
},

-------------- trigger
NameEveryTrainStation,

{ --------- trigger item ----------
    type = "item",
    name = "RTTrapdoorTriggerItem",
    icon = '__RenaiTransportation__/graphics/TrainRamp/RTImpactUnloader-icon.png',
    icon_size = 64,
    subgroup = "RT",
    order = "g",
    place_result = "RTTrapdoorTrigger",
    stack_size = 10,
},
{ --------- trigger recipe ----------
    type = "recipe",
    name = "RTTrapdoorTriggerRecipe",
    enabled = true,
    energy_required = 0.1,
    ingredients =
    {
        {type="item", name="advanced-circuit", amount=10},
    },
    results = {
        {type="item", name="RTTrapdoorTriggerItem", amount=1}
    }
}

})

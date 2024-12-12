local OhYouLikeTrains = table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])
local color = {1,1,0}
OhYouLikeTrains.name = "RTTrapdoortWagon"
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

local NameEveryTrainStation = table.deepcopy(data.raw["land-mine"]["land-mine"])
NameEveryTrainStation.name = "RTTrapdoorTrigger"
NameEveryTrainStation.trigger_collision_mask = {layers={["elevated_train"]=true, ["train"]=true}}
NameEveryTrainStation.collision_mask = {layers={}}
NameEveryTrainStation.picture_safe.tint = color
NameEveryTrainStation.picture_set.tint = color
NameEveryTrainStation.picture_set_enemy.tint = color
NameEveryTrainStation.trigger_radius = 0.75
NameEveryTrainStation.timeout = 0
NameEveryTrainStation.trigger_force = "all"
NameEveryTrainStation.force_die_on_attack = false
NameEveryTrainStation.action =
{
    type = "direct",
    action_delivery =
    {
        type = "instant",
        target_effects =
        {
            {
                type = "script",
                effect_id = "RTToggleTrapdoor",
                affects_target = true,
            },
        }
    }
}


data:extend({
----wagon
OhYouLikeTrains,

{ --------- wagon item -------------
	type = "item",
	name = "RTTrapdoortWagonItem",
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
	place_result = "RTTrapdoortWagon",
	stack_size = 5
},

{ --------- wagon recipe ----------
	type = "recipe",
	name = "RTTrapdoortWagonRecipe",
	enabled = false,
	energy_required = 1,
	ingredients =
		{
			{type="item", name="advanced-circuit", amount=10},
			{type="item", name="steel-plate", amount=50},
			{type="item", name="cargo-wagon", amount=1}
		},
	results = {
		{type="item", name="RTTrapdoortWagonItem", amount=1}
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
    stack_size = 10
},
{ --------- trigger recipe ----------
    type = "recipe",
    name = "RTTrapdoorTriggerRecipe",
    enabled = false,
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

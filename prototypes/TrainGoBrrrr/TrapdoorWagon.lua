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

local NameEveryTrainStation =
{
	type = "simple-entity-with-owner",
	name = "RTTrapdoorTrigger",
	flags = {"placeable-off-grid", "player-creation"},
	minable = {mining_time = 0.5, result = "RTTrapdoorTriggerItem"},
	max_health = 500,
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
	collision_mask = {layers={}, not_colliding_with_itself=true},
	render_layer = "transport-belt",
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
    icon = '__RenaiTransportation__/graphics/LickmawBALLS.png',
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
},
{ -- actual collision detector
	type = "simple-entity-with-owner",
	name = "RTTrainDetector",
	icon = '__RenaiTransportation__/graphics/Untitled.png',
	icon_size = 32,
	flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-flammable", "no-copy-paste"},
	max_health = 1,
	selection_box = {{-0.2, -0.2}, {0.2, 0.2}},
	collision_box = {{-0.01, -0.01}, {0.01, 0.01}},
	collision_mask = {layers={["elevated_train"]=true, ["train"]=true}},
	picture = {
		filename = '__RenaiTransportation__/graphics/Untitled.png',
		width = 32,
		height = 32,
		scale = 0.5
	},
}

})

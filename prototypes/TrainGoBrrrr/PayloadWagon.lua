local OhYouLikeTrains = table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])

OhYouLikeTrains.name = "RTPayloadWagon"
OhYouLikeTrains.icons = 
{
	{
		icon = "__base__/graphics/icons/cargo-wagon.png",
		icon_size = 64, 
		icon_mipmaps = 4,
		tint = {220,125,0}
	}
}
OhYouLikeTrains.minable = {mining_time = 0.5, result = "RTPayloadWagonItem"}
OhYouLikeTrains.inventory_size = 8

OhYouLikeTrains.pictures.rotated.layers[1].tint = {220,125,0}
OhYouLikeTrains.pictures.rotated.layers[2].tint = {220,125,0}
OhYouLikeTrains.pictures.rotated.layers[3].tint = {220,125,0}

OhYouLikeTrains.horizontal_doors.layers[1].tint = {220,125,0}
OhYouLikeTrains.horizontal_doors.layers[2].tint = {220,125,0}

OhYouLikeTrains.vertical_doors.layers[1].tint = {220,125,0}
OhYouLikeTrains.vertical_doors.layers[2].tint = {220,125,0}

data:extend({ 

OhYouLikeTrains,

{ --------- prop item -------------
	type = "item",
	name = "RTPayloadWagonItem",
	icon_size = 64,
	icons = 
	{
		{
			icon = "__base__/graphics/icons/cargo-wagon.png",
			icon_mipmaps = 4,
			tint = {220,150,50}
		}
	},
	subgroup = "train-transport",
	order = "aj",
	place_result = "RTPayloadWagon",
	stack_size = 5
},

{ --------- prop recipie ----------
	type = "recipe",
	name = "RTPayloadWagonRecipe",
	enabled = false,
	energy_required = 1,
	ingredients = 
		{
			{type="item", name="explosives", amount=10},
			{type="item", name="PrimerBouncePlateItem", amount=5},
			{type="item", name="cargo-wagon", amount=1}
		},
	results = {
		{type="item", name="RTPayloadWagonItem", amount=1}
	}
}

})
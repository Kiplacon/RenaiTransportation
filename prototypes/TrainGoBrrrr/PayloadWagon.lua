local OhYouLikeTrains = table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])
local color = {220,125,0}
OhYouLikeTrains.name = "RTPayloadWagon"
OhYouLikeTrains.icons =
{
	{
		icon = "__base__/graphics/icons/cargo-wagon.png",
		icon_size = 64, 
		icon_mipmaps = 4,
		tint = color
	}
}
OhYouLikeTrains.minable = {mining_time = 0.5, result = "RTPayloadWagonItem"}
OhYouLikeTrains.inventory_size = 8

for _, part in pairs({"rotated", "sloped"}) do
	if OhYouLikeTrains.pictures[part].layers then
		for i, layer in pairs(OhYouLikeTrains.pictures[part].layers) do
			layer.tint = color
		end
	end
end
for _, part in pairs({"horizontal_doors", "vertical_doors"}) do
	if OhYouLikeTrains[part].layers then
		for i, layer in pairs(OhYouLikeTrains[part].layers) do
			layer.tint = color
		end
	end
end

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

{ --------- prop recipe ----------
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
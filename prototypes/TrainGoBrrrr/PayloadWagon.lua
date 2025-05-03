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
OhYouLikeTrains.minable = {mining_time = 0.5, result = "RTPayloadWagon"}
OhYouLikeTrains.inventory_size = 8

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

data:extend({ 

OhYouLikeTrains,

{ --------- prop item -------------
	type = "item",
	name = "RTPayloadWagon",
	icon_size = 64,
	icons = 
	{
		{
			icon = "__base__/graphics/icons/cargo-wagon.png",
			icon_mipmaps = 4,
			tint = {220,150,50}
		}
	},
	subgroup = "RTTrainStuff",
	order = "f",
	place_result = "RTPayloadWagon",
	stack_size = 5
},

{ --------- prop recipe ----------
	type = "recipe",
	name = "RTPayloadWagon",
	enabled = false,
	energy_required = 1,
	ingredients = 
		{
			{type="item", name="explosives", amount=10},
			{type="item", name="PrimerBouncePlate", amount=5},
			{type="item", name="cargo-wagon", amount=1}
		},
	results = {
		{type="item", name="RTPayloadWagon", amount=1}
	}
},

{
	type = "technology",
	name = "RTDeliverThePayload",
	icon = "__RenaiTransportation__/graphics/tech/boom.png",
	icon_size = 128,
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "RTPayloadWagon"
		}
	},
	prerequisites = {"PrimerPlateTech", "RTFlyingFreight", "explosives", "military-3"},
	unit =
	{
		count = 200,
		ingredients =
			{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"military-science-pack", 1},
			{"chemical-science-pack", 1}
			},
		time = 30
		}
}

})
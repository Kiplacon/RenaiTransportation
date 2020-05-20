-------------Open Container Entity ---------------------
local datboi = table.deepcopy(data.raw.container["iron-chest"])
	datboi.name = "OpenContainer"
	datboi.icon = "__RenaiTransportation__/graphics/OpenContainer/icon.png"
	datboi.picture.layers[1].hr_version.filename = "__RenaiTransportation__/graphics/OpenContainer/hrOpenContainer.png"
	datboi.minable = {mining_time = 0.2, result = "OpenContainerItem"}
	
data:extend({ 
	
	{ --------- The container item -------------
		type = "item",
		name = "OpenContainerItem",
		icon = "__RenaiTransportation__/graphics/OpenContainer/icon.png",
		icon_size = 64, 
		icon_mipmaps = 4,
		subgroup = "RT",
		order = "a[items]-b[wooden-chest]",
		place_result = "OpenContainer",
		stack_size = 50
	},
	
	{ --------- The container recipie ----------
		type = "recipe",
		name = "OpenContainerRecipie",
		enabled = true,
		energy_required = 0.5,
		ingredients = {{"iron-chest", 1}},
		result = "OpenContainerItem"
	},
	
	datboi
	
})
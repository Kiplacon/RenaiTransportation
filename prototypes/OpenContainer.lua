-------------Open Container Entity ---------------------
local datboi = table.deepcopy(data.raw.container["iron-chest"])
	datboi.name = "OpenContainer"
	datboi.icon = "__RenaiTransportation__/graphics/OpenContainer/icon.png"
	datboi.picture = {
		filename = "__RenaiTransportation__/graphics/OpenContainer/hrOpenContainer.png",
		priority = "extra-high",
		width = 66,
		height = 76,
		scale = 0.5
	}
	datboi.minable = {mining_time = 0.2, result = "OpenContainerItem"}
	datboi.next_upgrade = nil
	datboi.not_upgradable = true
	
data:extend({ 
	
	{ --------- The container item -------------
		type = "item",
		name = "OpenContainerItem",
		icon = "__RenaiTransportation__/graphics/OpenContainer/icon.png",
		icon_size = 64, 
		icon_mipmaps = 4,
		subgroup = "RT",
		order = "b",
		place_result = "OpenContainer",
		stack_size = 50
	},
	
	{ --------- The container recipie ----------
		type = "recipe",
		name = "OpenContainerRecipie",
		enabled = true,
		energy_required = 0.5,
		ingredients = {{type="item", name="iron-chest", amount=1}},
		results = {
			{type="item", name="OpenContainerItem", amount=1}
		}
	},
	
	{ --------- open to regular chest recipie ----------
		type = "recipe",
		name = "OpenContainerRevertRecipie",
		enabled = true,
		energy_required = 0.5,
		ingredients = {{type="item", name="OpenContainerItem", amount=1}},
		results = {
			{type="item", name="iron-chest", amount=1}
		},
		allow_as_intermediate = false
	},
	
	datboi
	
})
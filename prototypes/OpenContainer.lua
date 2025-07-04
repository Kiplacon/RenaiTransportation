-------------Open Container Entity ---------------------
local datboi = table.deepcopy(data.raw.container["iron-chest"])
	datboi.name = "OpenContainer"
	datboi.icon = renaiIcons .. "OpenContainer_icon.png"
	datboi.picture = {
		filename = renaiEntity .. "OpenContainer/OpenContainer.png",
		priority = "extra-high",
		width = 66,
		height = 76,
		scale = 0.5
	}
	datboi.minable = {mining_time = 0.2, result = "OpenContainer"}
	datboi.next_upgrade = nil
	datboi.not_upgradable = true
	
data:extend({ 
	
	{ --------- The container item -------------
		type = "item",
		name = "OpenContainer",
		icon = renaiIcons .. "OpenContainer_icon.png",
		icon_size = 64,
		subgroup = "RT",
		order = "b",
		place_result = "OpenContainer",
		stack_size = 50
	},
	
	{ --------- The container recipe ----------
		type = "recipe",
		name = "OpenContainer",
		enabled = true,
		energy_required = 0.5,
		ingredients = {{type="item", name="iron-chest", amount=1}},
		results = {
			{type="item", name="OpenContainer", amount=1}
		}
	},
	
	{ --------- open to regular chest recipe ----------
		type = "recipe",
		name = "OpenContainerRevertRecipe",
		enabled = true,
		energy_required = 0.5,
		ingredients = {{type="item", name="OpenContainer", amount=1}},
		results = {
			{type="item", name="iron-chest", amount=1}
		},
		allow_as_intermediate = false
	},
	
	datboi
	
})
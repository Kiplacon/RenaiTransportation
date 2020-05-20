-------------Bounce Plate Entity ---------------------
local rrrrr = table.deepcopy(data.raw.inserter["inserter"])
	rrrrr.type = "inserter"
	rrrrr.name = "BouncePlate"
	rrrrr.minable = { mining_time = 0.1, result = "BouncePlateItem"}
    rrrrr.selection_box = {{-0.4, -0.35}, {0.4, 0.45}}
    rrrrr.pickup_position = {0, -0.8}
    rrrrr.insert_position = {0, -10.2}
	--rrrrr.chases_belt_items = false
	rrrrr.allow_custom_vectors = true
	rrrrr.rotation_speed = 0.0005
	rrrrr.extension_speed = 0.0003
	rrrrr.inserter_stack_size_override = 0
	rrrrr.next_upgrade = ""
	rrrrr.fast_replaceable_group = ""
	rrrrr.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
	--rrrrr.collision_mask = {}
	nothinggg = {
        filename = "__Kupo__/graphics/nothing.png",
        priority = "extra-high",
        width = 32,
        height = 32,
        scale = 0.25}
	rrrrr.hand_base_picture.hr_version= nothinggg
	rrrrr.hand_closed_picture.hr_version= nothinggg
	rrrrr.hand_open_picture.hr_version= nothinggg
	rrrrr.hand_base_shadow.hr_version= nothinggg
	rrrrr.hand_closed_shadow.hr_version= nothinggg
	rrrrr.hand_open_shadow.hr_version= nothinggg
	rrrrr.platform_picture.sheet.hr_version =
		{
		  filename = "__Kupo__/graphics/BouncePlate/BouncePlate.png",
		  priority = "extra-high",
		  width = 105,
		  height = 79,
		  --shift = util.by_pixel(1.5, 7.5-1),
		  scale = 0.5
		}
	rrrrr.energy_source = {type = "void"}

data:extend({ 
	
	{ --------- The Bounce plate item -------------
		type = "item",
		name = "BouncePlateItem",
		icon = "__Kupo__/graphics/BouncePlate/icon.png",
		icon_size = 32, --icon_mipmaps = 4,
		subgroup = "storage",
		order = "a[items]-a[wooden-chest]",
		place_result = "BouncePlate",
		stack_size = 50
	},
	
	{ --------- The Bounce plate recipie ----------
		type = "recipe",
		name = "BouncePlateRecipie",
		enabled = true,
		energy_required = 1,
		ingredients = {{"stone", 1}},
		result = "BouncePlateItem"
	},
	
	rrrrr
	
})
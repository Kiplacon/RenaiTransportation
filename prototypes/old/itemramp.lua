
--Item Ramp item
pokemon = {type = "simple-entity-with-owner",
name = "item-ramp-entity",
icon = "__Kupo__/graphics/entity/icon.png",
icon_size = 32,
collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
minable = {mining_time = 0.2},
animations = {
  {filename = "__Kupo__/graphics/entity/ramp.png",
  width = 64,
  height = 64,
  line_length = 3,
  frame_count = 3,
  --shift = { -0.03125, -1.71875},
  animation_speed = 0.05,
  scale = 0.5}}
}

--invisible inserter entity
local rrrrr = table.deepcopy(data.raw.inserter["filter-inserter"])
	rrrrr.type = "inserter"
	rrrrr.name = "item-ramp-animator"
	rrrrr.minable = { mining_time = 0.1 }
    rrrrr.selection_box = {{-0.4, -0.35}, {0.4, 0.45}}
    --rrrrr.pickup_position = {-5.8, -4}
    --rrrrr.insert_position = {5, -4.2}
	rrrrr.pickup_position = {-1, 0}
    rrrrr.insert_position = {10, 0}
	rrrrr.chases_belt_items = false
	rrrrr.allow_custom_vectors = true
	rrrrr.rotation_speed = 0.005
	rrrrr.extension_speed = 0.3
	rrrrr.inserter_stack_size_override = 0
	rrrrr.next_upgrade = ""
	rrrrr.fast_replaceable_group = ""
	rrrrr.collision_mask = {}
	nothinggg = {
        filename = "__Kupo__/graphics/entity/nothing.png",
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
	--rrrrr.platform_picture.sheet.hr_version.filename = "__Kupo__/graphics/entity/nobass.png"
	rrrrr.energy_source = {type = "void"}

data:extend({
	--make item ramp item properties
	{type = "item",
    name = "item-ramp-item",
    icon_size = 32,
    icon = "__Kupo__/graphics/entity/untitled.png",
    place_result = "item-ramp-entity",
	subgroup = "logistic-network",
    order = "b[storage]-c[logistic-chest-storage]",
    stack_size = 50},
	
	--make item ramp recipie
	{type = "recipe",
    name = "item-ramp-recipie",
    enabled = true,
	category = "advanced-crafting",
    energy_required = 3,
    ingredients = {{"stone", 1}},
    result = "item-ramp-item"},
	
	
	
	{type = "item",
    name = "item-ramp-animator-dummy-item",
    icon_size = 32,
    icon = "__Kupo__/graphics/entity/untitled.png",
	--flags = {"hidden"},
    place_result = "item-ramp-animator",
	subgroup = "logistic-network",
    order = "b[storage]-d[logistic-chest-storage]",
    stack_size = 1},
	
	{type = "recipe",
    name = "item-ramp-dummy-recipie",
    enabled = true,
	category = "advanced-crafting",
    energy_required = 3,
    ingredients = {{"stone", 1}},
    result = "item-ramp-animator-dummy-item"},
	
	rrrrr,
	
	pokemon
})


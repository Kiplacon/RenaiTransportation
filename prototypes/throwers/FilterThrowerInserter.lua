------ the thrower entity ----------
local memes = table.deepcopy(data.raw.inserter["filter-inserter"])
	memes.name = "FilterThrowerInserter"
	memes.icon = "__RenaiTransportation__/graphics/ThrowerInserter/filtericonn.png"
	memes.icon_size = 64 
	memes.icon_mipmaps = 4
	memes.minable = {mining_time = 0.2, result = "FilterThrowerInserterItem"}
	memes.insert_position = {0, 14.9}
	memes.hand_size = 0
	--memes.chases_belt_items = false
    --memes.extension_speed = 0.027 -- default 0.03
    --memes.rotation_speed = 0.03 -- default 0.014 
    memes.fast_replaceable_group = "inserter"
    memes.next_upgrade = nil
	memes.hand_base_picture = 
		{
		filename = "__RenaiTransportation__/graphics/ThrowerInserter/hr-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
		}
	memes.hand_closed_picture = 
		{
		filename = "__RenaiTransportation__/graphics/ThrowerInserter/hr-inserter-hand-closed.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
		}
	memes.hand_open_picture =
		{
		filename = "__RenaiTransportation__/graphics/ThrowerInserter/hr-inserter-hand-open.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
		}

------ Adds the fast thrower to appropriate research -------	
table.insert(data.raw["technology"]["fast-inserter"].effects,{type="unlock-recipe",recipe="FilterThrowerInserterRecipie"})	
	
data:extend({ 	
	{ --------- The thrower item -------------
		type = "item",
		name = "FilterThrowerInserterItem",
		icon = "__RenaiTransportation__/graphics/ThrowerInserter/filtericonn.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "throwers",
		order = "a[items]-d[wooden-chest]",
		place_result = "FilterThrowerInserter",
		stack_size = 50
	},
	
	{ --------- The thrower recipie ----------
		type = "recipe",
		name = "FilterThrowerInserterRecipie",
		enabled = false,
		energy_required = 0.5,
		ingredients = 
			{
				{"filter-inserter", 1},
				{"copper-cable", 4}
			},
		result = "FilterThrowerInserterItem"
	},
	
	memes
	
})

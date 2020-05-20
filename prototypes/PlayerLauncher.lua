------ the thrower entity ----------
local PikachuFace = table.deepcopy(data.raw.inserter["inserter"])
	PikachuFace.name = "PlayerLauncher"
	PikachuFace.icon = "__RenaiTransportation__/graphics/PlayerLauncher/icon.png"
	PikachuFace.icon_size = 32 
	PikachuFace.icon_mipmaps = 4
	PikachuFace.minable = {mining_time = 0.2, result = "PlayerLauncherItem"}
	PikachuFace.insert_position = {0, -10.2}
	PikachuFace.pickup_position = {0, -0.1}
	PikachuFace.hand_size = 0
	PikachuFace.collision_box = {{-0.05, -0.05}, {0.05, 0.05}} -- This size keeps it from being STOMPED when a player lands on it
	PikachuFace.collision_mask = { "item-layer", "object-layer", "water-tile"} --not the player-layer so they can step on it
	PikachuFace.selection_box = {{-0.35, -0.35}, {0.35, 0.35}}
    PikachuFace.extension_speed = 0.027 -- default 0.03
    PikachuFace.rotation_speed = 0.03 -- default 0.014 
    PikachuFace.fast_replaceable_group = nil
    PikachuFace.next_upgrade = nil
	PikachuFace.energy_source = {type = "void"}	
	nothing =
		{
		filename = "__RenaiTransportation__/graphics/nothing.png",
        priority = "extra-high",
        width = 32,
        height = 32,
        scale = 0.25
		}	
	PikachuFace.hand_base_picture = nothing
	PikachuFace.hand_closed_picture = nothing
	PikachuFace.hand_open_picture = nothing
	PikachuFace.hand_base_shadow.hr_version= nothing
	PikachuFace.hand_closed_shadow.hr_version= nothing
	PikachuFace.hand_open_shadow.hr_version= nothing
	PikachuFace.platform_picture.sheet.hr_version =
		{
		  filename = "__RenaiTransportation__/graphics/PlayerLauncher/PlayerLauncher.png",
		  priority = "extra-high",
		  width = 105,
		  height = 79,
		  shift = nil, -- originally util.by_pixel(1.5, 7.5-1),
		  scale = 0.5
		}

data:extend({ 	
	{ --------- The thrower item -------------
		type = "item",
		name = "PlayerLauncherItem",
		icon = "__RenaiTransportation__/graphics/PlayerLauncher/icon.png",
		icon_size = 32,
		icon_mipmaps = 4,
		subgroup = "RT",
		order = "a[items]-c[wooden-chest]",
		place_result = "PlayerLauncher",
		stack_size = 50
	},
	
	{ --------- The thrower recipie ----------
		type = "recipe",
		name = "PlayerLauncherRecipie",
		enabled = true,
		energy_required = 0.5,
		ingredients = 
			{
				{"BouncePlateItem", 1},
				{"iron-plate", 4}
			},
		result = "PlayerLauncherItem"
	},
	
	PikachuFace
	
})
local brrr = table.deepcopy(data.raw.radar["radar"])
brrr.name = "RTZipline"
brrr.selectable_in_game = false
brrr.flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-flammable", "no-copy-paste"}
brrr.collision_mask = {}
brrr.energy_per_sector = "69TJ"
brrr.max_distance_of_sector_revealed = 0
brrr.max_distance_of_nearby_sector_revealed = 1
brrr.energy_per_nearby_scan = "420TJ"
brrr.energy_source =
    {
      type = "void"
    }
brrr.energy_usage = "420kW"
brrr.radius_minimap_visualisation_color = { r = 0.059, g = 0.092, b = 0.235, a = 0.275 }
brrr.rotation_speed = 0.1
brrr.pictures =
	{
	  filename = "__RenaiTransportation__/graphics/zipline/ZipUnderPlayer.png",
	  priority = "high",
	  width = 128,
	  height = 128,
	  scale = 0.5,
	  apply_projection = false,
	  direction_count = 2,
	  line_length = 2
    }
-- brrr.render_layer = "higher-object-under" -- doesnt work
brrr.integration_patch = nil
brrr.water_reflection = nil
brrr.working_sound =
    {
      sound =
      {
        {
          --filename = "__base__/sound/transport-belt-working.ogg",
		  filename = "__RenaiTransportation__/sickw0bs/zapline.ogg",
          volume = 0.35
        }
      },
	fade_in_ticks = 35,
    max_sounds_per_type = 3,
    audible_distance_modifier = 0.75,
    use_doppler_shift = false
    }

data:extend({ 

brrr,

{
	type = "ammo-category",
	name = "ZiplineMotor",
},

{ --------- zipline item -------------
	type = "gun",
	name = "RTZiplineItem",
	icon = "__RenaiTransportation__/graphics/zipline/icon.png",
	icon_size = 64,
	subgroup = "gun",
	order = "hh",
	stack_size = 1,
    attack_parameters =
    {
      type = "projectile",
	  ammo_category = "ZiplineMotor",
      cooldown = 60,
      movement_slow_down_factor = 0,
      range = 0
    },
},

{ --------- zipline recipie ----------
	type = "recipe",
	name = "RTZiplineRecipe",
	enabled = false,
	energy_required = 0.5,
	ingredients = 
		{
			{"copper-cable", 100},
			{"iron-gear-wheel", 50},
			{"electronic-circuit", 4},
			{"PlayerLauncherItem", 1},
			{"steel-chest", 1}		
		},
	result = "RTZiplineItem"
},

{ --------- zipline controls -------------
	type = "ammo",
	name = "RTZiplineControlsItem",
	icon = "__RenaiTransportation__/graphics/zipline/controls.png",
	icon_size = 64,
	subgroup = "gun",
	order = "hi",
	stack_size = 1,
	ammo_type =
    {
      category = "ZiplineMotor"
	}
},

{ --------- zipline controls recipie ----------
	type = "recipe",
	name = "RTZiplineControlsRecipe",
	enabled = false,
	energy_required = 0.5,
	ingredients = 
		{
			{"copper-cable", 10},
			{"iron-stick", 6},
			{"iron-plate", 2},
			{"electronic-circuit", 2}
		},
	result = "RTZiplineControlsItem"
},

{ ------ zipline over player graphic -----------
	type = "animation",
	name = "RTZiplineOverGFX",
	filename = "__RenaiTransportation__/graphics/zipline/ZipOverPlayer.png",
	size = 128, --{128,128},
	frame_count = 2,
	line_length = 2,
	animation_speed = 0.3
},

{
	type = "sprite",
	name = "RTZiplineHarnessGFX",
	filename = "__RenaiTransportation__/graphics/zipline/ZipHarness.png",
	size = 70
},

})

local succ = table.deepcopy(data.raw.radar["RTZipline"])
succ.name = "RTZiplinePowerDrain"
succ.icon = "__RenaiTransportation__/graphics/zipline/icon.png"
succ.icon_size = 64
succ.energy_per_sector = "69TJ"
succ.energy_per_nearby_scan = "420TJ"
succ.max_distance_of_sector_revealed = 0
succ.max_distance_of_nearby_sector_revealed = 1
succ.energy_source =
    {
      type = "electric",
	  usage_priority = "primary-input"
	  --render_no_power_icon = false,
	  --render_no_network_icon = false
    }
succ.energy_usage = "450kW"
succ.pictures =
	{
	  filename = "__RenaiTransportation__/graphics/nothing.png",
	  priority = "low",
	  width = 32,
	  height = 32,
	  scale = 0.5,
	  apply_projection = false,
	  direction_count = 1,
	  line_length = 1
    }
succ.working_sound = nil

data:extend({ succ })
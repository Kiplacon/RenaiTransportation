local brrr = table.deepcopy(data.raw.radar["radar"])
brrr.name = "RTZipline"
brrr.next_upgrade = nil
brrr.not_upgradable = true
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

{ --------- zipline crank controls -------------
	type = "ammo",
	name = "RTZiplineCrankControlsItem",
	icon = "__RenaiTransportation__/graphics/zipline/crankcontrols.png",
	icon_size = 64,
	subgroup = "gun",
	order = "hj",
	stack_size = 1,
	magazine_size = 1000,
	ammo_type =
    {
      category = "ZiplineMotor",
	  target_type = "position",
	  clamp_position = true,
	  cooldown_modifier = 0.2,
	  action =
		{
			{
			  type = "direct",
			  action_delivery =
			  {
				{
				  type = "instant",
				  source_effects =
				  {
					{
					  type = "script",
					  effect_id = "RTCrank"
					}
				  }
				}
			  }
			}
		}
	}
},
{ --------- zipline crank controls recipie ----------
	type = "recipe",
	name = "RTZiplineCrankControlsRecipe",
	enabled = false,
	energy_required = 0.5,
	ingredients =
		{
			{"RTZiplineControlsItem", 1},
			{"iron-stick", 2},
			{"iron-gear-wheel", 10}
		},
	result = "RTZiplineCrankControlsItem"
},

{ --------- programmabel zipline controls -------------
	type = "ammo",
	name = "RTProgrammableZiplineControlsItem",
	icon = "__RenaiTransportation__/graphics/zipline/autocontrols.png",
	icon_size = 64,
	subgroup = "gun",
	order = "hk",
	stack_size = 1,
	ammo_type =
    {
      category = "ZiplineMotor"

	}
},
{ --------- programmable zipline controls recipie ----------
	type = "recipe",
	name = "RTProgrammableZiplineControlsRecipe",
	enabled = false,
	energy_required = 0.5,
	ingredients =
		{
         {"RTZiplineControlsItem", 1},
			{"electronic-circuit", 5}
		},
	result = "RTProgrammableZiplineControlsItem"
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


if (settings.startup["RTThrowersSetting"].value == true) then
	data:extend({
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
		}
	})

else
	data:extend({
		{ --------- zipline recipie ----------
			type = "recipe",
			name = "RTZiplineRecipe",
			enabled = false,
			energy_required = 0.5,
			ingredients =
				{
					{"copper-cable", 100},
					{"iron-gear-wheel", 50},
					{"electronic-circuit", 5},
					{"steel-chest", 1}
				},
			result = "RTZiplineItem"
		}
	})
end
--============ trolley 2 ==================
local succ2 = table.deepcopy(data.raw.radar["RTZiplinePowerDrain"])
succ2.name = "RTZiplinePowerDrain2"
succ2.icons = {
   {
      icon = "__RenaiTransportation__/graphics/zipline/icon.png",
      icon_size = 64,
      tint = {1,0.9,0},
   }
}
succ2.energy_usage = "1MW"
data:extend({ succ2 })
data:extend({
   { --------- zipline item -------------
   	type = "gun",
   	name = "RTZiplineItem2",
      icons = {
         {
         	icon = "__RenaiTransportation__/graphics/zipline/icon.png",
         	icon_size = 64,
            tint = {1,0.9,0},
         }
      },
   	subgroup = "gun",
   	order = "hha",
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
      name = "RTZiplineRecipe2",
      enabled = false,
      energy_required = 0.5,
      ingredients =
         {
            {"iron-gear-wheel", 100},
            {"engine-unit", 10},
            {"RTZiplineItem", 1},
         },
      result = "RTZiplineItem2"
   }
})
--============ trolley 3 ==================
local succ3 = table.deepcopy(data.raw.radar["RTZiplinePowerDrain"])
succ3.name = "RTZiplinePowerDrain3"
succ3.icons = {
   {
      icon = "__RenaiTransportation__/graphics/zipline/icon.png",
      icon_size = 64,
      tint = {255,35,35},
   }
}
succ3.energy_usage = "5MW"
data:extend({ succ3 })
data:extend({
   { --------- zipline item -------------
   	type = "gun",
   	name = "RTZiplineItem3",
      icons = {
         {
         	icon = "__RenaiTransportation__/graphics/zipline/icon.png",
         	icon_size = 64,
            tint = {255,35,35},
         }
      },
   	subgroup = "gun",
   	order = "hhb",
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
      name = "RTZiplineRecipe3",
      enabled = false,
      energy_required = 0.5,
      ingredients =
         {
            {"iron-gear-wheel", 150},
            {"electric-engine-unit", 10},
            {"advanced-circuit", 10},
            {"RTZiplineItem2", 1},
         },
      result = "RTZiplineItem3"
   }
})
--============ trolley 4 ==================
local succ4 = table.deepcopy(data.raw.radar["RTZiplinePowerDrain"])
succ4.name = "RTZiplinePowerDrain4"
succ4.icons = {
   {
      icon = "__RenaiTransportation__/graphics/zipline/icon.png",
      icon_size = 64,
      tint = {18,201,233},
   }
}
succ4.energy_usage = "10MW"
data:extend({ succ4 })
data:extend({
   { --------- zipline item -------------
   	type = "gun",
   	name = "RTZiplineItem4",
      icons = {
         {
         	icon = "__RenaiTransportation__/graphics/zipline/icon.png",
         	icon_size = 64,
            tint = {18,201,233},
         }
      },
   	subgroup = "gun",
   	order = "hhc",
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
      name = "RTZiplineRecipe4",
      enabled = false,
      energy_required = 0.5,
      ingredients =
         {
            {"iron-gear-wheel", 200},
            {"rocket-fuel", 25},
            {"processing-unit", 5},
            {"RTZiplineItem3", 1},
         },
      result = "RTZiplineItem4"
   }
})
--============ trolley 5 ==================
local succ5 = table.deepcopy(data.raw.radar["RTZiplinePowerDrain"])
succ5.name = "RTZiplinePowerDrain5"
succ5.icons = {
   {
      icon = "__RenaiTransportation__/graphics/zipline/icon.png",
      icon_size = 64,
      tint = {83,255,26},
   }
}
succ5.energy_usage = "50MW"
data:extend({ succ5 })
data:extend({
   { --------- zipline item -------------
   	type = "gun",
   	name = "RTZiplineItem5",
      icons = {
         {
         	icon = "__RenaiTransportation__/graphics/zipline/icon.png",
         	icon_size = 64,
            tint = {83,255,26},
         }
      },
   	subgroup = "gun",
   	order = "hhd",
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
      name = "RTZiplineRecipe5",
      enabled = false,
      energy_required = 0.5,
      ingredients =
         {
            {"iron-gear-wheel", 300},
            {"nuclear-fuel", 5},
            {"fusion-reactor-equipment", 1},
            {"RTZiplineItem4", 1},
         },
      result = "RTZiplineItem5"
   }
})

local RTZiplineTerminal = table.deepcopy(data.raw["electric-pole"]["medium-electric-pole"])
   RTZiplineTerminal.icon = "__RenaiTransportation__/graphics/zipline/terminalicon.png"
   RTZiplineTerminal.icon_size = 64
   RTZiplineTerminal.icon_mipmaps = 1
   RTZiplineTerminal.name = "RTZiplineTerminal"
   RTZiplineTerminal.minable = {mining_time = 0.5, result = "RTZiplineTerminalItem"}
   RTZiplineTerminal.collision_box = {{-0.9, -0.3}, {0.9, 0.9}}
   RTZiplineTerminal.selection_box = {{-1, -0.5}, {1, 1}}
   RTZiplineTerminal.pictures =
    {
      layers =
      {
        {
          filename = "__RenaiTransportation__/graphics/zipline/terminal.png",
          priority = "extra-high",
          width = 125,
          height = 250,
          direction_count = 1,
          shift = {0, -1},
          scale = 0.5
        },
        {
          filename = "__RenaiTransportation__/graphics/zipline/OwTheEdge.png",
          priority = "extra-high",
          width = 212,
          height = 48,
          direction_count = 1,
          shift = {2.6, 0.6},
          scale = 0.5,
          draw_as_shadow = true
        }
      }
    }
   RTZiplineTerminal.connection_points =
   {
     {
       shadow =
       {
         copper = {3.9, 0.5},
         red = {4.25, 0.7},
         green = {3.5, 0.65}
       },
       wire =
       {
         copper = util.by_pixel(0.0, -93),
         red = util.by_pixel(18, -85.0),
         green = util.by_pixel(-14, -85.0)
       }
     }
   }
   RTZiplineTerminal.supply_area_distance = 0
local RTZiplineTerminalItem = table.deepcopy(data.raw.item["medium-electric-pole"])
   RTZiplineTerminalItem.name = "RTZiplineTerminalItem"
   RTZiplineTerminalItem.icon = "__RenaiTransportation__/graphics/zipline/terminalicon.png"
   RTZiplineTerminalItem.icon_size = 64
   RTZiplineTerminalItem.icon_mipmaps = 1
   RTZiplineTerminalItem.place_result = "RTZiplineTerminal"
   RTZiplineTerminalItem.order = "a[energy]-x[ZiplineTerminal]"
local RTZiplineTerminalRecipe =
   {
      type = "recipe",
      name = "RTZiplineTerminalRecipe",
      enabled = false,
      energy_required = 3,
      ingredients =
         {
            {"medium-electric-pole", 1},
            {"electronic-circuit", 10},
            {"steel-plate", 20},
            {"concrete", 25}
         },
      result = "RTZiplineTerminalItem"
   }
data:extend({
   RTZiplineTerminal,
   RTZiplineTerminalItem,
   RTZiplineTerminalRecipe
})

local brrr = table.deepcopy(data.raw.radar["radar"])
brrr.name = "RTZipline"
brrr.next_upgrade = nil
brrr.not_upgradable = true
brrr.selectable_in_game = false
brrr.flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-flammable", "no-copy-paste"}
brrr.collision_mask = {layers={}}
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
      filename = renaiEntity .. "zipline/ZipUnderPlayer.png",
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
            filename = renaiSounds .. "zapline.ogg",
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
	name = "ZiplineController",
   hidden = true,
},

{ --------- zipline item -------------
	type = "gun",
	name = "RTZiplineTrolley",
	icon = renaiIcons .. "zipline_icon1.png",
	icon_size = 64,
	subgroup = "RTZiplineStuff",
	order = "aa",
	stack_size = 1,
   attack_parameters =
   {
      type = "projectile",
      ammo_category = "ZiplineController",
      cooldown = 60,
      movement_slow_down_factor = 0,
      range = 0
   },
},



{ --------- zipline controls -------------
	type = "ammo",
	name = "RTZiplineControls",
	icon = renaiIcons .. "zipline_controls.png",
	icon_size = 64,
	subgroup = "RTZiplineStuff",
	order = "ba",
	stack_size = 1,
	ammo_type =
   {
      category = "ZiplineController"
	},
   ammo_category = "ZiplineController"
},
{ --------- zipline controls recipe ----------
	type = "recipe",
	name = "RTZiplineControls",
	enabled = false,
	energy_required = 0.5,
	ingredients =
		{
			{type="item", name="copper-cable", amount=10},
			{type="item", name="iron-stick", amount=6},
			{type="item", name="iron-plate", amount=2},
			{type="item", name="electronic-circuit", amount=2}
		},
   results = {
      {type="item", name="RTZiplineControls", amount=1}
   }
},

{ --------- zipline crank controls -------------
	type = "ammo",
	name = "RTZiplineCrankControls",
	icon = renaiIcons .. "zipline_crankcontrols.png",
	icon_size = 64,
	subgroup = "RTZiplineStuff",
	order = "bb",
	stack_size = 1,
	magazine_size = 1000,
	ammo_type =
   {
      category = "ZiplineController",
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
	},
   ammo_category = "ZiplineController"
},
{ --------- zipline crank controls recipe ----------
	type = "recipe",
	name = "RTZiplineCrankControls",
	enabled = false,
	energy_required = 0.5,
	ingredients =
		{
			{type="item", name="RTZiplineControls", amount=1},
			{type="item", name="iron-stick", amount=2},
			{type="item", name="iron-gear-wheel", amount=10}
		},
   results = {
      {type="item", name="RTZiplineCrankControls", amount=1}
   }
},

{ --------- programmabel zipline controls -------------
	type = "ammo",
	name = "RTProgrammableZiplineControls",
	icon = renaiIcons .. "zipline_autocontrols.png",
	icon_size = 64,
	subgroup = "RTZiplineStuff",
	order = "bc",
	stack_size = 1,
	ammo_type =
   {
      category = "ZiplineController"
	},
   ammo_category = "ZiplineController"
},
{ --------- programmable zipline controls recipe ----------
	type = "recipe",
	name = "RTProgrammableZiplineControls",
	enabled = false,
	energy_required = 0.5,
	ingredients =
		{
         {type="item", name="RTZiplineControls", amount=1},
			{type="item", name="advanced-circuit", amount=5}
		},
   results = {
      {type="item", name="RTProgrammableZiplineControls", amount=1}
   }
},

{ ------ zipline over player graphic -----------
	type = "animation",
	name = "RTZiplineOverGFX",
	filename = renaiEntity .. "zipline/ZipOverPlayer.png",
	size = 128, --{128,128},
	frame_count = 2,
	line_length = 2,
	animation_speed = 0.3
},
{
	type = "sprite",
	name = "RTZiplineHarnessGFX",
	filename = renaiEntity .. "zipline/ZipHarness.png",
	size = 70
},
})

local succ = table.deepcopy(data.raw.radar["RTZipline"])
succ.name = "RTZiplinePowerDrain"
succ.icon = renaiIcons .. "zipline_icon1.png"
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
      filename = emptypng,
      priority = "low",
      width = 1,
      height = 1,
      apply_projection = false,
      direction_count = 1,
      line_length = 1
   }
succ.working_sound = nil

data:extend({ succ })


if (settings.startup["RTThrowersSetting"].value == true) then
	data:extend({
		{ --------- zipline recipe ----------
			type = "recipe",
			name = "RTZiplineTrolley",
			enabled = false,
			energy_required = 0.5,
			ingredients =
				{
					{type="item", name="copper-cable", amount=100},
					{type="item", name="iron-gear-wheel", amount=50},
					{type="item", name="electronic-circuit", amount=4},
					{type="item", name="PlayerLauncher", amount=1},
					{type="item", name="steel-chest", amount=1}
				},
         results = {
            {type="item", name="RTZiplineTrolley", amount=1}
         }
		}
	})

else
	data:extend({
		{ --------- zipline recipe ----------
			type = "recipe",
			name = "RTZiplineTrolley",
			enabled = false,
			energy_required = 0.5,
			ingredients =
				{
					{type="item", name="copper-cable", amount=100},
					{type="item", name="iron-gear-wheel", amount=50},
					{type="item", name="electronic-circuit", amount=5},
					{type="item", name="steel-chest", amount=1}
				},
         results = {
            {type="item", name="RTZiplineTrolley", amount=1}
         }
		}
	})
end
--============ trolley 2 ==================
local succ2 = table.deepcopy(data.raw.radar["RTZiplinePowerDrain"])
succ2.name = "RTZiplinePowerDrain2"
succ2.icon = renaiIcons .. "zipline_icon2.png"
succ2.icon_size = 64
succ2.energy_usage = "1MW"
data:extend({ succ2 })
data:extend({
   { --------- zipline item -------------
      type = "gun",
      name = "RTZiplineTrolley2",
      icon = renaiIcons .. "zipline_icon2.png",
      icon_size = 64,
      subgroup = "RTZiplineStuff",
      order = "ab",
      stack_size = 1,
      attack_parameters =
      {
         type = "projectile",
         ammo_category = "ZiplineController",
         cooldown = 60,
         movement_slow_down_factor = 0,
         range = 0
      },
   },
   { --------- zipline recipe ----------
      type = "recipe",
      name = "RTZiplineTrolley2",
      enabled = false,
      energy_required = 0.5,
      ingredients =
         {
            {type="item", name="iron-gear-wheel", amount=100},
            {type="item", name="engine-unit", amount=10},
            {type="item", name="RTZiplineTrolley", amount=1},
         },
         results = {
            {type="item", name="RTZiplineTrolley2", amount=1}
         }
   }
})
--============ trolley 3 ==================
local succ3 = table.deepcopy(data.raw.radar["RTZiplinePowerDrain"])
succ3.name = "RTZiplinePowerDrain3"
succ3.icon = renaiIcons .. "zipline_icon3.png"
succ3icon_size = 64
succ3.energy_usage = "5MW"
data:extend({ succ3 })
data:extend({
   { --------- zipline item -------------
      type = "gun",
      name = "RTZiplineTrolley3",
      icon = renaiIcons .. "zipline_icon3.png",
      icon_size = 64,
      subgroup = "RTZiplineStuff",
      order = "ac",
      stack_size = 1,
      attack_parameters =
      {
         type = "projectile",
         ammo_category = "ZiplineController",
         cooldown = 60,
         movement_slow_down_factor = 0,
         range = 0
      },
   },
   { --------- zipline recipe ----------
      type = "recipe",
      name = "RTZiplineTrolley3",
      enabled = false,
      energy_required = 0.5,
      ingredients =
         {
            {type="item", name="iron-gear-wheel", amount=150},
            {type="item", name="electric-engine-unit", amount=10},
            {type="item", name="advanced-circuit", amount=10},
            {type="item", name="RTZiplineTrolley2", amount=1},
         },
         results = {
            {type="item", name="RTZiplineTrolley3", amount=1}
         }
   }
})
--============ trolley 4 ==================
local succ4 = table.deepcopy(data.raw.radar["RTZiplinePowerDrain"])
succ4.name = "RTZiplinePowerDrain4"
succ4.icon = renaiIcons .. "zipline_icon4.png"
succ4.icon_size = 64
succ4.energy_usage = "10MW"
data:extend({ succ4 })
data:extend({
   { --------- zipline item -------------
      type = "gun",
      name = "RTZiplineTrolley4",
      icon = renaiIcons .. "zipline_icon4.png",
      icon_size = 64,
      subgroup = "RTZiplineStuff",
      order = "ad",
      stack_size = 1,
      attack_parameters =
      {
         type = "projectile",
         ammo_category = "ZiplineController",
         cooldown = 60,
         movement_slow_down_factor = 0,
         range = 0
      },
   },
   { --------- zipline recipe ----------
      type = "recipe",
      name = "RTZiplineTrolley4",
      enabled = false,
      energy_required = 0.5,
      ingredients =
         {
            {type="item", name="iron-gear-wheel", amount=200},
            {type="item", name="rocket-fuel", amount=25},
            {type="item", name="processing-unit", amount=5},
            {type="item", name="RTZiplineTrolley3", amount=1},
         },
         results = {
            {type="item", name="RTZiplineTrolley4", amount=1}
         }
   }
})
--============ trolley 5 ==================
local succ5 = table.deepcopy(data.raw.radar["RTZiplinePowerDrain"])
succ5.name = "RTZiplinePowerDrain5"
succ5.icon = renaiIcons .. "zipline_icon1.png"
succ5.icon_size = 64
succ5.energy_usage = "50MW"
data:extend({ succ5 })
data:extend({
   { --------- zipline item -------------
      type = "gun",
      name = "RTZiplineTrolley5",
      icon = renaiIcons .. "zipline_icon5.png",
      icon_size = 64,
      subgroup = "RTZiplineStuff",
      order = "ae",
      stack_size = 1,
      attack_parameters =
      {
         type = "projectile",
         ammo_category = "ZiplineController",
         cooldown = 60,
         movement_slow_down_factor = 0,
         range = 0
      },
   },
   { --------- zipline recipe ----------
      type = "recipe",
      name = "RTZiplineTrolley5",
      enabled = false,
      energy_required = 0.5,
      ingredients =
         {
            {type="item", name="iron-gear-wheel", amount=300},
            {type="item", name="nuclear-fuel", amount=5},
            {type="item", name="fission-reactor-equipment", amount=1},
            {type="item", name="RTZiplineTrolley4", amount=1},
         },
         results = {
            {type="item", name="RTZiplineTrolley5", amount=1}
         }
   }
})

local RTZiplineTerminal = table.deepcopy(data.raw["electric-pole"]["medium-electric-pole"])
   RTZiplineTerminal.icon = renaiIcons .. "zipline_terminalicon.png"
   RTZiplineTerminal.icon_size = 64
   RTZiplineTerminal.name = "RTZiplineTerminal"
   RTZiplineTerminal.minable = {mining_time = 0.5, result = "RTZiplineTerminal"}
   RTZiplineTerminal.collision_box = {{-0.9, -0.3}, {0.9, 0.9}}
   RTZiplineTerminal.selection_box = {{-1, -0.5}, {1, 1}}
   RTZiplineTerminal.pictures =
   {
      layers =
      {
         {
            filename = renaiEntity .. "zipline/terminal.png",
            priority = "extra-high",
            width = 125,
            height = 250,
            direction_count = 1,
            shift = {0, -1},
            scale = 0.5
         },
         {
            filename = renaiEntity .. "zipline/OwTheEdge.png",
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
   RTZiplineTerminal.next_upgrade = nil

local RTZiplineTerminalItemP = table.deepcopy(data.raw.item["medium-electric-pole"])
   RTZiplineTerminalItemP.name = "RTZiplineTerminal"
   RTZiplineTerminalItemP.icon = renaiIcons .. "zipline_terminalicon.png"
   RTZiplineTerminalItemP.icon_size = 64
   RTZiplineTerminalItemP.place_result = "RTZiplineTerminal"
   RTZiplineTerminalItemP.order = "a[energy]-x[ZiplineTerminal]"
local RTZiplineTerminalRecipeP =
   {
      type = "recipe",
      name = "RTZiplineTerminal",
      enabled = false,
      energy_required = 3,
      ingredients =
         {
            {type="item", name="medium-electric-pole", amount=1},
            {type="item", name="advanced-circuit", amount=10},
            {type="item", name="steel-plate", amount=20},
            {type="item", name="concrete", amount=25}
         },
      results = {
         {type="item", name="RTZiplineTerminal", amount=1}
      }
   }
data:extend({
   RTZiplineTerminal,
   RTZiplineTerminalItemP,
   RTZiplineTerminalRecipeP
})

data:extend({
   { --------- AI zipline controls -------------
      type = "ammo",
      name = "RTAIZiplineControls",
      icon = renaiIcons .. "zipline_AIcontrols.png",
      icon_size = 64,
      subgroup = "RTZiplineStuff",
      order = "bd",
      stack_size = 1,
      ammo_type =
      {
         category = "ZiplineController"
      },
      ammo_category = "ZiplineController"
   },
   
})


data:extend({
   {
		type = "technology",
		name = "RTZiplineTech",
		icon = renaiTechIcons .. "Zipline1.png",
		icon_size = 256,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "RTZiplineTrolley"
			},
			{
				type = "unlock-recipe",
				recipe = "RTZiplineControls"
			}
		},
		prerequisites = {"se-no", "steel-processing"},
		unit =
		{
			count = 100,
			ingredients =
			{
			{"automation-science-pack", 1}
			},
			time = 30
		}
	},
	{
		type = "technology",
		name = "RTZiplineControlTech1",
		icon = renaiTechIcons .. "Zipline_crankcontrols.png",
		icon_size = 256,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "RTZiplineCrankControls"
			}
		},
		prerequisites = {"RTZiplineTech"},
		unit =
		{
			count = 50,
			ingredients =
			{
			{"automation-science-pack", 1}
			},
			time = 30
		}
	},
	{
		type = "technology",
		name = "RTZiplineTech2",
      icon = renaiTechIcons .. "Zipline2.png",
      icon_size = 256,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "RTZiplineTrolley2"
			}
		},
		prerequisites = {"RTZiplineTech", "engine"},
		unit =
		{
			count = 100,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 15
		}
	},
	{
		type = "technology",
		name = "RTZiplineTech3",
      icon = renaiTechIcons .. "Zipline3.png",
      icon_size = 256,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "RTZiplineTrolley3"
			}
		},
		prerequisites = {"RTZiplineTech2", "electric-engine"},
		unit =
		{
			count = 100,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1}
			},
			time = 30
		}
	},
	{
		type = "technology",
		name = "RTZiplineTech4",
      icon = renaiTechIcons .. "Zipline4.png",
      icon_size = 256,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "RTZiplineTrolley4"
			}
		},
		prerequisites = {"RTZiplineTech3", "rocket-fuel", "processing-unit"},
		unit =
		{
			count = 150,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1}
			},
			time = 30
		}
	},
	{
		type = "technology",
		name = "RTZiplineTech5",
      icon = renaiTechIcons .. "Zipline5.png",
      icon_size = 256,
		effects =
		{
			{	
				type = "unlock-recipe",
				recipe = "RTZiplineTrolley5"
			}
		},
		prerequisites = {"RTZiplineTech4", "kovarex-enrichment-process", "fission-reactor-equipment"},
		unit =
		{
			count = 200,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
				},
			time = 30
		}
	},
	{
		type = "technology",
		name = "RTProgrammableZiplineControlTech",
		icon = renaiTechIcons .. "Zipline_terminaltech.png",
		icon_size = 256,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "RTProgrammableZiplineControls"
			},
			{
				type = "unlock-recipe",
				recipe = "RTZiplineTerminal"
			}
		},
		prerequisites = {"RTZiplineTech", "electric-energy-distribution-1", "concrete", "chemical-science-pack"},
		unit =
		{
			count = 200,
			ingredients =
			{
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
			},
			time = 30
		}
	},
})

if (data.raw.item["carbon-fiber"] and data.raw.item["pentapod-egg"] and data.raw.tool["agricultural-science-pack"]) then
	data:extend({
      { --------- AI zipline controls recipe ----------
         type = "recipe",
         name = "RTAIZiplineControls",
         enabled = false,
         energy_required = 1,
         ingredients =
            {
               {type="item", name="RTProgrammableZiplineControls", amount=1},
               {type="item", name="processing-unit", amount=5},
               {type="item", name="carbon-fiber", amount=10},
               {type="item", name="pentapod-egg", amount=1}
            },
         results = {
            {type="item", name="RTAIZiplineControls", amount=1}
         }
      },
		{
         type = "technology",
         name = "RTAIZiplineControlTech",
         icon = renaiTechIcons .. "AIZiplineTech.png",
         icon_size = 256,
         effects =
         {
            {
               type = "unlock-recipe",
               recipe = "RTAIZiplineControls"
            },
         },
         prerequisites = {"RTProgrammableZiplineControlTech", "carbon-fiber", "utility-science-pack"},
         unit =
         {
            count = 500,
            ingredients =
            {
               {"automation-science-pack", 1},
               {"logistic-science-pack", 1},
               {"chemical-science-pack", 1},
               {"utility-science-pack", 1},
               {"space-science-pack", 1},
               {"agricultural-science-pack", 1}
            },
            time = 60
         }
      },
	})
else
	data:extend({
      { --------- AI zipline controls recipe ----------
         type = "recipe",
         name = "RTAIZiplineControls",
         enabled = false,
         energy_required = 1,
         ingredients =
            {
               {type="item", name="RTProgrammableZiplineControls", amount=1},
               {type="item", name="processing-unit", amount=10},
               {type="item", name="raw-fish", amount=5}
            },
         results = {
            {type="item", name="RTAIZiplineControls", amount=1}
         }
      },
		{
         type = "technology",
         name = "RTAIZiplineControlTech",
         icon = renaiTechIcons .. "AIZiplineTech.png",
         icon_size = 256,
         effects =
         {
            {
               type = "unlock-recipe",
               recipe = "RTAIZiplineControls"
            },
         },
         prerequisites = {"RTProgrammableZiplineControlTech", "utility-science-pack"},
         unit =
         {
            count = 500,
            ingredients =
            {
               {"automation-science-pack", 1},
               {"logistic-science-pack", 1},
               {"chemical-science-pack", 1},
               {"utility-science-pack", 1},
            },
            time = 60
         }
      },
	})
end
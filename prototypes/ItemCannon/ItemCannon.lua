local SpaceConditions
if (mods["space-age"]) then
  SpaceConditions = {
    {
      property = "gravity",
      min = 1
    }
  }
end
data:extend({
  { --------- entity
    type = "electric-energy-interface",
    name = "RTItemCannon",
    icon = renaiIcons .. "ItemCannonIcon.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.2, result = "RTItemCannon"},
    max_health = 500,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      buffer_capacity = "5MJ",
      drain = "100kW"
    },
    gui_mode = "none",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    surface_conditions = SpaceConditions,
    pictures =
    {
      sheets = 
      {
        {
          filename = renaiEntity .. "ItemCannon/ItemCannon.png",
          width = 512,
          height = 512,
          direction_count = 4,
          line_length = 4,
          priority = "high",
          scale = 0.5
        },
        {
          filename = renaiEntity .. "ItemCannon/ItemCannonShadows.png",
          width = 512,
          height = 512,
          direction_count = 4,
          line_length = 4,
          priority = "high",
          scale = 0.5,
          draw_as_shadow = true -- will be ignored in this entity type
        }
      }
    }
  },
  { --------- item -------------
    type = "item",
    name = "RTItemCannon",
    icon = renaiIcons .. "ItemCannonIcon.png",
    icon_size = 64,
    subgroup = "RTCannonStuff",
    order = "a",
    place_result = "RTItemCannon",
    stack_size = 5
  },


  { --------- linked container
    type = "container",
    name = "RTItemCannonChest",
    icon = "__base__/graphics/icons/iron-chest.png",
    flags = {"placeable-neutral", "not-on-map", "not-blueprintable", "not-deconstructable", "placeable-off-grid", "hide-alt-info"},
    hidden = true,
    quality_affects_inventory_size = false,
    max_health = 42069,
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    collision_mask = {layers={}},
    inventory_size = 1,
    --inventory_type = "with_filters_and_bar",
  },
  { --------- mask
    type = "simple-entity-with-owner",
    name = "RTItemCannonMask",
    icon = renaiIcons .. "ItemCannonIcon.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map", "not-blueprintable", "not-deconstructable", "placeable-off-grid", "hide-alt-info"},
    hidden = true,
    collision_box = nil,
    collision_mask = {layers={}},
    render_layer = "higher-object-under",
    picture =
    {
      sheet = 
      {
        filename = renaiEntity .. "ItemCannon/ItemCannonMask.png",
        width = 512,
        height = 512,
        direction_count = 4,
        line_length = 4,
        priority = "high",
        scale = 0.5,
        apply_runtime_tint = true
      }
    }
  },


  --[[ { -- base item shell
    type = "item",
    name = "RTItemShellItem",
    icons =
    {
      {icon = "__RenaiTransportation__/graphics/ItemCannon/EmptyItemShell.png"}
    },
    subgroup = "RTCannonStuff",
    order = "ab",
    stack_size = 20
  },
  { --------- recipe ----------
    type = "recipe",
    name = "RTItemShellRecipe",
    enabled = false,
    energy_required = 1,
    ingredients =
      {
        {type="item", name="barrel", amount=1},
        {type="item", name="copper-cable", amount=4},
      },
    results = {
      {type="item", name="RTItemShellItem", amount=1}
    }
  }, ]]


  --[[ {
    type = "recipe-category",
    name = "RTItemShellPacking"
  },
  {
    type = "item-group",
    name = "RTItemShellPacking",
    icons = {
      {icon = "__RenaiTransportation__/graphics/ItemCannon/EmptyItemShell.png"},
      {icon = "__RenaiTransportation__/graphics/ItemCannon/LoadShellGroupIcon.png"}
    },
    order = "cc"
  },
  {
    type = "item-subgroup",
    name = "RTItemShellPacking",
    group = "RTItemShellPacking"
  }, ]]
  { -- the impact effect of a shell hitting the ground
    type = "projectile",
    name = "RTItemShellImpact",
    flags = {"not-on-map"},
    hidden = true,
    acceleration = 0.005,
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-entity",
              entity_name = "small-scorchmark-tintable",
              check_buildability = true
            },
            {
              type = "invoke-tile-trigger",
              repeat_count = 1
            },
            {
              type = "destroy-decoratives",
              from_render_layer = "decorative",
              to_render_layer = "object",
              include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
              include_decals = false,
              invoke_decorative_trigger = true,
              decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
              radius = 2.25 -- large radius for demostrative purposes
            }
          }
        }
      },
      {
        type = "area",
        radius = 1.5,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "damage",
              damage = {amount = 1000, type = "impact"}
            },
          }
        }
      }
    },
  },
  {
    type = "projectile",
    name = "RTItemShell".."LaserPointer".."-Q-".."normal",
    acceleration = 0,
    direction_only = true,
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    --hit_collision_mask = {layers={object=true, player=true, train=true}},
    --hit_at_collision_position = true,
    height = 1,
    animation =
    {
      layers =
      {
        {
          filename = renaiEntity .. "range.png",
          size = 64,
          tint = {1,0,0,0.5},
          frame_count = 1,
          priority = "high",
          scale = 0.1
        },
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "script",
            effect_id = "RTItemShell".."LaserPointer".."-Q-".."normal"
          },
        }
      }
    },
  },
})


if (data.raw.item["holmium-plate"] and data.raw.tool["electromagnetic-science-pack"]) then
  data:extend({
    { --------- recipe ----------
      type = "recipe",
      name = "RTItemCannon",
      enabled = false,
      energy_required = 5,
      ingredients =
        {
          {type="item", name="refined-concrete", amount=100},
          {type="item", name="steel-plate", amount=50},
          {type="item", name="superconductor", amount=10},
          {type="item", name="discharge-defense-equipment", amount=5}
        },
      results = {
        {type="item", name="RTItemCannon", amount=1}
      }
    },
    {
      type = "technology",
      name = "RTItemCannonTech",
      icon = renaiTechIcons .. "ItemCannonTech.png",
      icon_size = 256,
      effects =
      {
        --[[ {
          type = "unlock-recipe",
          recipe = "RTItemShellRecipe"
        }, ]]
        {
          type = "unlock-recipe",
          recipe = "RTItemCannon"
        },
        {
          type = "unlock-recipe",
          recipe = "RTRicochetPanel"
        },
        {
          type = "unlock-recipe",
          recipe = "RTCatchingChute"
        },
      },
      prerequisites = {"se-no", "concrete", "logistics-2", "discharge-defense-equipment", "electromagnetic-science-pack"},
      unit =
      {
        count = 1000,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"space-science-pack", 1},
          {"electromagnetic-science-pack", 1},
        },
        time = 60
      }
    },
    {
      type = "technology",
      name = "RTItemCannonLogisticsTech",
      icon = renaiTechIcons .. "ItemCannonLogisticsTech.png",
      icon_size = 1256,
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "RTDivergingChute"
        },
        {
          type = "unlock-recipe",
          recipe = "RTMergingChute"
        },
      },
      prerequisites = {"RTItemCannonTech"},
      unit =
      {
        count = 500,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"space-science-pack", 1},
          {"electromagnetic-science-pack", 1},
        },
        time = 60
      }
    },
  })
else
  data:extend({
    { --------- recipe ----------
      type = "recipe",
      name = "RTItemCannon",
      enabled = false,
      energy_required = 5,
      ingredients =
        {
          {type="item", name="refined-concrete", amount=100},
          {type="item", name="steel-plate", amount=50},
          {type="item", name="processing-unit", amount=10},
          {type="item", name="discharge-defense-equipment", amount=5}
        },
      results = {
        {type="item", name="RTItemCannon", amount=1}
      }
    },
    {
      type = "technology",
      name = "RTItemCannonTech",
      icon = renaiTechIcons .. "ItemCannonTech.png",
      icon_size = 256,
      effects =
      {
        --[[ {
          type = "unlock-recipe",
          recipe = "RTItemShellRecipe"
        }, ]]
        {
          type = "unlock-recipe",
          recipe = "RTItemCannon"
        },
        {
          type = "unlock-recipe",
          recipe = "RTRicochetPanel"
        },
        {
          type = "unlock-recipe",
          recipe = "RTCatchingChute"
        },
      },
      prerequisites = {"se-no", "concrete", "logistics-2", "discharge-defense-equipment", "production-science-pack"},
      unit =
      {
        count = 1000,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
        },
        time = 60
      }
    },
    {
      type = "technology",
      name = "RTItemCannonLogisticsTech",
      icon = renaiTechIcons .. "ItemCannonLogisticsTech.png",
      icon_size = 256,
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "RTDivergingChute"
        },
        {
          type = "unlock-recipe",
          recipe = "RTMergingChute"
        },
      },
      prerequisites = {"RTItemCannonTech"},
      unit =
      {
        count = 500,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
        },
        time = 60
      }
    },
  })
end
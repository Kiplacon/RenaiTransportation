local vertical =
{
  layers =
  {
    {
      filename = renaiEntity .. "ItemCannon/RicochetPanel_v.png",
      shift = util.by_pixel(0, -16),
      width = 256,
      height = 256,
      priority = "high",
      scale = 0.5
    },
    {
      filename = renaiEntity .. "ItemCannon/RicochetPanel_v_shadow.png",
      shift = util.by_pixel(0, -16),
      width = 256,
      height = 256,
      priority = "high",
      scale = 0.5,
      draw_as_shadow = true,
    },
    {
      filename = renaiEntity .. "ItemCannon/RicochetPanel_v_glow.png",
      shift = util.by_pixel(0, -16),
      width = 256,
      height = 256,
      priority = "high",
      scale = 0.5,
      draw_as_glow = true,
      blend_mode = "additive",
    },
  }
}

local horizontal =
{
  layers =
  {
    {
      filename = renaiEntity .. "ItemCannon/RicochetPanel_h.png",
      shift = util.by_pixel(0, -16),
      width = 256,
      height = 256,
      priority = "high",
      scale = 0.5
    },
    {
      filename = renaiEntity .. "ItemCannon/RicochetPanel_h_shadow.png",
      shift = util.by_pixel(0, -16),
      width = 256,
      height = 256,
      priority = "high",
      scale = 0.5,
      draw_as_shadow = true,
    },
    {
      filename = renaiEntity .. "ItemCannon/RicochetPanel_h_glow.png",
      shift = util.by_pixel(0, -16),
      width = 256,
      height = 256,
      priority = "high",
      scale = 0.5,
      draw_as_glow = true,
      blend_mode = "additive",
    },
  }
}

data.extend({
  { --------- entity
    type = "electric-energy-interface",
    name = "RTRicochetPanel",
    icon = renaiIcons .. "RicochetPanelIcon.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.2, result = "RTRicochetPanel"},
    hidden = true,
    max_health = 250,
    corpse = "steel-chest-remnants",
    dying_explosion = "medium-explosion",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      buffer_capacity = "1MJ",
      drain = "25kW"
    },
    gui_mode = "none",
    collision_box = {{-0.45, -0.2}, {0.45, 0.2}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    resistances = {
      {
        type = "impact",
        percent = 100
      },
      {
        type = "explosion",
        percent = 25
      },
      {
        type = "physical",
        percent = 50
      },
    },
    pictures = {
      north = horizontal,
      east = vertical,
      south = horizontal,
      west = vertical,
    }
  },
  { --------- item -------------
    type = "item",
    name = "RTRicochetPanel",
    icon = renaiIcons .. "RicochetPanelIcon.png",
    icon_size = 64,
    subgroup = "RTCannonStuff",
    order = "c",
    place_result = "RTRicochetPanel",
    stack_size = 50
  },
  {
    type = "animation",
    name = "RTRicochetPanelZap",
    filename = "__base__/graphics/entity/accumulator/accumulator-charge.png",
    size = {178, 210},
    scale = 0.5,
    frame_count = 24,
    line_length = 6
  }
})

if (data.raw.item["supercapacitor"] and data.raw.tool["electromagnetic-science-pack"]) then
  data:extend({
    { --------- recipe ----------
    type = "recipe",
    name = "RTRicochetPanel",
    enabled = false,
    energy_required = 2,
    ingredients =
      {
        {type="item", name="steel-plate", amount=20},
        {type="item", name="supercapacitor", amount=1},
        {type="item", name="processing-unit", amount=2},
        {type="item", name="copper-cable", amount=12}
      },
    results = {
      {type="item", name="RTRicochetPanel", amount=1}
    }
  },
  })
else
  data:extend({
    { --------- recipe ----------
    type = "recipe",
    name = "RTRicochetPanel",
    enabled = false,
    energy_required = 2,
    ingredients =
      {
        {type="item", name="steel-plate", amount=20},
        {type="item", name="accumulator", amount=1},
        {type="item", name="processing-unit", amount=2},
        {type="item", name="copper-cable", amount=8}
      },
    results = {
      {type="item", name="RTRicochetPanel", amount=1}
    }
  },
  })
end
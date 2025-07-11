local sounds = {}
for i = 1, 14 do
    table.insert(sounds, {filename = "__RenaiTransportation__/sickw0bs/impact"..i..".ogg", volume = 0.5})
end

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
            sheet = {
                filename = renaiEntity .. "ItemCannon/RicochetPanel.png",
                shift = {0, -0.6},
                width = 66,
                height = 128,
                priority = "high",
                scale = 0.5
            }
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
        type = "sound",
        name = "RTRicochetPanelSound",
        variations=sounds,
        aggregation =
		{
			max_count = 4,
			remove = true,
			count_already_playing = true
		}
    },
    {
        type = "sound",
        name = "RTRicochetPanelSpark",
        variations={
            {filename = "__RenaiTransportation__/sickw0bs/zap1.ogg"},
            {filename = "__RenaiTransportation__/sickw0bs/zap2.ogg"},
            {filename = "__RenaiTransportation__/sickw0bs/zap3.ogg"},
        },
        aggregation =
		{
			max_count = 2,
			remove = true,
			count_already_playing = true
		}
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
local sounds = {}
for i = 1, 14 do
    table.insert(sounds, {filename = "__RenaiTransportation__/sickw0bs/impact"..i..".ogg", volume = 0.5})
end

data.extend({
    { --------- entity
        type = "electric-energy-interface",
        name = "RTRicochetPanel",
        icon = "__RenaiTransportation__/graphics/ItemCannon/RicochetPanelIcon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.2, result = "RTRicochetPanelItem"},
        hidden = true,
        max_health = 250,
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
                filename = "__RenaiTransportation__/graphics/ItemCannon/RicochetPanel.png",
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
        name = "RTRicochetPanelItem",
        icon = "__RenaiTransportation__/graphics/ItemCannon/RicochetPanelIcon.png",
        icon_size = 128,
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
    }
})

if (data.raw.item["supercapacitor"] and data.raw.tool["electromagnetic-science-pack"]) then
    data:extend({
        { --------- recipe ----------
        type = "recipe",
        name = "RTRicochetPanelRecipe",
        enabled = false,
        energy_required = 1,
        ingredients =
            {
                {type="item", name="steel-plate", amount=10},
                {type="item", name="supercapacitor", amount=1},
                {type="item", name="processing-unit", amount=2}
            },
        results = {
            {type="item", name="RTRicochetPanelItem", amount=1}
        }
    },
    })
else
    data:extend({
        { --------- recipe ----------
        type = "recipe",
        name = "RTRicochetPanelRecipe",
        enabled = false,
        energy_required = 1,
        ingredients =
            {
                {type="item", name="steel-plate", amount=10},
                {type="item", name="accumulator", amount=1},
                {type="item", name="advanced-circuit", amount=2}
            },
        results = {
            {type="item", name="RTRicochetPanelItem", amount=1}
        }
    },
    })
end
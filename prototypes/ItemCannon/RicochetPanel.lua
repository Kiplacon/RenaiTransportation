local sounds = {}
for i = 1, 14 do
    table.insert(sounds, {filename = "__RenaiTransportation__/sickw0bs/impact"..i..".ogg", volume = 0.5})
end

data.extend({
    { --------- entity
        type = "simple-entity-with-owner",
        name = "RTRicochetPanel",
        icon = "__RenaiTransportation__/graphics/ItemCannon/RicochetPanelIcon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.2, result = "RTRicochetPanelItem"},
        hidden = true,
        max_health = 420,
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
        picture = {
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
    { --------- recipe ----------
        type = "recipe",
        name = "RTRicochetPanelRecipe",
        enabled = true,
        energy_required = 1,
        ingredients =
            {
                {type="item", name="HatchRTItem", amount=1},
                {type="item", name="pump", amount=1},
                {type="item", name="electronic-circuit", amount=2}
            },
        results = {
            {type="item", name="RTRicochetPanelItem", amount=1}
        }
    },
    { --------- item -------------
        type = "item",
        name = "RTRicochetPanelItem",
        icon = "__RenaiTransportation__/graphics/ItemCannon/RicochetPanelIcon.png",
        icon_size = 128,
        subgroup = "RT",
        order = "f-c",
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
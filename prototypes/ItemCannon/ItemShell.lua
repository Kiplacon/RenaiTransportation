local sounds = {}
for i = 1, 14 do
    table.insert(sounds, {filename = "__RenaiTransportation__/sickw0bs/impact"..i..".ogg", volume = 0.5})
end

data.extend({
    {
        type = "projectile",
        name = "RTItemShellwood",
        acceleration = 0,
        direction_only = true,
        collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
        --hit_collision_mask = {layers={object=true, player=true, train=true}},
        piercing_damage = 9999999999,
        --hit_at_collision_position = true,
        height = 0.5,
        animation =
        {
            filename = "__RenaiTransportation__/graphics/Untitled.png",
            size = 32,
            frame_count = 1,
            priority = "high"
        },
        shadow =
        {
            filename = "__RenaiTransportation__/graphics/Untitled.png",
            size = 32,
            frame_count = 1,
            priority = "high",
            draw_as_shadow = true
        },
        action =
        {
            type = "direct",
            action_delivery =
            {
                type = "instant",
                target_effects =
                {
                    {
                        type = "damage",
                        damage = { amount = 9999999999, type = "impact" }
                    }
                }
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
                        effect_id = "ItemShellTest"
                    },
                }
            }
        },
        smoke =
        {
            {
                name = "smoke-fast",
                frequency = 1,
            }
        },
    },
    { --------- entity
        type = "simple-entity-with-owner",
        name = "RTReinforcedRicochetPanel",
        icon = "__RenaiTransportation__/graphics/ItemCannon/RicochetPanelIcon.png",
        icon_size = 128,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.2, result = "RTReinforcedRicochetPanelItem"},
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
        name = "RTReinforcedRicochetPanelRecipe",
        enabled = true,
        energy_required = 1,
        ingredients =
            {
                {type="item", name="HatchRTItem", amount=1},
                {type="item", name="pump", amount=1},
                {type="item", name="electronic-circuit", amount=2}
            },
        results = {
            {type="item", name="RTReinforcedRicochetPanelItem", amount=1}
        }
    },
    { --------- item -------------
        type = "item",
        name = "RTReinforcedRicochetPanelItem",
        icon = "__RenaiTransportation__/graphics/ItemCannon/RicochetPanelIcon.png",
        icon_size = 128,
        subgroup = "RT",
        order = "f-c",
        place_result = "RTReinforcedRicochetPanel",
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
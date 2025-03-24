data:extend({
    { --------- entity
        type = "electric-energy-interface",
        name = "RTItemCannon",
        icon = "__RenaiTransportation__/graphics/ItemCannon/ItemCannonIcon.png",
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.2, result = "RTItemCannonItem"},
        max_health = 420,
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
        surface_conditions  = {
            {
                property = "gravity",
                min = 1
            }
        },
        pictures =
        {
            sheet =
            {
                filename = "__RenaiTransportation__/graphics/ItemCannon/ItemCannon.png",
                --shift = {0, -0.6},
                width = 64*3,
                height = 64*3,
                priority = "high",
                scale = 0.5
            }
        }
    },
    { --------- recipe ----------
        type = "recipe",
        name = "RTItemCannonRecipe",
        enabled = false,
        energy_required = 1,
        ingredients =
            {
                {type="item", name="HatchRTItem", amount=1},
                {type="item", name="pump", amount=1},
                {type="item", name="electronic-circuit", amount=2}
            },
        results = {
            {type="item", name="RTItemCannonItem", amount=1}
        }
    },
    { --------- item -------------
        type = "item",
        name = "RTItemCannonItem",
        icon = "__RenaiTransportation__/graphics/ItemCannon/ItemCannonIcon.png",
        subgroup = "RT",
        order = "f-c",
        place_result = "RTItemCannon",
        stack_size = 50
    },


    { --------- entity
        type = "container",
        name = "RTItemCannonChest",
        icon = "__base__/graphics/icons/iron-chest.png",
        flags = {"placeable-neutral", "not-on-map", "not-blueprintable", "not-deconstructable", "placeable-off-grid", "hide-alt-info"},
        hidden = true,
        max_health = 42069,
        collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
        collision_mask = {layers={}},
        inventory_size = 1,
        inventory_type = "normal",
    },



    { -- base item shell
		type = "item",
		name = "RTItemShellItem",
		icons =
		{
			{icon = "__RenaiTransportation__/graphics/ItemCannon/EmptyItemShell.png"}
		},
		subgroup = "RT",
		order = "f-b",
		stack_size = 1
	},
    { --------- recipe ----------
        type = "recipe",
        name = "RTItemShellRecipe",
        enabled = false,
        energy_required = 1,
        ingredients =
            {
                {type="item", name="steel-plate", amount=10},
            },
        results = {
            {type="item", name="RTItemShellItem", amount=1}
        }
    },


    {
        type = "recipe-category",
        name = "RTItemShellPacking"
    },
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
                    filename = "__RenaiTransportation__/graphics/TrainRamp/range.png",
                    size = 64,
                    tint = {1,0,0,0.5},
                    frame_count = 1,
                    priority = "high",
                    scale = 0.25
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

    {
        type = "technology",
        name = "RTItemCannonTech",
        icon = "__RenaiTransportation__/graphics/tech/ItemCannonTech.png",
        icon_size = 128,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "RTItemShellRecipe"
            },
            {
                type = "unlock-recipe",
                recipe = "RTItemCannonRecipe"
            },
        },
        prerequisites = {"se-no", "electromagnetic-science-pack"},
        unit =
        {
            count = 50,
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
        name = "RTItemCannonLogisticsTech",
        icon = "__RenaiTransportation__/graphics/tech/ItemCannonLogisticsTech.png",
        icon_size = 128,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "RTRicochetPanelRecipe"
            },
            {
                type = "unlock-recipe",
                recipe = "RTCatchingChuteRecipe"
            },
            {
                type = "unlock-recipe",
                recipe = "RTDivergingChuteRecipe"
            },
            {
                type = "unlock-recipe",
                recipe = "RTMergingChuteRecipe"
            },
        },
        prerequisites = {"RTItemCannonTech"},
        unit =
        {
            count = 50,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            },
            time = 15
        }
    },
})
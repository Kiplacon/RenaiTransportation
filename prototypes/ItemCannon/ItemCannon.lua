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
        gui_mode = "all",
        collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        resistances = {
            {
                type = "impact",
                percent = 80
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
        enabled = true,
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
})
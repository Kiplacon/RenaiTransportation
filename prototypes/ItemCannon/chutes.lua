data.extend({
    { --------- entity
        type = "container",
        name = "RTCatchingChute",
        icon = renaiIcons .. "CatchingChuteIcon.png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = "RTCatchingChute"},
        max_health = 250,
        corpse = "small-remnants",
        dying_explosion = "iron-chest-explosion",
        circuit_wire_max_distance = 9,
        inventory_size = 48,
        collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
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
            layers = {
            {
                filename = renaiEntity .. "ItemCannon/CatchingChute.png",
                shift = {0, -0.72},
                size = 260,
                priority = "high",
                scale = 0.3
            },
            {
                filename = renaiEntity .. "ItemCannon/CatchingChuteShadow.png",
                shift = {0, -0.72},
                size = 512,
                draw_as_shadow = true,
                priority = "high",
                scale = 0.3
            },
        }
        }
    },
    { --------- item -------------
        type = "item",
        name = "RTCatchingChute",
        icon = renaiIcons .. "CatchingChuteIcon.png",
        icon_size = 64,
        subgroup = "RTCannonStuff",
        order = "d",
        place_result = "RTCatchingChute",
        stack_size = 50
    },


    { --------- entity
        type = "electric-energy-interface",
        name = "RTDivergingChute",
        icon = renaiIcons .. "DivergingChuteIcon.png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = "RTDivergingChute"},
        max_health = 250,
        corpse = "small-remnants",
        dying_explosion = "iron-chest-explosion",
        energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			buffer_capacity = "1MJ",
            drain = "15kW"
		},
        gui_mode = "none",
        collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
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
            sheets = {
                {
                    filename = renaiEntity .. "ItemCannon/DivergingChute.png",
                    shift = {0, -0.72},
                    size = 260,
                    priority = "high",
                    scale = 0.3
                },
                {
                    filename = renaiEntity .. "ItemCannon/DivergingChuteShadow.png",
                    shift = {0, -0.72},
                    size = 512,
                    draw_as_shadow = true,
                    priority = "high",
                    scale = 0.3
                },
            }
        }
    },
    { --------- item -------------
        type = "item",
        name = "RTDivergingChute",
        icon = renaiIcons .. "DivergingChuteIcon.png",
        icon_size = 64,
        subgroup = "RTCannonStuff",
        order = "db",
        place_result = "RTDivergingChute",
        stack_size = 50
    },


    { --------- entity
        type = "electric-energy-interface",
        name = "RTMergingChute",
        icon = renaiIcons .. "MergingChuteIcon.png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = "RTMergingChute"},
        max_health = 250,
        corpse = "small-remnants",
        dying_explosion = "iron-chest-explosion",
        energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			buffer_capacity = "1MJ",
            drain = "15kW"
		},
        gui_mode = "none",
        collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
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
            sheets = {
                {
                    filename = renaiEntity .. "ItemCannon/MergingChute.png",
                    shift = {0, -0.72},
                    size = 260,
                    priority = "high",
                    scale = 0.3
                },
                {
                    filename = renaiEntity .. "ItemCannon/MergingChuteShadow.png",
                    shift = {0, -0.72},
                    size = 512,
                    draw_as_shadow = true,
                    priority = "high",
                    scale = 0.3
                },
            }
        }
    },

    { --------- item -------------
        type = "item",
        name = "RTMergingChute",
        icon = renaiIcons .. "MergingChuteIcon.png",
        icon_size = 64,
        subgroup = "RTCannonStuff",
        order = "da",
        place_result = "RTMergingChute",
        stack_size = 50
    },

    {
        type = "sound",
        name = "RTHitWrongAngle",
        variations=
        {
            {
                filename = "__RenaiTransportation__/sickw0bs/HitWrongAngle1.ogg",
                volume = 0.75,
            },
            {
                filename = "__RenaiTransportation__/sickw0bs/HitWrongAngle2.ogg",
                volume = 0.75,
            },
        },
        aggregation =
		{
			max_count = 2,
			remove = true,
			count_already_playing = true
		}
    }
})

data:extend({
    { --------- recipe ----------
        type = "recipe",
        name = "RTMergingChute",
        enabled = false,
        energy_required = 2,
        ingredients =
            {
                {type="item", name="RTCatchingChute", amount=1},
                {type="item", name="RTRicochetPanel", amount=2},
                {type="item", name="HatchRT", amount=2},
                {type="item", name="RTThrower-EjectorHatchRT", amount=1},
            },
        results = {
            {type="item", name="RTMergingChute", amount=1}
        }
    },
    { --------- recipe ----------
        type = "recipe",
        name = "RTDivergingChute",
        enabled = false,
        energy_required = 2,
        ingredients =
            {
                {type="item", name="RTCatchingChute", amount=1},
                {type="item", name="RTRicochetPanel", amount=2},
                {type="item", name="HatchRT", amount=1},
                {type="item", name="RTThrower-EjectorHatchRT", amount=2},
            },
        results = {
            {type="item", name="RTDivergingChute", amount=1}
        }
    },
})

if (data.raw.item["holmium-plate"]) then
    data:extend({
        { --------- recipe ----------
            type = "recipe",
            name = "RTCatchingChute",
            enabled = false,
            energy_required = 1,
            ingredients =
                {
                    {type="item", name="holmium-plate", amount=5},
                    {type="item", name="concrete", amount=10},
                    {type="item", name="steel-plate", amount=20},
                },
            results = {
                {type="item", name="RTCatchingChute", amount=1}
            }
        },
    })
else
    data:extend({
        { --------- recipe ----------
            type = "recipe",
            name = "RTCatchingChute",
            enabled = false,
            energy_required = 1,
            ingredients =
                {
                    {type="item", name="iron-chest", amount=1},
                    {type="item", name="concrete", amount=20},
                    {type="item", name="steel-plate", amount=20},
                },
            results = {
                {type="item", name="RTCatchingChute", amount=1}
            }
        },
    })
end
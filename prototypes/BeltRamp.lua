local tiers = {
    {name="", tint={255,208,0}, speed=32, order="a"},
    {name="fast", tint={1,0,0}, speed=64, order="b"},
    {name="express", tint={0,0.75,1}, speed=96, order="c"},
}


for _, tier in pairs(tiers) do
    local TierName = tier.name
    local BaseBelt = tier.name
    if (tier.name ~= "") then
        BaseBelt = tier.name.."-"
    end
    local TierTint = tier.tint
    local TierSpeed = tier.speed
    data:extend({
        { --------- Bounce plate entity --------------
            type = "transport-belt",
            name = "RT"..TierName.."BeltRamp",
            icons =
            {
                {
                    icon = "__RenaiTransportation__/graphics/BeltRamp/BeltRampIconBase.png",
                    icon_size = 150,
                },
                {
                    icon = "__RenaiTransportation__/graphics/BeltRamp/BeltRampIconArrows.png",
                    icon_size = 150,
                },
            },
            flags = {"placeable-neutral", "player-creation"},
            minable = {mining_time = 0.5, result = "RT"..TierName.."BeltRampItem"},
            max_health = 200,
            collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
            collision_mask = {layers={["item"]=true, ["object"]=true, ["water_tile"]=true}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            fast_replaceable_group = "BeltRamps",
            speed = 0.03125,
            animation_speed_coefficient = TierSpeed,
            belt_animation_set =
            {
                animation_set =
                {
                    layers =
                    {
                        {
                            filename = "__RenaiTransportation__/graphics/BeltRamp/BeltRampBase.png",
                            priority = "extra-high",
                            size = 256,
                            frame_count = 16,
                            direction_count = 5,
                            scale = 0.39,
                        },
                        {
                            filename = "__RenaiTransportation__/graphics/BeltRamp/BeltRampArrows.png",
                            tint = TierTint,
                            priority = "extra-high",
                            size = 256,
                            frame_count = 16,
                            direction_count = 5,
                            scale = 0.39,
                        },
                    }
                },
                ending_north_index = 5,
                ending_east_index = 5,
                ending_south_index = 5,
                ending_west_index = 5,
                starting_north_index = 5,
                starting_east_index = 5,
                starting_south_index = 5,
                starting_west_index = 5,
                east_to_north_index = 3,
                north_to_east_index = 1,
                west_to_north_index = 3,
                north_to_west_index = 2,
                south_to_east_index = 1,
                east_to_south_index = 4,
                south_to_west_index = 2,
                west_to_south_index = 4,
            },
        },
        { --------- The Bounce plate item -------------
            type = "item",
            name = "RT"..TierName.."BeltRampItem",
            icons =
            {
                {
                    icon = "__RenaiTransportation__/graphics/BeltRamp/BeltRampIconBase.png",
                    icon_size = 150,
                },
                {
                    icon = "__RenaiTransportation__/graphics/BeltRamp/BeltRampIconArrows.png",
                    tint = TierTint,
                    icon_size = 150,
                },
            },
            subgroup = "belt",
            order = "e-"..tier.order,
            place_result = "RT"..TierName.."BeltRamp",
            stack_size = 50
        },
        {
            type = "recipe",
            name = "RT"..TierName.."BeltRampRecipe",
            enabled = true,
            energy_required = 1,
            ingredients =
                {
                    {type="item", name=BaseBelt.."transport-belt", amount=2},
                    {type="item", name="electric-engine-unit", amount=1},
                    {type="item", name="iron-gear-wheel", amount=2},
                },
            results = {
                {type="item", name="RT"..TierName.."BeltRampItem", amount=1}
            }
        },
    })
end

--for orient, stuff in pairs({[0]="up", [0.75]="left", [0.5]="down", [0.25]="right"}) do
    data:extend({
        {
            type = "land-mine",
            name = "RTBeltRampPlayerTrigger",
            flags = {"not-on-map", "placeable-off-grid", "not-selectable-in-game", "no-copy-paste", "not-blueprintable", "not-deconstructable"},
            trigger_collision_mask = {layers={["player"]=true}},
            trigger_radius = 0.5,
            timeout = 0,
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    source_effects = {
                        type = "script",
                        effect_id = "BeltRampPlayer"
                    }
                }
            },
            force_die_on_attack = false,
            picture_set = {
                filename = '__RenaiTransportation__/graphics/Untitled.png',
                width = 32,
                height = 32,
            }
        }
    })

--end

if (data.raw["transport-belt"]["turbo-transport-belt"]) then -- space age belt tier
    data:extend({
        { --------- Bounce plate entity --------------
            type = "transport-belt",
            name = "RTturboBeltRamp",
            icons =
            {
                {
                    icon = "__RenaiTransportation__/graphics/BeltRamp/BeltRampIconBase.png",
                    icon_size = 150,
                },
                {
                    icon = "__RenaiTransportation__/graphics/BeltRamp/BeltRampIconArrows.png",
                    icon_size = 150,
                },
            },
            flags = {"placeable-neutral", "player-creation"},
            minable = {mining_time = 0.5, result = "RTturboBeltRampItem"},
            max_health = 200,
            collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
            collision_mask = {layers={["item"]=true, ["object"]=true, ["water_tile"]=true}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            speed = 0.125,
            animation_speed_coefficient = 32,
            belt_animation_set =
            {
                animation_set =
                {
                    filename = "__RenaiTransportation__/graphics/BeltRamp/GreenBeltRamp6.png",
                    priority = "extra-high",
                    size = 128,
                    frame_count = 64,
                    direction_count = 5,
                    scale = 0.78,
                },
                ending_north_index = 5,
                ending_east_index = 5,
                ending_south_index = 5,
                ending_west_index = 5,
                starting_north_index = 5,
                starting_east_index = 5,
                starting_south_index = 5,
                starting_west_index = 5,
                east_to_north_index = 3,
                north_to_east_index = 1,
                west_to_north_index = 3,
                north_to_west_index = 2,
                south_to_east_index = 1,
                east_to_south_index = 4,
                south_to_west_index = 2,
                west_to_south_index = 4,
            },
        },
        { --------- The Bounce plate item -------------
            type = "item",
            name = "RTturboBeltRampItem",
            icons =
            {
                {
                    icon = "__RenaiTransportation__/graphics/BeltRamp/BeltRampIconBase.png",
                    icon_size = 150,
                },
                {
                    icon = "__RenaiTransportation__/graphics/BeltRamp/BeltRampIconArrows.png",
                    tint = {12,255,0},
                    icon_size = 150,
                },
            },
            subgroup = "belt",
            order = "e-d",
            place_result = "RTturboBeltRamp",
            stack_size = 50
        },
        {
            type = "recipe",
            name = "RTturboBeltRampRecipe",
            enabled = true,
            energy_required = 1,
            ingredients =
                {
                    {type="item", name="turbo-transport-belt", amount=2},
                    {type="item", name="electric-engine-unit", amount=1},
                    {type="item", name="iron-gear-wheel", amount=2},
                },
            results = {
                {type="item", name="RTturboBeltRampItem", amount=1}
            }
        },
    })
end
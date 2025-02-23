data:extend({
{ --------- Bounce plate entity --------------
    type = "transport-belt",
    name = "RTBeltRamp",
    icon = "__RenaiTransportation__/graphics/BeltRamp/BeltRampIcon.png",
    icon_size = 90,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.2, result = "RTBeltRampItem"},
    max_health = 200,
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    collision_mask = {layers={["item"]=true, ["object"]=true, ["player"]=true, ["water_tile"]=true}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    speed = 0.03125,
    animation_speed_coefficient = 32,
    belt_animation_set =
    {
        animation_set =
        {
            layers =
            {
                {
                    filename = "__RenaiTransportation__/graphics/BeltRamp/BeltRampBase.png",
                    priority = "extra-high",
                    size = 128,
                    frame_count = 17,
                    direction_count = 5,
                    scale = 0.5,
                    animation_speed = 1,
                },
                {
                    filename = "__RenaiTransportation__/graphics/BeltRamp/BeltRampArrows.png",
                    --tint = {1, 0, 0},
                    priority = "extra-high",
                    size = 128,
                    frame_count = 17,
                    direction_count = 5,
                    scale = 0.5,
                    animation_speed = 1,
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
    name = "RTBeltRampItem",
    icon = "__RenaiTransportation__/graphics/BeltRamp/BeltRampIcon.png",
    icon_size = 90,
    subgroup = "throwers",
    order = "z-a",
    place_result = "RTBeltRamp",
    stack_size = 50
},
{
    type = "recipe",
    name = "RTBeltRampRecipe",
    enabled = false,
    energy_required = 1,
    ingredients =
        {
            {type="item", name="transport-belt", amount=2},
            {type="item", name="engine-unit", amount=1},
            {type="item", name="iron-gear-wheel", amount=2},
        },
    results = {
        {type="item", name="RTBeltRampItem", amount=1}
    }
},
})

data:extend({ 

{ --------- ramp entity -------------
	type = "rail-signal",
	name = "RTTrainRamp",
	icon = "__RenaiTransportation__/graphics/TrainRamp/icon.png",
	icon_size = 64,
	flags = {"placeable-neutral", "player-creation", "filter-directions", "fast-replaceable-no-build-while-moving"},
    minable = {mining_time = 0.5, result = "RTTrainRampItem"},
    max_health = 500,
	render_layer = "higher-object-under",
    --corpse = "rail-signal-remnants",
    --dying_explosion = "rail-signal-explosion",
    collision_box = {{-0.01, -1.6}, {1.6, 1.6}},
    selection_box = {{-0.01, -2}, {2, 2}},
	collision_mask = {"train-layer"},
	selection_priority = 100,
    --damaged_trigger_effect = hit_effects.entity(),
    animation =
    {
      filename = "__RenaiTransportation__/graphics/TrainRamp/lol3.png",
      priority = "high",
      width = 200,
      height = 200,
      frame_count = 1,
      direction_count = 4
    },
},

{ --------- ramp item -------------
	type = "item",
	name = "RTTrainRampItem",
	icon = "__RenaiTransportation__/graphics/TrainRamp/icon.png",
	icon_size = 64,
	subgroup = "RT",
	order = "g",
	place_result = "RTTrainRamp",
	stack_size = 10
},

{ --------- ramp recipie ----------
	type = "recipe",
	name = "RTTrainRampRecipe",
	enabled = false,
	energy_required = 2,
	ingredients = 
		{
			{"rail", 4},
			{"steel-plate", 30},
			{"concrete", 50}
		},
	result = "RTTrainRampItem"
}

})
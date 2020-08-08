local MLG = table.deepcopy(data.raw.car["car"])
MLG.name = "RTPropCar"
MLG.collision_mask = {}
MLG.energy_source ={type = "void"}
MLG.working_sound = 
    {
      sound =
      {
        filename = "__base__/sound/train-engine.ogg",
        volume = 0.35
      },
      match_volume_to_activity = true
    }
MLG.friction = 1e-99
MLG.light.intensity = 0
MLG.light.size = 0
MLG.turret_animation = nil
MLG.animation = 
	{
	filename = "__RenaiTransportation__/graphics/nothing.png",
	size = 32,
	direction_count = 1
	}

data:extend({ 

MLG,

{ --------- prop item -------------
	type = "item",
	name = "RTPropCarItem",
	icon = "__RenaiTransportation__/graphics/Untitled.png",
	icon_size = 32,
	subgroup = "RT",
	order = "c",
	place_result = "RTPropCar",
	stack_size = 50
},

{ --------- prop recipie ----------
	type = "recipe",
	name = "RTPropCar",
	enabled = false,
	energy_required = 0.5,
	ingredients = 
		{
			{"iron-plate", 999}
		},
	result = "RTPropCarItem"
}

})
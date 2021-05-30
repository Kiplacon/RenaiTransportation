local MLG = table.deepcopy(data.raw.car["car"])
MLG.name = "RTPropCar"
MLG.collision_mask = {}
MLG.selectable_in_game = false
MLG.corpse = nil
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
MLG.light_animation = MLG.animation
MLG.water_reflection = nil
MLG.has_belt_immunity = true
MLG.turret_rotation_speed = 0.00000000000001
MLG.track_particle_triggers = nil
--MLG.allow_passengers = false   -- cant have this because otherwise players are ejected when a train jumps

data:extend({ 

MLG,
{
    type = "car",
    name = "RTPropCart",
	collision_mask = {},
	selectable_in_game = false,
	corpse = nil,
	weight = 1,
	braking_power = "1J",
	energy_per_hit_point = 99999,
	effectivity = 69,
	inventory_size = 0,
	consumption = "1J",
	rotation_speed = 0,
	has_belt_immunity = true,
	energy_source ={type = "void"},
	working_sound = 
		{
		  sound =
		  {
			filename = "__base__/sound/train-engine.ogg",
			volume = 0.35
		  },
		  match_volume_to_activity = true
		},
	friction = 1e-98,

	animation = 
		{
		filename = "__RenaiTransportation__/graphics/nothing.png",
		size = 32,
		direction_count = 1
		}
},
{ --------- prop item -------------
	type = "item",
	name = "RTPropCarItem",
	icon = "__RenaiTransportation__/graphics/Untitled.png",
	icon_size = 32,
	flags = {"hidden"},
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

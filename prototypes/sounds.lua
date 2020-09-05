data:extend({

{
	type = "sound",
	name = "bounce",
	audible_distance_modifier = 0.5,
	variations=
		{
			{
			filename = "__RenaiTransportation__/sickw0bs/a.ogg"
			},
			{
			filename = "__RenaiTransportation__/sickw0bs/b.ogg",
			volume = 0.7
			}
		},
	aggregation =
		{
			max_count = 4,
			remove = true,
			count_already_playing = true
		}
},

{
	type = "sound",
	name = "PrimeClick",
	filename = "__RenaiTransportation__/sickw0bs/click.ogg",
	audible_distance_modifier = 0.5,
	volume = 0.75,
	aggregation =
		{
			max_count = 3,
			remove = true,
			count_already_playing = true
		}
},

{
	type = "sound",
	name = "RTZipAttach",
	filename = "__base__/sound/power-switch-activate-2.ogg",
	audible_distance_modifier = 0.5,
	volume = 0.75
},
{
	type = "sound",
	name = "RTZipDettach",
	filename = "__base__/sound/power-switch-activate-3.ogg",
	audible_distance_modifier = 0.5,
	volume = 0.75
},
{
	type = "sound",
	name = "RTZipWindDown",
	filename = "__base__/sound/car-engine-stop.ogg",
	audible_distance_modifier = 0.5,
	volume = 0.75
}
})
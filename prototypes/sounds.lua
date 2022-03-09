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
	name = "RTThrow",
	audible_distance_modifier = 0.5,
	variations=
		{
			{
			filename = "__RenaiTransportation__/sickw0bs/throw1.ogg"
			},
			{
			filename = "__RenaiTransportation__/sickw0bs/throw2.ogg"
			},
			{
			filename = "__RenaiTransportation__/sickw0bs/throw3.ogg"
			},
			{
			filename = "__RenaiTransportation__/sickw0bs/throw4.ogg"
			},
			{
			filename = "__RenaiTransportation__/sickw0bs/throw5.ogg"
			},
		}
},

{
	type = "sound",
	name = "RTClunk",
	audible_distance_modifier = 0.4,
	allow_random_repeat = true,
	variations=
		{
			{
			filename = "__RenaiTransportation__/sickw0bs/clunk1.ogg",
			volume = 0.5,
			},
			{
			filename = "__RenaiTransportation__/sickw0bs/clunk2.ogg",
			volume = 0.5,
			},
			{
			filename = "__RenaiTransportation__/sickw0bs/clunk3.ogg",
			volume = 0.5,
			},
			{
			filename = "__RenaiTransportation__/sickw0bs/clunk4.ogg",
			volume = 0.5,
			},
			{
			filename = "__RenaiTransportation__/sickw0bs/clunk5.ogg",
			volume = 0.5,
			}
		}
},

{
	type = "sound",
	name = "RTEjector",
	filename = "__RenaiTransportation__/sickw0bs/cannon.ogg",
	audible_distance_modifier = 0.65,
	volume = 1
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

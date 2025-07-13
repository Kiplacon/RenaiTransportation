data:extend({

{
	type = "sound",
	name = "bounce",
	audible_distance_modifier = 0.5,
	variations=
	{
		{
			filename = renaiSounds .. "a.ogg"
		},
		{
			filename = renaiSounds .. "b.ogg",
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
	variations = sound_variations(renaiSounds .. "throw", 5, 1),
},

{
	type = "sound",
	name = "RTClunk",
	audible_distance_modifier = 0.3,
	allow_random_repeat = true,
	variations = sound_variations(renaiSounds .. "clunk", 5, 0.4),
	aggregation =
	{
		max_count = 4,
		remove = true,
		count_already_playing = true
	}
},
{
	type = "sound",
	name = "RTEjector",
	filename = renaiSounds .. "cannon.ogg",
	audible_distance_modifier = 0.65,
	volume = 1
},
{
	type = "sound",
	name = "PrimeClick",
	filename = renaiSounds .. "click.ogg",
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
},
{
	type = "sound",
	name = "RTZipBrake",
	filename = renaiSounds .. "brake.ogg",
	audible_distance_modifier = 0.5,
},
{
	type = "sound",
	name = "RTThrower-EjectorHatchRT-sound",
	variations = sound_variations(renaiSounds .. "pop", 15, 0.8, {volume_multiplier("main-menu", 2), volume_multiplier("tips-and-tricks", 1.8)}),
	audible_distance_modifier = 0.8
},
{
	type = "sound",
	name = "RTTrapdoorOpenSound",
	filename = renaiSounds .. "TrapdoorOpen.ogg",
	volume = 0.5
},
{
	type = "sound",
	name = "RTTrapdoorCloseSound",
	filename = renaiSounds .. "TrapdoorClose.ogg",
	volume = 0.3
},
{
	type = "sound",
	name = "RTImpactPlayerLaunch",
	filename = "__base__/sound/car-metal-impact-6.ogg",
	volume = 0.5
},
{
	type = "sound",
	name = "RTHitWrongAngle",
	variations = sound_variations(renaiSounds .. "HitWrongAngle", 2, 0.75),
	aggregation =
	{
		max_count = 2,
		remove = true,
		count_already_playing = true
	}
},
{
	type = "sound",
	name = "RTItemCannonFireSound",
	filename = renaiSounds .. "ItemCannonFire1.ogg",
	aggregation =
	{
		max_count = 4,
		remove = true,
		count_already_playing = true
	}
},
{
	type = "sound",
	name = "RTTrapdoorSwitchSound",
	filename = renaiSounds .. "TrapdoorSwitch.ogg",
	volume = 0.5
},
{
	type = "sound",
	name = "RTRicochetPanelSound",
	variations = sound_variations(renaiSounds .. "impact", 14, 0.5),
	aggregation =
	{
		max_count = 4,
		remove = true,
		count_already_playing = true
	}
},
{
	type = "sound",
	name = "RTRicochetPanelSpark",
	variations = sound_variations(renaiSounds .. "zap", 3, 1),
	aggregation =
	{
		max_count = 2,
		remove = true,
		count_already_playing = true
	}
},

})
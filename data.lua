require("prototypes.technology")
require("prototypes.sounds")
require("prototypes.TabSortingStuff")
require("prototypes.TrainGoBrrrr.PropHunt")

if (settings.startup["RTThrowersSetting"].value == true) then
	require("prototypes.BouncePlates.BouncePlate")
	require("prototypes.BouncePlates.DirectedBouncePlate")
	require("prototypes.BouncePlates.DirectorBouncePlate")
	require("prototypes.PlayerLauncher")
	require("prototypes.OpenContainer")
	require("prototypes.hatch")

	if (settings.startup["RTBounceSetting"].value == true) then
		require("prototypes.BouncePlates.PrimerBouncePlate")
		--require("prototypes.BouncePlates.SignalBouncePlate")

		require("prototypes.PrimerThrower.CheckingTurret")
		require("prototypes.PrimerThrower.PrimerThrowerInserter")

		if (settings.startup["RTTrainRampSetting"].value == true) then
			require("prototypes.TrainGoBrrrr.PayloadWagon")
		end
	end

	if (settings.startup["RTTrainBounceSetting"].value == true and settings.startup["RTTrainRampSetting"].value == true) then
		require("prototypes.BouncePlates.TrainBouncePlate")
		require("prototypes.BouncePlates.TrainDirectedBouncePlate")
	end
end

if (settings.startup["RTTrainRampSetting"].value == true) then
	require("prototypes.TrainGoBrrrr.prototypes.ramps")
	require("prototypes.TrainGoBrrrr.sprites.base")
	require("prototypes.TrainGoBrrrr.GhostLoco")
	if (settings.startup["RTImpactSetting"].value == true) then
		require("prototypes.TrainGoBrrrr.ImpactWagon")
	end
end

if (settings.startup["RTZiplineSetting"].value == true) then
	require("prototypes.zipline")
end

--require("prototypes.TrainGoBrrrr.TrapdoorWagon")


data:extend({
{
	type = "custom-input",
	name = "RTInteract",
	key_sequence = "F"
},
{
	type = "custom-input",
	name = "RTThrow",
	key_sequence = "SHIFT + F"
},
{
	type = "custom-input",
	name = "RTOnOffZipline",
	key_sequence = "F"
},
{
	type = "custom-input",
	name = "RTZiplineBrake",
	key_sequence = "LSHIFT"
},
{
	type = "custom-input",
	name = "RTClick",
	key_sequence = "",
	linked_game_control = "open-gui",
	hidden = true
},
{
	type = "sprite",
	name = "RTBlank",
	filename = "__RenaiTransportation__/graphics/nothing.png",
	size = 1
},
{
	type = "animation",
	name = "RTMOREPOWER",
	filename = "__RenaiTransportation__/graphics/NoPowerBlink.png",
	size = {64,64},
	frame_count = 2,
	line_length = 2,
	animation_speed = 1/30
},
{
	type = "animation",
	name = "RTHoojinTime",
	filename = "__RenaiTransportation__/graphics/TrainRamp/trains/base/WatchHimHooj.png",
	size = {128,222},
	frame_count = 7,
	line_length = 7,
	shift = {0, -1.5},
	scale = 0.75,
},
{
	type = "sticker",
	name = "RTSaysYourCrosshairIsTooLow",
	duration_in_ticks = math.floor(60*28.13),
	working_sound =
	{
		sound =
		{
			filename = "__RenaiTransportation__/graphics/TrainRamp/trains/base/Crank dat Hooja Boi.ogg",
			volume = 0.5,
		},
		use_doppler_shift = false,
	}
},
{
	type = "custom-input",
	name = "DebugAdvanceActionProcess",
	key_sequence = "BACKSLASH",
	enabled_while_in_cutscene = true,
	order = "zzz",
	hidden = true
},
{
	type = "virtual-signal",
	name = "ThrowerRangeSignal",
	icon = "__RenaiTransportation__/graphics/RangeSignaling.png",
	icon_size = 64,
},
{
	type = "stream",
	name = "RTTestProjectile18",
	particle_spawn_interval = 0,
	particle_spawn_timeout = 0,
	particle_vertical_acceleration = 0.0035,
	particle_horizontal_speed = 0.18,
	particle_horizontal_speed_deviation = 0,
	particle =
		{
			layers =
			{
				{
					filename = "__RenaiTransportation__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2/32
				}
			}
		},
	shadow =
		{
			layers =
			{
				{
					filename = "__RenaiTransportation__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2/32,
					tint = {0,0,0,0.5}
				}
			}
		},
	oriented_particle = true
},
{
	type = "stream",
	name = "RTTestProjectile25",
	particle_spawn_interval = 0,
	particle_spawn_timeout = 0,
	particle_vertical_acceleration = 0.0035,
	particle_horizontal_speed = 0.25,
	particle_horizontal_speed_deviation = 0,
	particle =
		{
			layers =
			{
				{
					filename = "__RenaiTransportation__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2/32
				}
			}
		},
	shadow =
		{
			layers =
			{
				{
					filename = "__RenaiTransportation__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2/32,
					tint = {0,0,0,0.5}
				}
			}
		},
	oriented_particle = true
},
{
	type = "stream",
	name = "RTTestProjectile60",
	particle_spawn_interval = 0,
	particle_spawn_timeout = 0,
	particle_vertical_acceleration = 0.0035,
	particle_horizontal_speed = 0.6,
	particle_horizontal_speed_deviation = 0,
	particle =
		{
			layers =
			{
				{
					filename = "__RenaiTransportation__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2/32
				}
			}
		},
	shadow =
		{
			layers =
			{
				{
					filename = "__RenaiTransportation__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2/32,
					tint = {0,0,0,0.5}
				}
			}
		},
	oriented_particle = true
},
})

if (feature_flags["spoiling"]) then
	data:extend({
		{
			type = "capsule",
			name = "RTLickmawBalls",
			icon = "__RenaiTransportation__/graphics/LickmawBALLS.png",
			icon_size = 64,
			subgroup = "agriculture-processes",
			default_import_location = "gleba",
			fuel_category = "chemical",
			fuel_value = "1MJ",
			weight = 2380,
			order = "bbc",
			stack_size = 69,
			capsule_action = {
				type = "use-on-self",
				attack_parameters =
				{
				  type = "projectile",
				  activation_type = "consume",
				  ammo_category = "capsule",
				  cooldown = 120,
				  range = 0,
				  ammo_type =
				  {
					target_type = "position",
					action =
					{
					  type = "direct",
					  action_delivery =
					  {
						type = "instant",
						target_effects =
						{
						  {
							type = "damage",
							damage = {type = "physical", amount = -125},
							use_substitute = false
						  },
						  {
							type = "play-sound",
							sound = {"__base__/sound/eat-1.ogg"},
						  }
						}
					  }
					}
				  }
				}
			  }
		}
	})
end
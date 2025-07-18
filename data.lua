renaiTechIcons = "__RenaiTransportation__/graphics/technology/"
renaiIcons = "__RenaiTransportation__/graphics/icons/"
renaiEntity = "__RenaiTransportation__/graphics/entity/"
renaiSounds = "__RenaiTransportation__/sickw0bs/"

emptypng = "__core__/graphics/empty.png"
emptypic = {
  filename = "__core__/graphics/empty.png",
  priority = "low",
  width = 1,
  height = 1
}



require("prototypes.technology")
require("prototypes.sounds")
require("prototypes.TabSortingStuff")
require("prototypes.TrainGoBrrrr.PropHunt")
require("prototypes.RailPlacerPrototypeStuff")
BouncePadMask = {layers={object=true, player=true, water_tile=true, is_object=true}} -- no item layer or lower_object so that inserters can "place" items onto them which lets them swing

if (settings.startup["RTThrowersSetting"].value == true) then
	require("prototypes.BouncePlates.BouncePlate")
	require("prototypes.BouncePlates.DirectedBouncePlate")
	require("prototypes.BouncePlates.DirectorBouncePlate")
	require("prototypes.PlayerLauncher")
	require("prototypes.OpenContainer")
	require("prototypes.hatch")
	require("prototypes.VacuumHatch")
	require("prototypes.BeltRamp")
	if (settings.startup["RTBounceSetting"].value == true) then
		require("prototypes.BouncePlates.PrimerBouncePlate")
		--require("prototypes.BouncePlates.SignalBouncePlate")
		require("prototypes.PrimerThrower.CheckingTurret")
		require("prototypes.PrimerThrower.PrimerThrowerInserter")
		if (settings.startup["RTTrainRampSetting"].value == true) then
			require("prototypes.TrainGoBrrrr.PayloadWagon")
		end
	end
	if (settings.startup["RTItemCannonSetting"].value == true) then
		require("prototypes.ItemCannon.RicochetPanel")
		require("prototypes.ItemCannon.ItemCannon")
		require("prototypes.ItemCannon.chutes")
	end
end

if (settings.startup["RTTrainRampSetting"].value == true) then
	require("prototypes.TrainGoBrrrr.prototypes.ramps")
	require("prototypes.TrainGoBrrrr.sprites.base")
	require("prototypes.TrainGoBrrrr.GhostLoco")
	if (settings.startup["RTTrainBounceSetting"].value == true) then
		require("prototypes.BouncePlates.TrainBouncePlate")
	end
end

if (settings.startup["RTImpactSetting"].value == true) then
	require("prototypes.TrainGoBrrrr.ImpactWagon")
end

if (settings.startup["RTZiplineSetting"].value == true) then
	require("prototypes.zipline")
end

if (settings.startup["RTTrapdoorSetting"].value == true) then
	require("prototypes.TrainGoBrrrr.TrapdoorWagon")
end


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
	filename = emptypng,
	size = 1
},
{
	type = "sprite",
	name = "RTCharacterGhostStanding",
	filename = renaiEntity .. "zipline/StandingShadow.png",
	width = 190,
	height = 72
},
{
	type = "sprite",
	name = "RTCharacterGhostMoving",
	filename = renaiEntity .. "zipline/DrivingShadow.png",
	width = 190,
	height = 72
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
	type = "virtual-signal",
	name = "DirectorBouncePlateUp",
	icon = renaiIcons .. "DirectorBouncePlate_Up.png",
	icon_size = 64,
	subgroup = "virtual-signal"
},
{
	type = "virtual-signal",
	name = "DirectorBouncePlateRight",
	icon = renaiIcons .. "DirectorBouncePlate_Right.png",
	icon_size = 64,
	subgroup = "virtual-signal"
},
{
	type = "virtual-signal",
	name = "DirectorBouncePlateDown",
	icon = renaiIcons .. "DirectorBouncePlate_Down.png",
	icon_size = 64,
	subgroup = "virtual-signal"
},
{
	type = "virtual-signal",
	name = "DirectorBouncePlateLeft",
	icon = renaiIcons .. "DirectorBouncePlate_Left.png",
	icon_size = 64,
	subgroup = "virtual-signal"
},
{
	type = "animation",
	name = "RTHoojinTime",
	filename = renaiEntity .. "meme/WatchHimHooj.png",
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
			filename = renaiEntity .. "meme/Crank dat Hooja Boi.ogg",
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
	icon = renaiIcons .. "RangeSignaling.png",
	icon_size = 64,
	subgroup = "virtual-signal"
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

--[[ if (data.raw["fluid"]["thruster-fuel"]) then
    data.raw["fluid"]["thruster-fuel"].auto_barrel = true
    data.raw["fluid"]["thruster-oxidizer"].auto_barrel = true
end ]]
if (data.raw.tree.lickmaw and data.raw["item-subgroup"]["agriculture-processes"]) then
	data:extend({
		{
			type = "capsule",
			name = "RTLickmawBalls",
			icon = renaiIcons .. "LickmawBALLS.png",
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
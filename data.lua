require("prototypes.technology")
require("prototypes.sounds")
require("prototypes.TabSortingStuff")
require("prototypes.TrainGoBrrrr.PropHunt")
require("prototypes.DataTracker")

if (settings.startup["RTThrowersSetting"].value == true) then
	require("prototypes.BouncePlates.BouncePlate")
	require("prototypes.BouncePlates.DirectedBouncePlate")
	require("prototypes.BouncePlates.DirectorBouncePlate")
	require("prototypes.PlayerLauncher")
	require("prototypes.OpenContainer")
	require("prototypes.hatch")

	if (settings.startup["RTBounceSetting"].value == true) then
		require("prototypes.BouncePlates.PrimerBouncePlate")
		require("prototypes.BouncePlates.SignalBouncePlate")

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


data:extend({
{
	type = "custom-input",
	name = "RTInteract",
	key_sequence = "F"
},
-- {
-- type = "custom-input",
-- name = "RTtcaretnI",
-- key_sequence = "SHIFT + F"
-- },
{
	type = "custom-input",
	name = "RTClick",
	key_sequence = "mouse-button-1"
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
	type = "custom-input",
	name = "DebugAdvanceActionProcess",
	key_sequence = "BACKSLASH",
	enabled_while_in_cutscene = true
},
{
	type = "virtual-signal",
	name = "ThrowerRangeSignal",
	icon = "__RenaiTransportation__/graphics/RangeSignaling.png",
	icon_size = 64,
},
{
	type = "stream",
	name = "RTTestProjectile",

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
	oriented_particle = true
}
})

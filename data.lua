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
  }
})

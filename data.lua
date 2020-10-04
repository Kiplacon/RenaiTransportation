require("prototypes.technology")
require("prototypes.sounds")
require("prototypes.TabSortingStuff")
require("prototypes.TrainGoBrrrr.PropHunt")

if (settings.startup["RTThrowersSetting"].value == true) then
	require("prototypes.BouncePlates.BouncePlate")
	require("prototypes.BouncePlates.DirectedBouncePlate")
	require("prototypes.PlayerLauncher")
	require("prototypes.OpenContainer")
	require("prototypes.hatch")
end

if (settings.startup["RTThrowersSetting"].value == true and settings.startup["RTBounceSetting"].value == true) then
	require("prototypes.BouncePlates.PrimerBouncePlate")
	require("prototypes.BouncePlates.SignalBouncePlate")
end

if (settings.startup["RTThrowersSetting"].value == true and settings.startup["RTTrainBounceSetting"].value == true and settings.startup["RTTrainRampSetting"].value == true) then
	require("prototypes.BouncePlates.TrainBouncePlate")
	require("prototypes.BouncePlates.TrainDirectedBouncePlate")
end

if (settings.startup["RTTrainRampSetting"].value == true) then
	require("prototypes.TrainGoBrrrr.TrainRamp")
	require("prototypes.TrainGoBrrrr.MagnetTrainRamp")
	require("prototypes.TrainGoBrrrr.sprites.base")
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
  }
})
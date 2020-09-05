require("prototypes.technology")
require("prototypes.sounds")
require("prototypes.TabSortingStuff")

require("prototypes.BouncePlates.BouncePlate")
require("prototypes.BouncePlates.DirectedBouncePlate")
require("prototypes.PlayerLauncher")

require("prototypes.OpenContainer")
require("prototypes.hatch")

if (settings.startup["RTBounceSetting"].value == true) then
	require("prototypes.BouncePlates.PrimerBouncePlate")
	require("prototypes.BouncePlates.SignalBouncePlate")
end

if (settings.startup["RTTrainBounceSetting"].value == true and settings.startup["RTTrainRampSetting"].value == true) then
	require("prototypes.BouncePlates.TrainBouncePlate")
	require("prototypes.BouncePlates.TrainDirectedBouncePlate")
end

if (settings.startup["RTTrainRampSetting"].value == true) then
	require("prototypes.TrainGoBrrrr.TrainRamp")
	require("prototypes.TrainGoBrrrr.PropHunt")
	require("prototypes.TrainGoBrrrr.sprites.base")
end

if (settings.startup["RTZiplineSetting"].value == true) then
	require("prototypes.zipline")
end

data:extend({
  {
    type = "custom-input",
    name = "EnterPipe",
    key_sequence = "F"
  },
  
  {
    type = "custom-input",
    name = "RTClick",
    key_sequence = "mouse-button-1"
  }
})
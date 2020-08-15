require("prototypes.BouncePlates.BouncePlate")
require("prototypes.BouncePlates.PrimerBouncePlate")
require("prototypes.BouncePlates.SignalBouncePlate")
require("prototypes.BouncePlates.DirectedBouncePlate")
require("prototypes.BouncePlates.TrainBouncePlate")
require("prototypes.BouncePlates.TrainDirectedBouncePlate")

require("prototypes.OpenContainer")

require("prototypes.sounds")

require("prototypes.TabSortingStuff")

require("prototypes.PlayerLauncher")

require("prototypes.hatch")

require("prototypes.technology")

require("prototypes.TrainGoBrrrr.TrainRamp")
require("prototypes.TrainGoBrrrr.PropHunt")
require("prototypes.TrainGoBrrrr.sprites.base")

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
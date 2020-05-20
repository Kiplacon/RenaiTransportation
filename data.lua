--require("prototypes.catapult")
require("prototypes.BouncePlate")
require("prototypes.OpenContainer")
require("prototypes.throwers.BurnerThrowerInserter")
require("prototypes.throwers.ThrowerInserter")
require("prototypes.throwers.FastThrowerInserter")
require("prototypes.throwers.FilterThrowerInserter")
require("prototypes.throwers.LongHandedThrowerInserter")
require("prototypes.throwers.StackThrowerInserter")
require("prototypes.throwers.StackFilterThrowerInserter")
require("prototypes.TabSortingStuff")
require("prototypes.PlayerLauncher")

data:extend({
  {
    type = "custom-input",
    name = "EnterPipe",
    key_sequence = "F"
  }
})
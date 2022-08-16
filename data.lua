require("prototypes.colonist")
require("prototypes.WorkStations")
require("prototypes.chests")
require("prototypes.PoleNetwork")
--require("prototypes.BTS")

data:extend({
	{
		type = "sprite",
		name = "FaPBlank",
		filename = "__FactoryPlanet__/graphics/nothing.png",
		size = 1
	},
	{
      type = "item-group",
		name = "ColonyItemGroup",
		icon = "__FactoryPlanet__/graphics/TownHall.png",
		icon_size = 256,
		order = "q",
	},
	{
      type = "item-subgroup",
		name = "ColonyWorkstations",
		group = "ColonyItemGroup",
		order = "a"
	},
	{
      type = "item-subgroup",
		name = "ColonyFurniture",
		group = "ColonyItemGroup",
		order = "b"
	},
	{
		type = "item-subgroup",
		name = "ColonyMachines",
		group = "ColonyItemGroup",
		order = "c"
	},
	{
		type = "item-subgroup",
		name = "ColonyIntermediates",
		group = "ColonyItemGroup",
		order = "d"
	},
	{
		type = "item-subgroup",
		name = "ColonyRawStuff",
		group = "ColonyItemGroup",
		order = "e"
	},
	{
		type = "item-subgroup",
		name = "ColonyIngredients",
		group = "ColonyItemGroup",
		order = "f"
	},
	{
		type = "item-subgroup",
		name = "ColonyFood",
		group = "ColonyItemGroup",
		order = "g"
	},
	{
      type = "item-subgroup",
		name = "ColonyTest",
		group = "ColonyItemGroup",
		order = "zzz"
	},
	{
		type = "custom-input",
		name = "ClickTracking",
		key_sequence = "",
		linked_game_control = "open-gui"
	},
	{
		type = "custom-input",
		name = "RightClickTracking",
		key_sequence = "mouse-button-2"
	},
	{
		type = "custom-input",
		name = "DebugAdvanceActionProcess",
		key_sequence = "BACKSLASH"
	},
})

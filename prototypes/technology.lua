data:extend({
  {
	type = "technology",
	name = "se~no",
	icon = "__RenaiTransportation__/graphics/tech/start.png",
	icon_size = 128,
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "DirectedBouncePlateRecipie"
		},
		{
			type = "unlock-recipe",
			recipe = "PlayerLauncherRecipie"
		}
	},
	unit =
	{
		count = 10,
		ingredients =
		{
		  {"automation-science-pack", 1}
		},
		time = 10
	}
  },
  {
 	type = "technology",
	name = "HatchRTTech",
	icon = "__RenaiTransportation__/graphics/hatch/icon.png",
	icon_size = 64,
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "HatchRTRecipe"
		}
	},
	prerequisites = {"se~no"},
	unit =
	{
		count = 20,
		ingredients =
		{
		  {"automation-science-pack", 1}
		},
		time = 10
	} 
  },
  {
 	type = "technology",
	name = "RTThrowerTime",
	icon = "__RenaiTransportation__/graphics/tech/ThrowerTech.png",
	icon_size = 128,
	effects =
	{
	},
	prerequisites = {"se~no", "logistic-science-pack"},
	unit =
	{
		count = 50,
		ingredients =
		{
		  {"automation-science-pack", 1},
		  {"logistic-science-pack", 1}
		},
		time = 20
	} 
  },
  {
 	type = "technology",
	name = "PrimerPlateTech",
	icon = "__RenaiTransportation__/graphics/BouncePlates/PrimerBouncePlate/PrimerPlateIconn.png",
	icon_size = 64,
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "PrimerBouncePlateRecipie"
		}
	},
	prerequisites = {"se~no", "military-2"},
	unit =
	{
		count = 25,
		ingredients =
		{
		  {"automation-science-pack", 1},
		  {"logistic-science-pack", 1}
		},
		time = 25
	} 
  },
  {
 	type = "technology",
	name = "SignalPlateTech",
	icon = "__RenaiTransportation__/graphics/BouncePlates/SignalBouncePlate/SignalPlateIconn.png",
	icon_size = 64,
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "SignalBouncePlateRecipie"
		}
	},
	prerequisites = {"se~no", "circuit-network"},
	unit =
	{
		count = 25,
		ingredients =
		{
		  {"automation-science-pack", 1},
		  {"logistic-science-pack", 1}
		},
		time = 25
	} 
  },
  {
 	type = "technology",
	name = "RTFocusedFlinging",
	icon = "__RenaiTransportation__/graphics/tech/focus.png",
	icon_size = 128,
	effects =
	{
		{
			type = "nothing", 
			effect_description = "Thrower Range 1-15 tiles"
		}	
	},
	prerequisites = {"RTThrowerTime"},
	unit =
	{
		count = 75,
		ingredients =
		{
		  {"automation-science-pack", 1},
		  {"logistic-science-pack", 1}
		},
		time = 30
	} 
  },
  {
 	type = "technology",
	name = "RTFlyingFreight",
	icon = "__RenaiTransportation__/graphics/tech/FlyingFreight.png",
	icon_size = 128,
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "RTTrainRampRecipe"
		}	
	},
	prerequisites = {"railway", "concrete"},
	unit =
	{
		count = 150,
		ingredients =
		{
		  {"automation-science-pack", 1},
		  {"logistic-science-pack", 1}
		},
		time = 30
	} 
  },
  {
 	type = "technology",
	name = "RTFreightPlates",
	icon = "__RenaiTransportation__/graphics/tech/FlyingFreightPlate.png",
	icon_size = 128,
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "RTTrainBouncePlateRecipie"
		},
		{
			type = "unlock-recipe",
			recipe = "RTTrainDirectedBouncePlateRecipie"
		}
	},
	prerequisites = {"se~no", "RTFlyingFreight"},
	unit =
	{
		count = 100,
		ingredients =
		{
		  {"automation-science-pack", 1},
		  {"logistic-science-pack", 1}
		},
		time = 30
	} 
  }
})
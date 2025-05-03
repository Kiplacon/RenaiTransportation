if (settings.startup["RTThrowersSetting"].value == true) then
	data:extend({
	{
		type = "technology",
		name = "se-no",
		icon = "__RenaiTransportation__/graphics/tech/start.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "DirectedBouncePlate"
			},
			{
				type = "unlock-recipe",
				recipe = "PlayerLauncher"
			}
		},
		prerequisites = {"automation-science-pack"},
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
		name = "RTFocusedFlinging",
		icon = "__RenaiTransportation__/graphics/tech/focus.png",
		icon_size = 128,
		effects =
		{
			{
				type = "nothing",
				effect_description = "Thrower Range 1-15 tiles"
			},
			{
				type = "nothing",
				effect_description = "Thrower Range can be set by this signal",
				icon = "__RenaiTransportation__/graphics/RangeSignaling.png",
				icon_size = 64,
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
		name = "HatchRTTech",
		icon = "__RenaiTransportation__/graphics/hatch/icon.png",
		icon_size = 64,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "HatchRT"
			}
		},
		prerequisites = {"se-no"},
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
		name = "EjectorHatchRTTech",
		icon = "__RenaiTransportation__/graphics/hatch/EjeectorIccon.png",
		icon_size = 43,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "RTThrower-EjectorHatchRT"
			},
			--[[ {
				type = "unlock-recipe",
				recipe = "RTThrower-FilterEjectorHatchRT"
			} ]]
		},
		prerequisites = {"HatchRTTech"},
		unit =
		{
			count = 25,
			ingredients =
			{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1}
			},
			time = 15
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
		prerequisites = {"se-no", "logistic-science-pack"},
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
		name = "RTSimonSays",
		icon = "__RenaiTransportation__/graphics/BouncePlates/DirectorBouncePlate/DirectorPlateIcon.png",
		icon_size = 64,
		effects =
		{
		{
			type = "unlock-recipe",
			recipe = "DirectorBouncePlate"
		}
		},
		prerequisites = {"se-no", "advanced-circuit"},
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

else
	data:extend({
	{
		type = "technology",
		name = "se-no",
		icon = "__RenaiTransportation__/graphics/tech/start.png",
		icon_size = 128,
		effects =
		{},
		prerequisites = {"automation-science-pack"},
		unit =
		{
			count = 10,
			ingredients =
			{
				{"automation-science-pack", 1}
			},
			time = 10
		}
	}
	})
end
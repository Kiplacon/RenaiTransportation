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
			recipe = "HatchRTRecipe"
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
			recipe = "RTThrower-EjectorHatchRTRecipe"
		},
		--[[ {
			type = "unlock-recipe",
			recipe = "RTThrower-FilterEjectorHatchRTRecipe"
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
          recipe = "DirectorBouncePlateRecipie"
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

if (settings.startup["RTThrowersSetting"].value == true and settings.startup["RTBounceSetting"].value == true) then
	data:extend({
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
		prerequisites = {"se-no", "military-2"},
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
   	--[[ {
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
   		prerequisites = {"se-no", "circuit-network"},
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
      }, ]]
      {
         type = "technology",
         name = "PrimerThrowerTech",
         icon = "__RenaiTransportation__/graphics/tech/PrimerThrower.png",
         icon_size = 128,
         effects =
         {
          {
             type = "unlock-recipe",
             recipe = "RTThrower-PrimerThrower-Recipe"
          }
         },
         prerequisites = {"se-no", "PrimerPlateTech", "gun-turret", "military-science-pack"},
         unit =
         {
          count = 50,
          ingredients =
          {
            {"military-science-pack", 1},
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
          },
          time = 30
         }
      }
	})

	if (settings.startup["RTTrainRampSetting"].value == true) then
		data:extend({
			{
				type = "technology",
				name = "RTDeliverThePayload",
				icon = "__RenaiTransportation__/graphics/tech/boom.png",
				icon_size = 128,
				effects =
				{
					{
						type = "unlock-recipe",
						recipe = "RTPayloadWagonRecipe"
					}
				},
				prerequisites = {"PrimerPlateTech", "RTFlyingFreight", "explosives", "military-3"},
				unit =
				{
					count = 200,
					ingredients =
						{
						  {"automation-science-pack", 1},
						  {"logistic-science-pack", 1},
						  {"military-science-pack", 1},
						  {"chemical-science-pack", 1}
						},
					time = 30
					}
			}
		})
	end
end

if (settings.startup["RTTrainRampSetting"].value == true) then

	data:extend({
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
			prerequisites = {"se-no", "railway", "concrete"},
			unit =
			{
				count = 200,
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
			name = "RTMagnetTrainRamps",
			icon = "__RenaiTransportation__/graphics/tech/MagnetFreight.png",
			icon_size = 128,
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "RTMagnetTrainRampRecipe"
				}
			},
			prerequisites = {"RTFlyingFreight", "electric-energy-accumulators", "electric-energy-distribution-2"},
			unit =
			{
				count = 250,
				ingredients =
				{
				  {"automation-science-pack", 1},
				  {"logistic-science-pack", 1},
				  {"chemical-science-pack", 1}
				},
				time = 45
			}
		}
	})
   
   if (settings.startup["RTImpactSetting"].value == true) then
   	data:extend({
   	  {
   		type = "technology",
   		name = "RTImpactTech",
   		icon = "__RenaiTransportation__/graphics/tech/Impact.png",
   		icon_size = 128,
   		effects =
   		{
   			{
   				type = "unlock-recipe",
   				recipe = "RTImpactWagonRecipe"
   			},
   			{
   				type = "unlock-recipe",
   				recipe = "RTImpactUnloaderRecipe"
   			}
   		},
   		prerequisites = {"se-no", "railway", "concrete", "advanced-circuit"},
   		unit =
   		{
   			count = 200,
   			ingredients =
   			{
               {"automation-science-pack", 1},
               {"logistic-science-pack", 1}
   			},
   			time = 45
   		}
   	  }
   	})
   end

	if (settings.startup["RTThrowersSetting"].value == true and settings.startup["RTTrainBounceSetting"].value == true) then
		data:extend({
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
				prerequisites = {"RTFlyingFreight"},
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
			}
		})
	end

end

if (settings.startup["RTZiplineSetting"].value == true) then
	data:extend({
   {
   	type = "technology",
   	name = "RTZiplineTech",
   	icon = "__RenaiTransportation__/graphics/zipline/icon.png",
   	icon_size = 64,
   	effects =
   	{
   		{
   			type = "unlock-recipe",
   			recipe = "RTZiplineRecipe"
   		},
   		{
   			type = "unlock-recipe",
   			recipe = "RTZiplineControlsRecipe"
   		}
   	},
   	prerequisites = {"se-no", "steel-processing"},
   	unit =
   	{
   		count = 100,
   		ingredients =
   		{
   		  {"automation-science-pack", 1}
   		},
   		time = 30
   	}
   },

   {
   	type = "technology",
   	name = "RTZiplineControlTech1",
   	icon = "__RenaiTransportation__/graphics/zipline/crankcontrols.png",
   	icon_size = 64,
   	effects =
   	{
   		{
   			type = "unlock-recipe",
   			recipe = "RTZiplineCrankControlsRecipe"
   		}
   	},
   	prerequisites = {"RTZiplineTech"},
   	unit =
   	{
   		count = 50,
   		ingredients =
   		{
   		  {"automation-science-pack", 1}
   		},
   		time = 30
   	}
   },

   {
      type = "technology",
      name = "RTProgrammableZiplineControlTech",
      icon = "__RenaiTransportation__/graphics/zipline/terminaltech.png",
      icon_size = 128,
      effects =
      {
         {
            type = "unlock-recipe",
            recipe = "RTProgrammableZiplineControlsRecipe"
         },
         {
            type = "unlock-recipe",
            recipe = "RTZiplineTerminalRecipe"
         }
      },
      prerequisites = {"RTZiplineTech", "electric-energy-distribution-1", "concrete"},
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
      name = "RTZiplineTech2",
      icons = {
       {
       	icon = "__RenaiTransportation__/graphics/zipline/icon.png",
       	icon_size = 64,
          tint = {1,0.9,0},
       }
      },
      effects =
      {
       {
          type = "unlock-recipe",
          recipe = "RTZiplineRecipe2"
       }
      },
      prerequisites = {"RTZiplineTech", "engine"},
      unit =
      {
       count = 100,
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
      name = "RTZiplineTech3",
      icons = {
       {
         icon = "__RenaiTransportation__/graphics/zipline/icon.png",
         icon_size = 64,
          tint = {255,35,35},
       }
      },
      effects =
      {
       {
          type = "unlock-recipe",
          recipe = "RTZiplineRecipe3"
       }
      },
      prerequisites = {"RTZiplineTech2", "electric-engine"},
      unit =
      {
       count = 100,
       ingredients =
       {
         {"automation-science-pack", 1},
         {"logistic-science-pack", 1},
         {"chemical-science-pack", 1}
       },
       time = 30
      }
   },

   {
      type = "technology",
      name = "RTZiplineTech4",
      icons = {
       {
         icon = "__RenaiTransportation__/graphics/zipline/icon.png",
         icon_size = 64,
          tint = {18,201,233},
       }
      },
      effects =
      {
       {
          type = "unlock-recipe",
          recipe = "RTZiplineRecipe4"
       }
      },
      prerequisites = {"RTZiplineTech3", "rocket-fuel", "processing-unit"},
      unit =
      {
       count = 150,
       ingredients =
       {
         {"automation-science-pack", 1},
         {"logistic-science-pack", 1},
         {"chemical-science-pack", 1}
       },
       time = 30
      }
   },

   {
      type = "technology",
      name = "RTZiplineTech5",
      icons = {
       {
         icon = "__RenaiTransportation__/graphics/zipline/icon.png",
         icon_size = 64,
          tint = {83,255,26},
       }
      },
      effects =
      {
       {
          type = "unlock-recipe",
          recipe = "RTZiplineRecipe5"
       }
      },
      prerequisites = {"RTZiplineTech4", "kovarex-enrichment-process", "fission-reactor-equipment"},
      unit =
      {
        count = 200,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
        },
        time = 30
      }
   },
	})
end

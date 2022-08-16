function RefreshReferenceLists()

global.ReferenceLists = {}

global.ReferenceLists.goals =
   {
      EmptyHolding = {-----------------------------------------------------------------------------
         name = "EmptyHolding",
         StartingEffects = {
         },
         RunningEffects = {
         },
         CompletedEffects = {
            {name="GoalCompleted"}
         },
         evaluations = {
            {name="ColonistHoldingNothing", value=false, ready="no"}
         },
         variables = {
            storage = 1
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {
            {name="DumpHolding", AlreadyTried={}, ready="no"}
         },
         StartTick = 0,
         duration = 1,
         status = "starting"
      },
      HarvestAtTreeFarm = {-----------------------------------------------------------------------------
         name = "HarvestAtTreeFarm",
         StartingEffects = {
         },
         RunningEffects = {
         },
         CompletedEffects = {
            {name="GoalCompleted"}
         },
         evaluations = {
            {name="ColonistHoldingNothing", value=true, ready="no"},
            {name="FindWorkplace", workplace="FPWoodcutter", record="workplace", AlreadyTried={}, ready="no"},
            {name="EntityHasEmptySlots", entity="workplace", amount=1, ParentEval=2, ParentEvalVariable="workplace", ready="no"},
            {name="FindUnreservedEntityNearEntityByType", entity="workplace", type="tree", radius=20, value=true, record="tree", reserve="tree", ParentEval=2, ParentEvalVariable="workplace", AlreadyTried={}, ready="no"},
         },
         variables = {
            workplace = 1,
            tree = 2
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {-- find actions for these requirements to be done from last to first
            {name="DepositAll", PassDown="workplace", AlreadyTried={}, ready="no"},
            {name="PerformedHarvest", PassDown="tree", AlreadyTried={},  ready="no"}
         },
         StartTick = 0,
         duration = 1,
         status = "starting"
      },
      -- HarvestAtMine = {-----------------------------------------------------------------------------
      --    name = "HarvestAtMine",
      --    StartingEffects = {
      --    },
      --    RunningEffects = {
      --    },
      --    CompletedEffects = {
      --       {name="GoalCompleted"}
      --    },
      --    evaluations = {
      --       {name="ColonistHoldingNothing", value=true, ready="no"},
      --       {name="FindWorkplace", workplace="FPMinersStation", record="workplace", AlreadyTried={}, ready="no"},
      --       {name="EntityIsEmpty", entity="workplace", value=true, ParentEval=2, ParentEvalVariable="workplace", ready="no"},
      --       {name="FindMinableResourceNearEntity", entity="workplace", radius=10, type="resource", record="resource", ParentEval=2, ParentEvalVariable="workplace", AlreadyTried={}, ready="no"},
      --    },
      --    variables = {
      --       workplace = 1,
      --       resource = 2
      --    },
      --    reservations = {
      --       items = {},
      --       entities = {}
      --    },
      --    requirements = {
      --       {name="DepositAll", PassDown="workplace", AlreadyTried={}, ready="no"},
      --       {name="MineResource", PassDown="resource", AlreadyTried={},  ready="no"}
      --    },
      --    StartTick = 0,
      --    duration = 1,
      --    status = "starting"
      -- },
      HarvestAtMine = {------------------------------------------------------------------------------
         name = "HarvestAtMine",
         StartingEffects = {
         },
         RunningEffects = {
         },
         CompletedEffects = {
            {name="GoalCompleted"}
         },
         evaluations = {
            {name="ColonistHoldingNothing", value=true, ready="no"},
            {name="FindWorkplace", workplace="FPMinersStation", record="workplace", AlreadyTried={}, ready="no"},
            {name="EntityHasEmptySlots", entity="workplace", amount=1, ParentEval=2, ParentEvalVariable="workplace", ready="no"},
            {name="FindMinableResourceNearEntity", entity="workplace", radius=10, type="resource", record="resource", record2="StackSize", ParentEval=2, ParentEvalVariable="workplace", AlreadyTried={}, ready="no"},
            {name="AddRequirement", addition={name="MineResource", PassDown="resource", optional=true, AlreadyTried={}, ready="no"}, amount="StackSize", ParentEval=3, ParentEvalVariable="StackSize", ready="no"},
            {name="AddRequirement", addition={name="MineResource", PassDown="resource", AlreadyTried={}, ready="no"}, amount="one", ParentEval=3, ParentEvalVariable="StackSize", ready="no"},

         },
         variables = {
            workplace = 1,
            resource = 2,
            StackSize = 3,
            one = 1
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {
            {name="DepositAll", PassDown="workplace", AlreadyTried={}, ready="no"}
         },
         StartTick = 0,
         duration = 1,
         status = "starting"
      },
      Idle = {-----------------------------------------------------------------------------
         name = "Idle",
         StartingEffects = {
         },
         RunningEffects = {
         },
         CompletedEffects = {
            {name="GoalCompleted"}
         },
         evaluations = {
         },
         variables = {
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {
            {name="idle",  AlreadyTried={}, ready="no"}
         },
         StartTick = 0,
         duration = 1,
         status = "starting"
      },
      Research = {--------------------------------------------------------------------------
         name = "Research",
         StartingEffects = {
            {name="ActivateLabs", SciCenter="workplace", record="labs"},
            {name="SetColonistWorkplace", workplace="workplace"},
            {name="SetColonistActivating", set="labs"}
         },
         RunningEffects = {
            {name="ActivateLabs", SciCenter="workplace", record="labs", frequency=60}
         },
         CompletedEffects = {
            {name="DeactivateLabs", SciCenter="workplace"},
            {name="UnsetColonistWorkplace"},
            {name="UnsetColonistActivating"},
            {name="GoalCompleted"}
         },
         evaluations = {
            {name="ForceIsResearching", ready="no"},
            {name="FindUnreservedWorkplace", workplace="FPScienceCenter", record="workplace", AlreadyTried={}, ready="no"},
         },
         variables = {
            workplace = 1,
            labs = {},
            proximity = 0.75
         },
         reservations = { -- blank to fill later
            items = {},
            entities = {}
         },
         requirements = {
            {name="ColonistNearEntity", PassDownRenamed={variable="workplace", rename="entity"}, PassDown="proximity", AlreadyTried={}, ready="no"}
         },
         StartTick = 0,
         duration = 60*5,
         status = "starting"
      },
      FulfillItemRequest = {--------------------------------------------------------------------------
         name = "FulfillItemRequest",
         StartingEffects = {
         },
         RunningEffects = {
         },
         CompletedEffects = {
            {name="GoalCompleted"}
         },
         evaluations = {
            {name="FindUnreservedWorkplace", workplace="ProviderPole", record="workplace", AlreadyTried={}, ready="no"},
            {name="OpenRequest", record="request", ParentEval=1, ParentEvalVariable="workplace", ready="no"},
            {name="RequestIsFulfillable", ParentEval=2, ParentEvalVariable="request",}
         },
         variables = { -- only some of these matter
            workplace = 1,
            request = {2},
            proximity = 0.75
         },
         reservations = { -- blank to fill later
            items = {},
            entities = {}
         },
         requirements = { -- to find actions for last to first
            {name="SentRequestedItems", PassDown="request", AlreadyTried={}, ready="no"}
         },
         StartTick = 0,
         duration = 1,
         status = "starting"
      }
   }

global.ReferenceLists.actions =
   {
      DepositAll = {-----------------------------------------------------------------------------
         name = "DepositAll",
         fulfills = {
            "DepositAll"
         },
         StartingEffects = {
         },
         RunningEffects = {
         },
         CompletedEffects = {
            {name="InsertHoldingIntoEntity", entity="workplace"},
         },
         evaluations = {
            {name="EntityIsValid", entity="workplace", ready="no"}
         },
         variables = {
            workplace = "inherited",
            proximity = 0.75
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {
            {name="ColonistNearEntity", PassDownRenamed={variable="workplace", rename="entity"}, PassDown="proximity", AlreadyTried={}, ready="no"}
         },
         ParentAction = 0,
         ParentActionsRequirement = 0,
         StartTick = 0,
         duration = 1,
         difficulty = 10,
         status = "starting"
      },
      ThrowDeposit = {-----------------------------------------------------------------------------
         name = "ThrowDeposit",
         fulfills = {
            "DepositAll"
         },
         StartingEffects = {
            {name="StartInsertAnimation", target="workplace", RecordStartPosition="start", RecordSprite="sprite", RecordVector="UnitVector"},
            {name="PlaySound", sound="sound", position="start"}
         },
         RunningEffects = {
            {name="AnimateMove", sprite="sprite", direction="UnitVector", start="start"}
         },
         CompletedEffects = {
            {name="InsertHoldingIntoEntity", entity="workplace"},
            {name="ClearAnimation", sprite="sprite"}
         },
         evaluations = {
            {name="EntityIsValid", entity="workplace", ready="no"}
         },
         variables = {
            workplace = "inherited",
            start = {},
            sprite = 1,
            UnitVector = 2,
            proximity = 8,
            sound = "utility/inventory_move"
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {
            {name="ColonistNearEntity", PassDownRenamed={variable="workplace", rename="entity"}, PassDown="proximity", AlreadyTried={}, ready="no"}
         },
         ParentAction = 0,
         ParentActionsRequirement = 0,
         StartTick = 0,
         duration = 7,
         HideProgress = "bofa",
         difficulty = 0,
         status = "starting"
      },
      GoToEntity = {-----------------------------------------------------------------------------
         name = "GoToEntity",
         fulfills = {
            "ColonistNearEntity"
         },
         StartingEffects = {
            {name="GoToEntity", entity="entity", proximity="proximity"},
         },
         RunningEffects = {
         },
         CompletedEffects = {
            {name="StopColonist"},
         },
         evaluations = {
            {name="EntityIsValid", entity="entity", ready="no"}
         },
         variables = {
            entity = "inherited",
            proximity = "inherited"
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {
         },
         ParentAction = 0,
         ParentActionsRequirement = 0,
         duration = "indeterminate",
         difficulty = 0,
         status = "starting"
      },
      HarvestTree = {-----------------------------------------------------------------------------
         name = "HarvestTree",
         fulfills = {
            "PerformedHarvest"
         },
         StartingEffects = {
            {name="CheckEntityIsValid", entity="tree"},
            {name="PlaySound", sound="sound"}
         },
         RunningEffects = {
         },
         CompletedEffects = {
            {name="InsertHarvestIntoHolding", harvesting="tree"}
         },
         evaluations = {
            {name="EntityIsValid", entity="tree", ready="no"}
         },
         variables = {
            tree = "inherited",
            proximity = 2,
            sound = "utility/mining_wood"
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {
            {name="ColonistNearEntity", PassDownRenamed={variable="tree", rename="entity"}, PassDown="proximity", AlreadyTried={}, ready="no"}
         },
         ParentAction = 0,
         ParentActionsRequirement = 0,
         StartTick = 0,
         duration = 30,
         difficulty = 0,
         status = "starting"
      },
      HarvestMinableResource = {-----------------------------------------------------------------------------
         name = "HarvestMinableResource",
         fulfills = {
            "MineResource"
         },
         StartingEffects = {
            {name="CheckEntityIsValid", entity="resource"},
            {name="PlaySound", sound="sound"},
            {name="CreateMiningParticle", source="resource"}
         },
         RunningEffects = {
         },
         CompletedEffects = {
            {name="MineResource", harvesting="resource"}
         },
         evaluations = {
            {name="EntityIsValid", entity="resource", ready="no"}
         },
         variables = {
            resource = "inherited",
            proximity = 2,
            sound = "utility/axe_mining_ore"
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {
            {name="ColonistNearEntity", PassDownRenamed={variable="resource", rename="entity"}, PassDown="proximity", AlreadyTried={}, ready="no"}
         },
         ParentAction = 0,
         ParentActionsRequirement = 0,
         StartTick = 0,
         duration = 5,
         difficulty = 0,
         status = "starting"
      },
      Idle = {-----------------------------------------------------------------------------
         name = "Idle",
         fulfills = {
            "idle"
         },
         StartingEffects = {
         },
         RunningEffects = {
         },
         CompletedEffects = {
         },
         evaluations = {
         },
         variables = {
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {
         },
         ParentAction = 0,
         ParentActionsRequirement = 0,
         StartTick = 0,
         duration = 180,
         difficulty = 0,
         status = "starting"
      },
      DumpInStorage = {-----------------------------------------------------------------------------
         name = "DumpInStorage",
         fulfills = {
            "DumpHolding"
         },
         StartingEffects = {
         },
         RunningEffects = {
         },
         CompletedEffects = {
            {name="InsertHoldingIntoEntity", entity="storage"}
         },
         evaluations = {
            {name="FindWorkplace", workplace="FPMiscChest", record="storage", AlreadyTried={}, ready="no"},
            {name="EntityHasEmptySlots", entity="storage", amount=1, ParentEval=1, ParentEvalVariable="storage", ready="no"}
         },
         variables = {
            storage = "sawcon"
         },
         reservations = {
            items = {},
            entities = {}
         },
         requirements = {
            {name="DepositAll", PassDownRenamed={variable="storage", rename="workplace"}, AlreadyTried={}, ready="no"}
         },
         ParentAction = 0,
         ParentActionsRequirement = 0,
         duration = 1,
         difficulty = 0,
         status = "starting"
      },
   }

global.ReferenceLists.workplaces =
   {
      FPWoodcutter = true,
      FPMinersStation = true,
      FPFarmingStation = true,
      FPPlantingStation = true,
      FPScienceCenter = true,
      FPWoodenWorkbench = true,
      FPMiscChest = true,
      FPAssemblyWorkstation = true,
      FPSortingCenter = true
   }

global.ReferenceLists.InsertInventory = {}
   global.ReferenceLists.InsertInventory["ammo-turret"] = "defines.inventory.turret_ammo"
   global.ReferenceLists.InsertInventory["artillery-turret"] = "defines.inventory.artillery_turret_ammo"
   global.ReferenceLists.InsertInventory["assembling-machine"] = "defines.inventory.assembling_machine_input"
   global.ReferenceLists.InsertInventory["beacon"] = "defines.inventory.beacon_modules"
   global.ReferenceLists.InsertInventory["boiler"] = "defines.inventory.fuel"
   global.ReferenceLists.InsertInventory["burner-generator"] = "defines.inventory.fuel"
   global.ReferenceLists.InsertInventory["container"] = "defines.inventory.chest"
   global.ReferenceLists.InsertInventory["furnace"] = "defines.inventory.furnace_source"
   global.ReferenceLists.InsertInventory["lab"] = "defines.inventory.lab_input"
   global.ReferenceLists.InsertInventory["linked-container"] = "defines.inventory.chest"


end

return RefreshReferenceLists

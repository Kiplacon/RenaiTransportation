evaluate = {
   ColonistHoldingNothing = function(ColonistProperties, action, evaluation)
      if (ColonistProperties.holding.is_empty() == evaluation.value) then
         evaluation.ready = "yes"
      else
         evaluation.ready = "failed"
      end
   end,
   FindWorkplace = function(ColonistProperties, action, evaluation)
      evaluation.ready = "failed"
      local ChosenWorkplace = "UrMumsHouse" -- kek
      local closest = 9999999999
      local colonist = ColonistProperties.entity
      if (colonist.valid and global.workplaces[colonist.force.name][colonist.surface.name] ~= nil) then -- if the list exists
         for EntityNumber, properties in pairs(global.workplaces[colonist.force.name][colonist.surface.name]) do
            if (properties.entity.valid) then
               if (evaluation.AlreadyTried[GetPlanningID(properties.entity)] == nil
               and properties.entity.name == evaluation.workplace
               and DistanceBetween(properties.entity.position, colonist.position) < closest) then
                  ChosenWorkplace = properties.entity
                  closest = DistanceBetween(properties.entity.position, colonist.position)
                  evaluation.ready = "yes"
               end
            else
               global.workplaces[colonist.force.name][colonist.surface.name][EntityNumber] = nil
            end
         end
         action.variables[evaluation.record] = ChosenWorkplace
      end
   end,
   FindUnreservedWorkplace = function(ColonistProperties, action, evaluation)
      evaluation.ready = "failed"
      local ChosenWorkplace = "UrMumsHouse" -- kek
      local closest = 9999999999
      local colonist = ColonistProperties.entity
      if (colonist.valid and global.workplaces[colonist.force.name][colonist.surface.name] ~= nil) then -- if the list exists
         for EntityNumber, properties in pairs(global.workplaces[colonist.force.name][colonist.surface.name]) do
            if (properties.entity.valid) then
               if (evaluation.AlreadyTried[GetPlanningID(properties.entity)] == nil
               and properties.entity.name == evaluation.workplace
               and DistanceBetween(properties.entity.position, colonist.position) < closest
               and global.reservations.entities[properties.entity.unit_number] == nil) then
                  ChosenWorkplace = properties.entity
                  closest = DistanceBetween(properties.entity.position, colonist.position)
                  evaluation.ready = "yes"
               end
            else
               global.workplaces[colonist.force.name][colonist.surface.name][EntityNumber] = nil
            end
         end
         action.variables[evaluation.record] = ChosenWorkplace
      end
      if (ChosenWorkplace ~= "UrMumsHouse") then
         global.reservations.entities[ChosenWorkplace.unit_number] = ChosenWorkplace
         action.reservations.entities[ChosenWorkplace.unit_number] = ChosenWorkplace
      end
   end,
   EntityHasEmptySlots = function(ColonistProperties, action, evaluation)
      local entity = action.variables[evaluation.entity]
      if (entity.valid and entity.get_output_inventory().count_empty_stacks() >= evaluation.amount) then
         evaluation.ready = "yes"
      else
         evaluation.ready = "failed"
      end
   end,
   EntityIsEmpty = function(ColonistProperties, action, evaluation)
      local entity = action.variables[evaluation.entity]
      if (entity.valid and entity.get_output_inventory().is_empty() == evaluation.value) then
         evaluation.ready = "yes"
      else
         evaluation.ready = "failed"
      end
   end,
   FindUnreservedEntityNearEntityByType = function(ColonistProperties, action, evaluation)
      local entity = action.variables[evaluation.entity]
      local colonist = ColonistProperties.entity
      local distance = 9999999999
      local found = "none"
      if (colonist.valid and entity.valid) then
         local set = entity.surface.find_entities_filtered{
            area = evaluation.area or nil,
            position = action.variables[evaluation.entity].position or nil,
            radius = evaluation.radius or nil,
            type = evaluation.type or nil,
            force = evaluation.force or nil,
            direction = evaluation.direction or nil,
            collision_mask = evaluation.collision_mask or nil,
            limit = evaluation.limit
         }
         for each, thing in pairs(set) do
            local ThingID = GetPlanningID(thing)
            if (evaluation.AlreadyTried[ThingID] == nil
            and DistanceBetween(thing.position, colonist.position) < distance
            and global.reservations.entities[ThingID] == nil) then
               found = thing
               distance = DistanceBetween(thing.position, colonist.position)
            end
         end
      end
      if (found ~= "none") then
         local ID = GetPlanningID(found)
         evaluation.ready = "yes"
         action.variables[evaluation.record] = found
         action.reservations.entities[ID] = found
         global.reservations.entities[ID] = found
      else
         evaluation.ready = "failed"
      end
   end,
   FindMinableResourceNearEntity = function(ColonistProperties, action, evaluation)
      local entity = action.variables[evaluation.entity]
      local colonist = ColonistProperties.entity
      local distance = 9999999999
      local found = "none"
      if (colonist.valid and entity.valid) then
         local set = entity.surface.find_entities_filtered{
            position = action.variables[evaluation.entity].position or nil,
            radius = evaluation.radius or nil,
            type = evaluation.type or nil
         }
         for each, thing in pairs(set) do
            local ThingID = GetPlanningID(thing)
            if (evaluation.AlreadyTried[ThingID] == nil
            and DistanceBetween(thing.position, colonist.position) < distance
            and thing.prototype.mineable_properties.minable == true
            and thing.prototype.mineable_properties.required_fluid == nil
            and #thing.prototype.mineable_properties.products >= 1
            and thing.prototype.mineable_properties.products[1].type == "item") then
               found = thing
               distance = DistanceBetween(thing.position, colonist.position)
               action.variables[evaluation.record2] = game.item_prototypes[thing.prototype.mineable_properties.products[1].name].stack_size - 1
            end
         end
      end
      if (found ~= "none") then
         evaluation.ready = "yes"
         action.variables[evaluation.record] = found
      else
         evaluation.ready = "failed"
      end
   end,
   AddRequirement = function(ColonistProperties, action, evaluation)
      local repeats = action.variables[evaluation.amount]
      --game.print(repeats)
      for i = 1, repeats do
         table.insert(action.requirements, copy(evaluation.addition))
      end
   end,
   EntityIsValid = function(ColonistProperties, action, evaluation)
      if (action.variables[evaluation.entity].valid) then
         evaluation.ready = "yes"
      else
         evaluation.ready = "failed"
      end
   end,
   ForceIsResearching = function(ColonistProperties, action, evaluation)
      if (ColonistProperties.entity.valid and ColonistProperties.entity.force.current_research == nil) then
         evaluation.ready = "failed"
      else
         evaluation.ready = "yes"
      end
   end,
}

CalculateDifficulty = { -- 1 difficulty point = walking 1 tile
   GoToEntity = function(ColonistProperties, TempCopy)
      return DistanceBetween(ColonistProperties.entity.position, TempCopy.variables.entity.position)
   end,
   DumpInStorage = function(ColonistProperties, TempCopy)
      return DistanceBetween(ColonistProperties.entity.position, TempCopy.variables.storage.position)
   end,
}

function FindFulfillingAction(ColonistProperties, action, a, requirement, r)
   if (ColonistProperties.alive == true) then
      local MaxDifficulty = 9999999999
      local ChosenAction = "chokoma"
      for ActionName, PossibleAction in pairs(global.ReferenceLists.actions) do
         --game.print("    Trying "..ActionName)
         local PossibleActionCopy = copy(PossibleAction)
         if (requirement.PassDown) then
            PossibleActionCopy.variables[requirement.PassDown] = action.variables[requirement.PassDown]
         end
         if (requirement.PassDown2) then
            PossibleActionCopy.variables[requirement.PassDown2] = action.variables[requirement.PassDown2]
         end
         if (requirement.PassDown3) then
            PossibleActionCopy.variables[requirement.PassDown3] = action.variables[requirement.PassDown3]
         end
         if (requirement.PassDownRenamed) then
            PossibleActionCopy.variables[requirement.PassDownRenamed.rename] = action.variables[requirement.PassDownRenamed.variable]
         end
         if (requirement.PassDownRenamed2) then
            PossibleActionCopy.variables[requirement.PassDownRenamed2.rename] = action.variables[requirement.PassDownRenamed2.variable]
         end
         if (requirement.PassDownRenamed3) then
            PossibleActionCopy.variables[requirement.PassDownRenamed3.rename] = action.variables[requirement.PassDownRenamed3.variable]
         end
         local ActionDifficulty = PossibleActionCopy.difficulty or 0
         for each, fulfiller in pairs(PossibleActionCopy.fulfills) do
            if (fulfiller == requirement.name and requirement.AlreadyTried[ActionName] == nil) then -- fulfillment match
               -- evaluate the action possibility
               local ValidAction = true
               local NeedsAnotherLoop = true
               while (NeedsAnotherLoop == true) do
                  NeedsAnotherLoop = false
                  for each, evaluation in pairs(PossibleActionCopy.evaluations) do
                     if (evaluation.ready ~= "yes" and ColonistProperties.entity.valid) then -- if hasn't been evaluated yet
                        evaluate[evaluation.name](ColonistProperties, PossibleActionCopy, evaluation) -- sets evaluation.ready to either "yes" or "failed"
                        -- if evaluation fails
                        if (evaluation.ready == "failed") then -- if the evaluation failed, the action can't be done
                           if (evaluation.ParentEval) then -- if it relied on the search of a previous eval maybe it can find an alternative
                              local ThingThatFailedID = GetPlanningID(action.variables[evaluation.ParentEvalVariable])
                              action.evaluations[evaluation.ParentEval].AlreadyTried[ThingThatFailedID] = "nope"
                              action.evaluations[evaluation.ParentEval].ready = "no" -- reseting to "no" lets it try again
                              for x = #action.evaluations, each, -1 do -- redo each evaluation after the parent one "which includes current eval"
                                 action.evaluations[x].ready = "no"
                              end
                              NeedsAnotherLoop = true
                           else -- only "foundational" evaluation failure causes action failure
                              ValidAction = false
                           end
                           --game.print("      "..ActionName.." eval #"..each.." failed")
                           break -- finish this evaluation
                        end
                     end
                  end
               end
               -- Calculate the action's difficulty --
               if (ValidAction == true) then
                  --game.print("      "..ActionName.." good")
                  if (CalculateDifficulty[ActionName]) then
                     --game.print("        Calculating difficulty")
                     ActionDifficulty = ActionDifficulty + CalculateDifficulty[ActionName](ColonistProperties, PossibleActionCopy)
                  end
                  if (ActionDifficulty < MaxDifficulty) then
                     --game.print("        "..ActionName.." can fulfill req#"..r.." for "..action.name)
                     ChosenAction = PossibleActionCopy
                     MaxDifficulty = ActionDifficulty
                     break -- break into looking at the next possible action
                  end
               end
            end
         end
      end
      if (ChosenAction ~= "chokoma") then
         --game.print("          "..ChosenAction.name.." chosen")
         if (requirement.optional) then
            ChosenAction.optional = requirement.optional
         elseif (action.optional) then
            ChosenAction.optional = action.optional
         end
         table.insert(ColonistProperties.ActionPlan.queue, ChosenAction)
         ColonistProperties.ActionPlan.queue[#ColonistProperties.ActionPlan.queue].ParentAction = a
         ColonistProperties.ActionPlan.queue[#ColonistProperties.ActionPlan.queue].ParentActionsRequirement = r
         requirement.ready = "yes"
      else
         --game.print("    No action found for "..action.name)
         requirement.ready = "failed"
      end
   end
end

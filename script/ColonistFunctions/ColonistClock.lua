-- Colonist GOAP --
local function ColonistClock(event)
   for ColonistName, ColonistProperties in pairs(global.AllColonists) do
      if (ColonistProperties.alive == true) then -- if colonist is alive
         if (ColonistProperties.ActionPlan.state == "interrupted") then
            ColonistReset(ColonistProperties)

         -- =========Find a goal=========
         elseif (#ColonistProperties.ActionPlan.queue==0 and ColonistProperties.ActionPlan.state == "planning") then
            -- select an untried goal
            for priority, GoalName in pairs(ColonistProperties.GoalList) do
               if (ColonistProperties.ActionPlan.AlreadyTried[GoalName] == nil -- havent tried before
               and global.ReferenceLists.goals[GoalName]) then
                  table.insert(ColonistProperties.ActionPlan.queue, copy(global.ReferenceLists.goals[GoalName]))
                  --game.print("Trying goal "..GoalName)
                  break
               end
            end
            -- evaluate the goal
            local action = ColonistProperties.ActionPlan.queue[1]
            --game.print("  Evaluating "..action.name)
            local NeedsAnotherLoop = true
            while (NeedsAnotherLoop == true) do
               NeedsAnotherLoop = false
               for each, evaluation in pairs(action.evaluations) do
                  if (evaluation.ready ~= "yes") then -- if hasn't been evaluated yet
                     evaluate[evaluation.name](ColonistProperties, action, evaluation) -- sets evaluation.ready to either "yes" or "failed"
                     if (evaluation.ready == "failed") then -- if the evaluation failed, the action can't be done
                        if (evaluation.ParentEval) then -- if it relied on the search of a previous eval maybe it can find an alternative
                           local ThingThatFailedID = GetPlanningID(action.variables[evaluation.ParentEvalVariable])
                           action.evaluations[evaluation.ParentEval].AlreadyTried[ThingThatFailedID] = "nope"
                           action.evaluations[evaluation.ParentEval].ready = "no" -- reseting to "no" lets it try again
                           for x = #action.evaluations, each, -1 do -- redo each evaluation after the parent one "which includes current eval"
                              action.evaluations[x].ready = "no" -- can be anything that's not 'yes' or 'failed'
                           end
                           NeedsAnotherLoop = true
                        else -- only "foundational" evaulations cause action failure
                           ColonistProperties.ActionPlan.AlreadyTried[action.name] = "Imagine Dragon deez nuts across your face"
                           ColonistProperties.ActionPlan.queue = {}
                        end
                        --game.print("  "..action.name.." evaluation #"..each.." failed")
                        break
                     end
                  end
               end
            end
            if (#ColonistProperties.ActionPlan.queue>0)then
               --game.print("  "..action.name.." good to try")
            end

         -- ======Find plan based on goal==========
         elseif (#ColonistProperties.ActionPlan.queue>0 and ColonistProperties.ActionPlan.state == "planning") then
            local PlanReady = "yes"
            -- ====================== Check each action================================
            for i = #ColonistProperties.ActionPlan.queue, 1, -1 do
               local ActionReady = "yes"
               local action = ColonistProperties.ActionPlan.queue[i]
               --game.print("Finding fulfilling actions for "..action.name)
               --======================== Analyze this action's requirements =============================
               for each, requirement in pairs(action.requirements) do
                  --game.print("  Requirement #"..each)
                  if (requirement.ready ~= "yes") then -- if fulfilling action hasn't been found yet
                     PlanReady = "no"
                     FindFulfillingAction(ColonistProperties, action, i, requirement, each)
                     if (requirement.ready == "failed") then -- if the requirement cant be fulfilled, the action can't be done
                        ActionReady = "failed"
                     end
                     break
                  end
               end
               if (ActionReady == "failed") then
                  if (action.ParentAction) then -- goals don't have a parent action
                     -- reset the parent requirement to evaluate again
                     ColonistProperties.ActionPlan.queue[action.ParentAction].requirements[action.ParentActionsRequirement].AlreadyTried[action.name] = "nope"
                     ColonistProperties.ActionPlan.queue[action.ParentAction].requirements[action.ParentActionsRequirement].ready = "no"
                  else
                     ColonistProperties.ActionPlan.AlreadyTried[action.name] = "Imagine Dragons"
                  end
                  for x = #ColonistProperties.ActionPlan.queue, i, -1 do -- remove the failed action and all its children. By necessity every action in the queue after the failed action is its child
                     table.remove(ColonistProperties.ActionPlan.queue, x)
                  end
                  break -- break to plan check
               elseif (ActionReady == "yes") then  -- ActionReady will be "yes" if nothing set it to "failed"
                  -- don't break and loop to next action
               end
            end
            --================= plan is ready ===============
            if (PlanReady == "yes") then -- Plan all ready
               ColonistProperties.ActionPlan.state = "executing"
               --game.print("Executing "..ColonistProperties.ActionPlan.queue[1].name)
            end

         elseif (ColonistProperties.ActionPlan.state == "executing") then
            StepActionQueue(ColonistName)
            -- coolio
         end
      end
   end
end

return ColonistClock

function ColonistReset(ColonistProperties)
   -- undo reservations
   for each, action in pairs(ColonistProperties.ActionPlan.queue) do
      for ID, entity in pairs(action.reservations.entities) do
         global.reservations.entities[ID] = nil
      end
      for ID, item in pairs(action.reservations.items) do
         global.reservations.items[ID] = nil
      end
   end
   -- deactivate activating things
   for each, entity in pairs(ColonistProperties.WorkingWith.activating) do
      if (entity.valid) then
         entity.active = false
      end
   end
   ColonistProperties.WorkingWith.workplace = "rhydon"
   ColonistProperties.WorkingWith.activating = {}
	-- return to zero
   ColonistProperties.ActionPlan.queue = {}
   ColonistProperties.ActionPlan.AlreadyTried = {}
   ColonistProperties.ActionPlan.state = "planning"
   if (ColonistProperties.entity.valid and ColonistProperties.entity.command and ColonistProperties.entity.command.type ~= 6) then
      ColonistProperties.entity.set_command({type = defines.command.wander})
   end
   if (ColonistProperties.entity.valid) then
      rendering.set_text(ColonistProperties.ActionTag, "Idling")
      rendering.set_angle(ColonistProperties.ProgressBar, 0)
      if (rendering.is_valid(ColonistProperties.MovingTo)) then
         rendering.destroy(ColonistProperties.MovingTo)
      end
   else
      ColonistProperties.alive = false
   end
end

-- steper function
function StepActionQueue(ColonistName)
   local ColonistProperties = global.AllColonists[ColonistName]
   local ExecutingAction = ColonistProperties.ActionPlan.queue[#ColonistProperties.ActionPlan.queue]
   if (ColonistProperties.entity.valid) then
      if (ExecutingAction.status == "starting") then
         -- set visuals --
         rendering.set_text(ColonistProperties.ActionTag, ExecutingAction.name)
         -- proc effects --
         for each, effect in pairs(ExecutingAction.StartingEffects) do
            local EffectSuccess = ProcEffect[effect.name](ColonistProperties, ExecutingAction, effect)
            if (EffectSuccess == "failed" and ExecutingAction.optional == nil) then
               ColonistReset(ColonistProperties)
               return
            elseif (EffectSuccess == "failed" and ExecutingAction.optional) then
               ExecutingAction.status = "GoNext"
               return
            end
         end
         -- set timers --
         ExecutingAction.StartTick = game.tick
         if (string.find(ExecutingAction.name, "GoTo")) then
            rendering.set_text(ColonistProperties.ActionTag, ColonistProperties.ActionPlan.queue[ExecutingAction.ParentAction].name)
         end
         ExecutingAction.status = "running"

      elseif (ExecutingAction.status == "running") then
         -- proc effects --
         for each, effect in pairs(ExecutingAction.RunningEffects) do
            if (effect.frequency == nil or (effect.frequency and game.tick%effect.frequency == 0)) then
               local EffectSuccess = ProcEffect[effect.name](ColonistProperties, ExecutingAction, effect)
               if (EffectSuccess == "failed" and ExecutingAction.optional == nil) then
                  ColonistReset(ColonistProperties)
                  return
               elseif (EffectSuccess == "failed" and ExecutingAction.optional) then
                  ExecutingAction.status = "GoNext"
                  return
               end
            end
         end
         -- check if timer is up --
         if (ExecutingAction.duration ~= "indeterminate") then
            if (game.tick == ExecutingAction.StartTick+ExecutingAction.duration) then
               ExecutingAction.status = "completed"
               rendering.set_angle(ColonistProperties.ProgressBar, 2*math.pi)
            elseif (ExecutingAction.HideProgress == nil) then
               local progress = (game.tick-ExecutingAction.StartTick)/ExecutingAction.duration
   			 	rendering.set_angle(ColonistProperties.ProgressBar, 2*math.pi*progress)
            end
         end

      elseif (ExecutingAction.status == "completed") then
         -- do effects --
         for each, effect in pairs(ExecutingAction.CompletedEffects) do
            local EffectSuccess = ProcEffect[effect.name](ColonistProperties, ExecutingAction, effect)
            if (EffectSuccess == "failed" and ExecutingAction.optional == nil) then
               ColonistReset(ColonistProperties)
               return
            elseif (EffectSuccess == "failed" and ExecutingAction.optional) then
               ExecutingAction.status = "GoNext"
               return
            end
         end
         ExecutingAction.status = "GoNext"

      elseif (ExecutingAction.status == "GoNext") then
         -- clear reservations --
         for ID, entity in pairs(ExecutingAction.reservations.entities) do
            global.reservations.entities[ID] = nil
         end
         for ID, item in pairs(ExecutingAction.reservations.items) do
            global.reservations.items[ID] = nil
         end
         -- update visuals --
         if (ColonistProperties.holding[1].count == 0) then
            rendering.set_sprite(ColonistProperties.HoldingSprite, "FaPBlank")
         else
            rendering.set_sprite(ColonistProperties.HoldingSprite, "item/"..ColonistProperties.holding[1].name)
         end
         if (rendering.is_valid(ColonistProperties.MovingTo)) then
            rendering.destroy(ColonistProperties.MovingTo)
         end
         rendering.set_angle(ColonistProperties.ProgressBar, 0)
         -- remove action so expose the next one --
         table.remove(ColonistProperties.ActionPlan.queue, #ColonistProperties.ActionPlan.queue)
      end
   end
end
-------------------------------------------------------------------
ProcEffect = { -- effects from the actions in the global.actions list. See them for variable links
   GoalCompleted = function(ColonistProperties, ExecutingAction, effect)
      ColonistReset(ColonistProperties)
   end,
   SetColonistWorkplace = function(ColonistProperties, ExecutingAction, effect)
      ColonistProperties.WorkingWith.workplace = ExecutingAction.variables[effect.workplace].unit_number
   end,
   SetColonistActivating = function(ColonistProperties, ExecutingAction, effect)
      for each, entity in pairs(ExecutingAction.variables[effect.set]) do
         table.insert(ColonistProperties.WorkingWith.activating, entity)
      end
   end,
   UnsetColonistWorkplace = function(ColonistProperties, ExecutingAction, effect)
      ColonistProperties.WorkingWith.workplace = "asthma"
   end,
   UnsetColonistActivating = function(ColonistProperties, ExecutingAction, effect)
      ColonistProperties.WorkingWith.activating = {}
   end,
   InsertHoldingIntoEntity = function(ColonistProperties, ExecutingAction, effect)
      local entity = ExecutingAction.variables[effect.entity]
      if (entity.valid) then
         if (ColonistProperties.holding[1].valid_for_read) then
            local inserted = entity.get_output_inventory().insert(ColonistProperties.holding[1])
            ColonistProperties.holding[1].count = ColonistProperties.holding[1].count - inserted
         end
      else
         return "failed"
      end
   end,
   RemoveFromHolding = function(ColonistProperties, ExecutingAction, effect)
      ColonistProperties.holding[1].count = ColonistProperties.holding[1].count - effect.amount
   end,
   GoToEntity = function(ColonistProperties, ExecutingAction, effect)
      local entity = ExecutingAction.variables[effect.entity]
      local colonist = ColonistProperties.entity
      if (rendering.is_valid(ColonistProperties.MovingTo)) then
         rendering.destroy(ColonistProperties.MovingTo)
      end
      if (entity.valid) then
         --game.print("issued move")
         colonist.set_command({
            type = defines.command.go_to_location,
            destination_entity = entity,
            radius = ExecutingAction.variables[effect.proximity],
            pathfind_flags = {cache=false}
            })
         ColonistProperties.MovingTo = rendering.draw_line{color={r=0.5, a=0.5}, width=4, from=ColonistProperties.entity, to=entity, surface=entity.surface, only_in_alt_mode=true, render_layer=181}
      else
         --game.print("move fialed")
         return "failed"
      end
   end,
   StopColonist = function(ColonistProperties, ExecutingAction, effect)
      local colonist = ColonistProperties.entity
      colonist.set_command({type = defines.command.stop})
   end,
   InsertHarvestIntoHolding = function(ColonistProperties, ExecutingAction, effect)
      local HarvestTarget = ExecutingAction.variables[effect.harvesting]
      local colonist = ColonistProperties.entity
      if (HarvestTarget.valid) then
         if (HarvestTarget.prototype.mineable_properties.minable == true and #HarvestTarget.prototype.mineable_properties.products) then
            for each, product in pairs(HarvestTarget.prototype.mineable_properties.products) do
               if (each == 1 and (product.probability==nil or product.probability>math.random())) then
                  ColonistProperties.holding.insert({name=product.name, count=product.amount or (product.amount_min+product.amount_max)/2})
               elseif (product.probability==nil or product.probability>math.random()) then
                  HarvestTarget.surface.spill_item_stack(HarvestTarget.position, {name=product.name, count=product.amount or (product.amount_min+product.amount_max)/2})
               end
            end
         end
         HarvestTarget.die()
      else
         return "failed"
      end
   end,
   DropHolding = function(ColonistProperties, ExecutingAction, effect)
      local colonist = ColonistProperties.entity
      colonist.surface.spill_item_stack(colonist.position, ColonistProperties.holding[1])
      ColonistProperties.holding[1].count = 0
   end,
   MineResource = function(ColonistProperties, ExecutingAction, effect)
      local resource = ExecutingAction.variables[effect.harvesting]
      if (resource.valid) then
         local result
         local amount
         for each, product in pairs(resource.prototype.mineable_properties.products) do
            if (each ~= #resource.prototype.mineable_properties.products and (product.probability==nil or product.probability>math.random()))
            or (each == #resource.prototype.mineable_properties.products) then
               result = product.name
               amount = product.amount or (product.amount_min+product.amount_max)/2
               if (amount >= resource.amount) then
                  amount = resource.amount
                  resource.destroy()
               else
                  resource.amount = resource.amount - amount
               end
               ColonistProperties.holding.insert({name=result, count=amount})
               break
            end
         end
      else
         return "failed"
      end
   end,
   CheckEntityIsValid = function(ColonistProperties, ExecutingAction, effect)
      if (ExecutingAction.variables[effect.entity].valid) then
         --coolio
      else
         return "failed"
      end
   end,
   StartInsertAnimation = function(ColonistProperties, ExecutingAction, effect)
      local item = ColonistProperties.holding[1].name
      local target = ExecutingAction.variables[effect.target]
      ExecutingAction.variables[effect.RecordSprite] = rendering.draw_sprite{
         sprite = "item/"..item,
         surface = ColonistProperties.entity.surface,
         target = ColonistProperties.entity.position,
         x_scale = 0.75,
         y_scale = 0.75
      }
      ExecutingAction.variables[effect.RecordStartPosition] = {x=ColonistProperties.entity.position.x, y=ColonistProperties.entity.position.y}
      ExecutingAction.variables[effect.RecordVector] = {x = (target.position.x-ColonistProperties.entity.position.x)/ExecutingAction.duration, y = (target.position.y-ColonistProperties.entity.position.y)/ExecutingAction.duration}
   end,
   AnimateMove = function(ColonistProperties, ExecutingAction, effect)
      rendering.set_target(ExecutingAction.variables[effect.sprite], {ExecutingAction.variables[effect.start].x+(ExecutingAction.variables[effect.direction].x*(game.tick-ExecutingAction.StartTick)), ExecutingAction.variables[effect.start].y+(ExecutingAction.variables[effect.direction].y*(game.tick-ExecutingAction.StartTick))})
   end,
   ClearAnimation = function(ColonistProperties, ExecutingAction, effect)
      rendering.destroy(ExecutingAction.variables[effect.sprite])
   end,
   PlaySound = function(ColonistProperties, ExecutingAction, effect)
      local point = nil
      if (effect.position == nil) then
         point = ColonistProperties.entity.position
      else
         point = ExecutingAction.variables[effect.position]
      end
      ColonistProperties.entity.surface.play_sound{path=ExecutingAction.variables[effect.sound], position=point}
   end,
   ActivateLabs = function(ColonistProperties, ExecutingAction, effect)
      local SciCenter = ExecutingAction.variables[effect.SciCenter]
      local ConnectedLabs = global.workplaces[SciCenter.force.name][SciCenter.surface.name][SciCenter.unit_number].ConnectedLabs
      for each, lab in pairs(ConnectedLabs) do
         if (lab.valid == true and lab.active == false) then
            lab.active = true
            table.insert(ExecutingAction.variables[effect.record], lab)
         elseif (lab.valid == false) then
            global.workplaces[SciCenter.force.name][SciCenter.surface.name][SciCenter.unit_number].ConnectedLabs[each] = nil
         end
      end
   end,
   DeactivateLabs = function(ColonistProperties, ExecutingAction, effect)
      local SciCenter = ExecutingAction.variables[effect.SciCenter]
      local ConnectedLabs = global.workplaces[SciCenter.force.name][SciCenter.surface.name][SciCenter.unit_number].ConnectedLabs
      for each, lab in pairs(ConnectedLabs) do
         if (lab.valid) then
            lab.active = false
         else
            global.workplaces[SciCenter.force.name][SciCenter.surface.name][SciCenter.unit_number].ConnectedLabs[each] = nil
         end
      end
   end,
   CreateMiningParticle = function(ColonistProperties, ExecutingAction, effect)
      if (ExecutingAction.variables[effect.source].prototype.mineable_properties.mining_particle) then
         local particle = ExecutingAction.variables[effect.source].prototype.mineable_properties.mining_particle
         for i = 1, 2 do
            ColonistProperties.entity.surface.create_particle
               ({
                  name = particle,
                  position = ExecutingAction.variables.resource.position,
                  movement = {math.random(-10,10)*0.004, math.random(-10,10)*0.004},
                  height = 0,
                  vertical_speed = 0.05,
                  frame_speed = 1
               })
         end
      end
   end,
}

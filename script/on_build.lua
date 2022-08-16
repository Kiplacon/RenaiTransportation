-- defines.events.on_built_entity, --| built by hand ----
	-- created_entity :: LuaEntity
	-- player_index :: uint
	-- stack :: LuaItemStack
	-- item :: LuaItemPrototype (optional): The item prototype used to build the entity. Note this won't exist in some situations (built from blueprint, undo, etc).
	-- tags :: Tags (optional): The tags associated with this entity if any.
-- defines.events.script_raised_built, --| built by script ----
	-- entity :: LuaEntity
-- defines.events.on_entity_cloned, -- | cloned by script ----
	-- source :: LuaEntity
	-- destination :: LuaEntity
-- defines.events.on_robot_built_entity	-- | built by robot ----
	-- robot :: LuaEntity: The robot that did the building.
	-- created_entity :: LuaEntity: The entity built.
	-- stack :: LuaItemStack: The item used to do the building.
	-- tags :: Tags (optional): The tags associated with this entity if any.
local function on_build(event)
   local entity = event.entity or event.created_entity or event.destination
   local player = nil
   if event.player_index then
      player = game.players[event.player_index]
   elseif event.robot then
      player = event.robot.last_user
   end
   --by name
   if (entity.name ~= "SupplierPole") then
      -- check each tile it's sitting on
      -- if there's a SupplierPoleChest there, delete it
   end

   if (entity.name == "colonist") then
      local NewName = game.backer_names[math.random(#game.backer_names)]
      while global.TrackingLists.UsedNames[NewName] ~= nil do
         NewName = game.backer_names[math.random(#game.backer_names)]
      end
      global.TrackingLists.UsedNames[NewName] = "used"
      global.TrackingLists.NumberToColonistName[entity.unit_number] = NewName
      global.AllColonists[NewName] = {}
      global.AllColonists[NewName].name = NewName
      global.AllColonists[NewName].NameTag = rendering.draw_text{text=NewName, surface=entity.surface, target=entity, target_offset={0,-1.5}, color = {r=1, g=1, b=1, a=1}, alignment="center"}
      global.AllColonists[NewName].entity = entity
      global.AllColonists[NewName].GoalList = {
         prio1 = "EmptyHolding",
         prio2 = "HarvestAtTreeFarm",
         prio3 = "HarvestAtMine",
         prio4 = "Research",
         prio999 = "Idle"
      }
      global.AllColonists[NewName].ActionPlan = {state="planning", queue={}, AlreadyTried={}}
      global.AllColonists[NewName].holding = game.create_inventory(1)
      global.AllColonists[NewName].MovingTo = rendering.draw_line{color={r=0.5, a=0.5}, width=5, from=entity, to=entity, surface=entity.surface, only_in_alt_mode=true, render_layer=181}
      global.AllColonists[NewName].ActionTag = rendering.draw_text{text="Idling", surface=entity.surface, target=entity, target_offset={0,0.5}, color = {r=1, g=1, b=1, a=1}, alignment="center", only_in_alt_mode=true, players={"Kiplacon"}}
      global.AllColonists[NewName].ProgressBar = rendering.draw_arc{color={r=1, g=1, b=0, a=0.5}, max_radius=0.3, min_radius=0.2, start_angle=-math.pi/2, angle=0, target=entity, target_offset={0,-0.25}, surface=entity.surface, only_in_alt_mode=true}
      global.AllColonists[NewName].HoldingSprite = rendering.draw_sprite{sprite="FaPBlank", target=entity, target_offset={0,-0.25}, x_scale=0.5, y_scale=0.5, surface=entity.surface, render_layer=178}
      global.AllColonists[NewName].WorkingWith = {workplace="candice", activating={}}
      global.AllColonists[NewName].alive = true
      global.AllColonists[NewName].needs = {}
      global.AllColonists[NewName].health = {}
      --script.register_on_entity_destroyed(entity)
   elseif (entity.type == "entity-ghost" and entity.ghost_name == "SupplierPoleInterface") then
      local a, proxy, c = entity.silent_revive{}
      proxy.destructible = false

   elseif (global.ReferenceLists.workplaces[entity.name] or entity.type == "lab") then
      table.insert(GetOrRegisterClearOnDestroyList(entity), {type="GlobalWorkplace", force=entity.force.name, surface=entity.surface.name, number=entity.unit_number})
      global.workplaces[entity.force.name][entity.surface.name][entity.unit_number] = {entity=entity}
      local properties = global.workplaces[entity.force.name][entity.surface.name][entity.unit_number]

      if (entity.name == "FPAssemblyWorkstation") then
         properties.DropOffLinks = {}
      end
      if (entity.type == "lab") then
         global.workplaces[entity.force.name][entity.surface.name][entity.unit_number] = nil
         entity.active = false
         -- Connect to nearby science center
         local owo = entity.surface.find_entities_filtered
         {
            position = entity.position,
            radius = 10,
            name = "FPScienceCenter",
            force = entity.force
         }
         local distance = 20
         local closest = "sugondese"
         for each, result in pairs(owo) do
            if (DistanceBetween(entity.position, result.position) < distance and global.workplaces[result.force.name][result.surface.name][result.unit_number]) then
               distance = DistanceBetween(entity.position, result.position)
               closest = result
            end
         end
         if (closest ~= "sugondese") then
            global.workplaces[closest.force.name][closest.surface.name][closest.unit_number].ConnectedLabs[entity.unit_number]=entity
            rendering.draw_line{
               color = {0,1,0,0.5},
               width = 5,
               surface = closest.surface,
               from = closest,
               to = entity,
               time_to_live = 180
            }
            table.insert(global.TrackingLists.ClearOnDestroy[entity.unit_number], {type="LinkedSciCenter", force=closest.force.name, surface=closest.surface.name, number=closest.unit_number, lab=entity.unit_number})
         end
      end
      if (entity.name == "FPScienceCenter") then
         properties.ConnectedLabs = {}
         -- Search for nearby labs
         local owo = entity.surface.find_entities_filtered
         {
            position = entity.position,
            radius = 10,
            type = "lab",
            force = entity.force
         }
         -- check if each lab is already linked to a sci center
         for each, result in pairs(owo) do
            local linked = false
            for number, props in pairs(global.workplaces[entity.force.name][entity.surface.name]) do
               if (props.ConnectedLabs) then
                  for every, lab in pairs(props.ConnectedLabs) do
                     if (every == result.unit_number) then
                        linked = true
                     end
                  end
               end
            end
            -- link to this one if not already
            if (linked == false) then
               properties.ConnectedLabs[result.unit_number]=result
               rendering.draw_line{
                  color = {0,1,0,0.5},
                  width = 5,
                  surface = result.surface,
                  from = result,
                  to = entity,
                  time_to_live = 180
               }
               -- set clear for the sci center
               table.insert(global.TrackingLists.ClearOnDestroy[result.unit_number], {type="LinkedSciCenter", force=entity.force.name, surface=entity.surface.name, number=entity.unit_number, lab=result.unit_number})
            end
         end
      end

   elseif (entity.name == "ProviderPole") then
      global.PoleNetwork.ProviderPoles[entity.unit_number] = {entity=entity, requests={}}
      table.insert(GetOrRegisterClearOnDestroyList(entity), {type="ProviderPole", number=entity.unit_number})

   elseif (entity.name == "SupplierPole") then
      global.PoleNetwork.SupplierPoles[entity.unit_number] = {entity=entity, paths={}, PathsCalculated=false, analyzed={}}
      table.insert(GetOrRegisterClearOnDestroyList(entity), {type="SupplierPole", number=entity.unit_number})
      local proxy = entity.surface.find_entity("SupplierPoleInterface", entity.position)
      if (proxy == nil) then
         proxy = entity.surface.create_entity
         {
            name = "SupplierPoleInterface",
            position = entity.position,
            force = entity.force,
            create_build_effect_smoke = false
         }
      end
      proxy.destructible = false
      global.PoleNetwork.SupplierPoles[entity.unit_number].interface = proxy
      table.insert(GetOrRegisterClearOnDestroyList(entity), {type="entity", entity=proxy})
   end

end
return on_build

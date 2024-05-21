local cube_flying_items = require("script.ultracube.cube_flying_items")

local function on_tick(event)

   for each, FlyingItem in pairs(global.FlyingItems) do
      local clear = true

      if (FlyingItem.sprite and event.tick < FlyingItem.LandTick) then -- for now only impact unloader items have sprites and need animating like this
         local duration = event.tick-FlyingItem.StartTick
         local x_coord = FlyingItem.path[duration].x
         local y_coord = FlyingItem.path[duration].y
         local height = FlyingItem.path[duration].height
         local orientation = FlyingItem.spin*duration
         rendering.set_target(FlyingItem.sprite, {x_coord, y_coord + height})
         rendering.set_orientation(FlyingItem.sprite, orientation)
         if (FlyingItem.space == false) then
            rendering.set_target(FlyingItem.shadow, {x_coord - height, y_coord})
            rendering.set_orientation(FlyingItem.shadow, orientation)
         end

      elseif (event.tick == FlyingItem.LandTick and FlyingItem.space == false) then
         --game.print(each)
         local ThingLandedOn = FlyingItem.surface.find_entities_filtered
            {
               position = {math.floor(FlyingItem.target.x)+0.5, math.floor(FlyingItem.target.y)+0.5},
               collision_mask = "object-layer"
            }[1]
         local LandedOnCargoWagon = FlyingItem.surface.find_entities_filtered
               {
                  area = {{FlyingItem.target.x-0.5, FlyingItem.target.y-0.5}, {FlyingItem.target.x+0.5, FlyingItem.target.y+0.5}},
                  type = "cargo-wagon"
               }[1]
         -- landed on something
         if (ThingLandedOn) then
            if (string.find(ThingLandedOn.name, "BouncePlate")) then -- if that thing was a bounce plate
               if (FlyingItem.sprite) then -- from impact unloader
                  rendering.destroy(FlyingItem.sprite)
                  FlyingItem.sprite = nil
               end
               if (FlyingItem.shadow and FlyingItem.player == nil) then -- from impact unloader
                  rendering.destroy(FlyingItem.shadow)
                  FlyingItem.shadow = nil
               end
               clear = false
               local unitx = 1
               local unity = 1
               local effect = "BouncePlateParticle"
               if (string.find(ThingLandedOn.name, "DirectedBouncePlate")) then
                  unitx = global.OrientationUnitComponents[ThingLandedOn.orientation].x
                  unity = global.OrientationUnitComponents[ThingLandedOn.orientation].y
                  if (FlyingItem.player) then
                     global.AllPlayers[FlyingItem.player.index].PlayerLauncher.direction = global.OrientationUnitComponents[ThingLandedOn.orientation].name
                  end
               elseif (string.find(ThingLandedOn.name, "DirectorBouncePlate")) then
                  for each, parameter in pairs(ThingLandedOn.get_or_create_control_behavior().parameters) do
                     if (parameter.signal.type == "item" and parameter.signal.name == FlyingItem.item) then
                        if (parameter.index >= 1 and parameter.index <= 10) then
                           unitx = 0
                           unity = -1
                           effect = "BouncePlateParticlered"
                        elseif (parameter.index >= 11 and parameter.index <= 20) then
                           unitx = 1
                           unity = 0
                           effect = "BouncePlateParticlegreen"
                        elseif (parameter.index >= 21 and parameter.index <= 30) then
                           unitx = 0
                           unity = 1
                           effect = "BouncePlateParticleblue"
                        elseif (parameter.index >= 31 and parameter.index <= 40) then
                           unitx = -1
                           unity = 0
                           effect = "BouncePlateParticleyellow"
                        end
                        break
                     end
                  end
                  if (unitx == 1 and unity == 1) then -- if there is no matching signal
                     if (FlyingItem.start.y > FlyingItem.target.y
                     and math.abs(FlyingItem.start.y-FlyingItem.target.y) > math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                        unitx = 0
                        unity = -1
                     elseif (FlyingItem.start.y < FlyingItem.target.y
                     and math.abs(FlyingItem.start.y-FlyingItem.target.y) > math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                        unitx = 0
                        unity = 1
                     elseif (FlyingItem.start.x > FlyingItem.target.x
                     and math.abs(FlyingItem.start.y-FlyingItem.target.y) < math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                        unitx = -1
                        unity = 0
                     elseif (FlyingItem.start.x < FlyingItem.target.x
                     and math.abs(FlyingItem.start.y-FlyingItem.target.y) < math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                        unitx = 1
                        unity = 0
                     end
                  end
               elseif (string.find(ThingLandedOn.name, "BouncePlate")) then
                  ---- determine "From" direction ----
                  if (FlyingItem.start.y > FlyingItem.target.y
                  and math.abs(FlyingItem.start.y-FlyingItem.target.y) > math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                     unitx = 0
                     unity = -1
                  elseif (FlyingItem.start.y < FlyingItem.target.y
                  and math.abs(FlyingItem.start.y-FlyingItem.target.y) > math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                     unitx = 0
                     unity = 1
                  elseif (FlyingItem.start.x > FlyingItem.target.x
                  and math.abs(FlyingItem.start.y-FlyingItem.target.y) < math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                     unitx = -1
                     unity = 0
                  elseif (FlyingItem.start.x < FlyingItem.target.x
                  and math.abs(FlyingItem.start.y-FlyingItem.target.y) < math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                     unitx = 1
                     unity = 0
                  end
               end

               ---- Bounce modifiers ----
               -- Defaults --
               local primable = ""
               local range = 9.9
               local RangeBonus = 0
               local SidewaysShift = 0
               local tunez = "bounce"
               if (string.find(ThingLandedOn.name, "Train")) then
                  range = 39.9
               elseif (ThingLandedOn.name == "BouncePlate5" or ThingLandedOn.name == "DirectedBouncePlate5") then
                  range = 4.9
               elseif (ThingLandedOn.name == "BouncePlate15" or ThingLandedOn.name == "DirectedBouncePlate15") then
                  range = 14.9
               end

               -- Modifiers --
               if (ThingLandedOn.name == "PrimerBouncePlate" and FlyingItem.player == nil and game.entity_prototypes[FlyingItem.item.."-projectileFromRenaiTransportationPrimed"]) then
                  primable = "Primed"
                  RangeBonus = 30
                  tunez = "PrimeClick"
                  effect = "PrimerBouncePlateParticle"
               elseif (ThingLandedOn.name == "PrimerSpreadBouncePlate" and FlyingItem.player == nil and game.entity_prototypes[FlyingItem.item.."-projectileFromRenaiTransportationPrimed"]) then
                  primable = "Primed"
                  tunez = "PrimeClick"
                  effect = "PrimerBouncePlateParticle"
               elseif (ThingLandedOn.name == "SignalBouncePlate") then
                  ThingLandedOn.get_control_behavior().enabled = not ThingLandedOn.get_control_behavior().enabled
                  effect = "SignalBouncePlateParticle"
               end

               if (not FlyingItem.tracing) then --if its an item and not a tracer
                  ---- Creating the bounced thing ----
                  if (primable == "Primed") then
                     for kidamogus = 1, FlyingItem.amount do
                        if (ThingLandedOn.name == "PrimerSpreadBouncePlate") then
                           RangeBonus = math.random(270,300)*0.1
                           SidewaysShift = math.random(-200,200)*0.1
                        end
                        ThingLandedOn.surface.create_entity
                           ({
                              name = FlyingItem.item.."-projectileFromRenaiTransportation"..primable,
                              position = ThingLandedOn.position, --required setting for rendering, doesn't affect spawn
                              source = event.source_entity, --defaults to nil if there was no source_entity and uses source_position instead
                              source_position = ThingLandedOn.position,
                              target_position = {ThingLandedOn.position.x  +unitx*(range+RangeBonus)  +unity*(SidewaysShift), ThingLandedOn.position.y  +unity*(range+RangeBonus)  +unitx*(SidewaysShift)},
                              force = ThingLandedOn.force
                           })
                     end
                  else
                     local	TargetX = ThingLandedOn.position.x  +unitx*(range+RangeBonus)  +unity*(SidewaysShift)
                     local TargetY = ThingLandedOn.position.y  +unity*(range+RangeBonus)  +unitx*(SidewaysShift)
                     local distance = math.sqrt((TargetX-ThingLandedOn.position.x)^2 + (TargetY-ThingLandedOn.position.y)^2)
                     if (string.find(ThingLandedOn.name, "Train")) then
                        FlyingItem.speed = 0.6
                     else
                        FlyingItem.speed = 0.18
                     end
                     local AirTime = math.floor(distance/FlyingItem.speed)
                     FlyingItem.target={x=TargetX, y=TargetY}
                     FlyingItem.start=ThingLandedOn.position
                     FlyingItem.StartTick=game.tick
                     FlyingItem.AirTime=AirTime
                     FlyingItem.LandTick=game.tick+AirTime
                     if (FlyingItem.player == nil) then -- the player doesnt have a projectile sprite
                        if (game.entity_prototypes["RTItemProjectile-"..FlyingItem.item..FlyingItem.speed*100]) then
                           FlyingItem.surface.create_entity
                           {
                              name="RTItemProjectile-"..FlyingItem.item..FlyingItem.speed*100,
                              position=ThingLandedOn.position,
                              source_position=ThingLandedOn.position,
                              target_position={TargetX, TargetY}
                           }
                        else
                           FlyingItem.surface.create_entity
                           {
                              name="RTTestProjectile"..FlyingItem.speed*100,
                              position=ThingLandedOn.position,
                              source_position=ThingLandedOn.position,
                              target_position={TargetX, TargetY}
                           }
                        end

						-- (If applicable) Update Ultracube ownership token to keep its timeout set to just after each bounce
						if global.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
							remote.call("Ultracube", "update_ownership_token",
								FlyingItem.cube_token_id, -- Token id
								FlyingItem.AirTime+1, -- Timeout before Ultracube forces recovery. AirTime+1 as that's the exact tick where if there hasn't been an update call something must have gone wrong
								{
									surface = FlyingItem.surface,
									position = ThingLandedOn.position,
									-- TODO: Velocity parameter?
								}
							)
						end

                     else -- the player does have a vector
                        FlyingItem.vector = {x=TargetX-ThingLandedOn.position.x, y=TargetY-ThingLandedOn.position.y}
                     end

                  end
                  ThingLandedOn.surface.create_particle
                     ({
                     name = effect,
                     position = ThingLandedOn.position,
                     movement = {0,0},
                     height = 0,
                     vertical_speed = 0.1,
                     frame_speed = 1
                     })
                  ThingLandedOn.surface.play_sound
                     {
                        path = tunez,
                        position = ThingLandedOn.position,
                        volume = 0.7
                     }
               else --it is a tracer
               -- add the bounce pad to the bounce path list if its a tracer
                  if (primable ~= "Primed") then
                     if (global.ThrowerPaths[ThingLandedOn.unit_number] == nil) then
                        global.ThrowerPaths[ThingLandedOn.unit_number] = {}
                        global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing] = {}
                        global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing][FlyingItem.item] = true
                     elseif (global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing] == nil) then
                        global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing] = {}
                        global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing][FlyingItem.item] = true
                     else
                        global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing][FlyingItem.item] = true
                     end
                     script.register_on_entity_destroyed(ThingLandedOn)
                     local	x = ThingLandedOn.position.x  +unitx*(range+RangeBonus)  +unity*(SidewaysShift)
                     local y = ThingLandedOn.position.y  +unity*(range+RangeBonus)  +unitx*(SidewaysShift)
                     FlyingItem.target={x=x, y=y}
                     FlyingItem.start=ThingLandedOn.position
                     FlyingItem.StartTick=game.tick
                     FlyingItem.AirTime=1
                     FlyingItem.LandTick=game.tick+1
                  else
                     global.CatapultList[FlyingItem.tracing].ImAlreadyTracer = "traced"
                     global.CatapultList[FlyingItem.tracing].targets[FlyingItem.item] = "nothing"
                     clear = true
                  end
               end

            -- non-tracers falling on something
            elseif (FlyingItem.tracing == nil) then
               -- players falling on something
               if (FlyingItem.player) then
                  ---- Doesn't make sense for player landing on cliff to destroy it ----
                  if (ThingLandedOn.name == "cliff") then
                     FlyingItem.player.teleport(ThingLandedOn.surface.find_non_colliding_position("iron-chest", FlyingItem.target, 0, 0.5))
                  elseif (ThingLandedOn.name ~= "PlayerLauncher") then
                     ---- Damage the player based on thing's size and destroy what they landed on to prevent getting stuck ----
                     FlyingItem.player.character.damage(10*(ThingLandedOn.bounding_box.right_bottom.x-ThingLandedOn.bounding_box.left_top.x)*(ThingLandedOn.bounding_box.right_bottom.y-ThingLandedOn.bounding_box.left_top.y), "neutral", "impact", ThingLandedOn)
                     ThingLandedOn.die()
                  end
               -- items falling on something
               else
                  if (ThingLandedOn.name == "OpenContainer" and ThingLandedOn.can_insert({name=FlyingItem.item})) then
                     if (FlyingItem.CloudStorage) then
                        ThingLandedOn.insert(FlyingItem.CloudStorage[1])
                        FlyingItem.CloudStorage.destroy()
					 elseif global.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
						cube_flying_items.release_and_insert(FlyingItem, ThingLandedOn)
                     else
                        ThingLandedOn.insert({name=FlyingItem.item, count=FlyingItem.amount})
                     end
                     ThingLandedOn.surface.play_sound
                        {
                           path = "RTClunk",
                           position = ThingLandedOn.position,
                           volume_modifier = 0.9
                        }

                  ---- If the thing it landed on has an inventory and a hatch, insert the item ----
                  elseif (ThingLandedOn.surface.find_entity('HatchRT', {math.floor(FlyingItem.target.x)+0.5, math.floor(FlyingItem.target.y)+0.5}) and ThingLandedOn.can_insert({name=FlyingItem.item})) then
                     if (FlyingItem.CloudStorage) then
                        ThingLandedOn.insert(FlyingItem.CloudStorage[1])
                        FlyingItem.CloudStorage.destroy()
					 elseif global.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
						cube_flying_items.release_and_insert(FlyingItem, ThingLandedOn)
                     else
                        ThingLandedOn.insert({name=FlyingItem.item, count=FlyingItem.amount})
                     end
                     ThingLandedOn.surface.play_sound
                        {
                           path = "RTClunk",
                           position = ThingLandedOn.position,
                           volume_modifier = 0.7
                        }

                  ---- If it landed on something but there's also a cargo wagon there
                  elseif (LandedOnCargoWagon ~= nil and LandedOnCargoWagon.can_insert({name=FlyingItem.item})) then
                     if (FlyingItem.CloudStorage) then
                        LandedOnCargoWagon.insert(FlyingItem.CloudStorage[1])
                        FlyingItem.CloudStorage.destroy()
					 elseif global.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
						cube_flying_items.release_and_insert(FlyingItem, LandedOnCargoWagon)
                     else
                        LandedOnCargoWagon.insert({name=FlyingItem.item, count=FlyingItem.amount})
                     end

				  -- If it's an Ultracube FlyingItem, just spill it near whatever it landed on, potentially onto a belt
				  elseif global.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
					cube_flying_items.release_and_spill(FlyingItem, ThingLandedOn)

                  ---- otherwise it bounces off whatever it landed on and lands as an item on the nearest empty space within 10 tiles. destroyed if no space ----
                  else
                     if (FlyingItem.CloudStorage) then -- for things with data/tags or whatever, should only ever be 1 in stack
                        if (ThingLandedOn.type == "transport-belt") then
                           for l = 1, 2 do
                              for i = 0, 0.9, 0.1 do
                                 if (FlyingItem.CloudStorage[1].count > 0 and ThingLandedOn.get_transport_line(l).can_insert_at(i) == true) then
                                    ThingLandedOn.get_transport_line(l).insert_at(i, FlyingItem.CloudStorage[1])
                                    FlyingItem.CloudStorage[1].count = FlyingItem.CloudStorage[1].count - 1
                                 end
                              end
                           end
                        end
                        FlyingItem.CloudStorage.destroy()
                     else -- depreciated drop method from old item tracking system
                        local total = FlyingItem.amount
                        if (ThingLandedOn.type == "transport-belt") then
                           for l = 1, 2 do
                              for i = 0, 0.9, 0.1 do
                                 if (total > 0 and ThingLandedOn.get_transport_line(l).can_insert_at(i) == true) then
                                    ThingLandedOn.get_transport_line(l).insert_at(i, {name=FlyingItem.item, count=1})
                                    total = total - 1
                                 end
                              end
                           end
                        end
                        if (total > 0) then
                           if (settings.global["RTSpillSetting"].value == "Destroy") then
                              FlyingItem.surface.pollute(FlyingItem.target, total*0.5)
                              FlyingItem.surface.create_entity
                              ({
                                 name = "water-splash",
                                 position = FlyingItem.target
                              })
                           else
                              local spilt = FlyingItem.surface.spill_item_stack
                              (
                                 FlyingItem.surface.find_non_colliding_position("item-on-ground",FlyingItem.target, 500, 0.1),
                                 {name=FlyingItem.item, count=total}
                              )
                              if (settings.global["RTSpillSetting"].value == "Spill and Mark") then
                                 for every, thing in pairs(spilt) do
                                    thing.order_deconstruction("player")
                                 end
                              end
                           end
                        end
                        
                     end

                  end
               end
            -- tracers falling on something
            else
               if (global.CatapultList[FlyingItem.tracing]) then
                  if (LandedOnCargoWagon) then
                     global.CatapultList[FlyingItem.tracing].targets[FlyingItem.item] = LandedOnCargoWagon
                     if (global.ThrowerPaths[LandedOnCargoWagon.unit_number] == nil) then
                        global.ThrowerPaths[LandedOnCargoWagon.unit_number] = {}
                        global.ThrowerPaths[LandedOnCargoWagon.unit_number][FlyingItem.tracing] = {}
                        global.ThrowerPaths[LandedOnCargoWagon.unit_number][FlyingItem.tracing][FlyingItem.item] = true
                     elseif (global.ThrowerPaths[LandedOnCargoWagon.unit_number][FlyingItem.tracing] == nil) then
                        global.ThrowerPaths[LandedOnCargoWagon.unit_number][FlyingItem.tracing] = {}
                        global.ThrowerPaths[LandedOnCargoWagon.unit_number][FlyingItem.tracing][FlyingItem.item] = true
                     else
                        global.ThrowerPaths[LandedOnCargoWagon.unit_number][FlyingItem.tracing][FlyingItem.item] = true
                     end
                     script.register_on_entity_destroyed(LandedOnCargoWagon)
                  elseif (ThingLandedOn.unit_number == nil) then -- cliffs/trees/other things without unit_numbers
                     global.CatapultList[FlyingItem.tracing].targets[FlyingItem.item] = "nothing"
                  else
                     global.CatapultList[FlyingItem.tracing].targets[FlyingItem.item] = ThingLandedOn
                     if (global.ThrowerPaths[ThingLandedOn.unit_number] == nil) then
                        global.ThrowerPaths[ThingLandedOn.unit_number] = {}
                        global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing] = {}
                        global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing][FlyingItem.item] = true
                     elseif (global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing] == nil) then
                        global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing] = {}
                        global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing][FlyingItem.item] = true
                     else
                        global.ThrowerPaths[ThingLandedOn.unit_number][FlyingItem.tracing][FlyingItem.item] = true
                     end
                     script.register_on_entity_destroyed(ThingLandedOn)
                  end
                  global.CatapultList[FlyingItem.tracing].ImAlreadyTracer = "traced"
               end
            end

         -- didn't land on anything
         elseif (FlyingItem.tracing == nil) then -- thrown items
            local ProjectileSurface = FlyingItem.surface
            if (ProjectileSurface.find_tiles_filtered{position = FlyingItem.target, radius = 1, limit = 1, collision_mask = "player-layer"}[1] ~= nil) then -- in theory, tiles the player cant walk on are some sort of fluid or other non-survivable ground
               ProjectileSurface.create_entity
                  ({
                     name = "water-splash",
                     position = FlyingItem.target
                  })
               if (FlyingItem.player) then
                  FlyingItem.player.character.die()
               else
                  if (FlyingItem.item == "raw-fish") then
                     for i = 1, math.floor(FlyingItem.amount/5) do
                        ProjectileSurface.create_entity
                        {
                           name = "fish",
                           position = FlyingItem.target,
                        }
                     end
                  elseif ((FlyingItem.item == "ironclad" or FlyingItem.item == "ironclad-ironclad-mortar" or FlyingItem.item == "ironclad-ironclad-cannon") and script.active_mods["aai-vehicles-ironclad"] and ProjectileSurface.can_place_entity{name="ironclad", position=FlyingItem.target} == true) then
                     ProjectileSurface.create_entity
                     {
                        name = FlyingItem.item,
                        position = FlyingItem.target,
                        force = "player",
                        raise_built = true
                     }
				  elseif global.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
					cube_flying_items.panic(FlyingItem) -- Purposefully resort to Ultracube forced recovery
                  else
                     ProjectileSurface.pollute(FlyingItem.target, FlyingItem.amount*0.5)
                  end

                  if (FlyingItem.CloudStorage) then
                     FlyingItem.CloudStorage.destroy()
                  end
               end
            else
               if (FlyingItem.player == nil) then
                  if (FlyingItem.CloudStorage) then
                     local spilt = ProjectileSurface.spill_item_stack
                        (
                           ProjectileSurface.find_non_colliding_position("item-on-ground", FlyingItem.target, 500, 0.1),
                           FlyingItem.CloudStorage[1]
                        )
                     if (settings.global["RTSpillSetting"].value == "Spill and Mark") then
                        for every, thing in pairs(spilt) do
                           thing.order_deconstruction("player")
                        end
                     end
                     FlyingItem.CloudStorage.destroy()
				  elseif global.Ultracube and FlyingItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
					 cube_flying_items.release_and_spill(FlyingItem)
                  else
                     local spilt = ProjectileSurface.spill_item_stack
                        (
                           ProjectileSurface.find_non_colliding_position("item-on-ground", FlyingItem.target, 500, 0.1),
                           {name=FlyingItem.item, count=FlyingItem.amount}
                        )
                     if (settings.global["RTSpillSetting"].value == "Spill and Mark") then
                        for every, thing in pairs(spilt) do
                           thing.order_deconstruction("player")
                        end
                     end
                  end
               end
            end

         -- tracer
         elseif (FlyingItem.tracing ~= nil and global.CatapultList[FlyingItem.tracing]) then
            --game.print(FlyingItem.tracing)
            global.CatapultList[FlyingItem.tracing].ImAlreadyTracer = "traced"
            global.CatapultList[FlyingItem.tracing].targets[FlyingItem.item] = "nothing"

         end


         if (clear == true) then
            if (FlyingItem.tracing == nil and FlyingItem.destination ~= nil and global.OnTheWay[FlyingItem.destination]) then
               global.OnTheWay[FlyingItem.destination][FlyingItem.item] = global.OnTheWay[FlyingItem.destination][FlyingItem.item] - FlyingItem.amount
            end
            if (FlyingItem.player) then
               SwapBackFromGhost(FlyingItem.player, FlyingItem)
            end
            if (FlyingItem.sprite) then -- from impact unloader
               rendering.destroy(FlyingItem.sprite)
            end
            if (FlyingItem.shadow) then -- from impact unloader
               rendering.destroy(FlyingItem.shadow)
            end
            global.FlyingItems[each] = nil
         end

      elseif (event.tick == FlyingItem.LandTick and FlyingItem.space == true) then
         if (FlyingItem.sprite) then -- from impact unloader/space throw
            rendering.destroy(FlyingItem.sprite)
         end
         if (FlyingItem.shadow) then -- from impact unloader/space throw
            rendering.destroy(FlyingItem.shadow)
         end
         global.FlyingItems[each] = nil
--[[       elseif (game.tick > FlyingItem.LandTick) then
         if (FlyingItem.sprite) then
            --rendering.destroy(FlyingItem.sprite)
            --rendering.destroy(FlyingItem.shadow)
         end
         if (FlyingItem.destination ~= nil and global.OnTheWay[FlyingItem.destination]) then
            global.OnTheWay[FlyingItem.destination][FlyingItem.item] = global.OnTheWay[FlyingItem.destination][FlyingItem.item] - FlyingItem.amount
         end
         if (FlyingItem.player) then
            SwapBackFromGhost(FlyingItem.player, FlyingItem)
         end
         global.FlyingItems[each] = nil ]]
      end

   end
end

return on_tick

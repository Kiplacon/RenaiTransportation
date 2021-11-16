
local function on_tick(event)

   for each, FlyingItem in pairs(global.FlyingItems) do
      local clear = true
      if (game.tick < FlyingItem.LandTick and FlyingItem.player == nil) then
         local duration = game.tick-FlyingItem.StartTick
         local progress = duration/FlyingItem.AirTime
         local height = (duration/(FlyingItem.arc*FlyingItem.AirTime))-(duration^2/(FlyingItem.arc*FlyingItem.AirTime^2))
         rendering.set_target(FlyingItem.sprite, {FlyingItem.start.x+(progress*FlyingItem.vector.x), FlyingItem.start.y+(progress*FlyingItem.vector.y)+height})
         rendering.set_target(FlyingItem.shadow, {FlyingItem.start.x+(progress*FlyingItem.vector.x)-height, FlyingItem.start.y+(progress*FlyingItem.vector.y)})
         rendering.set_orientation(FlyingItem.sprite, rendering.get_orientation(FlyingItem.sprite)+FlyingItem.spin)
         rendering.set_orientation(FlyingItem.shadow, rendering.get_orientation(FlyingItem.shadow)+FlyingItem.spin)

      elseif (game.tick == FlyingItem.LandTick) then
         local ThingLandedOn = rendering.get_surface(FlyingItem.sprite).find_entities_filtered
            {
               position = {math.floor(FlyingItem.target.x)+0.5, math.floor(FlyingItem.target.y)+0.5},
               collision_mask = "object-layer"
            }[1]
         local LandedOnCargoWagon = rendering.get_surface(FlyingItem.sprite).find_entities_filtered
               {
                  area = {{FlyingItem.target.x-0.5, FlyingItem.target.y-0.5}, {FlyingItem.target.x+0.5, FlyingItem.target.y+0.5}},
                  type = "cargo-wagon"
               }[1]
         -- landed on something
         if (ThingLandedOn) then
            if (string.find(ThingLandedOn.name, "BouncePlate")) then -- if that thing was a bounce plate
               local unitx = 1
               local unity = 1
               if (string.find(ThingLandedOn.name, "DirectedBouncePlate")) then
                  unitx = global.OrientationUnitComponents[ThingLandedOn.orientation].x
                  unity = global.OrientationUnitComponents[ThingLandedOn.orientation].y
                  traveling = global.OrientationUnitComponents[ThingLandedOn.orientation].name
                  if (FlyingItem.player) then
                     global.AllPlayers[FlyingItem.player.index].direction = global.OrientationUnitComponents[ThingLandedOn.orientation].name
                  end
               else
                  ---- "From" details ----
                  ---- I set thrown things to have a range just short of dead center to detect what direction they came from ----
                  if (FlyingItem.start.y > FlyingItem.target.y
                  and math.abs(FlyingItem.start.y-FlyingItem.target.y) > math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                     unitx = 0
                     unity = -1
                     traveling = "up"
                  elseif (FlyingItem.start.y < FlyingItem.target.y
                  and math.abs(FlyingItem.start.y-FlyingItem.target.y) > math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                     unitx = 0
                     unity = 1
                     traveling = "down"
                  elseif (FlyingItem.start.x > FlyingItem.target.x
                  and math.abs(FlyingItem.start.y-FlyingItem.target.y) < math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                     unitx = -1
                     unity = 0
                     traveling = "left"
                  elseif (FlyingItem.start.x < FlyingItem.target.x
                  and math.abs(FlyingItem.start.y-FlyingItem.target.y) < math.abs(FlyingItem.start.x-FlyingItem.target.x)) then
                     unitx = 1
                     unity = 0
                     traveling = "right"
                  end
               end

               ---- Bounce modifiers ----
               -- Defaults --
               primable = ""
               range = 9.9
               RangeBonus = 0
               SidewaysShift = 0
               tunez = "bounce"
               effect = "BouncePlateParticle"

               -- Modifiers --
               if (ThingLandedOn.name == "PrimerBouncePlate" and game.entity_prototypes[FlyingItem.item.."-projectileFromRenaiTransportationPrimed"]) then
               	primable = "Primed"
               	RangeBonus = 30
               	tunez = "PrimeClick"
               	effect = "PrimerBouncePlateParticle"
               elseif (ThingLandedOn.name == "PrimerSpreadBouncePlate" and game.entity_prototypes[FlyingItem.item.."-projectileFromRenaiTransportationPrimed"]) then
               	primable = "Primed"
               	RangeBonus = math.random(270,300)*0.1
               	SidewaysShift = math.random(-200,200)*0.1
               	tunez = "PrimeClick"
               	effect = "PrimerBouncePlateParticle"
               elseif (ThingLandedOn.name == "SignalBouncePlate") then
               	ThingLandedOn.get_control_behavior().enabled = not ThingLandedOn.get_control_behavior().enabled
               	effect = "SignalBouncePlateParticle"
               end

               ---- Creating the bounced thing ----
               if (primable == "Primed") then
                  ThingLandedOn.surface.create_entity
                  	({
                     	name = FlyingItem.item.."-projectileFromRenaiTransportation"..primable,
                     	position = ThingLandedOn.position, --required setting for rendering, doesn't affect spawn
                     	source = event.source_entity, --defaults to nil if there was no source_entity and uses source_position instead
                     	source_position = ThingLandedOn.position,
                     	target_position = {ThingLandedOn.position.x  +unitx*(range+RangeBonus)  +unity*(SidewaysShift), ThingLandedOn.position.y  +unity*(range+RangeBonus)  +unitx*(SidewaysShift)},
                     	force = ThingLandedOn.force
                  	})

               else
                  local	x = ThingLandedOn.position.x  +unitx*(range+RangeBonus)  +unity*(SidewaysShift)
                  local y = ThingLandedOn.position.y  +unity*(range+RangeBonus)  +unitx*(SidewaysShift)
                  local distance = math.sqrt((x-ThingLandedOn.position.x)^2 + (y-ThingLandedOn.position.y)^2)
                  local speed = FlyingItem.speed
                  local AirTime = math.floor(distance/speed)
                  local vector = {x=x-ThingLandedOn.position.x, y=y-ThingLandedOn.position.y}
                  FlyingItem.target={x=x, y=y}
                  FlyingItem.start=ThingLandedOn.position
                  FlyingItem.StartTick=game.tick
                  if (FlyingItem.tracing == nil) then
                     FlyingItem.AirTime=AirTime
                     FlyingItem.arc = -0.1
                     FlyingItem.LandTick=game.tick+AirTime
                  else
                     FlyingItem.AirTime=1
                     FlyingItem.LandTick=game.tick+1
                  end
                  FlyingItem.vector=vector
               end

               if (not FlyingItem.tracing) then
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
               end
               clear = false

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
                     ThingLandedOn.insert({name=FlyingItem.item, count=FlyingItem.amount})

                  ---- If the thing it landed on has an inventory and a hatch, insert the item ----
                  elseif (ThingLandedOn.surface.find_entity('HatchRT', {math.floor(FlyingItem.target.x)+0.5, math.floor(FlyingItem.target.y)+0.5}) and ThingLandedOn.can_insert({name=FlyingItem.item})) then
                     ThingLandedOn.insert({name=FlyingItem.item, count=FlyingItem.amount})

                  ---- If it landed on something but there's also a cargo wagon there
                  elseif (LandedOnCargoWagon ~= nil and LandedOnCargoWagon.can_insert({name=FlyingItem.item})) then
                     LandedOnCargoWagon.insert({name=FlyingItem.item, count=FlyingItem.amount})

                  ---- otherwise it bounces off whatever it landed on and lands as an item on the nearest empty space within 10 tiles. destroyed if no space ----
                  else
                     rendering.get_surface(FlyingItem.sprite).spill_item_stack
                        (
                           rendering.get_surface(FlyingItem.sprite).find_non_colliding_position("item-on-ground",FlyingItem.target, 0, 0.1),
                           {name=FlyingItem.item, count=FlyingItem.amount}
                        )

                  end
               end
            -- tracers falling on something
            else
               if (global.CatapultList[FlyingItem.tracing]) then
                  global.CatapultList[FlyingItem.tracing].target = ThingLandedOn
                  script.register_on_entity_destroyed(ThingLandedOn)
                  global.CatapultList[FlyingItem.tracing].ImAlreadyTracer = "traced"
               end
            end
         -- didn't land on anything
         -- non-tracers
         elseif (FlyingItem.tracing == nil) then
            if (rendering.get_surface(FlyingItem.sprite).find_tiles_filtered{position = FlyingItem.target, radius = 1, limit = 1, collision_mask = "player-layer"}[1] ~= nil) then -- in theory, tiles the player cant walk on are some sort of fluid or other non-survivable ground
      			rendering.get_surface(FlyingItem.sprite).create_entity
      				({
      					name = "water-splash",
      					position = FlyingItem.target
      				})
               if (FlyingItem.player) then
                  FlyingItem.player.character.die()
               else
                  rendering.get_surface(FlyingItem.sprite).pollute(FlyingItem.target, FlyingItem.amount*0.5)
               end
            else
               if (FlyingItem.player == nil) then
                  rendering.get_surface(FlyingItem.sprite).spill_item_stack
                     (
                        rendering.get_surface(FlyingItem.sprite).find_non_colliding_position("item-on-ground", FlyingItem.target, 0, 0.1),
                        {name=FlyingItem.item, count=FlyingItem.amount}
                     )
               end
            end
         -- tracer
         elseif (FlyingItem.tracing ~= nil and global.CatapultList[FlyingItem.tracing]) then
            --game.print(FlyingItem.tracing)
            global.CatapultList[FlyingItem.tracing].ImAlreadyTracer = "traced"
            global.CatapultList[FlyingItem.tracing].target = "nothing"
         end
         if (clear == true) then
            rendering.destroy(FlyingItem.sprite)
            rendering.destroy(FlyingItem.shadow)
            global.FlyingItems[each] = nil
            if (FlyingItem.destination ~= nil and global.OnTheWay[FlyingItem.destination]) then
               global.OnTheWay[FlyingItem.destination][FlyingItem.item] = global.OnTheWay[FlyingItem.destination][FlyingItem.item] - FlyingItem.amount
            end
            if (FlyingItem.player) then
               global.AllPlayers[FlyingItem.player.index].jumping = nil
               global.AllPlayers[FlyingItem.player.index] = {}
               if (FlyingItem.player.character) then
                  local OG2 = FlyingItem.player.character
                  FlyingItem.SwapBack.teleport(FlyingItem.player.position)
                  FlyingItem.player.character = FlyingItem.SwapBack
                  FlyingItem.SwapBack.direction = OG2.direction
                  for i = 1, #OG2.get_main_inventory() do
                     FlyingItem.player.character.get_main_inventory().insert(OG2.get_main_inventory()[i])
                  end
                  for i = 1, #OG2.get_inventory(defines.inventory.character_guns) do
                     FlyingItem.player.character.get_inventory(defines.inventory.character_guns).insert(OG2.get_inventory(defines.inventory.character_guns)[i])
                  end
                  for i = 1, #OG2.get_inventory(defines.inventory.character_ammo) do
                     FlyingItem.player.character.get_inventory(defines.inventory.character_ammo).insert(OG2.get_inventory(defines.inventory.character_ammo)[i])
                  end
                  for i = 1, #OG2.get_inventory(defines.inventory.character_armor) do
                     FlyingItem.player.character.get_inventory(defines.inventory.character_armor).insert(OG2.get_inventory(defines.inventory.character_armor)[i])
                  end
                  for i = 1, #OG2.get_inventory(defines.inventory.character_trash) do
                     FlyingItem.player.character.get_inventory(defines.inventory.character_trash).insert(OG2.get_inventory(defines.inventory.character_trash)[i])
                  end
                  FlyingItem.SwapBack.destructible = true
                  FlyingItem.SwapBack.health = OG2.health
                  FlyingItem.SwapBack.selected_gun_index = OG2.selected_gun_index
                  FlyingItem.player.character_running_speed_modifier = 0
                  OG2.destroy()
               else
                  --FlyingItem.SwapBack.teleport(FlyingItem.player.position)
                  FlyingItem.SwapBack.destructible = true
                  FlyingItem.SwapBack.destroy()
               end
            end
         end
      end

   end
end

return on_tick

--======= util.swap_entity_inventories and swap_inventories method copied from the Jetpacks mod cause this somehow preserves blueprints in the quickbar
--https://mods.factorio.com/mod/jetpack
function util.swap_entity_inventories(entity_a, entity_b, inventory)
  swap_inventories(entity_a.get_inventory(inventory), entity_b.get_inventory(inventory))
end
function swap_inventories(inv_a, inv_b)
  if inv_a.is_filtered() then
    for i = 1, math.min(#inv_a, #inv_b) do
      inv_b.set_filter(i, inv_a.get_filter(i))
    end
  end
  for i = 1, math.min(#inv_a, #inv_b)do
    inv_b[i].swap_stack(inv_a[i])
  end
end
--=============================================================================================

---- ziplines and player launchers swap the character with a collision immune copy
function SwapToGhost(player)
	-------------- create ghost copy ---------------
	local OG = player.character
	OG.destructible = false
   local NEWHOST = OG.surface.create_entity{
      name = OG.name.."RTGhost",
      position = OG.position,
      force = OG.force,
      direction = OG.direction
   }
   local zhonyas = OG.surface.create_entity{
      name = "RTPropCar",
      position = OG.position,
      force = OG.force
   }
	NEWHOST.health = OG.health
	NEWHOST.selected_gun_index = OG.selected_gun_index
	------ modifiers --------
	local CharacterModifiers = {
		"character_crafting_speed_modifier",
		"character_inventory_slots_bonus",
		"character_mining_speed_modifier",
		"character_additional_mining_categories",
		"character_build_distance_bonus",
		"character_item_drop_distance_bonus",
		"character_reach_distance_bonus",
		"character_resource_reach_distance_bonus",
		"character_item_pickup_distance_bonus",
		"character_loot_pickup_distance_bonus",
		"character_trash_slot_count_bonus",
		"character_maximum_following_robot_count_bonus",
		"character_health_bonus",
      "allow_dispatching_robots"
	}
	for each, modifier in pairs(CharacterModifiers) do
		NEWHOST[modifier] = OG[modifier]
	end
   NEWHOST.get_requester_point().enabled = OG.get_requester_point().enabled
   NEWHOST.get_requester_point().trash_not_requested = OG.get_requester_point().trash_not_requested
	------ undo crafting queue -------
	local TheList = nil
	if (OG.crafting_queue) then
		TheList = {}
		for i = OG.crafting_queue_size, 1, -1 do
			if OG.crafting_queue and OG.crafting_queue[i] then
				table.insert(TheList, OG.crafting_queue[i])
				OG.cancel_crafting(OG.crafting_queue[i])
			end
		end
	end

	------ move items ----------
	OG.character_inventory_slots_bonus = OG.character_inventory_slots_bonus+10000 -- hopefully offset losing armor inventory bonuses
	for i = 1, #OG.get_inventory(defines.inventory.character_armor) do
		NEWHOST.get_inventory(defines.inventory.character_armor).insert(OG.get_inventory(defines.inventory.character_armor)[i])
	end
	util.swap_entity_inventories(OG, NEWHOST, defines.inventory.character_main)
	util.swap_entity_inventories(OG, NEWHOST, defines.inventory.character_guns)
	util.swap_entity_inventories(OG, NEWHOST, defines.inventory.character_ammo)
	util.swap_entity_inventories(OG, NEWHOST, defines.inventory.character_trash)
	OG.get_main_inventory().clear()
	OG.get_inventory(defines.inventory.character_guns).clear()
	OG.get_inventory(defines.inventory.character_ammo).clear()
	OG.get_inventory(defines.inventory.character_armor).clear()
	OG.get_inventory(defines.inventory.character_trash).clear()
   NEWHOST.cursor_stack.transfer_stack(OG.cursor_stack)
   --[[ for i = 1, OG.request_slot_count do
      local thing = OG.get_personal_logistic_slot(i)
      NEWHOST.set_personal_logistic_slot(i, thing)
      OG.clear_personal_logistic_slot(i)
   end ]]
	---------- redo crafting queue -----------
	if (TheList ~= nil) then
		for i = #TheList, 1, -1 do
			local crafting = TheList[i]
			if crafting then
				crafting.silent = true
				NEWHOST.begin_crafting(crafting)
			end
		end
	end
   ---------- move robot ownership ----------
   for each, bot in pairs(OG.following_robots) do
      bot.combat_robot_owner = NEWHOST
   end
   local spidies = NEWHOST.surface.find_entities_filtered{
      position = NEWHOST.position,
      radius = 100,
      type = "spider-vehicle"
   }
   for each, spider in pairs(spidies) do
      if (spider.follow_target == OG) then
         spider.follow_target = NEWHOST
      end
   end
   ---------- swap control -----------------
	player.set_controller{type=defines.controllers.character, character=NEWHOST}
   if (remote.interfaces.jetpack and remote.interfaces.jetpack.block_jetpack) then
      remote.call("jetpack", "block_jetpack", {character=NEWHOST})
   end
   if (remote.interfaces["space-exploration"] and remote.interfaces["space-exploration"].on_character_swapped) then
      remote.call("space-exploration", "on_character_swapped", {new_character=NEWHOST,old_character=OG})
   end
   zhonyas.set_driver(OG)
   zhonyas.force = "enemy"
   zhonyas.destructible = false
	return OG
end

---- swapping back from character ghost copy from using the ziplines or player launcher
function SwapBackFromGhost(player, FlyingItem)
	if (FlyingItem) then
		storage.AllPlayers[FlyingItem.player.index].state = "default"
      storage.AllPlayers[FlyingItem.player.index].PlayerLauncher = {}
		if (FlyingItem.player.character) then
			local OG2 = FlyingItem.player.character
         FlyingItem.SwapBack.vehicle.destroy()
			FlyingItem.SwapBack.teleport(FlyingItem.player.position)
			FlyingItem.player.character = FlyingItem.SwapBack
			FlyingItem.SwapBack.direction = OG2.direction
			------ undo crafting queue -------
			local TheList = nil
			if (OG2.crafting_queue) then
				TheList = {}
				for i = OG2.crafting_queue_size, 1, -1 do
					if OG2.crafting_queue and OG2.crafting_queue[i] then
						table.insert(TheList, OG2.crafting_queue[i])
						OG2.cancel_crafting(OG2.crafting_queue[i])
					end
				end
			end
			------ swap inventories ---------
			util.swap_entity_inventories(OG2, FlyingItem.SwapBack, defines.inventory.character_main)
			util.swap_entity_inventories(OG2, FlyingItem.SwapBack, defines.inventory.character_guns)
			util.swap_entity_inventories(OG2, FlyingItem.SwapBack, defines.inventory.character_ammo)
			util.swap_entity_inventories(OG2, FlyingItem.SwapBack, defines.inventory.character_trash)
			for i = 1, #OG2.get_inventory(defines.inventory.character_armor) do
				FlyingItem.player.character.get_inventory(defines.inventory.character_armor).insert(OG2.get_inventory(defines.inventory.character_armor)[i])
			end
         player.character.cursor_stack.transfer_stack(OG2.cursor_stack)
			FlyingItem.SwapBack.character_inventory_slots_bonus = FlyingItem.SwapBack.character_inventory_slots_bonus-10000
         --[[ for i = 1, OG2.request_slot_count do
            local thing = OG2.get_personal_logistic_slot(i)
            FlyingItem.SwapBack.set_personal_logistic_slot(i, thing)
            OG2.clear_personal_logistic_slot(i)
         end ]]
			---------- redo crafting queue -----------
			if (TheList ~= nil) then
				for i = #TheList, 1, -1 do
					local crafting = TheList[i]
					if crafting then
						crafting.silent = true
						player.character.begin_crafting(crafting)
					end
				end
			end
         ---------- move robot ownership ----------
         for each, bot in pairs(OG2.following_robots) do
            bot.combat_robot_owner = FlyingItem.SwapBack
         end
         local spidies = OG2.surface.find_entities_filtered{
            position = OG2.position,
            radius = 100,
            type = "spider-vehicle"
         }
         for each, spider in pairs(spidies) do
            if (spider.follow_target == OG2) then
               spider.follow_target = FlyingItem.SwapBack
            end
         end
			FlyingItem.SwapBack.destructible = true
			FlyingItem.SwapBack.health = OG2.health
			FlyingItem.SwapBack.selected_gun_index = OG2.selected_gun_index
         ------ modifiers --------
         local CharacterModifiers = {
            "character_crafting_speed_modifier",
            "character_inventory_slots_bonus",
            "character_mining_speed_modifier",
            "character_additional_mining_categories",
            "character_build_distance_bonus",
            "character_item_drop_distance_bonus",
            "character_reach_distance_bonus",
            "character_resource_reach_distance_bonus",
            "character_item_pickup_distance_bonus",
            "character_loot_pickup_distance_bonus",
            "character_trash_slot_count_bonus",
            "character_maximum_following_robot_count_bonus",
            "character_health_bonus",
            "allow_dispatching_robots"
         }
         for each, modifier in pairs(CharacterModifiers) do
            OG2[modifier] = FlyingItem.SwapBack[modifier]
         end
         FlyingItem.SwapBack.get_requester_point().enabled = OG2.get_requester_point().enabled
         FlyingItem.SwapBack.get_requester_point().trash_not_requested = OG2.get_requester_point().trash_not_requested
         if (remote.interfaces["space-exploration"] and remote.interfaces["space-exploration"].on_character_swapped) then
            remote.call("space-exploration", "on_character_swapped", {new_character=FlyingItem.SwapBack,old_character=OG2})
         end
			OG2.destroy()
		else
			FlyingItem.SwapBack.destructible = true
			FlyingItem.SwapBack.destroy()
		end

	elseif (player.character) then
		local PlayerProperties = storage.AllPlayers[player.index]
		local OG2 = player.character
      PlayerProperties.SwapBack.vehicle.destroy()
		PlayerProperties.SwapBack.teleport(player.position)
		player.character = PlayerProperties.SwapBack
		PlayerProperties.SwapBack.direction = OG2.direction
		------ undo crafting queue -------
		local TheList = nil
		if (OG2.crafting_queue) then
			TheList = {}
			for i = OG2.crafting_queue_size, 1, -1 do
				if OG2.crafting_queue and OG2.crafting_queue[i] then
					table.insert(TheList, OG2.crafting_queue[i])
					OG2.cancel_crafting(OG2.crafting_queue[i])
				end
			end
		end
		------ swap inventories ---------
		util.swap_entity_inventories(OG2, PlayerProperties.SwapBack, defines.inventory.character_main)
		util.swap_entity_inventories(OG2, PlayerProperties.SwapBack, defines.inventory.character_guns)
		util.swap_entity_inventories(OG2, PlayerProperties.SwapBack, defines.inventory.character_ammo)
		util.swap_entity_inventories(OG2, PlayerProperties.SwapBack, defines.inventory.character_trash)
		for i = 1, #OG2.get_inventory(defines.inventory.character_armor) do
			player.character.get_inventory(defines.inventory.character_armor).insert(OG2.get_inventory(defines.inventory.character_armor)[i])
		end
      player.character.cursor_stack.transfer_stack(OG2.cursor_stack)
		player.character.character_inventory_slots_bonus = player.character.character_inventory_slots_bonus-10000
      for i = 1, OG2.request_slot_count do
         local thing = OG2.get_personal_logistic_slot(i)
         PlayerProperties.SwapBack.set_personal_logistic_slot(i, thing)
         OG2.clear_personal_logistic_slot(i)
      end
		---------- redo crafting queue -----------
		if (TheList ~= nil) then
			for i = #TheList, 1, -1 do
				local crafting = TheList[i]
				if crafting then
					crafting.silent = true
					player.character.begin_crafting(crafting)
				end
			end
		end
      ---------- move robot ownership ----------
      for each, bot in pairs(OG2.following_robots) do
         bot.combat_robot_owner = PlayerProperties.SwapBack
      end
      local spidies = OG2.surface.find_entities_filtered{
         position = OG2.position,
         radius = 100,
         type = "spider-vehicle"
      }
      for each, spider in pairs(spidies) do
         if (spider.follow_target == OG2) then
            spider.follow_target = PlayerProperties.SwapBack
         end
      end
      PlayerProperties.SwapBack.destructible = true
      PlayerProperties.SwapBack.health = OG2.health
      PlayerProperties.SwapBack.selected_gun_index = OG2.selected_gun_index
      if (remote.interfaces["space-exploration"] and remote.interfaces["space-exploration"].on_character_swapped) then
            remote.call("space-exploration", "on_character_swapped", {new_character=PlayerProperties.SwapBack,old_character=OG2})
      end
      OG2.destroy()
      PlayerProperties.SwapBack = nil
      end
end

function copy(object)
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    -- don't copy factorio rich objects
    elseif object.__self then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for index, value in pairs(object) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  return _copy(object)
end

function DistanceBetween(p1, p2)
   return math.sqrt((p1.x-p2.x)^2+(p1.y-p2.y)^2)
end

function GetOnZipline(player, PlayerProperties, pole)
   ---------- get on zipline -----------------
   local TheGuy = player
   local FromXWireOffset = prototypes.recipe["RTGetTheGoods-"..pole.name.."X"].emissions_multiplier
   local FromYWireOffset = prototypes.recipe["RTGetTheGoods-"..pole.name.."Y"].emissions_multiplier
   local EquippedTrolley = player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name
   local SpookySlideGhost = pole.surface.create_entity
      ({
         name = "RTPropCar",
         position = {pole.position.x+FromXWireOffset, pole.position.y+FromYWireOffset},
         --force = TheGuy.force,
         create_build_effect_smoke = false
      })
   local trolley = pole.surface.create_entity
      ({
         name = "RTZipline",
         position = {pole.position.x+FromXWireOffset, pole.position.y+FromYWireOffset},
         force = TheGuy.force,
         create_build_effect_smoke = false
      })

   local drain
   local shade
   if (EquippedTrolley == "RTZiplineItem") then
      drain = pole.surface.create_entity
         ({
            name = "RTZiplinePowerDrain",
            position = pole.position,
            force = TheGuy.force,
            create_build_effect_smoke = false
         })
      shade = {1,1,1}
   elseif (EquippedTrolley == "RTZiplineItem2") then
      drain = pole.surface.create_entity
         ({
            name = "RTZiplinePowerDrain2",
            position = pole.position,
            force = TheGuy.force,
            create_build_effect_smoke = false
         })
      shade = {1,0.9,0}
   elseif (EquippedTrolley == "RTZiplineItem3") then
      drain = pole.surface.create_entity
         ({
            name = "RTZiplinePowerDrain3",
            position = pole.position,
            force = TheGuy.force,
            create_build_effect_smoke = false
         })
      shade = {255,35,35}
   elseif (EquippedTrolley == "RTZiplineItem4") then
      drain = pole.surface.create_entity
         ({
            name = "RTZiplinePowerDrain4",
            position = pole.position,
            force = TheGuy.force,
            create_build_effect_smoke = false
         })
      shade = {18,201,233}
   elseif (EquippedTrolley == "RTZiplineItem5") then
      drain = pole.surface.create_entity
         ({
            name = "RTZiplinePowerDrain5",
            position = pole.position,
            force = TheGuy.force,
            create_build_effect_smoke = false
         })
      shade = {83,255,26}
   end

   rendering.draw_animation
      {
         animation = "RTZiplineOverGFX",
         surface = TheGuy.surface,
         tint = shade,
         target = trolley,
         target_offset = {0, -0.3},
         x_scale = 0.5,
         y_scale = 0.5,
         render_layer = "wires-above"
      }
   rendering.draw_sprite
      {
         sprite = "RTZiplineHarnessGFX",
         surface = TheGuy.surface,
         tint = shade,
         target = trolley,
         target_offset = {0.03, 0.1},
         x_scale = 0.5,
         y_scale = 0.5,
         render_layer = "128"
      }
   trolley.destructible = false
   SpookySlideGhost.destructible = false
   drain.destructible = false
   TheGuy.teleport({SpookySlideGhost.position.x, 2+SpookySlideGhost.position.y})
   trolley.teleport({SpookySlideGhost.position.x, 0.5+SpookySlideGhost.position.y})
   PlayerProperties.zipline.LetMeGuideYou = SpookySlideGhost
   PlayerProperties.zipline.ChuggaChugga = trolley
   PlayerProperties.zipline.WhereDidYouComeFrom = pole
   PlayerProperties.zipline.AreYouStillThere = true
   PlayerProperties.zipline.succ = drain
   --game.print("Attached to track")
   PlayerProperties.state = "zipline"
   PlayerProperties.zipline.StartingSurface = TheGuy.surface
   PlayerProperties.OGSpeed = player.character.character_running_speed_modifier
   pole.surface.play_sound
      {
         path = "RTZipAttach",
         position = pole.position,
         volume = 0.7
      }
end


function GetOffZipline(player, PlayerProperties)
   local ZiplineStuff = PlayerProperties.zipline
   ZiplineStuff.LetMeGuideYou.surface.play_sound
      {
         path = "RTZipDettach",
         position = ZiplineStuff.LetMeGuideYou.position,
         volume = 0.4
      }
   ZiplineStuff.LetMeGuideYou.surface.play_sound
      {
         path = "RTZipWindDown",
         position = ZiplineStuff.LetMeGuideYou.position,
         volume = 0.4
      }
   ZiplineStuff.LetMeGuideYou.destroy()
   ZiplineStuff.ChuggaChugga.destroy()
   ZiplineStuff.succ.destroy()
   player.teleport(player.surface.find_non_colliding_position("character", {player.position.x, player.position.y+2}, 0, 0.01))
   PlayerProperties.zipline = {}
   PlayerProperties.state = "default"
   player.character.character_running_speed_modifier = PlayerProperties.OGSpeed
   PlayerProperties.OGSpeed = nil
end

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
    direction = OG.direction,
  }
   OG.teleport({1000000,1000000})
	NEWHOST.health = OG.health
	NEWHOST.selected_gun_index = OG.selected_gun_index
	------ modifiers --------
	local CharacterModifiers = {
		"character_crafting_speed_modifier",
		"character_inventory_slots_bonus",
		"character_mining_speed_modifier",
		"character_additional_mining_categories",
		"character_running_speed_modifier",
		"character_build_distance_bonus",
		"character_item_drop_distance_bonus",
		"character_reach_distance_bonus",
		"character_resource_reach_distance_bonus",
		"character_item_pickup_distance_bonus",
		"character_loot_pickup_distance_bonus",
		"character_trash_slot_count_bonus",
		"character_maximum_following_robot_count_bonus",
		"character_health_bonus"
	}
	for each, modifier in pairs(CharacterModifiers) do
		NEWHOST[modifier] = OG[modifier]
	end
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
	player.set_controller{type=defines.controllers.character, character=NEWHOST}
	return OG
end

---- swapping back from character ghost copy from using the ziplines or player launcher
function SwapBackFromGhost(player, FlyingItem)
	if (FlyingItem) then
		global.AllPlayers[FlyingItem.player.index].jumping = nil
		global.AllPlayers[FlyingItem.player.index] = {}
		if (FlyingItem.player.character) then
			local OG2 = FlyingItem.player.character
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

	elseif (player.character) then
		local stuff = global.AllPlayers[player.index]
		local OG2 = player.character
		stuff.SwapBack.teleport(player.position)
		player.character = stuff.SwapBack
		stuff.SwapBack.direction = OG2.direction
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
		util.swap_entity_inventories(OG2, stuff.SwapBack, defines.inventory.character_main)
		util.swap_entity_inventories(OG2, stuff.SwapBack, defines.inventory.character_guns)
		util.swap_entity_inventories(OG2, stuff.SwapBack, defines.inventory.character_ammo)
		util.swap_entity_inventories(OG2, stuff.SwapBack, defines.inventory.character_trash)
		for i = 1, #OG2.get_inventory(defines.inventory.character_armor) do
			player.character.get_inventory(defines.inventory.character_armor).insert(OG2.get_inventory(defines.inventory.character_armor)[i])
		end
      player.character.cursor_stack.transfer_stack(OG2.cursor_stack)
		player.character.character_inventory_slots_bonus = player.character.character_inventory_slots_bonus-10000
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
		stuff.SwapBack.destructible = true
		stuff.SwapBack.health = OG2.health
		stuff.SwapBack.selected_gun_index = OG2.selected_gun_index
		player.character_running_speed_modifier = 0
		OG2.destroy()
	end
end

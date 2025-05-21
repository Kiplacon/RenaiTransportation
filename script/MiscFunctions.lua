--local utild = require('util')
--======= util.swap_entity_inventories and swap_inventories method copied from the Jetpacks mod cause this somehow preserves blueprints in the quickbar
--https://mods.factorio.com/mod/jetpack
function util.swap_entity_inventories(entity_a, entity_b, inventory)
    local inv_a = entity_a.get_inventory(inventory)
    local inv_b = entity_b.get_inventory(inventory)
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
	-------------- create ghost copy and place original in car ---------------
	local OG = player.character
	OG.destructible = false
    local NEWHOST = OG.surface.create_entity{
        name = OG.name.."RTGhost",
        position = OG.position,
        force = OG.force,
        direction = OG.direction
    }
    local OwTheEdge = rendering.draw_sprite{
        sprite = "RTCharacterGhostStanding",
        target = {entity=NEWHOST, offset={3, 0.25}},
        tint = {r=1,g=1,b=1,a=0.3},
        surface = NEWHOST.surface,
        render_layer = "wires",
        x_scale = 0.5,
        y_scale = 0.5
    }
    local zhonyas = OG.surface.create_entity{
        name = "RTPropCar",
        position = OG.position,
        force = OG.force
    }
    player.character = NEWHOST

    -- copy stats of character to the ghost --
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

    -- logistics stuff
    if (player.force.character_logistic_requests == true) then
        NEWHOST.get_requester_point().enabled = OG.get_requester_point().enabled
        NEWHOST.get_requester_point().trash_not_requested = OG.get_requester_point().trash_not_requested
        OG.get_requester_point().enabled = false
        OG.get_requester_point().trash_not_requested = false
        NEWHOST.get_logistic_sections().remove_section(1) -- new character starts with one
        for i = 1, OG.get_logistic_sections().sections_count do
            local from = OG.get_logistic_sections().get_section(i)
            local to = NEWHOST.get_logistic_sections().add_section(from.group)
            to.active = from.active
            to.multiplier = from.multiplier
            if (from.group == "") then
                for j = 1, from.filters_count do
                    to.set_slot(j, from.get_slot(j))
                end
            end
        end
        for i = 1, OG.get_logistic_sections().sections_count do
            OG.get_logistic_sections().remove_section(1) --whenever you remove a slot, a new one becomes slot 1
        end
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
    -- move items into intermediate inventory to account for all inventory bonuses when armor is removed
    local CloudStorage = game.create_inventory(#OG.get_inventory(defines.inventory.character_main))
    for i = 1, #OG.get_inventory(defines.inventory.character_main) do
        OG.get_inventory(defines.inventory.character_main)[i].swap_stack(CloudStorage[i])
	end
    -- copy the main inventory filters
    local filters = {} -- record it because the inventory sizes of the player and ghost might be different if they were wearing armor with inventory bonus
    for i = 1, #OG.get_inventory(defines.inventory.character_main) do
        filters[i] = OG.get_inventory(defines.inventory.character_main).get_filter(i)
    end
    -- SWAP the armor, inserting a copy of the armor does NOT instantly apply tool belt inventory bonuses apparently. Do this after copying the filters
	util.swap_entity_inventories(OG, NEWHOST, defines.inventory.character_armor)
    -- write the main inventory filters
    for i = 1, #NEWHOST.get_inventory(defines.inventory.character_main) do
        NEWHOST.get_inventory(defines.inventory.character_main).set_filter(i, filters[i])
    end
    -- move items from intermediate inventory to the new character then destroy the intermediate
    for i = 1, math.min(#CloudStorage, #NEWHOST.get_inventory(defines.inventory.character_main)) do
        CloudStorage[i].swap_stack(NEWHOST.get_inventory(defines.inventory.character_main)[i])
	end
    CloudStorage.destroy()
    -- swap the other inventories
	util.swap_entity_inventories(OG, NEWHOST, defines.inventory.character_guns)
	util.swap_entity_inventories(OG, NEWHOST, defines.inventory.character_ammo)
	util.swap_entity_inventories(OG, NEWHOST, defines.inventory.character_trash)
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
        --player.set_controller{type=defines.controllers.character, character=NEWHOST}
    if (remote.interfaces.jetpack and remote.interfaces.jetpack.block_jetpack) then
        remote.call("jetpack", "block_jetpack", {character=NEWHOST})
    end
    if (remote.interfaces["space-exploration"] and remote.interfaces["space-exploration"].on_character_swapped) then
        remote.call("space-exploration", "on_character_swapped", {new_character=NEWHOST,old_character=OG})
    end
    zhonyas.set_driver(OG)
    zhonyas.force = "enemy"
    zhonyas.destructible = false

	return OG, OwTheEdge
end

---- swapping back from character ghost copy from using the ziplines or player launcher
function SwapBackFromGhost(player, FlyingItem)
    local PlayerProperties = storage.AllPlayers[player.index]
    PlayerProperties.state = "default"
    
    local OG = PlayerProperties.SwapBack
    if (FlyingItem) then
        OG = FlyingItem.SwapBack
    end
    
    if (player.character) then
        -- swap the original character back to the ghost position ---
        local ghost = player.character
        OG.vehicle.destroy()
        OG.teleport(ghost.position)
        player.teleport(OG.position, OG.surface)
        player.character = OG
        OG.direction = ghost.direction
        OG.destructible = true

        -- copy stats of ghost back to the original (it might have changed --
        OG.health = ghost.health
        OG.selected_gun_index = ghost.selected_gun_index
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
            OG[modifier] = ghost[modifier]
        end

        -- logistics stuff
        if (player.force.character_logistic_requests == true) then
            OG.get_requester_point().enabled = ghost.get_requester_point().enabled
            OG.get_requester_point().trash_not_requested = ghost.get_requester_point().trash_not_requested
            for i = 1, ghost.get_logistic_sections().sections_count do
                local from = ghost.get_logistic_sections().get_section(i)
                local to = OG.get_logistic_sections().add_section(from.group)
                to.active = from.active
                to.multiplier = from.multiplier
                if (from.group == "") then
                    for j = 1, from.filters_count do
                    to.set_slot(j, from.get_slot(j))
                    end
                end
            end
        end

        ------ undo crafting queue -------
        local TheList = nil
        if (ghost.crafting_queue) then
            TheList = {}
            for i = ghost.crafting_queue_size, 1, -1 do
                if ghost.crafting_queue and ghost.crafting_queue[i] then
                table.insert(TheList, ghost.crafting_queue[i])
                ghost.cancel_crafting(ghost.crafting_queue[i])
                end
            end
        end

        ------ move items ----------
        -- move items into intermediate inventory to account for all inventory bonuses when armor is removed
        local CloudStorage = game.create_inventory(#ghost.get_inventory(defines.inventory.character_main))
        for i = 1, #ghost.get_inventory(defines.inventory.character_main) do
            ghost.get_inventory(defines.inventory.character_main)[i].swap_stack(CloudStorage[i])
        end
        -- copy the main inventory filters
        local filters = {} -- record it because the inventory sizes of the player and ghost might be different if they were wearing armor with inventory bonus
        for i = 1, #ghost.get_inventory(defines.inventory.character_main) do
            filters[i] = ghost.get_inventory(defines.inventory.character_main).get_filter(i)
        end
        -- SWAP the armor, inserting a copy of the armor does NOT instantly apply tool belt inventory bonuses apparently
        util.swap_entity_inventories(ghost, OG, defines.inventory.character_armor)
        -- write the main inventory filters
        for i = 1, #OG.get_inventory(defines.inventory.character_main) do
            OG.get_inventory(defines.inventory.character_main).set_filter(i, filters[i])
        end
        -- move items from intermediate inventory to the new character then destroy the intermediate
        for i = 1, math.min(#CloudStorage, #OG.get_inventory(defines.inventory.character_main)) do
            CloudStorage[i].swap_stack(OG.get_inventory(defines.inventory.character_main)[i])
        end
        CloudStorage.destroy()
        -- swap the other inventories
        util.swap_entity_inventories(ghost, OG, defines.inventory.character_guns)
        util.swap_entity_inventories(ghost, OG, defines.inventory.character_ammo)
        util.swap_entity_inventories(ghost, OG, defines.inventory.character_trash)
        OG.cursor_stack.transfer_stack(ghost.cursor_stack)

        ---------- redo crafting queue -----------
        if (TheList ~= nil) then
            for i = #TheList, 1, -1 do
                local crafting = TheList[i]
                if crafting then
                crafting.silent = true
                OG.begin_crafting(crafting)
                end
            end
        end

        ---------- move robot ownership ----------
        for each, bot in pairs(ghost.following_robots) do
            bot.combat_robot_owner = OG
        end
        local spidies = OG.surface.find_entities_filtered{
            position = OG.position,
            radius = 100,
            type = "spider-vehicle"
        }
        for each, spider in pairs(spidies) do
            if (spider.follow_target == ghost) then
                spider.follow_target = OG
            end
        end

        --- swap control
        if (remote.interfaces["space-exploration"] and remote.interfaces["space-exploration"].on_character_swapped) then
            remote.call("space-exploration", "on_character_swapped", {new_character=OG, old_character=ghost})
        end
        ghost.destroy()
        PlayerProperties.SwapBack = nil
        if (player.character and player.character.valid and PlayerProperties.PlayerLauncher and PlayerProperties.PlayerLauncher.FallDamage) then
            player.character.damage(PlayerProperties.PlayerLauncher.height*20, "neutral")
        end
    else
        OG.vehicle.destroy()
        OG.destructible = true
        OG.destroy()
        PlayerProperties.SwapBack = nil
    end

    PlayerProperties.PlayerLauncher = {}

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
    local p1x = p1.x or p1[1]
    local p1y = p1.y or p1[2]
    local p2x = p2.x or p2[1]
    local p2y = p2.y or p2[2]
    return math.sqrt((p1x-p2x)^2+(p1y-p2y)^2)
end

function OffsetPosition(p1, p2)
    local p1x = p1.x or p1[1]
    local p1y = p1.y or p1[2]
    local p2x = p2.x or p2[1]
    local p2y = p2.y or p2[2]
    return {x=p1x+p2x, y=p1y+p2y}
end

function ToggleTrapdoorWagon(WagonEntity, StationToggleBack)
    local DestroyNumber = script.register_on_object_destroyed(WagonEntity)
    -- properties.entity = the wagon entity
    -- properties.open = true/false
    -- properties.OpenIndicator = RenderObject
    if (storage.TrapdoorWagonsOpen[DestroyNumber] ~= nil) then
        storage.TrapdoorWagonsOpen[DestroyNumber].OpenIndicator.sprite = "RTTrapdoorWagonClosed"
        storage.TrapdoorWagonsOpen[DestroyNumber].StationToggleBack = StationToggleBack
        --storage.TrapdoorWagonsOpen[DestroyNumber].open = false
        storage.TrapdoorWagonsClosed[DestroyNumber], storage.TrapdoorWagonsOpen[DestroyNumber] = storage.TrapdoorWagonsOpen[DestroyNumber], nil
        WagonEntity.surface.play_sound{path="RTTrapdoorCloseSound", position=WagonEntity.position}
    elseif (storage.TrapdoorWagonsClosed[DestroyNumber] ~= nil) then
        storage.TrapdoorWagonsClosed[DestroyNumber].OpenIndicator.sprite = "RTTrapdoorWagonOpen"
        storage.TrapdoorWagonsClosed[DestroyNumber].StationToggleBack = StationToggleBack
        --storage.TrapdoorWagonsClosed[DestroyNumber].open = true
        storage.TrapdoorWagonsOpen[DestroyNumber], storage.TrapdoorWagonsClosed[DestroyNumber] = storage.TrapdoorWagonsClosed[DestroyNumber], nil
        storage.TrapdoorWagonsOpen[DestroyNumber].timeout = nil
        WagonEntity.surface.play_sound{path="RTTrapdoorOpenSound", position=WagonEntity.position}
    end
end
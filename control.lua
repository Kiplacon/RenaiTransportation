if script.active_mods["gvv"] then require("__gvv__.gvv")() end
-- Setup tables and stuff for new/existing saves ----
script.on_init(
	require("script.event.init")
)

-- game version changes, prototypes change, startup mod settings change, and any time mod versions change including adding or removing mods
script.on_configuration_changed(
	require("script.event.config_changed")
)

---- Add new players to the AllPlayers table ----
script.on_event(
	defines.events.on_player_created,
	require("script.event.player_created")
)

-- On Built/Copy/Stuff

---- adds new thrower inserters to the list of throwers to check.
---- Make player launchers (reskinned inserters) to be inoperable
---- and inactive ----
script.on_event(
	{
		defines.events.on_built_entity, --| built by hand ----
		defines.events.on_robot_built_entity, --| built by robot ----
		defines.events.script_raised_built, --| built by script ----
		defines.events.on_entity_cloned, -- | cloned by script ----
		defines.events.script_raised_revive, -- | ghost revived by script
	},
	require("script.event.entity_built")
)


-- On Rotate
script.on_event(
	defines.events.on_player_rotated_entity,
	require("script.event.rotate")
)


-- Thrower Range blueprint auto build cancel
script.on_event(defines.events.on_player_cursor_stack_changed, -- only has .player_index
function(event)
if (global.AllPlayers[event.player_index].RangeAdjusting == true) then
	global.AllPlayers[event.player_index].RangeAdjusting = nil
end
end)


-- Clear invalid things
script.on_nth_tick(300,
function(event)
	for unitID, ItsStuff in pairs(global.BouncePadList) do
		if (ItsStuff.TheEntity and ItsStuff.TheEntity.valid) then
			-- it's good
		else
			global.BouncePadList[unitID] = nil
		end
	end

	for unitID, ItsStuff in pairs(global.MagnetRamps) do
		if (ItsStuff.entity and ItsStuff.entity.valid) then
			-- it's good
		else
			global.MagnetRamps[unitID] = nil
		end
	end
	
	for each, world in pairs(game.surfaces) do
		for every, ZiplinePart in pairs(world.find_entities_filtered{name = {"RTZipline", "RTZiplinePowerDrain"}}) do
			local owned = false
			for all, player in pairs(global.AllPlayers) do
				if ((player.ChuggaChugga and ZiplinePart.unit_number == player.ChuggaChugga.unit_number)
				or  (player.succ and ZiplinePart.unit_number == player.succ.unit_number)
				) then
					owned = true
				end
			end
			if (owned == false) then
				ZiplinePart.destroy()
			end
		end
	end
end)

-- Thrower Check
---- checks if thrower inserters have something in their hands and it's in the throwing position, then creates the approppriate projectile ----
script.on_nth_tick(3,
function(event)
	if (global.CatapultList ~= {}) then
		for catapultID, properties in pairs(global.CatapultList) do

			local catapult = properties.entity

			BurnerSelfRefuelCompensation = 0.2
			if (catapult.valid and catapult.burner == nil and catapult.fluidbox == nil and catapult.energy/catapult.electric_buffer_size >= 0.9) then
				catapult.active = true
				BurnerSelfRefuelCompensation = 0
			elseif (catapult.valid and catapult.burner == nil and catapult.fluidbox == nil) then
				catapult.active = false
				rendering.draw_sprite
					{
						sprite = "utility.electricity_icon_unplugged",
						x_scale = 0.5,
						y_scale = 0.5,
						target = catapult,
						surface = catapult.surface,
						time_to_live = 4
					}
			end

			if (catapult.valid and catapult.held_stack.valid_for_read) then
				if (settings.global["RTOverflowComp"].value == true) then
					if (properties.target ~= "nothing" and properties.target.valid and global.ThrowerTargets[properties.target.unit_number]) then						
						if (properties.target.type ~= "transport-belt") then
							local InAir = {}
							for name, count in pairs(global.ThrowerTargets[properties.target.unit_number].OnTheWay) do
								local total = count
								if (name == catapult.held_stack.name) then
									total = count + catapult.held_stack.count
								end
								local inserted = nil
								if (total > 0) then
									inserted = properties.target.insert({name=name, count=total})
									InAir[name] = inserted
								end
								if (total > 0 and inserted < total) then
									for namee, countt in pairs(InAir) do
										if (countt > 0) then
											properties.target.remove_item({name=namee, count=countt})
										end
									end
									catapult.active = false
									InAir = {}
									break
								elseif (InAir == {}) then
									catapult.active = true
								else
									catapult.active = true
								end
							end
							for namee, countt in pairs(InAir) do
								properties.target.remove_item({name=namee, count=countt})
							end
							
						elseif (properties.target.type == "transport-belt" 
						and (properties.target.get_transport_line(1).can_insert_at_back() == true 
							 or properties.target.get_transport_line(2).can_insert_at_back() == true)
						) then
							local InAir = 0
							for name, count in pairs(global.ThrowerTargets[properties.target.unit_number].OnTheWay) do
								InAir = InAir + count
							end
							local total = InAir + properties.target.get_transport_line(1).get_item_count() + properties.target.get_transport_line(2).get_item_count()
							if (total <= 6) then
								catapult.active = true
							else
								catapult.active = false
							end
						end
						
					elseif (properties.target == "nothing") then
						catapult.active = true
					end
				else
					catapult.active = true
				end

				if (catapult.active == true) then
					if (catapult.orientation == 0    and catapult.held_stack_position.y >= catapult.position.y+BurnerSelfRefuelCompensation)
					or (catapult.orientation == 0.25 and catapult.held_stack_position.x <= catapult.position.x-BurnerSelfRefuelCompensation)
					or (catapult.orientation == 0.50 and catapult.held_stack_position.y <= catapult.position.y-BurnerSelfRefuelCompensation)
					or (catapult.orientation == 0.75 and catapult.held_stack_position.x >= catapult.position.x+BurnerSelfRefuelCompensation)
					then
						for i = 1, catapult.held_stack.count do
							if (not pcall(function() catapult.surface.create_entity
								({
								name = catapult.held_stack.name.."-projectileFromRenaiTransportation",
								position = catapult.position, --required setting for rendering, doesn't affect spawn
								source_position = catapult.held_stack_position, --launch from
								target_position = catapult.drop_position --launch to
								}) 
								end)
							) then
								catapult.active = false
						        for ii, player in pairs(game.players) do
									player.print("Invalid throwable item "..catapult.held_stack.name.." at "..catapult.held_stack_position.x..","..catapult.held_stack_position.x..". Thrower halted. Please report the item to the mod portal form.")
								end
								
							elseif (settings.global["RTOverflowComp"].value == true and properties.target ~= "nothing" and properties.target.valid and global.ThrowerTargets[properties.target.unit_number]) then
								local unused = 1
								while (global.ThrownItems[unused] ~= nil) do
									unused = unused + 1
								end
								
								global.ThrownItems[unused] = {
									from = catapult.held_stack_position,
									to = catapult.drop_position,
									destination = properties.target.unit_number,
									item = catapult.held_stack.name}
									
								if (global.ThrowerTargets[properties.target.unit_number].OnTheWay[catapult.held_stack.name] == nil) then
									global.ThrowerTargets[properties.target.unit_number].OnTheWay[catapult.held_stack.name] = 1
								else
									global.ThrowerTargets[properties.target.unit_number].OnTheWay[catapult.held_stack.name] = global.ThrowerTargets[properties.target.unit_number].OnTheWay[catapult.held_stack.name] + 1
								end
								
							end
						end
						catapult.held_stack.clear()
					end
				end

			elseif (catapult.valid == false) then
				global.CatapultList[catapultID] = nil
				
			end
		end
	end
end)

script.on_nth_tick(120,
function(event)
	if (settings.global["RTOverflowComp"].value == true) then
		for catapultID, properties in pairs(global.CatapultList) do
			if (properties.ImAlreadyTracer == nil or properties.ImAlreadyTracer == "traced") then
				properties.ImAlreadyTracer = "tracing"
				properties.entity.surface.create_entity
					({
					name = "MaybeIllBeTracer-projectileFromRenaiTransportation",
					position = properties.entity.position, --required setting for rendering, doesn't affect spawn
					source = properties.entity, --launch from
					target_position = properties.entity.drop_position --launch to
					})
			end
		end
	else
	--dont
	end
end)

-- Projectile Lands
-- When a projectile lands and its effect_id is triggered, what to do ----
script.on_event(
	defines.events.on_script_trigger_effect,
	require("script.event.effect_triggered")
)

-- Animating/On Tick
script.on_nth_tick(
	1,
	require("script.event.on_tick")
)

-- On Damaged
script.on_event(
	defines.events.on_entity_damaged,
	require("script.event.entity_damaged")
)

-- On Interact
script.on_event(
	"RTInteract",
	require("script.event.interact")
)

-- On Click
script.on_event(
	"RTClick",
	require("script.event.click")
)

script.on_event(
	defines.events.on_entity_destroyed,
	require("script.event.entity_destroyed")
)


script.on_event(defines.events.on_player_changed_surface,
-- .player_index :: uint: The player who changed surfaces
-- .surface_index :: uint: The surface index the player was on
function(event)
local player = game.players[event.player_index]
	if (global.AllPlayers[event.player_index] and global.AllPlayers[event.player_index].sliding and global.AllPlayers[event.player_index].sliding == true and player.surface.name ~= global.AllPlayers[event.player_index].StartingSurface.name) then
		player.teleport(player.position, game.get_surface(event.surface_index))
	end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed,
-- player_index :: uint (optional): The player who changed the setting or nil if changed by script.
-- setting :: string: The setting name that changed.
-- setting_type :: string: The setting type: "runtime-per-user", or "runtime-global".
function(event)
	if (event.setting == "RTOverflowComp" and settings.global["RTOverflowComp"].value == false) then
		global.ThrowerTargets = {}
		global.ThrownItems = {}
	end
end)
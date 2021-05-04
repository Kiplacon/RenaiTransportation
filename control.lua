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
		for every, ZiplinePart in pairs(world.find_entities_filtered{name = {"RTZipline", "RTZiplinePowerDrain", "RTPropCar"}}) do
			local owned = false
			for all, player in pairs(global.AllPlayers) do
				if ((player.ChuggaChugga and ZiplinePart.unit_number == player.ChuggaChugga.unit_number)
				or  (player.succ and ZiplinePart.unit_number == player.succ.unit_number)
				or  (player.LetMeGuideYou and ZiplinePart.unit_number == player.LetMeGuideYou.unit_number)
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
					if (properties.target and properties.target.valid and properties.target ~= "nothing" and properties.target.type == "transport-belt" and (properties.target.get_transport_line(1).can_insert_at_back() == false and properties.target.get_transport_line(2).can_insert_at_back() == false)) then
						catapult.active = false
					elseif (properties.target and properties.target.valid and properties.target ~= "nothing" and properties.target.can_insert(catapult.held_stack) == false) then
						catapult.active = false
					else
						catapult.active = true
					end
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
								end) --end of pcall function
							) then
								catapult.active = false
						        for ii, player in pairs(game.players) do
									player.print("Invalid throwable item "..catapult.held_stack.name.." at "..catapult.held_stack_position.x..","..catapult.held_stack_position.x..". Thrower halted. Please report the item to the mod portal form.")
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
			properties.entity.surface.create_entity
				({
				name = "MaybeIllBeTracer-projectileFromRenaiTransportation",
				position = properties.entity.position, --required setting for rendering, doesn't affect spawn
				source = properties.entity, --launch from
				target_position = properties.entity.drop_position --launch to
				})
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
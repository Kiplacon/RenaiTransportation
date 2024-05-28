if script.active_mods["gvv"] then require("__gvv__.gvv")() end
if script.active_mods["Ultracube"] then CubeFlyingItems = require("script.ultracube.cube_flying_items") end

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
	global.AllPlayers[event.player_index].RangeAdjusting = false
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
end)

-- Thrower Check
---- checks if thrower inserters have something in their hands and it's in the throwing position, then creates the approppriate projectile ----
script.on_nth_tick(3,
function(event)
	for catapultID, properties in pairs(global.CatapultList) do
		local catapult = properties.entity
		if (catapult.valid) then
			-- power check. low power makes inserter arms stretch
			if (properties.IsElectric == true and catapult.energy/catapult.electric_buffer_size >= 0.9) then
				catapult.active = true
			elseif (properties.IsElectric == true and catapult.is_connected_to_electric_network() == true) then
				catapult.active = false
				rendering.draw_animation
					{
						animation = "RTMOREPOWER",
						x_scale = 0.5,
						y_scale = 0.5,
						target = catapult,
						surface = catapult.surface,
						time_to_live = 4
					}
			end

			if (catapult.held_stack.valid_for_read) then -- if it has power
				local HeldItem = catapult.held_stack.name
				-- if it's passed the "half swing" point
				if (catapult.orientation == 0    and catapult.held_stack_position.y >= catapult.position.y+properties.BurnerSelfRefuelCompensation)
				or (catapult.orientation == 0.25 and catapult.held_stack_position.x <= catapult.position.x-properties.BurnerSelfRefuelCompensation)
				or (catapult.orientation == 0.50 and catapult.held_stack_position.y <= catapult.position.y-properties.BurnerSelfRefuelCompensation)
				or (catapult.orientation == 0.75 and catapult.held_stack_position.x >= catapult.position.x+properties.BurnerSelfRefuelCompensation)
				then
					-- activate/disable thrower based on overflow prevention
					if (catapult.name ~= "RTThrower-PrimerThrower" and settings.global["RTOverflowComp"].value == true and properties.InSpace == false) then
						-- pointing at some entity
						if (properties.targets[HeldItem]
						and properties.targets[HeldItem].valid -- its an entity
						and global.OnTheWay[properties.targets[HeldItem].unit_number] -- receptions are being tracked for the entity
						and global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem]) then -- receptions are being tracked for the entity for the particular item
							if (properties.targets[HeldItem].type ~= "transport-belt") then
								if (global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] < 0) then
									global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] = 0  -- correct any miscalculaltions resulting in negative values
								end
								local total = global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] + catapult.held_stack.count
								local inserted = properties.targets[HeldItem].insert({name=HeldItem, count=total})
								if (inserted < total) then
									catapult.active = false
								else
									catapult.active = true
								end
								if (inserted > 0) then -- when the destination is full. Have to check otherwise there's an error
									properties.targets[HeldItem].remove_item({name=HeldItem, count=inserted})
								end
							elseif (properties.targets[HeldItem].type == "transport-belt") then
								local incomming = 0
								for name, count in pairs(global.OnTheWay[properties.targets[HeldItem].unit_number]) do
									incomming = incomming + count
								end
								local total = incomming + properties.targets[HeldItem].get_transport_line(1).get_item_count() + properties.targets[HeldItem].get_transport_line(2).get_item_count() + catapult.held_stack.count
								if (properties.targets[HeldItem].belt_shape == "straight" and total <= 8)
								or (properties.targets[HeldItem].belt_shape ~= "straight" and total <= 7) then
									catapult.active = true
									if (global.HoverGFX[catapult.unit_number]) then
										for playerID, graphic in pairs(global.HoverGFX[catapult.unit_number]) do
											rendering.destroy(graphic)
										end
										global.HoverGFX[catapult.unit_number] = {}
									end
								else
									catapult.active = false
									if (global.HoverGFX[catapult.unit_number] == nil) then
										global.HoverGFX[catapult.unit_number] = {}
									end
									for ID, player in pairs(game.players) do
										if (global.HoverGFX[catapult.unit_number][ID] == nil) then
											local hovering = false
											if (player.selected and player.selected.unit_number == catapult.unit_number) then
												hovering = true
											end
											global.HoverGFX[catapult.unit_number][ID] = rendering.draw_text
											{
												text = {"RTmisc.EightMax"},
												surface = catapult.surface,
												target = catapult,
												alignment = "center",
												scale = 0.5,
												color = {1,1,1},
												players = {player},
												visible = hovering
											}
										end
									end
								end
							end

						-- pointing at nothing/the ground
						elseif (properties.targets[HeldItem] == "nothing") then
							catapult.active = true

						-- item needs path validation/is currently tracking path
						elseif (properties.targets[HeldItem] == nil) then
							-- start path tracking, repeatedly stops here until trace ends, setting the target in properties
							if (properties.ImAlreadyTracer == nil or properties.ImAlreadyTracer == "traced") then
								properties.ImAlreadyTracer = "tracing"
								-- set tracer "projectile"
								local AirTime = 1
								global.FlyingItems[global.FlightNumber] =
									{
									item=HeldItem, --not like it matters
									amount=0, --not like it matters
									target=
									{
										x=properties.entity.drop_position.x, 
										y=properties.entity.drop_position.y
									},
									start=properties.entity.position,
									AirTime=AirTime,
									StartTick=event.tick,
									LandTick=event.tick+AirTime,
									tracing = properties.entity.unit_number,
									surface = catapult.surface,
									space = false --necessary
									}
								global.FlightNumber = global.FlightNumber + 1
							end
							catapult.active = false
						-- first time throws for items to this target
						elseif (properties.targets[HeldItem]
						and properties.targets[HeldItem].valid
						and global.OnTheWay[properties.targets[HeldItem].unit_number] == nil) then
							global.OnTheWay[properties.targets[HeldItem].unit_number] = {}
							global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] = 0
						-- first time throws for this particular item to this target
						elseif (properties.targets[HeldItem]
						and properties.targets[HeldItem].valid
						and global.OnTheWay[properties.targets[HeldItem].unit_number]
						and global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] == nil) then
							global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] = 0
						end
					-- overflow prevention is set to off
					else
						catapult.active = true
					end

					-- if the thrower is still active after the checks then:
					if (catapult.active == true) then
						if (catapult.name == "RTThrower-PrimerThrower" and game.entity_prototypes["RTPrimerThrowerShooter-"..HeldItem]) then
							catapult.inserter_stack_size_override = 1
							catapult.active = false
							global.PrimerThrowerLinks[properties.entangled.detector.unit_number].ready = true
						else
							-- starting parameters
							local x = catapult.drop_position.x
							local y = catapult.drop_position.y
							local distance = math.sqrt((x-catapult.held_stack_position.x)^2 + (y-catapult.held_stack_position.y)^2)
							-- calcaulte projectile parameters
							local start=catapult.held_stack_position
							local speed = 0.18
							if (catapult.name == "RTThrower-EjectorHatchRT") then
								distance = math.sqrt((x-catapult.position.x)^2 + (y-catapult.position.y)^2)
								start=catapult.position
								speed = 0.25
								-- catapult.surface.play_sound
								-- 	{
								-- 		path = "RTEjector",
								-- 		position = catapult.position,
								-- 		volume = 0.7
								-- 	}
							else
								-- catapult.surface.play_sound
								-- 	{
								-- 		path = "RTThrow",
								-- 		position = catapult.position
								-- 	}
							end
							local AirTime = math.max(1, math.floor(distance/speed)) -- for super fast throwers that move right on top of their target
							local destination = nil
							if (settings.global["RTOverflowComp"].value == true and properties.InSpace == false) then
								if (properties.targets[HeldItem] ~= nil and properties.targets[HeldItem].valid) then
									destination = properties.targets[HeldItem].unit_number
									if (global.OnTheWay[properties.targets[HeldItem].unit_number] == nil) then
										global.OnTheWay[properties.targets[HeldItem].unit_number] = {}
										global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] = catapult.held_stack.count
									elseif (global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] == nil) then
										global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] = catapult.held_stack.count
									else
										global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] = global.OnTheWay[properties.targets[HeldItem].unit_number][HeldItem] + catapult.held_stack.count
									end
								elseif (properties.targets[HeldItem] == "nothing") then -- recheck pointing at nothing/things without unit_numbers
									properties.targets[HeldItem] = nil
								end
							end
							global.FlyingItems[global.FlightNumber] =
								{
									item=HeldItem,
									amount=catapult.held_stack.count,
									target={x=x, y=y},
									start=start,
									AirTime=AirTime,
									StartTick=game.tick,
									LandTick=game.tick+AirTime,
									destination=destination,
									space=properties.InSpace,
									surface=catapult.surface,
								}
							if (properties.InSpace == false) then
								if (game.entity_prototypes["RTItemProjectile-"..HeldItem..speed*100]) then
									catapult.surface.create_entity
									{
										name="RTItemProjectile-"..HeldItem..speed*100,
										position=catapult.held_stack_position,
										source_position=start,
										target_position=catapult.drop_position
									}
								else
									catapult.surface.create_entity
									{
										name="RTTestProjectile"..speed*100,
										position=catapult.held_stack_position,
										source_position=start,
										target_position=catapult.drop_position
									}
								end
							else
								x = x + (-global.OrientationUnitComponents[catapult.orientation].x * 100)
								y = y + (-global.OrientationUnitComponents[catapult.orientation].y * 100)
								distance = math.sqrt((x-catapult.held_stack_position.x)^2 + (y-catapult.held_stack_position.y)^2)
								AirTime = math.max(1, math.floor(distance/speed))
								local vector = {x=x-catapult.held_stack_position.x, y=y-catapult.held_stack_position.y}
								local path = {}
								for i = 1, AirTime do
									local progress = i/AirTime
									path[i] =
									{
										x = catapult.held_stack_position.x+(progress*vector.x),
										y = catapult.held_stack_position.y+(progress*vector.y),
										height = 0
									}
								end
								path.duration = AirTime
								global.FlyingItems[global.FlightNumber].path = path
								global.FlyingItems[global.FlightNumber].space = true
								global.FlyingItems[global.FlightNumber].LandTick = game.tick+AirTime
								global.FlyingItems[global.FlightNumber].sprite = rendering.draw_sprite
									{
										sprite = "item/"..HeldItem,
										x_scale = 0.5,
										y_scale = 0.5,
										target = catapult.held_stack_position,
										surface = catapult.surface
									}
								global.FlyingItems[global.FlightNumber].spin = math.random(-10,10)*0.01
							end
							if (catapult.held_stack.item_number ~= nil) then
								local CloudStorage = game.create_inventory(1)
								CloudStorage.insert(catapult.held_stack)
								global.FlyingItems[global.FlightNumber].CloudStorage = CloudStorage
							end

							-- Ultracube irreplaceables detection & handling
							if global.Ultracube and global.Ultracube.prototypes.irreplaceable[HeldItem] then -- Ultracube mod is active, and the held item is an irreplaceable
								-- Sets cube_token_id and cube_should_hint for the new FlyingItems entry
								CubeFlyingItems.create_token_for(global.FlyingItems[global.FlightNumber])
							end
							
							global.FlightNumber = global.FlightNumber + 1
							catapult.held_stack.clear()
						end
					end
				end

			elseif (catapult.active == false and catapult.held_stack.valid_for_read == false) then
				catapult.active = true
			end

			if (properties.RangeAdjustable == true) then
				local range = catapult.get_merged_signal({type="virtual", name="ThrowerRangeSignal"})
				if (properties.range==nil or properties.range~=range) then
					if (catapult.name == "RTThrower-long-handed-inserter" and range > 0 and range <= 25)
					or (catapult.name ~= "RTThrower-long-handed-inserter" and range > 0 and range <= 15) then
						catapult.drop_position =
							{
								catapult.position.x + -range*global.OrientationUnitComponents[catapult.orientation].x,
								catapult.position.y + -range*global.OrientationUnitComponents[catapult.orientation].y
							}
						properties.range = range
						if (global.CatapultList[catapult.unit_number]) then
							global.CatapultList[catapult.unit_number].targets = {}
							for componentUN, PathsItsPartOf in pairs(global.ThrowerPaths) do
								for ThrowerUN, TrackedItems in pairs(PathsItsPartOf) do
									if (ThrowerUN == catapult.unit_number) then
										global.ThrowerPaths[componentUN][ThrowerUN] = {}
									end
								end
							end
						end
					end
				end
			end

		elseif (catapult.valid == false) then
			global.CatapultList[catapultID] = nil
		end
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
local PlayerProperties = global.AllPlayers[event.player_index]
	if (PlayerProperties and PlayerProperties.state == "zipline" and player.surface.name ~= PlayerProperties.zipline.StartingSurface.name) then
		player.teleport(player.position, game.get_surface(event.surface_index))
	end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed,
-- player_index :: uint (optional): The player who changed the setting or nil if changed by script.
-- setting :: string: The setting name that changed.
-- setting_type :: string: The setting type: "runtime-per-user", or "runtime-global".
function(event)
	if (event.setting == "RTOverflowComp" and settings.global["RTOverflowComp"].value == false) then
		global.OnTheWay = {}
	end
end)

-- script.on_event(defines.events.on_player_driving_changed_state,
-- -- player_index :: uint
-- -- entity :: LuaEntity (optional): The vehicle if any.
-- function(event)
-- 	local player = game.players[event.player_index]
-- 	if (player.character and player.driving == false) then
-- 		for each, properties in pairs(global.FlyingTrains) do
-- 			if (properties.passenger and properties.passenger.unit_number == player.character.unit_number) then
-- 				properties.GuideCar.set_passenger(player)
-- 			end
-- 		end
-- 	end
-- end)

script.on_event(defines.events.on_gui_closed,
function(event)
	if (event.entity and event.entity.name == "DirectorBouncePlate" and global.ThrowerPaths[event.entity.unit_number] ~= nil) then
		for ThrowerUN, TrackedItems in pairs(global.ThrowerPaths[event.entity.unit_number]) do
			if (global.CatapultList[ThrowerUN]) then
				for item, asthma in pairs(TrackedItems) do
					global.CatapultList[ThrowerUN].targets[item] = nil
				end
			end
		end
		global.ThrowerPaths[event.entity.unit_number] = {}
	end
end)

-- a bunch of functions used in various other places
require("script.MiscFunctions")
require("script.GUIs")

script.on_event(defines.events.on_gui_click,
	require("script.event.ClickGUI")
)

-- displaying things on hover
script.on_event(defines.events.on_selected_entity_changed,
--player_index	:: uint			The player whose selected entity changed.
--last_entity	:: LuaEntity?	The last selected entity if it still exists and there was one.
function(event)
	local player = game.players[event.player_index]
	if (event.last_entity
	and event.last_entity.unit_number
	and global.HoverGFX[event.last_entity.unit_number]
	and global.HoverGFX[event.last_entity.unit_number][event.player_index]) then
		rendering.set_visible(global.HoverGFX[event.last_entity.unit_number][event.player_index], false)
	end
	if (player.selected and player.selected.unit_number and global.HoverGFX[player.selected.unit_number] and global.HoverGFX[player.selected.unit_number][event.player_index]) then
		rendering.set_visible(global.HoverGFX[player.selected.unit_number][event.player_index], true)
	end
end)

script.on_event(defines.events.on_pre_surface_deleted,
--surface_index :: uint
--name :: defines.events	Identifier of the event
--tick :: uint				Tick the event was generated.
function(event)
	for each, FlyingItem in pairs(global.FlyingItems) do
		if (FlyingItem.surface.index == event.surface_index) then
            if (FlyingItem.sprite) then
				rendering.destroy(FlyingItem.sprite)
			end
			if (FlyingItem.shadow) then
				rendering.destroy(FlyingItem.shadow)
			end
			if (FlyingItem.destination ~= nil and global.OnTheWay[FlyingItem.destination]) then
				global.OnTheWay[FlyingItem.destination][FlyingItem.item] = global.OnTheWay[FlyingItem.destination][FlyingItem.item] - FlyingItem.amount
			end
			if (FlyingItem.player) then
				SwapBackFromGhost(FlyingItem.player, FlyingItem)
			end
			global.FlyingItems[each] = nil
		end
	end
end)

script.on_event(
"DebugAdvanceActionProcess",
function(event)
	local player = game.players[event.player_index]
	if (player.cursor_stack.valid_for_read == true) then
		local item = player.cursor_stack.name
		if (game.entity_prototypes["RTItemProjectile-"..item..25]) then
			player.surface.create_entity
			{
				name="RTItemProjectile-"..item..25,
				position=player.position,
				source_position=player.position,
				target_position=event.cursor_position
			}
		else
			player.surface.create_entity
			{
				name="RTTestProjectile"..25,
				position=player.position,
				source_position=player.position,
				target_position=event.cursor_position
			}
		end
	end
end)

script.on_event(defines.events.on_research_finished,
--research	:: LuaTechnology		The researched technology
--by_script	:: boolean				If the technology was researched by script.
--name		:: defines.events		Identifier of the event
--tick		:: uint					Tick the event was generated.
function(event)
	if (event.research.name == "RTFocusedFlinging") then
		for each, properties in pairs(global.CatapultList) do
			if (string.find(properties.entity.name, "RTThrower-") and properties.entity.name ~= "RTThrower-PrimerThrower") then
				properties.RangeAdjustable = true
			end
		end
	end
end)

script.on_event(defines.events.on_pre_player_left_game,
function(event)
	local player = game.players[event.player_index]
	local PlayerProperties = global.AllPlayers[event.player_index]
	if (PlayerProperties.state == "zipline") then
		GetOffZipline(player, PlayerProperties)
	elseif (PlayerProperties.state == "jumping") then
		if (PlayerProperties.PlayerLauncher.tracker and global.FlyingItems[PlayerProperties.PlayerLauncher.tracker] ~= nil) then
			local number = PlayerProperties.PlayerLauncher.tracker
			local FlyingItem = global.FlyingItems[number]
			if (FlyingItem.sprite) then
				rendering.destroy(FlyingItem.sprite)
			end
			if (FlyingItem.shadow) then
				rendering.destroy(FlyingItem.shadow)
			end
			SwapBackFromGhost(player, FlyingItem)
			global.FlyingItems[number] = nil
		end
	end
end)

ElectricPoleBlackList = {PoleName="windows", ["factory-power-connection"]=true, ["factory-power-pole"]=true, ["factory-overflow-pole"]=true}
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
if (storage.AllPlayers[event.player_index].RangeAdjusting == true and game.players[event.player_index].is_cursor_empty() == true) then
	storage.AllPlayers[event.player_index].RangeAdjusting = false
	storage.AllPlayers[event.player_index].RangeAdjustingDirection = nil
	storage.AllPlayers[event.player_index].RangeAdjustingRange = nil
end
end)


-- Clear invalid things
script.on_nth_tick(300,
function(event)
	for unitID, ItsStuff in pairs(storage.BouncePadList) do
		if (ItsStuff.TheEntity and ItsStuff.TheEntity.valid) then
			-- it's good
		else
			storage.BouncePadList[unitID] = nil
		end
	end

	for unitID, ItsStuff in pairs(storage.MagnetRamps) do
		if (ItsStuff.entity and ItsStuff.entity.valid) then
			-- it's good
		else
			storage.MagnetRamps[unitID] = nil
		end
	end
end)

-- Thrower Check
---- checks if thrower inserters have something in their hands and it's in the throwing position, then creates the approppriate projectile ----
script.on_nth_tick(3,
function(event)
	for catapultID, properties in pairs(storage.CatapultList) do
		local catapult = properties.entity
		if (catapult.valid) then
			local CatapulyDestroyNumber = script.register_on_object_destroyed(catapult)
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
						and storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])] -- receptions are being tracked for the entity
						and storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])][HeldItem]) then -- receptions are being tracked for the entity for the particular item
							local TargetDestroyNumber = script.register_on_object_destroyed(properties.targets[HeldItem])
							if (properties.targets[HeldItem].type ~= "transport-belt") then
								if (storage.OnTheWay[TargetDestroyNumber][HeldItem] < 0) then
									storage.OnTheWay[TargetDestroyNumber][HeldItem] = 0  -- correct any miscalculaltions resulting in negative values
								end
								local total = storage.OnTheWay[TargetDestroyNumber][HeldItem] + catapult.held_stack.count
								local inserted = properties.targets[HeldItem].insert({name=HeldItem, count=total, quality=catapult.held_stack.quality.name})
								if (inserted < total) then
									catapult.active = false
								else
									catapult.active = true
								end
								if (inserted > 0) then -- when the destination is full. Have to check otherwise there's an error
									properties.targets[HeldItem].remove_item({name=HeldItem, count=inserted, quality=catapult.held_stack.quality.name})
								end
							elseif (properties.targets[HeldItem].type == "transport-belt") then
								local incomming = 0
								for name, count in pairs(storage.OnTheWay[TargetDestroyNumber]) do
									incomming = incomming + count
								end
								local total = incomming + properties.targets[HeldItem].get_transport_line(1).get_item_count() + properties.targets[HeldItem].get_transport_line(2).get_item_count() + catapult.held_stack.count
								if (properties.targets[HeldItem].belt_shape == "straight" and total <= 8)
								or (properties.targets[HeldItem].belt_shape ~= "straight" and total <= 7) then
									catapult.active = true
									if (storage.HoverGFX[CatapulyDestroyNumber]) then
										for playerID, graphic in pairs(storage.HoverGFX[CatapulyDestroyNumber]) do
											graphic.destroy()
										end
										storage.HoverGFX[CatapulyDestroyNumber] = {}
									end
								else
									catapult.active = false
									if (storage.HoverGFX[CatapulyDestroyNumber] == nil) then
										storage.HoverGFX[CatapulyDestroyNumber] = {}
									end
									for ID, player in pairs(game.players) do
										if (storage.HoverGFX[CatapulyDestroyNumber][ID] == nil) then
											local hovering = false
											if (player.selected and player.selected.unit_number == catapult.unit_number) then
												hovering = true
											end
											storage.HoverGFX[CatapulyDestroyNumber][ID] = rendering.draw_text
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
								storage.FlyingItems[storage.FlightNumber] =
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
									tracing = catapultID,
									surface = catapult.surface,
									space = false --necessary
									}
								storage.FlightNumber = storage.FlightNumber + 1
							end
							catapult.active = false

						-- first time throws for items to this target
						elseif (properties.targets[HeldItem]
						and properties.targets[HeldItem].valid
						and storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])] == nil) then
							storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])] = {}
							storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])][HeldItem] = 0

						-- first time throws for this particular item to this target
						elseif (properties.targets[HeldItem]
						and properties.targets[HeldItem].valid
						and storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])]
						and storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])][HeldItem] == nil) then
							storage.OnTheWay[script.register_on_object_destroyed(properties.targets[HeldItem])][HeldItem] = 0
						end
					-- overflow prevention is set to off
					else
						catapult.active = true
					end

					-- if the thrower is still active after the checks then:
					if (catapult.active == true) then
						if (catapult.name == "RTThrower-PrimerThrower" and prototypes.entity["RTPrimerThrowerShooter-"..HeldItem]) then
							catapult.inserter_stack_size_override = 1
							catapult.active = false
							storage.PrimerThrowerLinks[script.register_on_object_destroyed(properties.entangled.detector)].ready = true
						else
							-- starting parameters
							local x = catapult.drop_position.x
							local y = catapult.drop_position.y
							local distance = math.sqrt((x-catapult.held_stack_position.x)^2 + (y-catapult.held_stack_position.y)^2)
							-- calcaulte projectile parameters
							local start=catapult.held_stack_position
							local speed = 0.18
							if (catapult.name == "RTThrower-EjectorHatchRT" or catapult.name == "RTThrower-FilterEjectorHatchRT") then
								distance = math.sqrt((x-catapult.position.x)^2 + (y-catapult.position.y)^2)
								start=catapult.position
								speed = 0.25
								--[[ catapult.surface.play_sound
								{
									path = "RTEjector",
									position = catapult.position,
									volume_modifier = 0.1
								} ]]
							else
								catapult.surface.play_sound
								{
									path = "RTThrow",
									position = catapult.position,
									volume_modifier = 0.2
								}
							end
							local AirTime = math.max(1, math.floor(distance/speed)) -- for super fast throwers that move right on top of their target
							local DestinationDestroyNumber
							if (settings.global["RTOverflowComp"].value == true and properties.InSpace == false) then
								if (properties.targets[HeldItem] ~= nil and properties.targets[HeldItem].valid) then
									DestinationDestroyNumber = script.register_on_object_destroyed(properties.targets[HeldItem])
									if (storage.OnTheWay[DestinationDestroyNumber] == nil) then
										storage.OnTheWay[DestinationDestroyNumber] = {}
										storage.OnTheWay[DestinationDestroyNumber][HeldItem] = catapult.held_stack.count
									elseif (storage.OnTheWay[DestinationDestroyNumber][HeldItem] == nil) then
										storage.OnTheWay[DestinationDestroyNumber][HeldItem] = catapult.held_stack.count
									else
										storage.OnTheWay[DestinationDestroyNumber][HeldItem] = storage.OnTheWay[DestinationDestroyNumber][HeldItem] + catapult.held_stack.count
									end
								elseif (properties.targets[HeldItem] == "nothing") then -- recheck pointing at nothing/things without unit_numbers
									properties.targets[HeldItem] = nil
								end
							end
							storage.FlyingItems[storage.FlightNumber] =
								{
									item=HeldItem,
									amount=catapult.held_stack.count,
									quality=catapult.held_stack.quality.name,
									thrower=catapult,
									ThrowerPosition=catapult.position,
									target={x=x, y=y},
									start=start,
									AirTime=AirTime,
									StartTick=game.tick,
									LandTick=game.tick+AirTime,
									destination=DestinationDestroyNumber,
									space=properties.InSpace,
									surface=catapult.surface,
								}
							if (properties.InSpace == false) then
								if (prototypes.entity["RTItemProjectile-"..HeldItem..speed*100]) then
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
								x = x + (-storage.OrientationUnitComponents[catapult.orientation].x * 100)
								y = y + (-storage.OrientationUnitComponents[catapult.orientation].y * 100)
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
								storage.FlyingItems[storage.FlightNumber].path = path
								storage.FlyingItems[storage.FlightNumber].space = true
								storage.FlyingItems[storage.FlightNumber].LandTick = game.tick+AirTime
								storage.FlyingItems[storage.FlightNumber].sprite = rendering.draw_sprite
									{
										sprite = "item/"..HeldItem,
										x_scale = 0.5,
										y_scale = 0.5,
										target = catapult.held_stack_position,
										surface = catapult.surface
									}
								storage.FlyingItems[storage.FlightNumber].spin = math.random(-10,10)*0.01
							end
							if (catapult.held_stack.item_number ~= nil) then
								local CloudStorage = game.create_inventory(1)
								CloudStorage.insert(catapult.held_stack)
								storage.FlyingItems[storage.FlightNumber].CloudStorage = CloudStorage
							end

							-- Ultracube irreplaceables detection & handling
							if storage.Ultracube and storage.Ultracube.prototypes.irreplaceable[HeldItem] then -- Ultracube mod is active, and the held item is an irreplaceable
								-- Sets cube_token_id and cube_should_hint for the new FlyingItems entry
								CubeFlyingItems.create_token_for(storage.FlyingItems[storage.FlightNumber])
							end
							
							storage.FlightNumber = storage.FlightNumber + 1
							catapult.held_stack.clear()
						end
					end
				end

			elseif (catapult.active == false and catapult.held_stack.valid_for_read == false) then
				catapult.active = true
			end

			if (properties.RangeAdjustable == true) then
				local range = catapult.get_signal({type="virtual", name="ThrowerRangeSignal"}, defines.wire_connector_id.circuit_red)
				if (properties.range==nil or properties.range~=range) then
					if (range > 0 and range <= catapult.prototype.inserter_drop_position[2]+0.1) then
						catapult.drop_position =
							{
								catapult.position.x + -range*storage.OrientationUnitComponents[catapult.orientation].x,
								catapult.position.y + -range*storage.OrientationUnitComponents[catapult.orientation].y
							}
						properties.range = range
						if (storage.CatapultList[CatapulyDestroyNumber]) then
							storage.CatapultList[CatapulyDestroyNumber].targets = {}
							for componentUN, PathsItsPartOf in pairs(storage.ThrowerPaths) do
								for ThrowerUN, TrackedItems in pairs(PathsItsPartOf) do
									if (ThrowerUN == CatapulyDestroyNumber) then
										storage.ThrowerPaths[componentUN][ThrowerUN] = {}
									end
								end
							end
						end
					end
				end
			end

		elseif (catapult.valid == false) then
			storage.CatapultList[catapultID] = nil
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
	defines.events.on_object_destroyed,
	require("script.event.entity_destroyed")
)


script.on_event(defines.events.on_player_changed_surface,
-- .player_index :: uint: The player who changed surfaces
-- .surface_index :: uint: The surface index the player was on
function(event)
local player = game.players[event.player_index]
local PlayerProperties = storage.AllPlayers[event.player_index]
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
		storage.OnTheWay = {}
	end
end)

script.on_event(defines.events.on_gui_closed,
function(event)
	local player = game.players[event.player_index]
	if (event.entity and event.entity.name == "DirectorBouncePlate" and storage.ThrowerPaths[script.register_on_object_destroyed(event.entity)] ~= nil) then
		for ThrowerUN, TrackedItems in pairs(storage.ThrowerPaths[script.register_on_object_destroyed(event.entity)]) do
			if (storage.CatapultList[ThrowerUN]) then
				for item, asthma in pairs(TrackedItems) do
					storage.CatapultList[ThrowerUN].targets[item] = nil
				end
			end
		end
		storage.ThrowerPaths[script.register_on_object_destroyed(event.entity)] = {}
	end
	if (player.gui.screen.RTZiplineTerminalGUI) then
		player.gui.screen.RTZiplineTerminalGUI.destroy()
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
	--hide the old one
	if (event.last_entity
	and storage.HoverGFX[script.register_on_object_destroyed(event.last_entity)]
	and storage.HoverGFX[script.register_on_object_destroyed(event.last_entity)][event.player_index]) then
		storage.HoverGFX[script.register_on_object_destroyed(event.last_entity)][event.player_index].visible = false
	end
	-- show the new one
	if (player.selected
	and storage.HoverGFX[script.register_on_object_destroyed(player.selected)]
	and storage.HoverGFX[script.register_on_object_destroyed(player.selected)][event.player_index]) then
		storage.HoverGFX[script.register_on_object_destroyed(player.selected)][event.player_index].visible = true
	end
end)

script.on_event(defines.events.on_pre_surface_deleted,
--surface_index :: uint
--name :: defines.events	Identifier of the event
--tick :: uint				Tick the event was generated.
function(event)
	for each, FlyingItem in pairs(storage.FlyingItems) do
		if (FlyingItem.surface.index == event.surface_index) then
            if (FlyingItem.sprite) then
				FlyingItem.sprite.destroy()
			end
			if (FlyingItem.shadow) then
				FlyingItem.shadow.destroy()
			end
			if (FlyingItem.destination ~= nil and storage.OnTheWay[FlyingItem.destination]) then
				storage.OnTheWay[FlyingItem.destination][FlyingItem.item] = storage.OnTheWay[FlyingItem.destination][FlyingItem.item] - FlyingItem.amount
			end
			if (FlyingItem.player) then
				SwapBackFromGhost(FlyingItem.player, FlyingItem)
			end
			storage.FlyingItems[each] = nil
		end
	end
end)

script.on_event(
"DebugAdvanceActionProcess",
function(event)
	local player = game.players[event.player_index]
	if (player.cursor_stack.valid_for_read == true) then
		local item = player.cursor_stack.name
		if (prototypes.entity["RTItemProjectile-"..item..25]) then
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
	else
		rendering.draw_animation
		{
			animation = "RTHoojinTime",
			x_scale = 0.5,
			y_scale = 0.5,
			target = player.character,
			surface = player.surface,
			time_to_live = 120,
			animation_speed = 0.5
		}
	end
end)

script.on_event(defines.events.on_research_finished,
--research	:: LuaTechnology		The researched technology
--by_script	:: boolean				If the technology was researched by script.
--name		:: defines.events		Identifier of the event
--tick		:: uint					Tick the event was generated.
function(event)
	if (event.research.name == "RTFocusedFlinging") then
		for each, properties in pairs(storage.CatapultList) do
			if (string.find(properties.entity.name, "RTThrower-") and properties.entity.name ~= "RTThrower-PrimerThrower") then
				properties.RangeAdjustable = true
			end
		end
	end
end)

script.on_event(defines.events.on_pre_player_left_game,
function(event)
	local player = game.players[event.player_index]
	local PlayerProperties = storage.AllPlayers[event.player_index]
	if (PlayerProperties.state == "zipline") then
		GetOffZipline(player, PlayerProperties)
	elseif (PlayerProperties.state == "jumping") then
		if (PlayerProperties.PlayerLauncher.tracker and storage.FlyingItems[PlayerProperties.PlayerLauncher.tracker] ~= nil) then
			local number = PlayerProperties.PlayerLauncher.tracker
			local FlyingItem = storage.FlyingItems[number]
			if (FlyingItem.sprite) then
				FlyingItem.sprite.destroy()
			end
			if (FlyingItem.shadow) then
				FlyingItem.shadow.destroy()
			end
			SwapBackFromGhost(player, FlyingItem)
			storage.FlyingItems[number] = nil
		end
	end
end)

script.on_event(
defines.events.on_gui_opened,
function(event)
    local player = game.players[event.player_index]
    local selected = player.selected
    if (selected and selected.valid and event.gui_type == 1) then
		if (selected.name == "RTZiplineTerminal") then
			if (storage.AllPlayers[event.player_index].state == "default"
			and player.character
			and (not string.find(player.character.name, "-jetpack"))
			and player.is_cursor_empty() == true) then
				if (player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].valid_for_read
				and string.find(player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name, "ZiplineItem")
				and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].valid_for_read
				and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].name == "RTProgrammableZiplineControlsItem") then
					player.opened = nil
					if (DistanceBetween(player.character.position, selected.position) <= 7) then
						ShowZiplineTerminalGUI(player, selected)
					else
						player.print({"zipline-stuff.range"})
					end
				else
					player.print({"zipline-stuff.terminalReqs"})
				end
			end

		elseif (selected.name == "RTTrainRamp"
			or selected.name == "RTTrainRampNoSkip"
			or selected.name == "RTMagnetTrainRamp"
			or selected.name == "RTMagnetTrainRampNoSkip"
			or selected.name == "RTMagnetRampDrain") then
			player.opened = nil

		elseif (selected.name == "DirectorBouncePlate") then
			player.opened = nil
			ShowDirectorGUI(player, selected)
		end
    end
end)

script.on_event(
defines.events.on_gui_closed,
function(event)
    local player = game.players[event.player_index]
	if (player.gui.screen.RTZiplineTerminalGUI) then
		player.gui.screen.RTZiplineTerminalGUI.destroy()
	end
	if (player.gui.screen.RTDirectorPadGUI) then
		player.gui.screen.RTDirectorPadGUI.destroy()
	end
end)

script.on_event(
defines.events.on_gui_elem_changed,
function(event)
	local element = event.element
	if (element.parent and element.parent.parent and element.parent.parent.name == "RTDirectorPadGUI") then
		local director = storage.BouncePadList[element.parent.parent.tags.ID].TheEntity
		local section = element.tags.section
		local slot = element.tags.slot
		if (element.elem_value) then
			director.get_or_create_control_behavior().get_section(section).set_slot(slot, {value={name=element.elem_value}})
		else
			director.get_or_create_control_behavior().get_section(section).clear_slot(slot)
		end
	end
end)

ElectricPoleBlackList = {PoleName="windows", ["factory-power-connection"]=true, ["factory-power-pole"]=true, ["factory-overflow-pole"]=true}
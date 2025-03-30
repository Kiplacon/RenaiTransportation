if script.active_mods["gvv"] then require("__gvv__.gvv")() end
if script.active_mods["Ultracube"] then CubeFlyingItems = require("script.ultracube.cube_flying_items") end

TrainConstants = require("__RenaiTransportation__/script/trains/constants")
require('util')
---- Space Age keikaku
------- improvements ✅
-- director pad range adjusting ✅
	-- change bounde pads from simple-entity to constant combinator ✅
	-- change on-build to default to 10 range, or set range/indicator according to the ghost signal value ✅
	-- copy/paste setting change bounce range value ✅
	-- Bounce pad ✅
	-- directed bounce pad ✅
	-- director bounce pad ✅
	-- migration names ✅
	-- interact cycling of range ✅
-- remove shadows from character ghosts ✅
	-- remove shadow layer from character prototype ✅
	-- animate character shadow separately ✅
		-- separate shadow sprite for manual animation ✅
-- generalize player launching with custom path ✅
-- better unloading of impact wagons at non-cardinal angles ✅
-- messages when toggling stuff ✅
-- zipline path to furthest connection ✅

------- New stuff
-- trapdoor wagon ✅
	-- trapdoor switch (rail signal all 16 directions) ✅
	-- trapdoor switch ramp ✅
		-- toggles trapdoor only while train is in flight, switches back upon landing ✅
	-- trapdoor switch placer graphics ✅
	-- trapdoor open/close sound ✅
	-- trapdoor open/close graphic ✅
	-- trapdoor toggles when stopping/leaving a station with a certain signal fed into it ✅
-- electromagnetic item cannon (rail gun)? ✅
	-- not placable in space ✅
	-- seal 1 stack of an item into a shell ✅
		-- procedural recipe/shell for every game item. Failsafe for items loaded after ✅
	-- can bounce off of reinforced plates that can be rotated to face the 4 cardinal directions. up/down and left/right are basically the same thing for this ✅
	-- falls to the ground if nothing hit after X tiles ✅
		-- damages things in a small area ✅
		-- vomits out the contents of the shell (lose some?) ✅
	-- catcher chute catches shell and drops contents into chest ✅
	-- merging chute. X-shaped, shells can enter from different directions and leave from one ✅
	-- diverging chure. T-shaped, shells enter from one and alternate leaving from the other two ✅
	-- laser pointer to test trail ✅
-- belt ramp ✅
	-- fast, express, and tungsten variants ✅
	-- items fly off into space at an angle ✅
	-- player can be launched by it ✅
-- vacuum hatch ✅
	-- connection to entity behind it ✅
	-- SUCC particles ✅
-- dynamic zipline, get on from anywhere and autodrive anywhere ✅
	-- include terminal list pop up ✅
	-- pentapod egg for SA, fish for vanilla ✅
-- techs for the above ✅
	-- nauvis: belt ramp, vacuum hatch ✅
	-- Fulgora: item cannon, ricochet panels, chutes ✅
	-- Gleba: AI zipline controller, primer throwers ✅
	-- Vulcanus: trapdoor wagon and switches and switch ramps ✅
	-- Aquilo: nothing yet
	-- check with vanilla start ✅
-- straight up grief ✅
	-- items in destroyed chests/containers fly out ✅
	-- getting hit by a train/car knocks you away assuming you survive the hit ✅
	-- items on the floor of a space platform fly away when the ship takes off ✅
	-- settings to turn these off ✅

------- bugs
-- crash on interact to toggle things not currently enabled ✅
-- rotating blueprints of trapdoor switches on angles doesnt always work due to rounding errors or something idk if you dont rotate it its fine ✅
-- vacuum hatch full inventory loop (is fine actually, just bounce them off a short distance and only suck up 1 item per tick) ✅
-- hover range indicator for bounce pads not synced with current setting ✅
-- magnet ramp migration ✅
-- director pad migration ✅
-- losing train groups when incrementing schedules. Use train.get_schedule() and use go_to_station(schedule_index) if train had a group ✅

------- possible future stuff
-- deflector pad, diagonal
-- Aquilo: launch trains iterplanetary

------- impossible atm
-- thrown item rework when animations can have dynamically rotated sprites
	-- particle for each item
	-- 10000 invisible particles with unique trigger IDs to cycle through
	-- sprite and invisible particle thrown on top of each other together to create the illusion of a single entity 


-- Setup tables and stuff for new/existing saves ----
script.on_init(
	require("script.event.init")
)

-- game version changes, prototypes change, startup mod settings change, adding or removing mods, mod version changes
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
		defines.events.on_post_entity_died, -- | ghost created when something dies
		defines.events.on_space_platform_built_entity -- | built by space platform
	},
	require("script.event.entity_built")
)

script.on_event(defines.events.on_entity_died ,
function(event)
	if settings.global["RTChestPop"].value == true
	and (event.entity.type == "container"
	or event.entity.type == "logistic-container"
	or event.entity.type == "cargo-wagon"
	or event.entity.type == "car") then
		local container = event.entity
		local scale = ((container.bounding_box.right_bottom.x-container.bounding_box.left_top.x)+(container.bounding_box.right_bottom.y-container.bounding_box.left_top.y))
		for i = 1, #container.get_output_inventory() do
			local stack = container.get_output_inventory()[i]
			if (stack.valid_for_read == true) then
				stack.count = math.ceil(stack.count*0.5) -- half the items lost in the destruction
				local GroupSize = math.ceil((stack.count/17))
				for _ = 1, math.floor(stack.count/GroupSize) do
					-- unit vector
					local angle = math.random(0, 100)*0.01
					local xUnit = math.cos(2*math.pi*angle)
					local yUnit = math.sin(2*math.pi*angle)
					-- flight arc
					local speed = math.random(10, 90)*0.0008 + (scale*0.01)
					local AirTime = math.max(1, math.floor(speed*800))
					local TargetX = event.entity.position.x + (xUnit*speed*AirTime)
					local TargetY = event.entity.position.y + (yUnit*speed*AirTime)
					local distance = DistanceBetween(container.position, {x=TargetX, y=TargetY})
					local vector = {x=TargetX-container.position.x, y=TargetY-container.position.y}
					local arc = 5/(distance^2)
					local path = {}
					for j = 0, AirTime do
						local progress = j/AirTime
						path[j] =
						{
							x = container.position.x+(progress*vector.x),
							y = container.position.y+(progress*vector.y),
							height = progress * (1-progress) / arc
						}
					end
					InvokeThrownItem({
						type = "CustomPath",
						render_layer = "elevated-higher-object",
						stack = stack,
						ThrowFromStackAmount = GroupSize,
						start = container.position,
						target = {x=TargetX, y=TargetY},
						path = path,
						AirTime = AirTime,
						surface=container.surface,
					})
				end
			end
		end
	end
end
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
		if (ItsStuff.entity and ItsStuff.entity.valid) then
			-- it's good
		else
			storage.BouncePadList[unitID] = nil
		end
	end

	for unitID, ItsStuff in pairs(storage.TrainRamps) do
		if (ItsStuff.entity and ItsStuff.entity.valid) then
			-- it's good
		else
			storage.TrainRamps[unitID] = nil
		end
	end
end)

-- Thrower Check
---- checks if thrower inserters have something in their hands and it's in the throwing position, then creates the approppriate projectile ----

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

-- Zipline mount/dismount
script.on_event(
	"RTOnOffZipline",
	require("script.event.GetOnOrOffZipline")
)

-- Zipline brakes
script.on_event(
	"RTZiplineBrake",
	function (event) -- has .name = event ID number, .tick = tick number, .player_index, and .input_name = custom input name
		local PlayerProperties = storage.AllPlayers[event.player_index]
		local player = game.players[event.player_index]
		if (PlayerProperties.state == "zipline"
		and PlayerProperties.zipline
		and PlayerProperties.zipline.path == nil
		and math.abs(PlayerProperties.zipline.LetMeGuideYou.speed) > 0
		) then
			--PlayerProperties.zipline.LetMeGuideYou.speed = 0
			PlayerProperties.zipline.braking = true
			player.character.surface.play_sound
			{
				path = "RTZipBrake",
				position = player.character.position,
				volume_modifier = 0.15
			}
		end
	end
)

-- throw
script.on_event(
	"RTThrow",
	function(event1)
		local player = game.get_player(event1.player_index)
		local CursorPosition = event1.cursor_position
		if (player
		and player.character
		and player.character.surface.name == player.surface.name
		and player.cursor_stack
		and player.cursor_stack.valid_for_read == true) then
			if (DistanceBetween(player.character.position, CursorPosition) <= player.character.reach_distance) then
				InvokeThrownItem({
					type = "ReskinnedStream",
					stack = player.cursor_stack,
					ThrowFromStackAmount = 1,
					start = OffsetPosition(player.character.position, {0, -1}),
					target = CursorPosition,
					surface = player.surface,
				})
				player.surface.play_sound
					{
						path = "RTThrow",
						position = player.position,
						--volume_modifier = 0.1
					}
			else
				rendering.draw_circle{
					color = {217, 145, 21},
					radius = player.character.reach_distance,
					target = player.character,
					surface = player.character.surface,
					players = {player},
					time_to_live = 60
				}
			end
		end
	end
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
-- .player_indent: Ter who changed surfaces
-- .surface_index :: uint: Te surace index the player was on
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
		ResetPathComponentOverflowTracking(event.entity)
		--[[ for ThrowerUN, TrackedItems in pairs(storage.ThrowerPaths[script.register_on_object_destroyed(event.entity)]) do
			if (storage.CatapultList[ThrowerUN]) then
				for item, asthma in pairs(TrackedItems) do
					storage.CatapultList[ThrowerUN].targets[item] = nil
				end
			end
		end ]]
		--storage.ThrowerPaths[script.register_on_object_destroyed(event.entity)] = {}
	end
	if (player.gui.screen.RTZiplineTerminalGUI) then
		player.gui.screen.RTZiplineTerminalGUI.destroy()
	end
	if (player.gui.screen.RTDirectorPadGUI) then
		player.gui.screen.RTDirectorPadGUI.destroy()
	end
end)

-- a bunch of functions used in various other places
require("script.MiscFunctions")
require("script.GUIs")
require("script.ThrowItemFunctions")

script.on_event(defines.events.on_gui_click,
	require("script.event.ClickGUI")
)

-- displaying things on hover
script.on_event(defines.events.on_selected_entity_changed,
--player_index	:: uint			The player whose selected entity changed.
--last_entity	:: LuaEntity?	The last selected entity if it still exists and there was one.
function(event)
	local player = game.players[event.player_index]
	--[[ --hide the old one
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
	end ]]

	--hide the old one
	if (event.last_entity
	and storage.BouncePadList[script.register_on_object_destroyed(event.last_entity)]
	and storage.BouncePadList[script.register_on_object_destroyed(event.last_entity)].arrow) then
		storage.BouncePadList[script.register_on_object_destroyed(event.last_entity)].arrow.visible = storage.BouncePadList[script.register_on_object_destroyed(event.last_entity)].ShowArrow
	end
	-- show the new one
	if (player.selected
	and storage.BouncePadList[script.register_on_object_destroyed(player.selected)]
	and storage.BouncePadList[script.register_on_object_destroyed(player.selected)].arrow) then
		storage.BouncePadList[script.register_on_object_destroyed(player.selected)].arrow.visible = true
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
	if (player.cursor_stack and player.cursor_stack.valid_for_read == true) then
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
	elseif (player.character) then
		rendering.draw_animation
			{
				animation = "RTHoojinTime",
				x_scale = 0.5,
				y_scale = 0.5,
				target = {
					entity = player.character,
				},
				surface = player.surface,
				time_to_live = 120,
				animation_speed = 0.5
			}
		player.surface.create_entity
			{
				name="RTSaysYourCrosshairIsTooLow",
				target=player.character,
				position={420,69},
			}.time_to_live=120
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
			PlayerProperties.state = "default"
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
				player.opened = nil
				if (player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].valid_for_read
				and string.find(player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name, "ZiplineItem")
				and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].valid_for_read
				and (player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].name == "RTProgrammableZiplineControlsItem"
					or player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].name == "RTAIZiplineControlsItem")
				) then
					
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
			or selected.name == "RTMagnetRampDrain"
			or selected.name == "RTBouncePlate"
			or selected.name == "DirectedBouncePlate"
			or selected.name == "PlayerLauncher"
			or selected.name == "RTRicochetPanel") then
			player.opened = nil

		elseif (selected.name == "DirectorBouncePlate") then
			player.opened = nil
			ShowDirectorGUI(player, selected)

		elseif (selected.name == "RTItemCannon") then
			player.opened = storage.ItemCannons[script.register_on_object_destroyed(selected)].chest
		end
    end
end)

script.on_event(
defines.events.on_gui_elem_changed,
function(event)
	local element = event.element
	if (element.parent and element.parent.parent and element.parent.parent.name == "RTDirectorPadGUI") then
		local director = storage.BouncePadList[element.parent.parent.tags.ID].entity
		local section = element.tags.section
		local slot = element.tags.slot
		if (element.elem_value) then
			director.get_or_create_control_behavior().get_section(section).set_slot(slot, {value={name=element.elem_value}})
		else
			director.get_or_create_control_behavior().get_section(section).clear_slot(slot)
		end
		ResetPathComponentOverflowTracking(director)
	end
end)

script.on_event(
defines.events.on_chart_tag_modified,
function(event)
	for OnDestroyNumber, properties in pairs(storage.ZiplineTerminals) do
		if (properties.tag and properties.tag.valid and properties.tag.tag_number == event.tag.tag_number) then
			properties.name = event.tag.text
		end
	end
end)

script.on_event(defines.events.on_space_platform_changed_state,
	require("script.event.platform_change_state")
)

script.on_event(defines.events.on_train_changed_state,
--train		:: LuaTrain	
--old_state	:: defines.train_state
function(event)
	local train = event.train
	if (train.state == defines.train_state.wait_station and train.station ~= nil and train.station.get_signal({type="virtual", name="StationTrapdoorWagonSignal"}, defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green) > 0)
	or (event.old_state == defines.train_state.wait_station) then
		for _, wagon in pairs(train.cargo_wagons) do
			if (wagon.name == "RTTrapdoorWagon") then
				ToggleTrapdoorWagon(wagon)
			end
		end
	end
end)

script.on_event(
defines.events.on_player_mined_entity,
function(event)
	local player = game.players[event.player_index]
	if (player.character and player.character.character_mining_speed_modifier > 0.1 
	and (
			string.find(event.entity.name, "HatchRT")
			or event.entity.name == "RTTrapdoorSwitch"
		)
	) then
		local back = player.character.character_mining_speed_modifier
		if (storage.clock[game.tick+30] == nil) then
			storage.clock[game.tick+30] = {MiningSpeedRevert={}}
		else
			if (storage.clock[game.tick+30].MiningSpeedRevert == nil) then
				storage.clock[game.tick+30].MiningSpeedRevert = {}
			end
		end
		table.insert(storage.clock[game.tick+30].MiningSpeedRevert, {character=player.character, back=back})
		player.character.character_mining_speed_modifier = 0.1
	end
end)

ElectricPoleBlackList = {PoleName="windows", ["factory-power-connection"]=true, ["factory-power-pole"]=true, ["factory-overflow-pole"]=true}

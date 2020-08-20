---- Setup tables and stuff for new/existing saves ----
script.on_init( -- new saves
function()
	if (global.CatapultList == nil) then
		global.CatapultList = {}		
	end

	if (global.AllPlayers == nil) then
		global.AllPlayers = {}		
	end
	
	if (global.OrientationUnitComponents == nil) then
		global.OrientationUnitComponents = {}
		global.OrientationUnitComponents[0] = {x = 0, y = -1, name = "up"}
		global.OrientationUnitComponents[0.25] = {x = 1, y = 0, name = "right"}
		global.OrientationUnitComponents[0.5] = {x = 0, y = 1, name = "down"}
		global.OrientationUnitComponents[0.75] = {x = -1, y = 0, name = "left"}
	end
	
	for PlayerID, PlayerLuaData in pairs(game.players) do
		global.AllPlayers[PlayerID] = {}
	end
	
	if (global.FlyingTrains == nil) then
		global.FlyingTrains = {}		
	end
	
	if (global.BouncePadList == nil) then
		global.BouncePadList = {}		
	end
end)

script.on_configuration_changed( --game version changes, prototypes change, startup mod settings change, and any time mod versions change including adding or removing mods
function()
	if (global.CatapultList == nil) then
		global.CatapultList = {}		
	end
	
	if (global.OrientationUnitComponents == nil) then
		global.OrientationUnitComponents = {}
		global.OrientationUnitComponents[0] = {x = 0, y = -1, name = "up"}
		global.OrientationUnitComponents[0.25] = {x = 1, y = 0, name = "right"}
		global.OrientationUnitComponents[0.5] = {x = 0, y = 1, name = "down"}
		global.OrientationUnitComponents[0.75] = {x = -1, y = 0, name = "left"}
	end	
	
	if (global.AllPlayers == nil) then
		global.AllPlayers = {}		
	end
	
	for PlayerID, PlayerLuaData in pairs(game.players) do
		global.AllPlayers[PlayerID] = {}
	end
	
	if (global.FlyingTrains == nil) then
		global.FlyingTrains = {}		
	end
	
	if (global.BouncePadList == nil) then
		global.BouncePadList = {}		
	end
end)

---- Add new players to the AllPlayers table ----
script.on_event(defines.events.on_player_created,
function(event)
	if (global.AllPlayers[event.player_index] == nil) then
		global.AllPlayers[event.player_index] = {}
	end	
end)

---- adds new thrower inserters to the list of throwers to check. Make player launchers (reskined inserters) to be inoperable and inactive ----
---- built by hand ----
script.on_event(defines.events.on_built_entity, 
function(event)
	if (string.find(event.created_entity.name, "RTThrower-")) then
		global.CatapultList[event.created_entity.unit_number] = event.created_entity
	
	elseif (event.created_entity.name == "PlayerLauncher") then
		event.created_entity.operable = false
		event.created_entity.active = false
	
	elseif (string.find(event.created_entity.name, "BouncePlate") and not string.find(event.created_entity.name, "Train")) then
		global.BouncePadList[event.created_entity.unit_number] = {TheEntity = event.created_entity}
		if (event.created_entity.name == "DirectedBouncePlate") then
			event.created_entity.operable = false
			if (event.created_entity.orientation == 0) then
				direction = "UD"
				xflip = 1
				yflip = 1
			elseif (event.created_entity.orientation == 0.25) then
				direction = "RL"
				xflip = 1
				yflip = 1
			elseif (event.created_entity.orientation == 0.5) then
				direction = "UD"
				xflip = 1
				yflip = -1
			elseif (event.created_entity.orientation == 0.75) then
				direction = "RL"
				xflip = -1
				yflip = 1
			end
			global.BouncePadList[event.created_entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = event.created_entity.surface,
					target = event.created_entity,
					only_in_alt_mode = true,
					x_scale = xflip,
					y_scale = yflip,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}			
		elseif (event.created_entity.name == "BouncePlate") then
			global.BouncePadList[event.created_entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = event.created_entity.surface,
					target = event.created_entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (event.created_entity.name == "SignalBouncePlate") then
			global.BouncePadList[event.created_entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = event.created_entity.surface,
					target = event.created_entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (event.created_entity.name == "PrimerBouncePlate") then
			global.BouncePadList[event.created_entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerRangeOverlay",
					surface = event.created_entity.surface,
					target = event.created_entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		elseif (event.created_entity.name == "PrimerSpreadBouncePlate") then
			global.BouncePadList[event.created_entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerSpreadRangeOverlay",
					surface = event.created_entity.surface,
					target = event.created_entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		end
	end
end)
---- built by robot ----
script.on_event(defines.events.on_robot_built_entity, 
function(event)
	if (string.find(event.created_entity.name, "RTThrower-")) then
		global.CatapultList[event.created_entity.unit_number] = event.created_entity
	
	elseif (event.created_entity.name == "PlayerLauncher") then
		event.created_entity.operable = false
		event.created_entity.active = false
		
	elseif (string.find(event.created_entity.name, "BouncePlate") and not string.find(event.created_entity.name, "Train")) then
		global.BouncePadList[event.created_entity.unit_number] = {TheEntity = event.created_entity}
		if (event.created_entity.name == "DirectedBouncePlate") then
			event.created_entity.operable = false
			if (event.created_entity.orientation == 0) then
				direction = "UD"
				xflip = 1
				yflip = 1
			elseif (event.created_entity.orientation == 0.25) then
				direction = "RL"
				xflip = 1
				yflip = 1
			elseif (event.created_entity.orientation == 0.5) then
				direction = "UD"
				xflip = 1
				yflip = -1
			elseif (event.created_entity.orientation == 0.75) then
				direction = "RL"
				xflip = -1
				yflip = 1
			end
			global.BouncePadList[event.created_entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = event.created_entity.surface,
					target = event.created_entity,
					only_in_alt_mode = true,
					x_scale = xflip,
					y_scale = yflip,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}			
		elseif (event.created_entity.name == "BouncePlate") then
			global.BouncePadList[event.created_entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = event.created_entity.surface,
					target = event.created_entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (event.created_entity.name == "SignalBouncePlate") then
			global.BouncePadList[event.created_entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = event.created_entity.surface,
					target = event.created_entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (event.created_entity.name == "PrimerBouncePlate") then
			global.BouncePadList[event.created_entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerRangeOverlay",
					surface = event.created_entity.surface,
					target = event.created_entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		elseif (event.created_entity.name == "PrimerSpreadBouncePlate") then
			global.BouncePadList[event.created_entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerSpreadRangeOverlay",
					surface = event.created_entity.surface,
					target = event.created_entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		end
		
	end
end)
---- built by script ----
script.on_event(defines.events.script_raised_built, 
function(event)
	if (string.find(event.entity.name, "RTThrower-")) then
		global.CatapultList[event.entity.unit_number] = event.entity
	
	elseif (event.entity.name == "PlayerLauncher") then
		event.entity.operable = false
		event.entity.active = false

	elseif (string.find(event.entity.name, "BouncePlate") and not string.find(event.entity.name, "Train")) then
		global.BouncePadList[event.entity.unit_number] = {TheEntity = event.entity}
		if (event.entity.name == "DirectedBouncePlate") then
			event.entity.operable = false
			if (event.entity.orientation == 0) then
				direction = "UD"
				xflip = 1
				yflip = 1
			elseif (event.entity.orientation == 0.25) then
				direction = "RL"
				xflip = 1
				yflip = 1
			elseif (event.entity.orientation == 0.5) then
				direction = "UD"
				xflip = 1
				yflip = -1
			elseif (event.entity.orientation == 0.75) then
				direction = "RL"
				xflip = -1
				yflip = 1
			end
			global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = event.entity.surface,
					target = event.entity,
					only_in_alt_mode = true,
					x_scale = xflip,
					y_scale = yflip,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}			
		elseif (event.entity.name == "BouncePlate") then
			global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = event.entity.surface,
					target = event.entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (event.entity.name == "SignalBouncePlate") then
			global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = event.entity.surface,
					target = event.entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (event.entity.name == "PrimerBouncePlate") then
			global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerRangeOverlay",
					surface = event.entity.surface,
					target = event.entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		elseif (event.entity.name == "PrimerSpreadBouncePlate") then
			global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerSpreadRangeOverlay",
					surface = event.entity.surface,
					target = event.entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		end

	end
end)
---- cloned by script ----
script.on_event(defines.events.on_entity_cloned, 
function(event)
	if (string.find(event.destination.name, "RTThrower-")) then
		global.CatapultList[event.destination.unit_number] = event.destination
	
	elseif (event.destination.name == "PlayerLauncher") then
		event.destination.operable = false
		event.destination.active = false

	elseif (string.find(event.destination.name, "BouncePlate") and not string.find(event.destination.name, "Train")) then
		global.BouncePadList[event.destination.unit_number] = {TheEntity = event.destination}
		if (event.destination.name == "DirectedBouncePlate") then
			event.destination.operable = false
			if (event.destination.orientation == 0) then
				direction = "UD"
				xflip = 1
				yflip = 1
			elseif (event.destination.orientation == 0.25) then
				direction = "RL"
				xflip = 1
				yflip = 1
			elseif (event.destination.orientation == 0.5) then
				direction = "UD"
				xflip = 1
				yflip = -1
			elseif (event.destination.orientation == 0.75) then
				direction = "RL"
				xflip = -1
				yflip = 1
			end
			global.BouncePadList[event.destination.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = event.destination.surface,
					target = event.destination,
					only_in_alt_mode = true,
					x_scale = xflip,
					y_scale = yflip,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}			
		elseif (event.destination.name == "BouncePlate") then
			global.BouncePadList[event.destination.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = event.destination.surface,
					target = event.destination,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (event.destination.name == "SignalBouncePlate") then
			global.BouncePadList[event.destination.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = event.destination.surface,
					target = event.destination,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (event.destination.name == "PrimerBouncePlate") then
			global.BouncePadList[event.destination.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerRangeOverlay",
					surface = event.destination.surface,
					target = event.destination,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		elseif (event.destination.name == "PrimerSpreadBouncePlate") then
			global.BouncePadList[event.destination.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerSpreadRangeOverlay",
					surface = event.destination.surface,
					target = event.destination,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		end		
	end
end)
---- revived(?) ----
script.on_event(defines.events.script_raised_revive, 
function(event)
	if (string.find(event.entity.name, "RTThrower-")) then
		global.CatapultList[event.entity.unit_number] = event.entity
	
	elseif (event.entity.name == "PlayerLauncher") then
		event.entity.operable = false
		event.entity.active = false
	
	elseif (string.find(event.entity.name, "BouncePlate") and not string.find(event.entity.name, "Train")) then
		global.BouncePadList[event.entity.unit_number] = {TheEntity = event.entity}
		if (event.entity.name == "DirectedBouncePlate") then
			event.entity.operable = false
			if (event.entity.orientation == 0) then
				direction = "UD"
				xflip = 1
				yflip = 1
			elseif (event.entity.orientation == 0.25) then
				direction = "RL"
				xflip = 1
				yflip = 1
			elseif (event.entity.orientation == 0.5) then
				direction = "UD"
				xflip = 1
				yflip = -1
			elseif (event.entity.orientation == 0.75) then
				direction = "RL"
				xflip = -1
				yflip = 1
			end
			global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = event.entity.surface,
					target = event.entity,
					only_in_alt_mode = true,
					x_scale = xflip,
					y_scale = yflip,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}			
		elseif (event.entity.name == "BouncePlate") then
			global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = event.entity.surface,
					target = event.entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (event.entity.name == "SignalBouncePlate") then
			global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = event.entity.surface,
					target = event.entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (event.entity.name == "PrimerBouncePlate") then
			global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerRangeOverlay",
					surface = event.entity.surface,
					target = event.entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		elseif (event.entity.name == "PrimerSpreadBouncePlate") then
			global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerSpreadRangeOverlay",
					surface = event.entity.surface,
					target = event.entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		end
	end
end)


script.on_event(defines.events.on_player_rotated_entity,
function(event)
	if (event.entity.name == "DirectedBouncePlate" and global.BouncePadList[event.entity.unit_number] ~= nil) then
		CantSeeMe = rendering.get_visible(global.BouncePadList[event.entity.unit_number].arrow)
		rendering.destroy(global.BouncePadList[event.entity.unit_number].arrow)
		if (event.entity.orientation == 0) then
			direction = "UD"
			xflip = 1
			yflip = 1
		elseif (event.entity.orientation == 0.25) then
			direction = "RL"
			xflip = 1
			yflip = 1
		elseif (event.entity.orientation == 0.5) then
			direction = "UD"
			xflip = 1
			yflip = -1
		elseif (event.entity.orientation == 0.75) then
			direction = "RL"
			xflip = -1
			yflip = 1
		end
		global.BouncePadList[event.entity.unit_number].arrow = rendering.draw_sprite
			{
				sprite = "RTDirectedRangeOverlay"..direction,
				surface = event.entity.surface,
				target = event.entity,
				--time_to_live = 240,
				only_in_alt_mode = true,
				visible = CantSeeMe,
				x_scale = xflip,
				y_scale = yflip,
				tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
			}
	end
end)

script.on_nth_tick(18000, 
function(event)
	for unitID, ItsStuff in pairs(global.BouncePadList) do
		if (ItsStuff.TheEntity and ItsStuff.TheEntity.valid) then
			-- it's good
		else
			global.BouncePadList[unitID] = nil
		end
	end
end)


---- checks if thrower inserters have something in their hands and it's in the throwing position, then creates the approppriate projectile ----
script.on_nth_tick(3, 
function(event)
	if (global.CatapultList ~= {}) then
		for catapultID, catapult in pairs(global.CatapultList) do
		
			BurnerSelfRefuelCompensation = 0.2
			if (catapult.valid and catapult.burner == nil and catapult.energy/catapult.electric_buffer_size >= 0.9) then
				catapult.active = true
				BurnerSelfRefuelCompensation = 0
			elseif (catapult.valid and catapult.burner == nil) then
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
			
			if (catapult.valid and catapult.active == true and catapult.held_stack.valid_for_read) then
				if (catapult.orientation == 0    and catapult.held_stack_position.y >= catapult.position.y+BurnerSelfRefuelCompensation)
				or (catapult.orientation == 0.25 and catapult.held_stack_position.x <= catapult.position.x-BurnerSelfRefuelCompensation)
				or (catapult.orientation == 0.50 and catapult.held_stack_position.y <= catapult.position.y-BurnerSelfRefuelCompensation)	
				or (catapult.orientation == 0.75 and catapult.held_stack_position.x >= catapult.position.x+BurnerSelfRefuelCompensation) 
				then
					for i = 1, catapult.held_stack.count do
						catapult.surface.create_entity
							({
							name = catapult.held_stack.name.."-projectileFromRenaiTransportation", 
							position = catapult.position, --required setting for rendering, doesn't affect spawn
							source_position = catapult.held_stack_position, --launch from
							target_position = catapult.drop_position --launch to
							})
					end
					catapult.held_stack.clear()
				end
				
			elseif (catapult.valid == false) then
				global.CatapultList[catapultID] = nil

			end
		end
	end
end)


---- When a projectile lands and its effect_id is triggered, what to do ----
script.on_event(defines.events.on_script_trigger_effect,
function (event) --has .effect_id, .surface_index, and .source_position, .source_entity, .target_position, and .target_entity depending on how the effect was triggered

---- If it's from this mod ----	
if (string.find(event.effect_id, "-LandedRT")) then

	---- What did it land on? ----
	ThingLandedOn = game.get_surface(event.surface_index).find_entities_filtered
		{
			position = event.target_position,
			collision_mask = "object-layer"
		}[1] -- in theory only one thing should be detected in the object layer this way

	if (ThingLandedOn ~= nil) then -- if it landed on something
		if (string.find(ThingLandedOn.name, "BouncePlate")) then -- if that thing was a bounce plate
			
			if (string.find(ThingLandedOn.name, "DirectedBouncePlate")) then
				unitx = global.OrientationUnitComponents[ThingLandedOn.orientation].x
				unity = global.OrientationUnitComponents[ThingLandedOn.orientation].y
				traveling = global.OrientationUnitComponents[ThingLandedOn.orientation].name
			else
				---- "From" details ----
				---- I set thrown things to have a range just short of dead center to detect what direction they came from ----
				if (ThingLandedOn.position.y < event.target_position.y) then
					unitx = 0
					unity = -1
					traveling = "up"
				elseif(ThingLandedOn.position.y > event.target_position.y) then
					unitx = 0
					unity = 1
					traveling = "down"
				elseif(ThingLandedOn.position.x < event.target_position.x) then
					unitx = -1
					unity = 0
					traveling = "left"
				elseif(ThingLandedOn.position.x > event.target_position.x) then
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
			if (ThingLandedOn.name == "PrimerBouncePlate" and game.entity_prototypes[string.gsub(event.effect_id, "-LandedRT", "-projectileFromRenaiTransportationPrimed")]) then
				primable = "Primed"
				RangeBonus = 30
				tunez = "PrimeClick"
				effect = "PrimerBouncePlateParticle"
			elseif (ThingLandedOn.name == "PrimerSpreadBouncePlate" and game.entity_prototypes[string.gsub(event.effect_id, "-LandedRT", "-projectileFromRenaiTransportationPrimed")]) then
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
			local cheesewheel = 
			ThingLandedOn.surface.create_entity
				({
				name = string.gsub(event.effect_id, "-LandedRT", "-projectileFromRenaiTransportation")..primable,
				position = ThingLandedOn.position, --required setting for rendering, doesn't affect spawn
				source = event.source_entity, --defaults to nil if there was no source_entity and uses source_position instead
				source_position = ThingLandedOn.position,
				target_position = {ThingLandedOn.position.x  +unitx*(range+RangeBonus)  +unity*(SidewaysShift), ThingLandedOn.position.y  +unity*(range+RangeBonus)  +unitx*(SidewaysShift)},
				force = ThingLandedOn.force
				})
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
			
			---- Handling players ---- 
			if (event.source_entity ~= nil) then
				event.source_entity.teleport(ThingLandedOn.position)
				global.AllPlayers[event.source_entity.player.index].direction = traveling
				global.AllPlayers[event.source_entity.player.index].StartMovementTick = event.tick
				global.AllPlayers[event.source_entity.player.index].LastBouncedOn = ThingLandedOn.name	
				global.AllPlayers[event.source_entity.player.index].GuideProjectile = cheesewheel
			end	
				
		---- If its a character (because it uses the test-LandedRT effect_id) destroy what they land on so they dont get stuck ----
		elseif (event.effect_id == "test-LandedRT") then
			
			---- The only thing that doesn't .die() is a cliff ---- 
			if (ThingLandedOn.name == "cliff") then
				global.AllPlayers[event.source_entity.player.index].GuideProjectile = nil
				event.source_entity.teleport(event.source_entity.surface.find_non_colliding_position("iron-chest", event.target_position, 0, 0.5))
			end
			
			---- Damage the player based on thing's size and destroy what they landed on to prevent getting stuck ----
			game.get_player(event.source_entity.player.index).character.destructible = true	
			event.source_entity.player.character.damage(10*(ThingLandedOn.bounding_box.right_bottom.x-ThingLandedOn.bounding_box.left_top.x)*(ThingLandedOn.bounding_box.right_bottom.y-ThingLandedOn.bounding_box.left_top.y), "neutral", "impact", ThingLandedOn)
			ThingLandedOn.die()
			
		---- presumably the thrown thing is an item if not a character ----
		---- If it landed on an open container, insert it ----
		elseif (ThingLandedOn.name == "OpenContainer" and ThingLandedOn.can_insert({name=string.gsub(event.effect_id, "-LandedRT", "")})) then
			ThingLandedOn.insert({name=string.gsub(event.effect_id, "-LandedRT", ""), count=1})
		
		---- If the thing it landed on has an inventory and a hatch, insert the item ----
		elseif (ThingLandedOn.surface.find_entity('HatchRT', event.target_position) and ThingLandedOn.can_insert({name=string.gsub(event.effect_id, "-LandedRT", "")}) ) then
			ThingLandedOn.insert({name=string.gsub(event.effect_id, "-LandedRT", ""), count=1})
			
		---- otherwise it bounces off whatever it landed on and lands as an item on the nearest empty space within 10 tiles. destroyed if no space ----
		else	
			game.get_surface(event.surface_index).spill_item_stack
				(
					game.get_surface(event.surface_index).find_non_colliding_position("item-on-ground", event.target_position, 0, 0.1),
					{name=string.gsub(event.effect_id, "-LandedRT", ""), count=1}
				)
		end
	
	---- if the item/character lands in the water, it's gone ----
	elseif (game.get_surface(event.surface_index).find_tiles_filtered{position = event.target_position, radius = 1, limit = 1, collision_mask = "player-layer"}[1] ~= nil) then -- in theory, tiles the player cant walk on are some sort of fluid or other non-survivable ground
		
		---- drown the character ----
		if (event.source_entity ~= nil) then
			game.get_player(event.source_entity.player.index).character.destructible = true
			game.get_player(event.source_entity.player.index).character.die()
		end
		
		---- splash ----
		game.get_surface(event.surface_index).create_entity
			({                     
				name = "water-splash",                     
				position = event.target_position
			})
		
		---- dont drop an item ----
	
	---- if thrown thing didn't land on anything and not in water, i don't want characters to do anything upon landing. it would cause an error if it got to the item drop code  ----
	elseif (event.effect_id == "test-LandedRT") then
		--nothing
	
	---- the presumably thrown item lands as an item on the ground ----
	else --if it fell on nothing just drop it
		game.get_surface(event.surface_index).spill_item_stack({event.target_position.x, event.target_position.y}, {name=string.gsub(event.effect_id, "-LandedRT", ""), count=1})

		--[[ random item landing offset
		local xoffset = 0.1*math.random(-1,6)
		local yoffset = 0.1*math.random(-1,6)
		event.entity.surface.spill_item_stack({event.entity.position.x+xoffset, event.entity.position.y+yoffset}, {name=string.gsub(event.entity.name, "-targetFromRenaiTransportation", ""), count=1})
		event.entity.die()
		--]]	
	end
end
end)



---- Animates players launching form player launchers ----
script.on_nth_tick(1, 
function(eventf)
	for ThePlayer, TheirProperties in pairs(global.AllPlayers) do
		if (TheirProperties.GuideProjectile and TheirProperties.GuideProjectile.valid and game.get_player(ThePlayer).character) then
			game.get_player(ThePlayer).character_running_speed_modifier = -0.65
			game.get_player(ThePlayer).character.destructible = false -- so they dont get damaged by things they are supposed to be "above"
			if (TheirProperties.direction == "right") then
				game.get_player(ThePlayer).walking_state = {walking = true, direction = defines.direction.east}
				game.get_player(ThePlayer).teleport -- predefined bounce "animation". wube plz let me read actual projectile position then i could just stick (ie teleport) the character to the projectile
					({
						TheirProperties.GuideProjectile.position.x+0.18*(game.tick-TheirProperties.StartMovementTick)-0.5,
						TheirProperties.GuideProjectile.position.y-2+((game.tick-TheirProperties.StartMovementTick-27)/24)^2
					})
					
			elseif (TheirProperties.direction == "left") then
				game.get_player(ThePlayer).walking_state = {walking = true, direction = defines.direction.west}
				game.get_player(ThePlayer).teleport -- predefined bounce "animation"
					({
						TheirProperties.GuideProjectile.position.x-0.18*(game.tick-TheirProperties.StartMovementTick)-0.5,
						TheirProperties.GuideProjectile.position.y-2+((game.tick-TheirProperties.StartMovementTick-27)/24)^2
					})
					
			elseif (TheirProperties.direction == "up") then
				game.get_player(ThePlayer).walking_state = {walking = true, direction = defines.direction.north}
				game.get_player(ThePlayer).teleport -- predefined bounce "animation"
					({
						TheirProperties.GuideProjectile.position.x-0.5,
						TheirProperties.GuideProjectile.position.y-25.6*((1/(1+math.exp(-0.04*(game.tick-TheirProperties.StartMovementTick))))-0.5)
					})		

			elseif (TheirProperties.direction == "down") then
				game.get_player(ThePlayer).walking_state = {walking = true, direction = defines.direction.south}
				game.get_player(ThePlayer).teleport -- predefined bounce "animation"
					({
						TheirProperties.GuideProjectile.position.x-0.5,
						TheirProperties.GuideProjectile.position.y+0.002*(game.tick-TheirProperties.StartMovementTick+15)^2-0.427
					})														
			end
			
		elseif (game.get_player(ThePlayer).character) then	
			game.get_player(ThePlayer).character_running_speed_modifier = 0
			game.get_player(ThePlayer).character.destructible = true
		end		
	end

	----------------- train flight ----------------
	for PropUnitNumber, properties in pairs(global.FlyingTrains) do
		---------- launching connected wagons ---------

		if (properties.follower and properties.follower.valid) then
			if (properties.follower.train.speed>0) then
				properties.follower.train.speed = math.abs(properties.speed)
			else
				properties.follower.train.speed = -math.abs(properties.speed)
			end
		end

		--------- landing ----------
		if (game.tick == properties.LandTick) then
			TrainLandedOn = properties.GuideCar.surface.find_entities_filtered
				{
					name = {"RTTrainBouncePlate", "RTTrainDirectedBouncePlate"},
					position = properties.GuideCar.position,
					radius = 1.5,
					collision_mask = "object-layer"
				}[1] -- in theory only one thing should be detected in the object layer this way
			if (TrainLandedOn ~= nil and TrainLandedOn.name == "RTTrainBouncePlate") then
				properties.LaunchTick = game.tick
				properties.LandTick = math.ceil(game.tick + 130*math.abs(properties.speed))
				properties.GuideCar.teleport(TrainLandedOn.position)
				TrainLandedOn.surface.create_particle
					({
					name = "RTTrainBouncePlateParticle",
					position = TrainLandedOn.position,
					movement = {0,0},
					height = 0,
					vertical_speed = 0.2,
					frame_speed = 1
					})
				TrainLandedOn.surface.play_sound
					{
						path = "bounce",
						position = TrainLandedOn.position,
						volume = 2
					}

			elseif (TrainLandedOn ~= nil and TrainLandedOn.name == "RTTrainDirectedBouncePlate") then
				properties.GuideCar.teleport(TrainLandedOn.position)
				properties.RampOrientation = TrainLandedOn.orientation+0.5
				if (properties.GuideCar.speed > 0) then
					properties.GuideCar.orientation = TrainLandedOn.orientation
					properties.orientation = TrainLandedOn.orientation
				elseif (properties.GuideCar.speed < 0) then
					properties.GuideCar.orientation = TrainLandedOn.orientation+0.5
					properties.orientation = TrainLandedOn.orientation+0.5
				end
				
				if (properties.orientation >= 1) then
					properties.orientation = properties.orientation-1
				end	
				if (properties.RampOrientation >= 1) then
					properties.RampOrientation = properties.RampOrientation-1
				end

				base = properties.type
				mask = "NoMask"
				way = global.OrientationUnitComponents[properties.orientation].name
				if (base == "locomotive") then
					mask = "locomotiveMask"..way
				--elseif (base == "cargo-wagon") then
				--elseif (base == "fluid-wagon") then
				--elseif (base == "artillery-wagon") then
				end
				rendering.destroy(properties.TrainImageID)
				rendering.destroy(properties.MaskID)
				rendering.destroy(properties.ShadowID)
				properties.TrainImageID = rendering.draw_sprite
					{
					sprite = "RT"..base..way, 
					target = properties.GuideCar,
					surface = properties.GuideCar.surface,
					x_scale = 0.5,
					y_scale = 0.5,
					render_layer = 145
					}
				properties.MaskID = rendering.draw_sprite
					{
					sprite = "RT"..mask, 
					tint = properties.color or {r = 234, g = 17, b = 0, a = 100},
					target = properties.GuideCar,
					surface = properties.GuideCar.surface,
					x_scale = 0.5,
					y_scale = 0.5,
					render_layer = 145
					}
				properties.ShadowID = rendering.draw_sprite
					{
					sprite = "GenericShadow", 
					tint = {a = 90},
					target = properties.GuideCar,
					surface = properties.GuideCar.surface,
					orientation = properties.orientation,
					x_scale = 0.25,
					y_scale = 0.4,
					render_layer = 144
					}		
					
				properties.LaunchTick = game.tick
				properties.LandTick = math.ceil(game.tick + 130*math.abs(properties.speed))
				TrainLandedOn.surface.create_particle
					({
					name = "RTTrainBouncePlateParticle",
					position = TrainLandedOn.position,
					movement = {0,0},
					height = 0,
					vertical_speed = 0.2,
					frame_speed = 1
					})
				TrainLandedOn.surface.play_sound
					{
						path = "bounce",
						position = TrainLandedOn.position,
						volume = 2
					}			
			
			
			else
				NewTrain = properties.GuideCar.surface.create_entity
					({
						name = properties.name,
						position = properties.GuideCar.position,
						direction = properties.orientation, -- i think this does nothing
						force = properties.GuideCar.force,
						raise_built = true
					})
				global.FlyingTrains[PropUnitNumber].LandedTrain = NewTrain
				-- train created --	
				if (NewTrain ~= nil) then 
					if (properties.passenger ~= nil) then
						NewTrain.set_driver(game.players[properties.passenger])	
					end	
				
					AngleChange = math.abs(NewTrain.orientation-properties.orientation) -- a new train will be made if there's enough rail, direction doesn't matter
					if (AngleChange > 0.5) then
						AngleChange = 1 - AngleChange
					end
					if (AngleChange <= 0.125) then	
					-- it's good
					elseif (AngleChange >= 0.375) then
						NewTrain.disconnect_rolling_stock(defines.rail_direction.front)
						NewTrain.disconnect_rolling_stock(defines.rail_direction.back)
						NewTrain.rotate()
						NewTrain.connect_rolling_stock(defines.rail_direction.front)
						NewTrain.connect_rolling_stock(defines.rail_direction.back)
					else -- AngleChange is between 0.125 and 0.375, which is a rail ~90 degrees off from original launch. doesn't make sense so destroy
						NewTrain.die()
						for urmum, lol in pairs(properties.GuideCar.surface.find_entities_filtered({position = properties.GuideCar.position, radius = 4})) do
							if (lol.valid and lol.is_entity_with_health == true and lol.health ~= nil) then
								lol.damage(1000, "neutral", "explosion")
							elseif (lol.valid and lol.name == "cliff") then
								lol.destroy({do_cliff_correction = true})
							end
						end
					end
					
					if (NewTrain.valid) then
						-- this order of setting speed -> manual mode -> schedule is very important, other orders mess up a lot more
						if (properties.RampOrientation == properties.orientation) then
							NewTrain.train.speed = -properties.speed
						else
							NewTrain.train.speed = properties.speed
						end

						NewTrain.train.manual_mode = properties.ManualMode -- Trains are default created in manual mode
						if (properties.schedule ~= nil) then
							NewTrain.train.schedule = properties.schedule
						end	
					
						if (NewTrain.type == "locomotive") then
							NewTrain.color = properties.color
							NewTrain.backer_name = properties.SpecialName
							if (NewTrain.burner) then
								NewTrain.burner.currently_burning = properties.CurrentlyBurning
								NewTrain.burner.remaining_burning_fuel = properties.RemainingFuel 
								for FuelName, quantity in pairs(properties.FuelInventory) do
									NewTrain.get_fuel_inventory().insert({name = FuelName, count = quantity})
								end
							end
						elseif (NewTrain.type == "cargo-wagon") then
							for ItemName, quantity in pairs(properties.cargo) do
								NewTrain.get_inventory(defines.inventory.cargo_wagon).insert({name = ItemName, count = quantity})
							end
							NewTrain.get_inventory(defines.inventory.cargo_wagon).set_bar(properties.bar)
							for i, filter in pairs(properties.filter) do
								NewTrain.get_inventory(defines.inventory.cargo_wagon).set_filter(i, filter)
							end
						elseif (NewTrain.type == "fluid-wagon") then
							for FluidName, quantity in pairs(properties.fluids) do
								NewTrain.insert_fluid({name = FluidName, amount = quantity})
							end
						elseif (NewTrain.type == "artillery-wagon") then
							for ItemName, quantity in pairs(properties.artillery) do
								NewTrain.get_inventory(defines.inventory.artillery_wagon_ammo).insert({name = ItemName, count = quantity})
							end
						end	
					end
					properties.GuideCar.destroy()
					
				-- no train created --
				else 
					if (properties.GuideCar.surface.find_tiles_filtered{position = properties.GuideCar.position, radius = 1, limit = 1, collision_mask = "player-layer"}[1] == nil) then
						properties.GuideCar.surface.create_entity
							({
								name = "big-scorchmark",
								position = properties.GuideCar.position
							})
					end
					
					local key, value = next(game.entity_prototypes[properties.name].corpses)
					rip = properties.GuideCar.surface.create_entity
						({
							name = key or "locomotive-remnants",
							position = properties.GuideCar.position,
							force = properties.GuideCar.force
						})
					rip.color = properties.color
					rip.orientation = properties.orientation

					boom = properties.GuideCar.surface.create_entity
						({
							name = "locomotive-explosion",
							position = properties.GuideCar.position
						})
					properties.GuideCar.destroy()
					
					for each, guy in pairs(game.connected_players) do
						guy.add_alert(rip,defines.alert_type.entity_destroyed)
					end
					
					for urmum, lol in pairs(boom.surface.find_entities_filtered({position = boom.position, radius = 4})) do
						if (lol.valid and lol.is_entity_with_health == true and lol.health ~= nil) then
							lol.damage(1000, "neutral", "explosion")
						elseif (lol.valid and lol.name == "cliff") then
							lol.destroy({do_cliff_correction = true})
						end
					end
					
				end
			end	
		elseif (game.tick < properties.LandTick) then	
			------------- animating -----------	
			if (properties.RampOrientation == 0) then -- going down
				rendering.set_target(properties.TrainImageID, properties.GuideCar, {0,((game.tick-properties.LaunchTick)^2-(game.tick-properties.LaunchTick)*properties.AirTime)/500})
				rendering.set_target(properties.MaskID, properties.GuideCar, {0,((game.tick-properties.LaunchTick)^2-(game.tick-properties.LaunchTick)*properties.AirTime)/500})
				rendering.set_target(properties.ShadowID, properties.GuideCar, {-((game.tick-properties.LaunchTick)^2-(game.tick-properties.LaunchTick)*properties.AirTime)/500,0})	
			elseif (properties.RampOrientation == 0.25) then -- going left
				rendering.set_target(properties.TrainImageID, properties.GuideCar, {0,(game.tick-properties.LaunchTick)*((game.tick-properties.LaunchTick)-properties.AirTime)/500})
				rendering.set_orientation(properties.TrainImageID, 0.1*( (2*(game.tick-properties.LaunchTick)/properties.AirTime-1)^23 - (2*(game.tick-properties.LaunchTick)/properties.AirTime-1) ))
				rendering.set_target(properties.MaskID, properties.GuideCar, {0,(game.tick-properties.LaunchTick)*((game.tick-properties.LaunchTick)-properties.AirTime)/500})
				rendering.set_orientation(properties.MaskID, 0.1*( (2*(game.tick-properties.LaunchTick)/properties.AirTime-1)^23 - (2*(game.tick-properties.LaunchTick)/properties.AirTime-1) ))
				rendering.set_target(properties.ShadowID, properties.GuideCar, {-((game.tick-properties.LaunchTick)^2-(game.tick-properties.LaunchTick)*properties.AirTime)/500,0})
			elseif (properties.RampOrientation == 0.50) then -- going up
				rendering.set_target(properties.TrainImageID, properties.GuideCar, {0,((game.tick-properties.LaunchTick)^2-(game.tick-properties.LaunchTick)*properties.AirTime)/500})
				rendering.set_target(properties.MaskID, properties.GuideCar, {0,((game.tick-properties.LaunchTick)^2-(game.tick-properties.LaunchTick)*properties.AirTime)/500})
				rendering.set_target(properties.ShadowID, properties.GuideCar, {-((game.tick-properties.LaunchTick)^2-(game.tick-properties.LaunchTick)*properties.AirTime)/500,0})	
			elseif (properties.RampOrientation == 0.75) then -- going right
				rendering.set_target(properties.TrainImageID, properties.GuideCar, {0,(game.tick-properties.LaunchTick)*((game.tick-properties.LaunchTick)-properties.AirTime)/500})
				rendering.set_orientation(properties.TrainImageID, -0.1*( (2*(game.tick-properties.LaunchTick)/properties.AirTime-1)^23 - (2*(game.tick-properties.LaunchTick)/properties.AirTime-1) ))
				rendering.set_target(properties.MaskID, properties.GuideCar, {0,(game.tick-properties.LaunchTick)*((game.tick-properties.LaunchTick)-properties.AirTime)/500})
				rendering.set_orientation(properties.MaskID, -0.1*( (2*(game.tick-properties.LaunchTick)/properties.AirTime-1)^23 - (2*(game.tick-properties.LaunchTick)/properties.AirTime-1) ))
				rendering.set_target(properties.ShadowID, properties.GuideCar, {-((game.tick-properties.LaunchTick)^2-(game.tick-properties.LaunchTick)*properties.AirTime)/500,0})	
			end
			
		elseif (game.tick > properties.LandTick and properties.length and properties.LandedTrain and properties.LandedTrain.valid) then
			if (#properties.LandedTrain.train.carriages ~= properties.length) then
				--game.print("not all here")
				if (properties.LandedTrain.train.speed>0) then
					properties.LandedTrain.train.speed = math.abs(properties.speed)
				else
					properties.LandedTrain.train.speed = -math.abs(properties.speed)
				end
			elseif (#properties.LandedTrain.train.carriages == properties.length or game.tick > properties.LandTick+240) then
				--game.print("all here")
				global.FlyingTrains[PropUnitNumber] = nil
			end
			
		elseif (game.tick > properties.LandTick) then -- for any trains already in the air when the speed control update was released or other catchall failsafes
			global.FlyingTrains[PropUnitNumber] = nil
			
		end	
	end
end)



script.on_event(defines.events.on_entity_damaged,
function(event)
if (event.entity.name == "RTTrainRamp" 
	and event.cause 
	and (event.cause.type == "locomotive" or event.cause.type == "cargo-wagon" or event.cause.type == "fluid-wagon" or event.cause.type == "artillery-wagon")
	and (math.abs(event.entity.orientation-event.cause.orientation) == 0.5 
		or math.abs(event.entity.orientation-event.cause.orientation) == 0
		)
	and (event.entity.orientation == 0 and event.entity.position.y-event.cause.position.y>0
		or event.entity.orientation == 0.25 and event.entity.position.x-event.cause.position.x<0
		or event.entity.orientation == 0.50 and event.entity.position.y-event.cause.position.y<0
		or event.entity.orientation == 0.75 and event.entity.position.x-event.cause.position.x>0
		)
	) then
	
	event.entity.health = event.entity.health+event.final_damage_amount
	
	SpookyGhost = event.entity.surface.create_entity
		({
			name = "RTPropCar",
			position = event.cause.position,
			force = event.cause.force
		})
	SpookyGhost.orientation = event.cause.orientation
	SpookyGhost.operable = false
	SpookyGhost.speed = 0.8*event.cause.speed
	
	base = event.cause.type
	mask = "NoMask"
	way = global.OrientationUnitComponents[event.cause.orientation].name
	if (event.cause.type == "locomotive") then
		mask = "locomotiveMask"..way
	--elseif (event.cause.type == "cargo-wagon") then
	--elseif (event.cause.type == "fluid-wagon") then
	--elseif (event.cause.type == "artillery-wagon") then
	end
	
	TrainImage = rendering.draw_sprite
		{
		sprite = "RT"..base..way, 
		target = SpookyGhost,
		surface = SpookyGhost.surface,
		x_scale = 0.5,
		y_scale = 0.5,
		render_layer = 145
		}
	Mask = rendering.draw_sprite
		{
		sprite = "RT"..mask, 
		tint = event.cause.color or {r = 234, g = 17, b = 0, a = 100},
		target = SpookyGhost,
		surface = SpookyGhost.surface,
		x_scale = 0.5,
		y_scale = 0.5,
		render_layer = 145
		}
	OwTheEdge = rendering.draw_sprite
		{
		sprite = "GenericShadow", 
		tint = {a = 90},
		target = SpookyGhost,
		surface = SpookyGhost.surface,
		orientation = event.cause.orientation,
		x_scale = 0.25,
		y_scale = 0.4,
		render_layer = 144
		}
	
	global.FlyingTrains[SpookyGhost.unit_number] = {}
	global.FlyingTrains[SpookyGhost.unit_number].GuideCar = SpookyGhost
	if (event.cause.get_driver() ~= nil) then
		global.FlyingTrains[SpookyGhost.unit_number].passenger = event.cause.get_driver().player.index
		SpookyGhost.set_passenger(event.cause.get_driver())	
	end
	global.FlyingTrains[SpookyGhost.unit_number].name = event.cause.name
	global.FlyingTrains[SpookyGhost.unit_number].type = event.cause.type
	global.FlyingTrains[SpookyGhost.unit_number].LaunchTick = game.tick
	global.FlyingTrains[SpookyGhost.unit_number].LandTick = math.ceil(game.tick + 130*math.abs(event.cause.speed))
	global.FlyingTrains[SpookyGhost.unit_number].AirTime = global.FlyingTrains[SpookyGhost.unit_number].LandTick - global.FlyingTrains[SpookyGhost.unit_number].LaunchTick
	global.FlyingTrains[SpookyGhost.unit_number].TrainImageID = TrainImage
	global.FlyingTrains[SpookyGhost.unit_number].MaskID = Mask
	global.FlyingTrains[SpookyGhost.unit_number].speed = event.cause.speed
	global.FlyingTrains[SpookyGhost.unit_number].SpecialName = event.cause.backer_name
	global.FlyingTrains[SpookyGhost.unit_number].color = event.cause.color or {r = 234, g = 17, b = 0, a = 100} 
	global.FlyingTrains[SpookyGhost.unit_number].orientation = event.cause.orientation
	global.FlyingTrains[SpookyGhost.unit_number].RampOrientation = event.entity.orientation
	global.FlyingTrains[SpookyGhost.unit_number].ShadowID = OwTheEdge
	global.FlyingTrains[SpookyGhost.unit_number].ManualMode = event.cause.train.manual_mode
	global.FlyingTrains[SpookyGhost.unit_number].length = #event.cause.train.carriages
	if (event.entity.orientation == 0) then --ramp down
		SearchBox = 
			{
				{event.cause.position.x-1,event.cause.position.y-6},
				{event.cause.position.x+1,event.cause.position.y-4}
			}
	elseif (event.entity.orientation == 0.25) then -- ramp left
		SearchBox = 
			{
				{event.cause.position.x+4,event.cause.position.y-1},
				{event.cause.position.x+6,event.cause.position.y+1}
			}
	elseif (event.entity.orientation == 0.50) then -- ramp up
		SearchBox = 
			{
				{event.cause.position.x-1,event.cause.position.y+4},
				{event.cause.position.x+1,event.cause.position.y+6}
			}
	elseif (event.entity.orientation == 0.75) then -- ramp right
		SearchBox = 
			{
				{event.cause.position.x-6,event.cause.position.y-1},
				{event.cause.position.x-4,event.cause.position.y+1}
			}
	end
	global.FlyingTrains[SpookyGhost.unit_number].follower = SpookyGhost.surface.find_entities_filtered
		{
		area = SearchBox,
		type = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"},
		limit = 1
		}[1]
		
	-- if (global.FlyingTrains[SpookyGhost.unit_number].follower ~= nil) then
	-- rendering.draw_circle
		-- {
		-- color = {r = 234, g = 17, b = 0, a = 100},
		-- radius = 1,
		-- filled = true,
		-- target = global.FlyingTrains[SpookyGhost.unit_number].follower,
		-- surface = SpookyGhost.surface
		-- }
	-- end
		
	global.FlyingTrains[SpookyGhost.unit_number].schedule = event.cause.train.schedule
	if (global.FlyingTrains[SpookyGhost.unit_number].schedule ~= nil) then
		if (global.FlyingTrains[SpookyGhost.unit_number].schedule.current == table_size(global.FlyingTrains[SpookyGhost.unit_number].schedule.records)) then
		global.FlyingTrains[SpookyGhost.unit_number].schedule.current = 1
		else
		global.FlyingTrains[SpookyGhost.unit_number].schedule.current = global.FlyingTrains[SpookyGhost.unit_number].schedule.current+1
		end
	end
	
	for number, properties in pairs(global.FlyingTrains) do
		if (properties.follower and properties.follower.valid and event.cause.unit_number == properties.follower.unit_number) then
			global.FlyingTrains[SpookyGhost.unit_number].leader = number
			global.FlyingTrains[SpookyGhost.unit_number].schedule = global.FlyingTrains[number].schedule
			global.FlyingTrains[SpookyGhost.unit_number].ManualMode = global.FlyingTrains[number].ManualMode
			global.FlyingTrains[SpookyGhost.unit_number].LandTick = math.ceil(game.tick + 130*math.abs(global.FlyingTrains[number].speed))
			global.FlyingTrains[SpookyGhost.unit_number].AirTime = global.FlyingTrains[number].AirTime
			global.FlyingTrains[SpookyGhost.unit_number].length = global.FlyingTrains[number].length
			if (global.FlyingTrains[SpookyGhost.unit_number].speed>0) then
				SpookyGhost.speed = 0.8*math.abs(global.FlyingTrains[number].speed)
				global.FlyingTrains[SpookyGhost.unit_number].speed = math.abs(global.FlyingTrains[number].speed)
			else
				SpookyGhost.speed = -0.8*math.abs(global.FlyingTrains[number].speed)
				global.FlyingTrains[SpookyGhost.unit_number].speed = -math.abs(global.FlyingTrains[number].speed)
			end
		end
	end	
	
	if (event.cause.type == "locomotive" and event.cause.burner) then
		global.FlyingTrains[SpookyGhost.unit_number].CurrentlyBurning = event.cause.burner.currently_burning
		global.FlyingTrains[SpookyGhost.unit_number].RemainingFuel = event.cause.burner.remaining_burning_fuel
		global.FlyingTrains[SpookyGhost.unit_number].FuelInventory = event.cause.get_fuel_inventory().get_contents()
	elseif (event.cause.type == "cargo-wagon") then
		global.FlyingTrains[SpookyGhost.unit_number].cargo = event.cause.get_inventory(defines.inventory.cargo_wagon).get_contents()
		global.FlyingTrains[SpookyGhost.unit_number].bar = event.cause.get_inventory(defines.inventory.cargo_wagon).get_bar()
		global.FlyingTrains[SpookyGhost.unit_number].filter = {}
		for i = 1, #event.cause.get_inventory(defines.inventory.cargo_wagon) do
			global.FlyingTrains[SpookyGhost.unit_number].filter[i] = event.cause.get_inventory(defines.inventory.cargo_wagon).get_filter(i)
		end
	elseif (event.cause.type == "fluid-wagon") then
		global.FlyingTrains[SpookyGhost.unit_number].fluids = event.cause.get_fluid_contents()
	elseif (event.cause.type == "artillery-wagon") then
		global.FlyingTrains[SpookyGhost.unit_number].artillery = event.cause.get_inventory(defines.inventory.artillery_wagon_ammo).get_contents()
	end
	
	event.cause.destroy()
end


end)




script.on_event("EnterPipe", 
function(event1) -- has .name = event ID number, .tick = tick number, .player_index, and .input_name = custom input name
	
	ThingHovering = game.get_player(event1.player_index).selected	
	SteppingOn = game.get_player(event1.player_index).surface.find_entities_filtered
	{
		name = "PlayerLauncher",
		position = game.get_player(event1.player_index).position,
		radius = 0.6
	}[1]
	
	if (SteppingOn ~= nil) then
		game.get_player(event1.player_index).teleport(SteppingOn.position) -- align player on the launch pad
		
		global.AllPlayers[event1.player_index].direction = global.OrientationUnitComponents[SteppingOn.orientation].name
		global.AllPlayers[event1.player_index].StartMovementTick = event1.tick
		global.AllPlayers[event1.player_index].GuideProjectile =
			game.get_player(event1.player_index).surface.create_entity
				({
					name = "test-projectileFromRenaiTransportation",
					position = game.get_player(event1.player_index).position, --required setting for rendering, doesn't affect spawn
					source = game.get_player(event1.player_index).character,
					target_position = SteppingOn.drop_position
				})
	end
	
	if (ThingHovering) then
		if (ThingHovering.name == "PrimerBouncePlate") then
			ThingHovering.surface.create_entity
				({
				name = "PrimerSpreadBouncePlate",
				position = ThingHovering.position, --required setting for rendering, doesn't affect spawn
				force = game.get_player(event1.player_index).force,
				raise_built = true
				})	
			ThingHovering.destroy()
			
		elseif (ThingHovering.name == "PrimerSpreadBouncePlate") then
			ThingHovering.surface.create_entity
				({
				name = "PrimerBouncePlate",
				position = ThingHovering.position, --required setting for rendering, doesn't affect spawn
				force = game.get_player(event1.player_index).force,
				raise_built = true
				})	
			ThingHovering.destroy()	
			
		elseif (string.find(ThingHovering.name, "RTThrower-") and game.get_player(event1.player_index).force.technologies["RTFocusedFlinging"].researched == true) then
			CurrentRange = math.ceil(math.abs(ThingHovering.drop_position.x-ThingHovering.position.x + ThingHovering.drop_position.y-ThingHovering.position.y))
			if ((ThingHovering.name ~= "RTThrower-long-handed-inserter" and CurrentRange >= 15) or CurrentRange >= 25) then
				ThingHovering.drop_position = 
					{
						ThingHovering.drop_position.x+(CurrentRange-1)*global.OrientationUnitComponents[ThingHovering.orientation].x,
						ThingHovering.drop_position.y+(CurrentRange-1)*global.OrientationUnitComponents[ThingHovering.orientation].y
					}				
			else
				ThingHovering.drop_position = 
					{
						ThingHovering.drop_position.x-global.OrientationUnitComponents[ThingHovering.orientation].x,
						ThingHovering.drop_position.y-global.OrientationUnitComponents[ThingHovering.orientation].y
					}
			end
			ThingHovering.surface.create_entity
				({
					name = "flying-text",
					position = ThingHovering.drop_position,
					text = "Range: "..math.ceil(math.abs(ThingHovering.drop_position.x-ThingHovering.position.x + ThingHovering.drop_position.y-ThingHovering.position.y))
				})
			
		end
	end
end)

script.on_event("RTClick",
function(event)
	if (game.get_player(event.player_index).selected and global.BouncePadList[game.get_player(event.player_index).selected.unit_number] ~= nil) then
		rendering.set_visible(global.BouncePadList[game.get_player(event.player_index).selected.unit_number].arrow, not rendering.get_visible(global.BouncePadList[game.get_player(event.player_index).selected.unit_number].arrow))
	end
end)
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
		
	elseif (event.created_entity.name == "DirectedBouncePlate") then
		event.created_entity.operable = false
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
		
	elseif (event.created_entity.name == "DirectedBouncePlate") then
		event.created_entity.operable = false
		
	end
end)
---- built by script (other mods) ----
script.on_event(defines.events.script_raised_built, 
function(event)
	if (string.find(event.entity.name, "RTThrower-")) then
		global.CatapultList[event.entity.unit_number] = event.entity
	
	elseif (event.entity.name == "PlayerLauncher") then
		event.entity.operable = false
		event.entity.active = false

	elseif (event.entity.name == "DirectedBouncePlate") then
		event.entity.operable = false		
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

	elseif (event.destination.name == "DirectedBouncePlate") then
		event.destination.operable = false		
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
	
	elseif (event.entity.name == "DirectedBouncePlate") then
		event.entity.operable = false	
	end
end)


---- checks if thrower inserters have something in their hands and it's in the throwing position, then creates the approppriate projectile ----
script.on_nth_tick(3, 
function(event)
	if (global.CatapultList ~= {}) then
		for catapultID, catapult in pairs(global.CatapultList) do

			if (catapult.valid  and catapult.energy == catapult.electric_buffer_size) then
				catapult.active = true
			elseif (catapult.valid and catapult.burner == nil) then
				catapult.active = false
			end
			
			if (catapult.valid and catapult.active == true and catapult.held_stack.valid_for_read) then
				if (catapult.orientation == 0    and catapult.held_stack_position.y >= catapult.position.y)
				or (catapult.orientation == 0.25 and catapult.held_stack_position.x <= catapult.position.x)
				or (catapult.orientation == 0.50 and catapult.held_stack_position.y <= catapult.position.y)	
				or (catapult.orientation == 0.75 and catapult.held_stack_position.x >= catapult.position.x) 
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
				catapultID = nil
				catapult = nil
				
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
			
			if (ThingLandedOn.name == "DirectedBouncePlate") then
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
					game.get_surface(event.surface_index).find_non_colliding_position("item-on-ground", event.target_position, 10, 0.1),
					{name=string.gsub(event.effect_id, "-LandedRT", ""), count=1}
				)
			--[[
			ThingLandedOn.surface.create_entity
				({
				name = string.gsub(event.effect_id, "-LandedRT", "-projectileFromRenaiTransportation"),
				position = ThingLandedOn.position, --required setting for rendering, doesn't affect spawn
				source_position = event.target_position,
				target_position = game.get_surface(event.surface_index).find_non_colliding_position("item-on-ground", event.target_position, 10, 0.1),
				force = ThingLandedOn.force
				})		
			--]]
		end
	
	---- if the item/character lands in the water, it's gone ----
	elseif (game.get_surface(event.surface_index).find_tiles_filtered{position = event.target_position, radius = 1, limit = 1, collision_mask = "player-layer"}[1] ~= nil) then
		
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
				force = game.get_player(event1.player_index).force
				})	
			ThingHovering.destroy()
		elseif (ThingHovering.name == "PrimerSpreadBouncePlate") then
			ThingHovering.surface.create_entity
				({
				name = "PrimerBouncePlate",
				position = ThingHovering.position, --required setting for rendering, doesn't affect spawn
				force = game.get_player(event1.player_index).force
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
script.on_init(
function()
	if (global.CatapultList == nil) then
		global.CatapultList = {}		
	end
	
	if (global.AllPlayers == nil) then
		global.AllPlayers = {}		
	end
	
	for PlayerID, PlayerLuaData in pairs(game.players) do
		global.AllPlayers[PlayerID] = {}
	end
end)

script.on_configuration_changed(
function()
	if (global.CatapultList == nil) then
		global.CatapultList = {}		
	end
	
	if (global.AllPlayers == nil) then
		global.AllPlayers = {}		
	end
	
	for PlayerID, PlayerLuaData in pairs(game.players) do
		global.AllPlayers[PlayerID] = {}
	end
end)

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
	if (string.find(event.created_entity.name, "ThrowerInserter")) then
		global.CatapultList[event.created_entity.unit_number] = event.created_entity
		--event.created_entity.inserter_stack_size_override = 1
	
	elseif (event.created_entity.name == "PlayerLauncher") then
		event.created_entity.operable = false
		event.created_entity.active = false
		
	end
end)
---- built by robot ----
script.on_event(defines.events.on_robot_built_entity, 
function(event)
	if (string.find(event.created_entity.name, "ThrowerInserter")) then
		global.CatapultList[event.created_entity.unit_number] = event.created_entity
	
	elseif (event.created_entity.name == "PlayerLauncher") then
		event.created_entity.operable = false
		event.created_entity.active = false
		
	end
end)
---- built by script (other mods) ----
script.on_event(defines.events.script_raised_built, 
function(event)
	if (string.find(event.entity.name, "ThrowerInserter")) then
		global.CatapultList[event.entity.unit_number] = event.entity
	
	elseif (event.entity.name == "PlayerLauncher") then
		event.entity.operable = false
		event.entity.active = false
		
	end
end)
---- cloned by script ----
script.on_event(defines.events.on_entity_cloned, 
function(event)
	if (string.find(event.destination.name, "ThrowerInserter")) then
		global.CatapultList[event.destination.unit_number] = event.destination
	
	elseif (event.destination.name == "PlayerLauncher") then
		event.destination.operable = false
		event.destination.active = false
		
	end
end)
---- revived? ----
script.on_event(defines.events.script_raised_revive, 
function(event)
	if (string.find(event.entity.name, "ThrowerInserter")) then
		global.CatapultList[event.entity.unit_number] = event.entity
	
	elseif (event.entity.name == "PlayerLauncher") then
		event.entity.operable = false
		event.entity.active = false
		
	end
end)


---- checks if thrower inserters have something in their hands and it's in the throwing position, then creates the approppriate projectile ----
script.on_nth_tick(2, 
function(event)
	if (global.CatapultList ~= {}) then
		for catapultID, catapult in pairs(global.CatapultList) do
			if (catapult.valid and catapult.held_stack.valid_for_read) then
				--catapult.inserter_stack_size_override = 1
				
				throw = 0
				if (catapult.orientation == 0 and catapult.held_stack_position.y >= catapult.position.y) then
					throw = 1
				elseif(catapult.orientation == 0.25 and catapult.held_stack_position.x <= catapult.position.x) then
					throw = 1
				elseif(catapult.orientation == 0.50 and catapult.held_stack_position.y <= catapult.position.y) then
					throw = 1		
				elseif(catapult.orientation == 0.75 and catapult.held_stack_position.x >= catapult.position.x) then
					throw = 1					
				end

				
				if (throw ~= 0) then
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
					catapult.drop_position =  {catapult.drop_position.x,catapult.drop_position.y+0.1}
				end
				
			elseif (catapult.valid == false) then
				catapultID=nil
				
			end
		end
	end
end)





---- When a projectile lands and its target is created, what to do ----
script.on_event(defines.events.on_script_trigger_effect,
function (event) --has .effect_id, .surface_index, and depending on how the effect was triggered: .source_position, .source_entity, .target_position, and .target_entity
	
	if (string.find(event.effect_id, "-LandedRT")) then

		---- What did it land on? ----
		ThingLandedOn = game.get_surface(event.surface_index).find_entities_filtered
			{
				position = event.target_position,
				collision_mask = "object-layer"
			}[1] -- in theory only one thing should be detected in the object layer this way

		if (ThingLandedOn ~= nil) then -- if it landed on something
			if (ThingLandedOn.name == "BouncePlate" or (event.source_entity ~= nil and global.AllPlayers[event.source_entity.player.index].LastBouncedOn == "se~no")) then -- if that thing was a bounce plate
				
				---- what direction was it traveling? ----
				---- I set thrown things to have a range just short of dead center to detect what direction they came from ---- 
				if (ThingLandedOn.position.y < event.target_position.y) then
					targetx = 0
					targety = -9.9
					traveling = "up"
				elseif(ThingLandedOn.position.y > event.target_position.y) then
					targetx = 0
					targety = 9.9	
					traveling = "down"
				elseif(ThingLandedOn.position.x < event.target_position.x) then
					targetx = -9.9
					targety = 0
					traveling = "left"
				elseif(ThingLandedOn.position.x > event.target_position.x) then
					targetx = 9.9
					targety = 0
					traveling = "right"
				end			
			
				---- the thrown thing is set up to only have a source entity if it came from a player character ----
				if (event.source_entity ~= nil) then -- if it's a character
					event.source_entity.player.teleport(ThingLandedOn.position) -- realign the character with the bounce pad to deal with any offset
	
					---- The 4 following properties are used in the on_nth_tick:1 script for how to animate the player bouncing
					global.AllPlayers[event.source_entity.player.index].direction = traveling
					global.AllPlayers[event.source_entity.player.index].StartMovementTick = event.tick
					global.AllPlayers[event.source_entity.player.index].LastBouncedOn = ThingLandedOn.name					
					global.AllPlayers[event.source_entity.player.index].GuideProjectile = ThingLandedOn.surface.create_entity
						({
						name = string.gsub(event.effect_id, "-LandedRT", "").."-projectileFromRenaiTransportation",   --------#######<<<<<<
						position = ThingLandedOn.position, --required setting for rendering, doesn't affect spawn
						source = event.source_entity,
						target_position = {ThingLandedOn.position.x+targetx, ThingLandedOn.position.y+targety}
						})
					
				else  -- if it doesn't have a source, it is a thrown item. Bounce forward
					ThingLandedOn.surface.create_entity
						({
						name = string.gsub(event.effect_id, "-LandedRT", "").."-projectileFromRenaiTransportation",
						position = ThingLandedOn.position, --required setting for rendering, doesn't affect spawn
						source_position = ThingLandedOn.position,
						target_position = {ThingLandedOn.position.x+targetx, ThingLandedOn.position.y+targety}
						})
				end
				
				---- spawns the bounce pad "animation" particle ----
				ThingLandedOn.surface.create_particle
					({
					name = "boing",
					position = ThingLandedOn.position,
					movement = {0,0},
					height = 0,
					vertical_speed = 0.1,
					frame_speed = 1
					})
					
			---- If its a character (because it uses the test-LandedRT effect_id) destroy what they land on so they dont get stuck ----
			elseif (event.effect_id == "test-LandedRT") then
				
				---- The only thing that doesn't .die() is a cliff ---- 
				if (ThingLandedOn.name == "cliff") then
					global.AllPlayers[event.source_entity.player.index].GuideProjectile = nil
					event.source_entity.teleport(event.source_entity.surface.find_non_colliding_position("iron-chest", event.target_position, 0, 0.5))
					--game.get_player(event.source.player.index).print("Ow")
				end
				
				---- Damage the player and destroy what they landed on to prevent getting stuck ----
				
				game.get_player(event.source_entity.player.index).character.destructible = true
				event.source_entity.player.character.damage(50, "neutral", "impact", ThingLandedOn)
				ThingLandedOn.die()
				
			---- presumably the thrown thing is an item if not a character ----
			---- If it landed on an open container, insert it ----
			elseif (ThingLandedOn.name == "OpenContainer" and ThingLandedOn.get_inventory(defines.inventory.chest).can_insert({name=string.gsub(event.effect_id, "-LandedRT", "")})) then
				ThingLandedOn.get_inventory(defines.inventory.chest).insert({name=string.gsub(event.effect_id, "-LandedRT", ""), count=1})
					
			---- otherwise it bounces off whatever it landed on and lands as an item on the nearest empty space within 10 tiles. destroyed if no space ----
			else
				--[[
				ThingLandedOn.surface.create_entity
					({
						name = string.gsub(event.entity.name, "-targetFromRenaiTransportation", "").."-projectileFromRenaiTransportation",
						position = event.entity.position, --required setting for rendering, doesn't affect spawn
						source_position = event.entity.position,
						target_position = {event.entity.position.x+0.2*targetx, event.entity.position.y+0.2*targety}
					})
				--]]	
					
				---[[
				game.get_surface(event.surface_index).spill_item_stack
					(
						game.get_surface(event.surface_index).find_non_colliding_position("item-on-ground", ThingLandedOn.position, 10, 0.1),
						{name=string.gsub(event.effect_id, "-LandedRT", ""), count=1}
					)
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
		
		---- if thrown thing didn't land on anything and not in water, i don't want characters to do anything upon landing ----
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

	--	event.entity.die() -- clear the dummy target
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
			--script.on_nth_tick(1, nil)
		end		
	end
end)




script.on_event("EnterPipe", 
function(event1) -- has .name = event ID number, .tick = tick number, .player_index, and .input_name = custom input name
	
	SteppingOn = game.get_player(event1.player_index).surface.find_entities_filtered
	{
		name = "PlayerLauncher",
		position = game.get_player(event1.player_index).position,
		radius = 0.6
	}[1]
	
	if (SteppingOn ~= nil) then
		game.get_player(event1.player_index).teleport(SteppingOn.position) -- align player to the launch pad
		global.AllPlayers[event1.player_index].LastBouncedOn = "se~no" -- says player launched from launch pad
		
		if (SteppingOn.orientation == 0) then
			launchx = 0
			launchy = 0.04
		elseif(SteppingOn.orientation == 0.5) then
			launchx = 0
			launchy = -0.04
		elseif(SteppingOn.orientation == 0.75) then
			launchx = 0.04
			launchy = 0
		elseif(SteppingOn.orientation == 0.25) then
			launchx = -0.04
			launchy = 0
		end		
		
		game.get_player(event1.player_index).surface.create_entity
			({
				name = "test-projectileFromRenaiTransportation",
				position = game.get_player(event1.player_index).position, --required setting for rendering, doesn't affect spawn
				source = game.get_player(event1.player_index).character,
				target_position = {game.get_player(event1.player_index).position.x+launchx, game.get_player(event1.player_index).position.y+launchy}
			})


	end
end)
local function effect_triggered(event) --has .effect_id, .surface_index, and .source_position, .source_entity, .target_position, and .target_entity depending on how the effect was triggered

	---- If it's from this mod ----
	if (string.find(event.effect_id, "-LandedRT")) then

		---- What did it land on? ----
		ThingLandedOn = game.get_surface(event.surface_index).find_entities_filtered
			{
				position = event.target_position,
				collision_mask = "object-layer"
			}[1] -- in theory only one thing should be detected in the object layer this way
			
		LandedOnCargoWagon = game.get_surface(event.surface_index).find_entities_filtered
			{
				area = {{event.target_position.x-0.5,event.target_position.y-0.5}, {event.target_position.x+0.5,event.target_position.y+0.5}},
				type = "cargo-wagon"
			}[1]
			
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
				if (event.effect_id ~= "MaybeIllBeTracer-LandedRT") then
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
				end
				---- Handling players ----
				if (event.effect_id == "test-LandedRT") then
					event.source_entity.teleport(ThingLandedOn.position)
					global.AllPlayers[event.source_entity.player.index].direction = traveling
					global.AllPlayers[event.source_entity.player.index].StartMovementTick = event.tick
					global.AllPlayers[event.source_entity.player.index].LastBouncedOn = ThingLandedOn.name
					global.AllPlayers[event.source_entity.player.index].GuideProjectile = cheesewheel
					global.AllPlayers[event.source_entity.player.index].jumping = true
				end

			---- If its a character (because it uses the test-LandedRT effect_id) destroy what they land on so they dont get stuck ----
			elseif (event.effect_id == "test-LandedRT") then

				---- Doesn't make sense for player landing on cliff to destroy it ----
				if (ThingLandedOn.name == "cliff") then
					global.AllPlayers[event.source_entity.player.index].GuideProjectile = nil
					event.source_entity.teleport(event.source_entity.surface.find_non_colliding_position("iron-chest", event.target_position, 0, 0.5))
				end

				---- Damage the player based on thing's size and destroy what they landed on to prevent getting stuck ----
				game.get_player(event.source_entity.player.index).character.destructible = true
				event.source_entity.player.character.damage(10*(ThingLandedOn.bounding_box.right_bottom.x-ThingLandedOn.bounding_box.left_top.x)*(ThingLandedOn.bounding_box.right_bottom.y-ThingLandedOn.bounding_box.left_top.y), "neutral", "impact", ThingLandedOn)
				ThingLandedOn.die()

			elseif (event.effect_id ~= "MaybeIllBeTracer-LandedRT") then
				---- presumably the thrown thing is an item if not a character ----
				---- If it landed on an open container, insert it ----
				if (ThingLandedOn.name == "OpenContainer" and ThingLandedOn.can_insert({name=string.gsub(event.effect_id, "-LandedRT", "")})) then
					ThingLandedOn.insert({name=string.gsub(event.effect_id, "-LandedRT", ""), count=1})

				---- If the thing it landed on has an inventory and a hatch, insert the item ----
				elseif (ThingLandedOn.surface.find_entity('HatchRT', event.target_position) and ThingLandedOn.can_insert({name=string.gsub(event.effect_id, "-LandedRT", "")}) ) then
					ThingLandedOn.insert({name=string.gsub(event.effect_id, "-LandedRT", ""), count=1})
				
				---- If it landed on something but there's also a cargo wagon there
				elseif (LandedOnCargoWagon ~= nil and LandedOnCargoWagon.can_insert({name=string.gsub(event.effect_id, "-LandedRT", "")})) then
					LandedOnCargoWagon.insert({name=string.gsub(event.effect_id, "-LandedRT", ""), count=1})
				
				---- otherwise it bounces off whatever it landed on and lands as an item on the nearest empty space within 10 tiles. destroyed if no space ----
				else
					game.get_surface(event.surface_index).spill_item_stack
						(
							game.get_surface(event.surface_index).find_non_colliding_position("item-on-ground", event.target_position, 0, 0.1),
							{name=string.gsub(event.effect_id, "-LandedRT", ""), count=1}
						)
				end

			elseif (event.effect_id == "MaybeIllBeTracer-LandedRT") then
				global.CatapultList[event.source_entity.unit_number].target = ThingLandedOn
			end
		
		---- If it didnt land on anything but theres a cargo wagon there
		elseif (LandedOnCargoWagon ~= nil and LandedOnCargoWagon.can_insert({name=string.gsub(event.effect_id, "-LandedRT", "")})) then
			LandedOnCargoWagon.insert({name=string.gsub(event.effect_id, "-LandedRT", ""), count=1})

		---- if the item/character lands in the water, it's gone ----
		elseif (event.effect_id ~= "MaybeIllBeTracer-LandedRT" and game.get_surface(event.surface_index).find_tiles_filtered{position = event.target_position, radius = 1, limit = 1, collision_mask = "player-layer"}[1] ~= nil) then -- in theory, tiles the player cant walk on are some sort of fluid or other non-survivable ground

			---- drown the character ----
			if (event.effect_id == "test-LandedRT") then
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
			if (event.effect_id ~= "MaybeIllBeTracer-LandedRT") then
				game.get_surface(event.surface_index).spill_item_stack({event.target_position.x, event.target_position.y}, {name=string.gsub(event.effect_id, "-LandedRT", ""), count=1})
			else
				global.CatapultList[event.source_entity.unit_number].target = "nothing"
			end
			--[[ random item landing offset
			local xoffset = 0.1*math.random(-1,6)
			local yoffset = 0.1*math.random(-1,6)
			event.entity.surface.spill_item_stack({event.entity.position.x+xoffset, event.entity.position.y+yoffset}, {name=string.gsub(event.entity.name, "-targetFromRenaiTransportation", ""), count=1})
			event.entity.die()
			--]]
		end
	
	elseif (event.effect_id == "RTCrank" 
	and global.AllPlayers[event.source_entity.player.index].sliding
	and global.AllPlayers[event.source_entity.player.index].succ.energy ~= 0
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].valid_for_read
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name == "RTZiplineItem"
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event.source_entity.player.index).character.selected_gun_index].valid_for_read
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name == "RTZiplineCrankControlsItem"
	and game.get_player(event.source_entity.player.index).walking_state.walking == true
	) then

		if (global.AllPlayers[event.source_entity.player.index].ForwardDirection[game.get_player(event.source_entity.player.index).walking_state.direction] ~= nil) then
			if (global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed <= 0.420) then
				global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed = global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed + 0.040 --increments slower than 0.008 don't seem to do anything
				game.get_player(event.source_entity.player.index).surface.play_sound
					{
						path = "RTZipAttach",
						position = game.get_player(event.source_entity.player.index).position,
						volume = 0.7
					}
			end
		elseif (global.AllPlayers[event.source_entity.player.index].BackwardsDirection[game.get_player(event.source_entity.player.index).walking_state.direction] ~= nil) then
			if (global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed >= -0.420) then
				global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed = global.AllPlayers[event.source_entity.player.index].LetMeGuideYou.speed - 0.040
				game.get_player(event.source_entity.player.index).surface.play_sound
					{
						path = "RTZipAttach",
						position = game.get_player(event.source_entity.player.index).position,
						volume = 0.7
					}
			end
		end	
		
		
	end
end

return effect_triggered

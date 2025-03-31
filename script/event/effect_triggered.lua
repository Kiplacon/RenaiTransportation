-- effect_id :: string: The effect_id specified in the trigger effect.
-- surface_index :: uint: The surface the effect happened on.
-- source_position :: Position (optional) | particle trigger effect where it lands
-- source_entity :: LuaEntity (optional)
-- target_position :: Position (optional) | particle trigger effect where it lands
-- target_entity :: LuaEntity (optional)
-- cause_entity :: LuaEntity (optional)

local function effect_triggered(event)
	local surface = game.surfaces[event.surface_index]

	if (event.effect_id == "RTCrank"
	and event.source_entity
	and event.source_entity.player
	and storage.AllPlayers[event.source_entity.player.index].state == "zipline"
	--and storage.AllPlayers[event.source_entity.player.index].zipline.succ.energy ~= 0
	and storage.AllPlayers[event.source_entity.player.index].zipline.path == nil
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].valid_for_read
	and string.find(game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name, "RTZiplineItem")
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event.source_entity.player.index).character.selected_gun_index].valid_for_read
	and game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_ammo)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name == "RTZiplineCrankControlsItem"
	and game.get_player(event.source_entity.player.index).walking_state.walking == true
	) then
		local EquippedTrolley = game.get_player(event.source_entity.player.index).character.get_inventory(defines.inventory.character_guns)[game.get_player(event.source_entity.player.index).character.selected_gun_index].name
		local PlayerProperties = storage.AllPlayers[event.source_entity.player.index]
		local MaxBoostedSpeed = 0.420
		local BoostAmount = 0.040
		if (EquippedTrolley == "RTZiplineItem") then
			-- MaxSpeed = 0.3
			-- accel = 0.004
			MaxBoostedSpeed = 0.420
			BoostAmount = 0.040
		elseif (EquippedTrolley == "RTZiplineItem2") then
			-- MaxSpeed = 0.6
			-- accel = 0.008
			MaxBoostedSpeed = 0.8
			BoostAmount = 0.080
		elseif (EquippedTrolley == "RTZiplineItem3") then
			-- MaxSpeed = 1.5
			-- accel = 0.012
			MaxBoostedSpeed = 2
			BoostAmount = 0.120
		elseif (EquippedTrolley == "RTZiplineItem4") then
			-- MaxSpeed = 4
			-- accel = 0.016
			MaxBoostedSpeed = 0.6
			BoostAmount = 0.20
		elseif (EquippedTrolley == "RTZiplineItem5") then
			-- MaxSpeed = 10
			-- accel = 0.05
			MaxBoostedSpeed = 15
			BoostAmount = 1
		end
		if (PlayerProperties.zipline.ForwardDirection ~= nil and PlayerProperties.zipline.ForwardDirection[game.get_player(event.source_entity.player.index).walking_state.direction] ~= nil) then
			if (PlayerProperties.zipline.LetMeGuideYou.speed <= MaxBoostedSpeed) then
				PlayerProperties.zipline.LetMeGuideYou.speed = PlayerProperties.zipline.LetMeGuideYou.speed + BoostAmount
				game.get_player(event.source_entity.player.index).surface.play_sound
					{
						path = "RTZipAttach",
						position = game.get_player(event.source_entity.player.index).position,
						volume = 0.7
					}
			end
		elseif (PlayerProperties.zipline.BackwardsDirection ~= nil and PlayerProperties.zipline.BackwardsDirection[game.get_player(event.source_entity.player.index).walking_state.direction] ~= nil) then
			if (PlayerProperties.zipline.LetMeGuideYou.speed >= -MaxBoostedSpeed) then
				PlayerProperties.zipline.LetMeGuideYou.speed = PlayerProperties.zipline.LetMeGuideYou.speed - BoostAmount
				game.get_player(event.source_entity.player.index).surface.play_sound
					{
						path = "RTZipAttach",
						position = game.get_player(event.source_entity.player.index).position,
						volume = 0.7
					}
			end
		end

	elseif (event.effect_id == "PrimerThrowerCheck") then
		local detector = event.source_entity
		local DetectorNumber = script.register_on_object_destroyed(detector)
		local thrower = storage.PrimerThrowerLinks[DetectorNumber].thrower
		if (storage.PrimerThrowerLinks[DetectorNumber].ready == true) then
			if (thrower.held_stack.valid_for_read == true) then
				game.surfaces[event.surface_index].create_entity
				{
					name = "RTPrimerThrowerShooter-"..thrower.held_stack.name,
					position = thrower.held_stack_position,
					direction = detector.direction,
					target = event.target_entity,
					force = detector.force,
					raise_built = true,
					create_build_effect_smoke = false
				}.destructible = false
				thrower.held_stack.clear()
			end
			storage.PrimerThrowerLinks[DetectorNumber].ready = false
		end
		
	elseif (string.find(event.effect_id, "RTItemShell")) then
		local ItemName, QualityName = string.match(event.effect_id, "^RTItemShell(.+)%-Q%-(.*)$")
		--[[ rendering.draw_line
		{
			color = {r = 1, g = 0.6, b = 0, a=1},
			width = 5,
			from = event.source_position,
			to = event.target_position,
			surface = surface,
			time_to_live = 120
		} ]]
		local eject = false
		local inserted = 0
		local debris = true
		local speed = storage.ItemCannonSpeed
		local LaserPointer = false
		if (ItemName == "LaserPointer") then
			speed = 0.75
			LaserPointer = true
		end
		if (event.target_entity) then
			local HitEntity = event.target_entity
			if (HitEntity.name == "RTRicochetPanel") then
				if (HitEntity.energy/HitEntity.electric_buffer_size > 0.75) then
					-- the following code was brought to you by ChatGPT cause im way too dumb to come up with this but basically it reflects the item shell off the panel in an angle in = angle out way based on whether the panel is vertical or horizontal. It's actually good enough to handle the panel being at any angle but that sounds like a pain to actually use in game
						local start = event.source_position
						local HitPosition = event.target_position
						local object = HitEntity
						-- positions
						local p_x, p_y = start.x, start.y
						local o_x, o_y = HitPosition.x, HitPosition.y
						local PanelOrientation = object.orientation  -- [0, 1)
						-- 1) Compute the projectile's incoming direction (v_x, v_y).
						--    Let's assume we want center-to-center for simplicity:
						local v_x = o_x - p_x
						local v_y = o_y - p_y
						local v_len = math.sqrt(v_x*v_x + v_y*v_y)
						if v_len > 0 then
							v_x = v_x / v_len
							v_y = v_y / v_len
						end
						-- 2) Compute the normal from Factorio orientation
						local theta = 2 * math.pi * PanelOrientation
						local n_x = math.cos(theta - math.pi/2)
						local n_y = math.sin(theta - math.pi/2)
						-- 3) Reflect v about n
						local dot = (v_x * n_x) + (v_y * n_y)
						local r_x = v_x - 2 * dot * n_x
						local r_y = v_y - 2 * dot * n_y
						-- r_x, r_y now points in the bounced (reflected) direction.
					surface.create_entity
					{
						name=event.effect_id,
						source = HitEntity,
						position = HitPosition,
						target = OffsetPosition(HitPosition, {100*r_x, 100*r_y}),
						speed=speed,
						max_range = 100
					}
					if (not LaserPointer) then
						HitEntity.energy = 0
						surface.play_sound
						{
							path = "RTRicochetPanelSpark",
							position = HitEntity.position,
							volume_modifier = 0.5
						}
						rendering.draw_animation
						{
							animation = "RTRicochetPanelZap",
							target = {entity=HitEntity, offset={0,-0.6}},
							surface = HitEntity.surface,
							time_to_live = 20,
							x_scale = 0.4,
							y_scale = 0.8,
						}
					end
				else
					eject = true
					--debris = false
					if (not LaserPointer) then
						HitEntity.die()
					end
				end
			elseif (HitEntity.name == "RTCatchingChute" and not LaserPointer) then
				surface.play_sound
				{
					path = "RTClunk",
					position = HitEntity.position
				}
				inserted = HitEntity.insert({name=ItemName, count=prototypes.item[ItemName].stack_size, quality=QualityName})
				if (inserted < prototypes.item[ItemName].stack_size) then
					eject = true
					debris = false
				end
			elseif (HitEntity.name == "RTMergingChute") then
				if (HitEntity.energy/HitEntity.electric_buffer_size > 0.75) then
					local start = event.source_position
					local HitPosition = event.target_position
					local deltaX = HitPosition.x - start.x
					local deltaY = HitPosition.y - start.y
					local angle = math.atan2(deltaY, deltaX) - 3*math.pi/4 -- to align with the 45 degree tilt of the chute
					local ProjectileOrientation = (angle / (2 * math.pi)) % 1
					if (ProjectileOrientation ~= HitEntity.orientation and (ProjectileOrientation+0.5)%1 ~= HitEntity.orientation) then
						local OutVector = storage.ChuteOrientationComponents[HitEntity.orientation]
						surface.create_entity
						{
							name=event.effect_id,
							source = HitEntity,
							position = HitEntity.position,
							target = OffsetPosition(HitEntity.position, {100*OutVector.x, 100*OutVector.y}),
							speed=speed,
							max_range = 100
						}
						if (not LaserPointer) then
							HitEntity.energy = 0
						end
					else
						eject = true
						debris = false
					end
				else
					eject = true
					if (not LaserPointer) then
						HitEntity.die()
					end
				end
			elseif (HitEntity.name == "RTDivergingChute") then
				if (HitEntity.energy/HitEntity.electric_buffer_size > 0.75) then
					local start = event.source_position
					local HitPosition = event.target_position
					local deltaX = HitPosition.x - start.x
					local deltaY = HitPosition.y - start.y
					local angle = math.atan2(deltaY, deltaX) - 3*math.pi/4 -- to align with the 45 degree tilt of the chute
					local ProjectileOrientation = (angle / (2 * math.pi)) % 1
					--game.print(ProjectileOrientation.." | "..HitEntity.orientation)
					--if (math.floor((ProjectileOrientation*100) + 0.5) == math.floor((HitEntity.orientation*100) + 0.5)) then
					if (ProjectileOrientation == HitEntity.orientation) then
						local OutX = storage.ChuteOrientationComponents[HitEntity.orientation].x
						local OutY = storage.ChuteOrientationComponents[HitEntity.orientation].y
						-- flips either X or Y direction to bounce out one way or the other. destructible isn't relavent 99% of the time so i use it to track the direction it deflected last
						if (HitEntity.destructible) then
							OutX = -OutX
							HitEntity.destructible = false
						else
							OutY = -OutY
							HitEntity.destructible = true
						end
						surface.create_entity
						{
							name=event.effect_id,
							source = HitEntity,
							position = HitEntity.position,
							target = OffsetPosition(HitEntity.position, {100*OutX, 100*OutY}),
							speed=speed,
							max_range = 100
						}
						if (not LaserPointer) then
							HitEntity.energy = 0
						end
					else
						eject = true
						debris = false
					end
				else
					eject = true
					if (not LaserPointer) then
						HitEntity.die()
					end
				end
			else
				eject = true
			end
		else
			eject = true
		end
		if (eject == true and ItemName ~= "LaserPointer") then
			local start = event.source_position
			local HitPosition = event.target_position
			local deltaX = HitPosition.x - start.x
			local deltaY = HitPosition.y - start.y
			local angle = math.atan2(deltaY, deltaX)
			local ProjectileOrientation = (angle / (2 * math.pi)) % 1
			local StartOffset = {0, 0}
			if (debris == false) then
				StartOffset = {0, -1}
			end
			local count = prototypes.item[ItemName].stack_size - inserted
			local GroupSize = math.ceil(count/17) -- each stack will launch out as maximum 17 projectiles per wagon
			for _ = 1, math.floor(count/GroupSize) do
				local AngleSpread = math.random(-40,40)*0.001
				local xUnit = math.cos(2*math.pi*(ProjectileOrientation+AngleSpread))
				local yUnit = math.sin(2*math.pi*(ProjectileOrientation+AngleSpread))
				local ForwardSpread = math.random(1000,3000)*0.01
				local TargetX = HitPosition.x + (ForwardSpread*0.6*xUnit)-- + (HorizontalSpread*wagon.speed*yUnit)
				local TargetY = HitPosition.y + (ForwardSpread*0.6*yUnit)-- + (HorizontalSpread*wagon.speed*xUnit)
				InvokeThrownItem({
					type = "ReskinnedStream",
					ItemName = ItemName,
					count = GroupSize,
					quality = QualityName,
					speed = 0.6,
					start = OffsetPosition(HitPosition, StartOffset),
					target = {TargetX, TargetY},
					surface = surface,
					space = false,
				})
			end
			if (debris) then
				surface.create_entity
				({
					name = "RTItemShellImpact",
					position = HitPosition,
					target = HitPosition,
					speed = 5
				})
				surface.create_entity
				({
					name = "wall-explosion",
					position = HitPosition
				})
			else
				surface.play_sound
				{
					path = "RTHitWrongAngle",
					position = HitPosition,
				}
			end
		elseif (eject == false and ItemName ~= "LaserPointer") then
			surface.play_sound
			{
				path = "RTRicochetPanelSound",
				position = event.target_position
			}
		end


	elseif (event.effect_id == "BeltRampPlayer") then
		local trigger = event.source_entity
		local ramp = trigger.surface.find_entities_filtered
		{
			type = "transport-belt",
			position = trigger.position,
			limit = 1
		}[1]
		local ranges =
		{
			RTBeltRamp = 10,
			RTfastBeltRamp = 20,
			RTexpressBeltRamp = 30,
			RTturboBeltRamp = 40,
		}
		local range = ranges[ramp.name]
		local speeds =
		{
			RTBeltRamp = 0.15,
			RTfastBeltRamp = 0.25,
			RTexpressBeltRamp = 0.35,
			RTturboBeltRamp = 0.45,
		}
		local speed = speeds[ramp.name]
		local orientation = ramp.orientation
		local characters = trigger.surface.find_entities_filtered
		{
			type = "character",
			position = trigger.position,
			radius = 0.7
		}
		for _, kharacter in pairs(characters) do
			local player = kharacter.player
			local PlayerProperties = storage.AllPlayers[player.index]
			PlayerProperties.state = "jumping"
			local OG, shadow = SwapToGhost(player)
			local TargetX = math.floor(trigger.position.x + range*storage.OrientationUnitComponents[orientation].x)+0.5
			local TargetY = math.floor(trigger.position.y + range*storage.OrientationUnitComponents[orientation].y)+0.5
			local distance = DistanceBetween(trigger.position, {x=TargetX, y=TargetY})
			local AirTime = math.floor(distance/speed)
			local arc = 0.3236*distance^-0.404 -- lower number is higher arc
			local vector = {x=TargetX-player.position.x, y=TargetY-player.position.y}
			local path = {}
			for j = 0, AirTime do
				local progress = j/AirTime
				path[j] =
				{
					x = player.character.position.x+(progress*vector.x),
					y = player.character.position.y+(progress*vector.y),
					height = progress * (1-progress) / arc
				}
			end
			local FlyingItem = InvokeThrownItem({
				type = "PlayerGuide",
				player = player,
				shadow = shadow,
				AirTime = AirTime,
				SwapBack = OG,
				IAmSpeed = player.character.character_running_speed_modifier,
				path = path,
				start = player.position,
				target={x=TargetX, y=TargetY},
				surface=player.surface,
			})
			PlayerProperties.PlayerLauncher.tracker = FlyingItem.FlightNumber
			PlayerProperties.PlayerLauncher.direction = storage.OrientationUnitComponents[orientation].name
		end
		--[[ rendering.draw_line
		{
			color = {r = 1, g = 0.6, b = 0, a=1},
			width = 5,
			from = start,
			to = HitPosition,
			surface = surface,
			time_to_live = 5
		} ]]
	--[[ elseif (event.effect_id == "RTTestProjectileRegularEffect") then
		game.print(game.tick.." Regular effect triggered")
	elseif (event.effect_id == "RTTestProjectileWaterEffect") then
		game.print("Water effect triggered")
		rendering.draw_circle
		{
			color = {r = 0, g = 0, b = 1},
			radius = 0.2,
			width = 1,
			filled = false,
			target = event.target_position,
			surface = surface,
			time_to_live = 60
		}
	elseif (event.effect_id == "RTTestProjectileGroundEffect") then
		game.print("Ground effect triggered")
		rendering.draw_circle
		{
			color = {r = 0, g = 1, b = 0},
			radius = 0.2,
			width = 1,
			filled = false,
			target = event.target_position,
			surface = surface,
			time_to_live = 60
		} ]]
	end
end

return effect_triggered

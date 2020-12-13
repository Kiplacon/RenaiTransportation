local function on_tick(event)
	--| Players
	for ThePlayer, TheirProperties in pairs(global.AllPlayers) do
		--|| Player Launchers
		if (TheirProperties.GuideProjectile and TheirProperties.GuideProjectile.valid and TheirProperties.jumping == true and game.get_player(ThePlayer).character) then
			game.get_player(ThePlayer).character_running_speed_modifier = -0.75
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

		elseif (TheirProperties.jumping == true and game.get_player(ThePlayer).character) then
			game.get_player(ThePlayer).character_running_speed_modifier = 0
			game.get_player(ThePlayer).character.destructible = true
			TheirProperties.jumping = false
			global.AllPlayers[ThePlayer] = {}

		--|| Ziplines
		elseif (TheirProperties.sliding == true and TheirProperties.LetMeGuideYou and TheirProperties.LetMeGuideYou.valid and game.get_player(ThePlayer).character) then
			game.get_player(ThePlayer).character.character_running_speed_modifier = -0.99999

			--||| Set the destination
			if (TheirProperties.WhereDidYouComeFrom ~= nil and TheirProperties.WhereDidYouComeFrom.valid == true and TheirProperties.WhereDidYouGo == nil and TheirProperties.WhereDidYouComeFrom.neighbours["copper"][1]) then
				--game.print("searching")
				game.get_player(ThePlayer).teleport({TheirProperties.ChuggaChugga.position.x, 1.5+TheirProperties.ChuggaChugga.position.y})
				TheirProperties.succ.teleport(TheirProperties.WhereDidYouComeFrom.position)
				--|||| Analyze neighbors
				local possibilities = TheirProperties.WhereDidYouComeFrom.neighbours["copper"] -- table of connected pole entities
				local AngleSorted = {}
				--|||| Group them by direction
				for i, pole in pairs(possibilities) do
					if (pole.type == "electric-pole") then
						local ToXWireOffset3 = game.recipe_prototypes["RTGetTheGoods-"..pole.name.."X"].emissions_multiplier
						local ToYWireOffset3 = game.recipe_prototypes["RTGetTheGoods-"..pole.name.."Y"].emissions_multiplier
						local WhichWay = (math.deg(math.atan2((TheirProperties.LetMeGuideYou.position.y-(pole.position.y+ToYWireOffset3)),(TheirProperties.LetMeGuideYou.position.x-(pole.position.x+ToXWireOffset3))))/1)-90

						if (WhichWay < 0) then -- converts all results to 0 -> +1 orientation notation
							WhichWay = 360+WhichWay
						end
						--game.print(WhichWay)
						if ((WhichWay >= 337.5 and WhichWay < 360) or (WhichWay >= 0 and WhichWay < 22.5)) then --U
							AngleSorted[0] = pole
						elseif (WhichWay >= 22.5 and WhichWay < 67.5) then --UR
							AngleSorted[1] = pole
						elseif (WhichWay >= 67.5 and WhichWay < 112.5) then --R
							AngleSorted[2] = pole
						elseif (WhichWay >= 112.5 and WhichWay < 157.5) then --DR
							AngleSorted[3] = pole
						elseif (WhichWay >= 157.5 and WhichWay < 202.5) then --D
							AngleSorted[4] = pole
						elseif (WhichWay >= 202.5 and WhichWay < 247.5) then --DL
							AngleSorted[5] = pole
						elseif (WhichWay >= 247.5 and WhichWay < 292.5) then --L
							AngleSorted[6] = pole
						elseif (WhichWay >= 292.5 and WhichWay < 337.5) then --UL
							AngleSorted[7] = pole
						end
					end
				end

				--|||| Check walking state
				if (game.get_player(ThePlayer).walking_state.walking == true or TheirProperties.LetMeGuideYou.speed ~= 0) then
					--||||| Set destination by matching walking state to a neighbor
					WhenYou = game.get_player(ThePlayer).walking_state.direction
					local FD = AngleSorted[WhenYou]
					local heading = WhenYou
					if (FD == nil) then
						if (WhenYou == 7) then
							FD = AngleSorted[0]
							heading = 0
						else
							FD = AngleSorted[WhenYou+1]
							heading = WhenYou+1
						end
					end
					if (FD == nil) then
						if (WhenYou == 0) then
							FD = AngleSorted[7]
							heading = 7
						else
							FD = AngleSorted[WhenYou-1]
							heading = WhenYou-1
						end
					end
					if (FD and FD.valid) then
						local current = TheirProperties.WhereDidYouComeFrom
						local FromXWireOffset = game.recipe_prototypes["RTGetTheGoods-"..current.name.."X"].emissions_multiplier
						local FromYWireOffset = game.recipe_prototypes["RTGetTheGoods-"..current.name.."Y"].emissions_multiplier
						local ToXWireOffset = game.recipe_prototypes["RTGetTheGoods-"..FD.name.."X"].emissions_multiplier
						local ToYWireOffset = game.recipe_prototypes["RTGetTheGoods-"..FD.name.."Y"].emissions_multiplier
						TheirProperties.LetMeGuideYou.teleport({current.position.x+FromXWireOffset, current.position.y+FromYWireOffset})
						local angle = math.deg(math.atan2((TheirProperties.LetMeGuideYou.position.y-(FD.position.y+ToYWireOffset)),(TheirProperties.LetMeGuideYou.position.x-(FD.position.x+ToXWireOffset))))
						TheirProperties.LetMeGuideYou.orientation = (angle/360)-0.25 -- I think because Factorio's grid is x-axis flipped compared to a traditional graph, it needs this -0.25 adjustment
						global.AllPlayers[ThePlayer].DaWhey = TheirProperties.LetMeGuideYou.orientation
						--global.AllPlayers[ThePlayer].WhereDidYouComeFrom = arrived
						global.AllPlayers[ThePlayer].WhereDidYouGo = FD
						global.AllPlayers[ThePlayer].distance = math.sqrt(
																		  ((current.position.y+FromYWireOffset)-(FD.position.y+ToYWireOffset))^2
																		 +((current.position.x+FromXWireOffset)-(FD.position.x+ToXWireOffset))^2
																		 )
						global.AllPlayers[ThePlayer].FromWireOffset = {FromXWireOffset, FromYWireOffset}
						global.AllPlayers[ThePlayer].ToWireOffset = {ToXWireOffset, ToYWireOffset}
						if (heading == 0) then
							global.AllPlayers[ThePlayer].ForwardDirection = {[7] = 3, [0] = 3, [1] = 3}
							global.AllPlayers[ThePlayer].BackwardsDirection = {[5] = 3, [4] = 3, [3] = 3}
						elseif (heading == 1) then
							global.AllPlayers[ThePlayer].ForwardDirection = {[0] = 3, [1] = 3, [2] = 3}
							global.AllPlayers[ThePlayer].BackwardsDirection = {[6] = 3, [5] = 3, [4] = 3}
						elseif (heading == 2) then
							global.AllPlayers[ThePlayer].ForwardDirection = {[1] = 3, [2] = 3, [3] = 3}
							global.AllPlayers[ThePlayer].BackwardsDirection = {[7] = 3, [6] = 3, [5] = 3}
						elseif (heading == 3) then
							global.AllPlayers[ThePlayer].ForwardDirection = {[2] = 3, [3] = 3, [4] = 3}
							global.AllPlayers[ThePlayer].BackwardsDirection = {[0] = 3, [7] = 3, [6] = 3}
						elseif (heading == 4) then
							global.AllPlayers[ThePlayer].ForwardDirection = {[3] = 3, [4] = 3, [5] = 3}
							global.AllPlayers[ThePlayer].BackwardsDirection = {[1] = 3, [0] = 3, [7] = 3}
						elseif (heading == 5) then
							global.AllPlayers[ThePlayer].ForwardDirection = {[4] = 3, [5] = 3, [6] = 3}
							global.AllPlayers[ThePlayer].BackwardsDirection = {[2] = 3, [1] = 3, [0] = 3}
						elseif (heading == 6) then
							global.AllPlayers[ThePlayer].ForwardDirection = {[5] = 3, [6] = 3, [7] = 3}
							global.AllPlayers[ThePlayer].BackwardsDirection = {[3] = 3, [2] = 3, [1] = 3}
						elseif (heading == 7) then
							global.AllPlayers[ThePlayer].ForwardDirection = {[6] = 3, [7] = 3, [0] = 3}
							global.AllPlayers[ThePlayer].BackwardsDirection = {[4] = 3, [3] = 3, [2] = 3}
						else
							global.AllPlayers[ThePlayer].ForwardDirection = {}
							global.AllPlayers[ThePlayer].BackwardsDirection = {}
						end
						--game.print("set destination, heading off in "..heading)
					else
						TheirProperties.LetMeGuideYou.speed = 0
						--game.print("not pressing a valid direction")
					end

				else
					TheirProperties.LetMeGuideYou.speed = 0
					--game.print("not pressing movement key")
				end

			--||| Do the movement
			elseif (TheirProperties.WhereDidYouComeFrom.valid and TheirProperties.WhereDidYouGo.valid and TheirProperties.AreYouStillThere == true) then
				--|||| Set/calc sliding "properties"
				TheirProperties.AreYouStillThere = false
				for the, poles in pairs(TheirProperties.WhereDidYouComeFrom.neighbours["copper"]) do
					if (TheirProperties.WhereDidYouGo.unit_number == poles.unit_number) then
						TheirProperties.AreYouStillThere = true
					end
				end

				local FromStart = math.sqrt((TheirProperties.LetMeGuideYou.position.y-(TheirProperties.WhereDidYouComeFrom.position.y+TheirProperties.FromWireOffset[2]))^2+(TheirProperties.LetMeGuideYou.position.x-(TheirProperties.WhereDidYouComeFrom.position.x+TheirProperties.FromWireOffset[1]))^2)
				local FromEnd = math.sqrt((TheirProperties.LetMeGuideYou.position.y-(TheirProperties.WhereDidYouGo.position.y+TheirProperties.ToWireOffset[2]))^2+(TheirProperties.LetMeGuideYou.position.x-(TheirProperties.WhereDidYouGo.position.x+TheirProperties.ToWireOffset[1]))^2)
				--game.print("From start "..string.format("%.2f", FromStart).."/"..TheirProperties.distance)
				--game.print("From end "..string.format("%.9f", FromEnd).."/"..TheirProperties.distance)
				--game.print(FromStart+FromEnd)
				--|||| Before destination
				if (FromStart <= TheirProperties.distance and FromEnd-0.1 <= TheirProperties.distance) then

					if (settings.get_player_settings(game.get_player(ThePlayer))["RTZiplineSmoothSetting"].value == "Motion Follows Trolley") then
						FollowZip = (3*(FromStart^2-FromStart*TheirProperties.distance)/TheirProperties.distance^2)
					else
						FollowZip = 0
					end

					game.get_player(ThePlayer).teleport
						({
							TheirProperties.LetMeGuideYou.position.x,
							2+TheirProperties.LetMeGuideYou.position.y-FollowZip
						})
					TheirProperties.ChuggaChugga.teleport
						({
							TheirProperties.LetMeGuideYou.position.x,
							0.5+TheirProperties.LetMeGuideYou.position.y-(3*(FromStart^2-FromStart*TheirProperties.distance)/TheirProperties.distance^2)
						})
					TheirProperties.LetMeGuideYou.orientation = TheirProperties.DaWhey

					if (game.get_player(ThePlayer).character.get_inventory(defines.inventory.character_guns)[game.get_player(ThePlayer).character.selected_gun_index].valid_for_read
					and game.get_player(ThePlayer).character.get_inventory(defines.inventory.character_guns)[game.get_player(ThePlayer).character.selected_gun_index].name == "RTZiplineItem"
					and game.get_player(ThePlayer).character.get_inventory(defines.inventory.character_ammo)[game.get_player(ThePlayer).character.selected_gun_index].valid_for_read
					and game.get_player(ThePlayer).walking_state.walking == true
					and TheirProperties.succ.energy ~= 0)
					then
						if (game.tick%2 == 0 and TheirProperties.ForwardDirection[game.get_player(ThePlayer).walking_state.direction] ~= nil) then
							if (TheirProperties.LetMeGuideYou.speed <= 0.315) then
								TheirProperties.LetMeGuideYou.speed = TheirProperties.LetMeGuideYou.speed + 0.008 --increments slower than 0.008 don't seem to do anything
							end
						elseif (game.tick%2 == 0 and TheirProperties.BackwardsDirection[game.get_player(ThePlayer).walking_state.direction] ~= nil) then
							if (TheirProperties.LetMeGuideYou.speed >= -0.315) then
								TheirProperties.LetMeGuideYou.speed = TheirProperties.LetMeGuideYou.speed - 0.008
							end
						end
					elseif (game.tick%2 == 0) then
						if (TheirProperties.LetMeGuideYou.speed > 0) then
							TheirProperties.LetMeGuideYou.speed = TheirProperties.LetMeGuideYou.speed - 0.004
						elseif (TheirProperties.LetMeGuideYou.speed < 0) then
							TheirProperties.LetMeGuideYou.speed = TheirProperties.LetMeGuideYou.speed + 0.004
						end
					end

				--|||| At/After destination
				elseif (FromStart >= TheirProperties.distance and #TheirProperties.WhereDidYouGo.neighbours["copper"] > 1 and TheirProperties.WhereDidYouGo.neighbours["copper"][1]) then
					--game.print("Arrived, removing destination to find a new one")
					TheirProperties.WhereDidYouComeFrom = TheirProperties.WhereDidYouGo
					TheirProperties.WhereDidYouGo = nil

				--|||| Back at start
				elseif (FromEnd-0.1 > TheirProperties.distance and #TheirProperties.WhereDidYouComeFrom.neighbours["copper"] > 1 and TheirProperties.WhereDidYouComeFrom.neighbours["copper"][1]) then
					--game.print("Returned, removing destination to find a new one")
					TheirProperties.LetMeGuideYou.speed = 0 --For some reason character gets stuck if I don't do this
					--TheirProperties.WhereDidYouComeFrom = TheirProperties.WhereDidYouGo
					TheirProperties.WhereDidYouGo = nil

				--|||| Hit dead end
				else
					TheirProperties.LetMeGuideYou.surface.play_sound
						{
							path = "RTZipDettach",
							position = TheirProperties.LetMeGuideYou.position,
							volume = 0.4
						}
					TheirProperties.LetMeGuideYou.surface.play_sound
						{
							path = "RTZipWindDown",
							position = TheirProperties.LetMeGuideYou.position,
							volume = 0.4
						}
					TheirProperties.LetMeGuideYou.destroy()
					TheirProperties.ChuggaChugga.destroy()
					TheirProperties.succ.destroy()
					game.get_player(ThePlayer).character_running_speed_modifier = 0
					game.get_player(ThePlayer).teleport(game.get_player(ThePlayer).surface.find_non_colliding_position("character", {game.get_player(ThePlayer).position.x, game.get_player(ThePlayer).position.y+2}, 0, 0.01))
					global.AllPlayers[ThePlayer] = {}
					--game.print("Dead end")
				end
			--||| Break if poles are invalid (destroyed or something)
			else -- One of the two ends is no longer valid
				TheirProperties.LetMeGuideYou.surface.play_sound
					{
						path = "RTZipDettach",
						position = TheirProperties.LetMeGuideYou.position,
						volume = 0.4
					}
				TheirProperties.LetMeGuideYou.surface.play_sound
					{
						path = "RTZipWindDown",
						position = TheirProperties.LetMeGuideYou.position,
						volume = 0.4
					}
				TheirProperties.LetMeGuideYou.destroy()
				TheirProperties.ChuggaChugga.destroy()
				TheirProperties.succ.destroy()
				game.get_player(ThePlayer).character_running_speed_modifier = 0
				game.get_player(ThePlayer).teleport(game.get_player(ThePlayer).surface.find_non_colliding_position("character", {game.get_player(ThePlayer).position.x, game.get_player(ThePlayer).position.y+2}, 0, 0.01))
				global.AllPlayers[ThePlayer] = {}
				--game.print("failsafe/wire destroyed")
			end
		--||| Zipline Failsafe
		elseif (TheirProperties.sliding == true) then
			TheirProperties.LetMeGuideYou.destroy()
			TheirProperties.ChuggaChugga.destroy()
			TheirProperties.succ.destroy()
			global.AllPlayers[ThePlayer] = {}

		--||| Failsafe failsafe
		elseif (TheirProperties.reset == nil and game.get_player(ThePlayer).connected and game.get_player(ThePlayer).character) then
				game.get_player(ThePlayer).character_running_speed_modifier = 0
				game.get_player(ThePlayer).character.destructible = true
				global.AllPlayers[ThePlayer] = {}
				global.AllPlayers[ThePlayer].reset = true

		end
	end
end

return on_tick

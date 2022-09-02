local function on_tick(event)
	--| Players
	for ThePlayer, PlayerProperties in pairs(global.AllPlayers) do
		local player = game.players[ThePlayer]
		--|| Player Launchers
		if (PlayerProperties.state == "jumping" and game.get_player(ThePlayer).character and PlayerProperties.sliding ~= true) then
			game.get_player(ThePlayer).character_running_speed_modifier = -0.75
			local FlyingItem = global.FlyingItems[PlayerProperties.PlayerLauncher.tracker]
			local duration = game.tick-FlyingItem.StartTick
			local progress = duration/FlyingItem.AirTime
			local height = (duration/(FlyingItem.arc*FlyingItem.AirTime))-(duration^2/(FlyingItem.arc*FlyingItem.AirTime^2))
			--rendering.set_target(FlyingItem.sprite, {FlyingItem.start.x+(progress*FlyingItem.vector.x), FlyingItem.start.y+(progress*FlyingItem.vector.y)+height})
			rendering.set_target(FlyingItem.shadow, {FlyingItem.start.x+(progress*FlyingItem.vector.x)-height, FlyingItem.start.y+(progress*FlyingItem.vector.y)})
			game.get_player(ThePlayer).teleport -- predefined bounce "animation"
				(
					{FlyingItem.start.x+(progress*FlyingItem.vector.x), FlyingItem.start.y+(progress*FlyingItem.vector.y)+height}
				)
			if (PlayerProperties.PlayerLauncher.direction == "right") then
				game.get_player(ThePlayer).walking_state = {walking = true, direction = defines.direction.east}
			elseif (PlayerProperties.PlayerLauncher.direction == "left") then
				game.get_player(ThePlayer).walking_state = {walking = true, direction = defines.direction.west}
			elseif (PlayerProperties.PlayerLauncher.direction == "up") then
				game.get_player(ThePlayer).walking_state = {walking = true, direction = defines.direction.north}
			elseif (PlayerProperties.PlayerLauncher.direction == "down") then
				game.get_player(ThePlayer).walking_state = {walking = true, direction = defines.direction.south}
			end

		--|| Ziplines
		elseif (PlayerProperties.state == "zipline" and PlayerProperties.zipline.LetMeGuideYou and PlayerProperties.zipline.LetMeGuideYou.valid and game.get_player(ThePlayer).character) then
			local ZiplineStuff = PlayerProperties.zipline
			game.get_player(ThePlayer).character.character_running_speed_modifier = -0.99999

			--||| Set the destination
			if (ZiplineStuff.WhereDidYouComeFrom ~= nil and ZiplineStuff.WhereDidYouComeFrom.valid == true and ZiplineStuff.WhereDidYouGo == nil and ZiplineStuff.WhereDidYouComeFrom.neighbours["copper"][1]) then
				--game.print("searching"..game.tick)
				game.get_player(ThePlayer).teleport({ZiplineStuff.ChuggaChugga.position.x, 1.5+ZiplineStuff.ChuggaChugga.position.y})
				ZiplineStuff.succ.teleport(ZiplineStuff.WhereDidYouComeFrom.position)
				--|||| Analyze neighbors
				local possibilities = ZiplineStuff.WhereDidYouComeFrom.neighbours["copper"] -- table of connected pole entities
				local AngleSorted = {}
				local AutoPathHeading
				if (ZiplineStuff.path == nil) then
					--|||| Group them by direction
					for i, pole in pairs(possibilities) do
						if (pole.type == "electric-pole" and pole.type ~= "entity-ghost") then
							local ToXWireOffset3 = game.recipe_prototypes["RTGetTheGoods-"..pole.name.."X"].emissions_multiplier
							local ToYWireOffset3 = game.recipe_prototypes["RTGetTheGoods-"..pole.name.."Y"].emissions_multiplier
							local WhichWay = (math.deg(math.atan2((ZiplineStuff.LetMeGuideYou.position.y-(pole.position.y+ToYWireOffset3)),(ZiplineStuff.LetMeGuideYou.position.x-(pole.position.x+ToXWireOffset3))))/1)-90

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
				else
					local pole
						for i, d in pairs(ZiplineStuff.path) do
							pole = d
							break
						end
						if (pole.valid == false) then
							GetOffZipline(player, PlayerProperties)
							player.print({"zipline-stuff.missing"})
							break
						end
					local ToXWireOffset3 = game.recipe_prototypes["RTGetTheGoods-"..pole.name.."X"].emissions_multiplier
					local ToYWireOffset3 = game.recipe_prototypes["RTGetTheGoods-"..pole.name.."Y"].emissions_multiplier
					local WhichWay = (math.deg(math.atan2((ZiplineStuff.LetMeGuideYou.position.y-(pole.position.y+ToYWireOffset3)),(ZiplineStuff.LetMeGuideYou.position.x-(pole.position.x+ToXWireOffset3))))/1)-90

					if (WhichWay < 0) then -- converts all results to 0 -> +1 orientation notation
						WhichWay = 360+WhichWay
					end
					--game.print(WhichWay)
					if ((WhichWay >= 337.5 and WhichWay < 360) or (WhichWay >= 0 and WhichWay < 22.5)) then --U
						AutoPathHeading = 0
					elseif (WhichWay >= 22.5 and WhichWay < 67.5) then --UR
						AutoPathHeading = 1
					elseif (WhichWay >= 67.5 and WhichWay < 112.5) then --R
						AutoPathHeading = 2
					elseif (WhichWay >= 112.5 and WhichWay < 157.5) then --DR
						AutoPathHeading = 3
					elseif (WhichWay >= 157.5 and WhichWay < 202.5) then --D
						AutoPathHeading = 4
					elseif (WhichWay >= 202.5 and WhichWay < 247.5) then --DL
						AutoPathHeading = 5
					elseif (WhichWay >= 247.5 and WhichWay < 292.5) then --L
						AutoPathHeading = 6
					elseif (WhichWay >= 292.5 and WhichWay < 337.5) then --UL
						AutoPathHeading = 7
					end
				end

				--|||| Check walking state
				if (game.get_player(ThePlayer).walking_state.walking == true or ZiplineStuff.LetMeGuideYou.speed ~= 0 or ZiplineStuff.path ~= nil) then
					local FD
					local heading
					if (ZiplineStuff.path == nil) then
						--||||| Set destination by matching walking state to a neighbor
						local WhenYou = game.get_player(ThePlayer).walking_state.direction
						FD = AngleSorted[WhenYou]
						heading = WhenYou
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
					else
						for i, d in pairs(ZiplineStuff.path) do
							FD = d
							break
						end
						heading = AutoPathHeading
					end

					if (FD and FD.valid) then
						local current = ZiplineStuff.WhereDidYouComeFrom
						local FromXWireOffset = game.recipe_prototypes["RTGetTheGoods-"..current.name.."X"].emissions_multiplier
						local FromYWireOffset = game.recipe_prototypes["RTGetTheGoods-"..current.name.."Y"].emissions_multiplier
						local ToXWireOffset = game.recipe_prototypes["RTGetTheGoods-"..FD.name.."X"].emissions_multiplier
						local ToYWireOffset = game.recipe_prototypes["RTGetTheGoods-"..FD.name.."Y"].emissions_multiplier
						ZiplineStuff.LetMeGuideYou.teleport({current.position.x+FromXWireOffset, current.position.y+FromYWireOffset})
						local angle = math.deg(math.atan2((ZiplineStuff.LetMeGuideYou.position.y-(FD.position.y+ToYWireOffset)),(ZiplineStuff.LetMeGuideYou.position.x-(FD.position.x+ToXWireOffset))))
						ZiplineStuff.LetMeGuideYou.orientation = (angle/360)-0.25 -- I think because Factorio's grid is x-axis flipped compared to a traditional graph, it needs this -0.25 adjustment
						ZiplineStuff.DaWhey = ZiplineStuff.LetMeGuideYou.orientation
						--global.AllPlayers[ThePlayer].WhereDidYouComeFrom = arrived
						ZiplineStuff.WhereDidYouGo = FD
						ZiplineStuff.distance = math.sqrt(
																		  ((current.position.y+FromYWireOffset)-(FD.position.y+ToYWireOffset))^2
																		 +((current.position.x+FromXWireOffset)-(FD.position.x+ToXWireOffset))^2
																		 )
						ZiplineStuff.FromWireOffset = {FromXWireOffset, FromYWireOffset}
						ZiplineStuff.ToWireOffset = {ToXWireOffset, ToYWireOffset}
						if (heading == 0) then
							ZiplineStuff.ForwardDirection = {[7] = 3, [0] = 3, [1] = 3}
							ZiplineStuff.BackwardsDirection = {[5] = 3, [4] = 3, [3] = 3}
						elseif (heading == 1) then
							ZiplineStuff.ForwardDirection = {[0] = 3, [1] = 3, [2] = 3}
							ZiplineStuff.BackwardsDirection = {[6] = 3, [5] = 3, [4] = 3}
						elseif (heading == 2) then
							ZiplineStuff.ForwardDirection = {[1] = 3, [2] = 3, [3] = 3}
							ZiplineStuff.BackwardsDirection = {[7] = 3, [6] = 3, [5] = 3}
						elseif (heading == 3) then
							ZiplineStuff.ForwardDirection = {[2] = 3, [3] = 3, [4] = 3}
							ZiplineStuff.BackwardsDirection = {[0] = 3, [7] = 3, [6] = 3}
						elseif (heading == 4) then
							ZiplineStuff.ForwardDirection = {[3] = 3, [4] = 3, [5] = 3}
							ZiplineStuff.BackwardsDirection = {[1] = 3, [0] = 3, [7] = 3}
						elseif (heading == 5) then
							ZiplineStuff.ForwardDirection = {[4] = 3, [5] = 3, [6] = 3}
							ZiplineStuff.BackwardsDirection = {[2] = 3, [1] = 3, [0] = 3}
						elseif (heading == 6) then
							ZiplineStuff.ForwardDirection = {[5] = 3, [6] = 3, [7] = 3}
							ZiplineStuff.BackwardsDirection = {[3] = 3, [2] = 3, [1] = 3}
						elseif (heading == 7) then
							ZiplineStuff.ForwardDirection = {[6] = 3, [7] = 3, [0] = 3}
							ZiplineStuff.BackwardsDirection = {[4] = 3, [3] = 3, [2] = 3}
						else
							ZiplineStuff.ForwardDirection = {}
							ZiplineStuff.BackwardsDirection = {}
						end
						--game.print("set destination, heading off in "..heading)
					else
						ZiplineStuff.LetMeGuideYou.speed = 0
						--game.print("not pressing a valid direction")
					end

				else
					ZiplineStuff.LetMeGuideYou.speed = 0
					--game.print("not pressing movement key")
				end

			--||| Do the movement
			elseif (ZiplineStuff.WhereDidYouComeFrom.valid and ZiplineStuff.WhereDidYouGo.valid and ZiplineStuff.AreYouStillThere == true) then
				--|||| Set/calc sliding "properties"
				ZiplineStuff.AreYouStillThere = false
				for the, poles in pairs(ZiplineStuff.WhereDidYouComeFrom.neighbours["copper"]) do
					if (ZiplineStuff.WhereDidYouGo.unit_number == poles.unit_number) then
						ZiplineStuff.AreYouStillThere = true
					end
				end

				local FromStart = math.sqrt((ZiplineStuff.LetMeGuideYou.position.y-(ZiplineStuff.WhereDidYouComeFrom.position.y+ZiplineStuff.FromWireOffset[2]))^2+(ZiplineStuff.LetMeGuideYou.position.x-(ZiplineStuff.WhereDidYouComeFrom.position.x+ZiplineStuff.FromWireOffset[1]))^2)
				local FromEnd = math.sqrt((ZiplineStuff.LetMeGuideYou.position.y-(ZiplineStuff.WhereDidYouGo.position.y+ZiplineStuff.ToWireOffset[2]))^2+(ZiplineStuff.LetMeGuideYou.position.x-(ZiplineStuff.WhereDidYouGo.position.x+ZiplineStuff.ToWireOffset[1]))^2)
				--game.print("From start "..string.format("%.2f", FromStart).."/"..ZiplineStuff.distance)
				--game.print("From end "..string.format("%.9f", FromEnd).."/"..ZiplineStuff.distance)
				--game.print(FromStart+FromEnd)
				--|||| Before destination
				if (FromStart <= ZiplineStuff.distance and FromEnd-0.1 <= ZiplineStuff.distance) then

					if (settings.get_player_settings(game.get_player(ThePlayer))["RTZiplineSmoothSetting"].value == "Bobbing Motion") then
						FollowZip = (3*(FromStart^2-FromStart*ZiplineStuff.distance)/ZiplineStuff.distance^2)
					else
						FollowZip = 0
					end

					game.get_player(ThePlayer).teleport
						({
							ZiplineStuff.LetMeGuideYou.position.x,
							2+ZiplineStuff.LetMeGuideYou.position.y-FollowZip
						})
					ZiplineStuff.ChuggaChugga.teleport
						({
							ZiplineStuff.LetMeGuideYou.position.x,
							0.5+ZiplineStuff.LetMeGuideYou.position.y-(3*(FromStart^2-FromStart*ZiplineStuff.distance)/ZiplineStuff.distance^2)
						})
					ZiplineStuff.LetMeGuideYou.orientation = ZiplineStuff.DaWhey
					local MaxSpeed = 0.3
					if (ZiplineStuff.path) then
						MaxSpeed = 0.15
					end
					if (game.get_player(ThePlayer).character.get_inventory(defines.inventory.character_guns)[game.get_player(ThePlayer).character.selected_gun_index].valid_for_read
					and game.get_player(ThePlayer).character.get_inventory(defines.inventory.character_guns)[game.get_player(ThePlayer).character.selected_gun_index].name == "RTZiplineItem"
					and game.get_player(ThePlayer).character.get_inventory(defines.inventory.character_ammo)[game.get_player(ThePlayer).character.selected_gun_index].valid_for_read
					and (game.get_player(ThePlayer).walking_state.walking == true or ZiplineStuff.path)
					and ZiplineStuff.succ.energy ~= 0
					and math.abs(ZiplineStuff.LetMeGuideYou.speed) <= MaxSpeed)
					then
						if (game.tick%2 == 0 and (ZiplineStuff.ForwardDirection[game.get_player(ThePlayer).walking_state.direction] ~= nil or ZiplineStuff.path)) then
							if (ZiplineStuff.LetMeGuideYou.speed <= MaxSpeed) then
								ZiplineStuff.LetMeGuideYou.speed = ZiplineStuff.LetMeGuideYou.speed + 0.008 --increments slower than 0.008 don't seem to do anything
							end
						elseif (ZiplineStuff.path == nil and game.tick%2 == 0 and ZiplineStuff.BackwardsDirection[game.get_player(ThePlayer).walking_state.direction] ~= nil) then
							if (ZiplineStuff.LetMeGuideYou.speed >= -MaxSpeed) then
								ZiplineStuff.LetMeGuideYou.speed = ZiplineStuff.LetMeGuideYou.speed - 0.008
							end
						end
					elseif (game.tick%2 == 0) then
						if (ZiplineStuff.LetMeGuideYou.speed > 0) then
							ZiplineStuff.LetMeGuideYou.speed = ZiplineStuff.LetMeGuideYou.speed - 0.004
						elseif (ZiplineStuff.LetMeGuideYou.speed < 0) then
							ZiplineStuff.LetMeGuideYou.speed = ZiplineStuff.LetMeGuideYou.speed + 0.004
						end
					end

				--|||| At/After destination
				elseif (FromStart >= ZiplineStuff.distance and #ZiplineStuff.WhereDidYouGo.neighbours["copper"] > 1 and ZiplineStuff.WhereDidYouGo.neighbours["copper"][1]) then
					--game.print("Arrived, removing destination to find a new one")
					ZiplineStuff.WhereDidYouComeFrom = ZiplineStuff.WhereDidYouGo
					ZiplineStuff.WhereDidYouGo = nil
					if (ZiplineStuff.path) then
						for i, d in pairs(ZiplineStuff.path) do
							ZiplineStuff.path[i] = nil
							break
						end
						if (ZiplineStuff.WhereDidYouComeFrom.unit_number == ZiplineStuff.FinalStop.unit_number) then
							GetOffZipline(player, PlayerProperties)
						end
					end

				--|||| Back at start
				elseif (FromEnd-0.1 > ZiplineStuff.distance and #ZiplineStuff.WhereDidYouComeFrom.neighbours["copper"] > 1 and ZiplineStuff.WhereDidYouComeFrom.neighbours["copper"][1]) then
					--game.print("Returned, removing destination to find a new one")
					ZiplineStuff.LetMeGuideYou.speed = 0 --For some reason character gets stuck if I don't do this
					--ZiplineStuff.WhereDidYouComeFrom = ZiplineStuff.WhereDidYouGo
					ZiplineStuff.WhereDidYouGo = nil

				--|||| Hit dead end
				else
					GetOffZipline(player, PlayerProperties)
					--game.print("Dead end")
				end
			--||| Break if poles are invalid (destroyed or something)
			else -- One of the two ends is no longer valid
				GetOffZipline(player, PlayerProperties)
				--game.print("failsafe/wire destroyed")
			end
		--||| Zipline Failsafe
		elseif (PlayerProperties.state == "zipline" and PlayerProperties.zipline.path == nil) then
			GetOffZipline(player, PlayerProperties)

		--||| Set thrower range before placing
		elseif (PlayerProperties.RangeAdjusting == true) then
			-- keep it on

		--||| Failsafe failsafe
		elseif (PlayerProperties.state ~= "default" and game.get_player(ThePlayer).connected and game.get_player(ThePlayer).character) then
			game.get_player(ThePlayer).character_running_speed_modifier = 0
			game.get_player(ThePlayer).character.destructible = true
		end

----------------- GUI stuff --------------------
		local player = game.players[ThePlayer]
		if (PlayerProperties.GUI.SwapTo) then
			if (PlayerProperties.GUI.SwapTo == "ZiplineTerminal") then
				player.opened = nil
				ShowZiplineTerminalGUI(player, PlayerProperties.GUI.terminal)
			end
		elseif (PlayerProperties.GUI.CloseOut) then
			local char = player.character
			player.character = nil
			player.character = char
		end
		PlayerProperties.GUI = {}

	end
end

return on_tick

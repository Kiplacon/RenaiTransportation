-- player_index :: uint
-- input_name :: string: The prototype name of the custom input that was activated.
-- cursor_position
local function ClickTracking(event)
local player = game.players[event.player_index]
local selected = player.selected
local PlayerProperties = GetOrRegisterPlayerProperties(player)
	if (PlayerProperties.action == "none") then
	 	if (selected and selected.name == "ProviderPole" and player.is_cursor_empty() == true and #selected.neighbours["copper"] > 0) then
			PlayerProperties.action = "PolePathing1"
			PlayerProperties.variables.StartPole = selected
			game.print("path start")
			CloseGUIs(player)
		elseif (selected and selected.name == "SupplierPole" and player.is_cursor_empty() == true) then
			--CloseGUIs(player)
			player.opened = SwapToGUI(player, global.PoleNetwork.SupplierPoles[selected.unit_number].interface)
		end

	elseif (PlayerProperties.action == "PolePathing1" and PlayerProperties.variables.StartPole.valid and selected and selected.name == "SupplierPole" and player.is_cursor_empty() == true ) then
		-- Should have:
		--	 PlayerProperties.variables.StartPole : the power pole entity
		if (PlayerProperties.variables.StartPole.electric_network_id ~= selected.electric_network_id) then
			player.print("Not connected")
			PlayerProperties.action = "none"
			PlayerProperties.variables = {}
		else
		   local start = PlayerProperties.variables.StartPole
		   local finish = selected
		   local possibilities = {}
					possibilities[start.unit_number] = {entity=start, FromStart=0, FromFinish=DistanceBetween(start.position, finish.position), difficulty=DistanceBetween(start.position, finish.position)}
		   local analyzed = {}
		   local found = false
		   while (found == false) do
		      local current
		      local ID
				for i, d in pairs(possibilities) do
					current = d
					ID = i
					break
				end
		      for i, option in pairs(possibilities) do
		         if (option.difficulty <= current.difficulty and option.FromFinish < current.FromFinish) then
		            current = option
		            ID = i
		         end
		      end
		      possibilities[ID] = nil
		      analyzed[current.entity.unit_number] = current
				rendering.draw_text{
					text="C",
					surface=current.entity.surface,
					target=current.entity,
					color={1,0,0},
					scale = 5,
					time_to_live = 60*5
				}
		      if (current.entity.unit_number == finish.unit_number) then
		         found = true
		         break
		      end

		      for each, neighbor in pairs(current.entity.neighbours["copper"]) do
		         local FromStart = current.FromStart + DistanceBetween(current.entity.position, neighbor.position)
		         if (analyzed[neighbor.unit_number] == nil and (#neighbor.neighbours["copper"] > 1 or neighbor.unit_number == finish.unit_number) and (possibilities[neighbor.unit_number] == nil or possibilities[neighbor.unit_number].FromStart > FromStart)) then
		            local difficulty = FromStart + DistanceBetween(neighbor.position, finish.position)
		            possibilities[neighbor.unit_number] = {entity=neighbor, FromStart=FromStart, FromFinish=DistanceBetween(neighbor.position, finish.position), difficulty=difficulty, parent=current.entity}
		         end
		      end
		   end

		   if (found == true) then
		      local backtrack = false
		      local path = {}
		      local WhereDidYouComeFrom = finish
		      table.insert(path, WhereDidYouComeFrom)
		      while (backtrack == false) do
		         WhereDidYouComeFrom = analyzed[WhereDidYouComeFrom.unit_number].parent
		         table.insert(path, WhereDidYouComeFrom)
		         if (WhereDidYouComeFrom.unit_number == start.unit_number) then
		            backtrack = true
		         end
		      end
		      for each, entity in pairs(path) do
					if (each ~= 1) then
			         rendering.draw_line{
			            surface=entity.surface,
			            from=entity,
							to=path[each-1],
			            color={0,1,0},
							width=5,
							time_to_live = 60*5
			         }
					end
		      end
		      PlayerProperties.action = "none"
		      PlayerProperties.variables = {}
		   end
		end
		CloseGUIs(player)
	end
end

return ClickTracking

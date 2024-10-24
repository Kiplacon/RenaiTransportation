local function FindPath(finish, start)
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
      if (current.entity.unit_number == finish.unit_number) then
         found = true
         break
      end

      for each, connection in pairs(current.entity.get_wire_connector(defines.wire_connector_id.pole_copper, true).real_connections) do
         local neighbor = connection.target.owner
         if (neighbor.type ~= "entity-ghost" and neighbor.type == "electric-pole" and ElectricPoleBlackList[neighbor.name] == nil) then
            local FromStart = current.FromStart + DistanceBetween(current.entity.position, neighbor.position)
            if (analyzed[neighbor.unit_number] == nil and (#neighbor.get_wire_connector(defines.wire_connector_id.pole_copper, true).real_connections > 1 or neighbor.unit_number == finish.unit_number) and (possibilities[neighbor.unit_number] == nil or possibilities[neighbor.unit_number].FromStart > FromStart)) then
               local difficulty = FromStart + DistanceBetween(neighbor.position, finish.position)
               possibilities[neighbor.unit_number] = {entity=neighbor, FromStart=FromStart, FromFinish=DistanceBetween(neighbor.position, finish.position), difficulty=difficulty, parent=current.entity}
            end
         end
      end
   end

   if (found == true) then
      local backtrack = false
      local path = {}
      local WhereDidYouComeFrom = finish
      --table.insert(path, WhereDidYouComeFrom)
      while (backtrack == false) do
         WhereDidYouComeFrom = analyzed[WhereDidYouComeFrom.unit_number].parent
         table.insert(path, WhereDidYouComeFrom)
         if (WhereDidYouComeFrom.unit_number == start.unit_number) then
            backtrack = true
         end
      end
      return path
   end
end

ClickableStuff = {
	RTCloseGUI = function(event, player)
		event.element.parent.parent.destroy()
	end,
	ZiplineAutoPath = function(event, player)
		local PlayerProperties = storage.AllPlayers[player.index]
      if (storage.ZiplineTerminals[event.element.tags.start] and storage.ZiplineTerminals[event.element.tags.finish]) then
         local start = storage.ZiplineTerminals[event.element.tags.start].entity
         local finish = storage.ZiplineTerminals[event.element.tags.finish].entity
         if (start.valid and finish.valid and start.electric_network_id == finish.electric_network_id) then
            GetOnZipline(player, PlayerProperties, start)
            PlayerProperties.zipline.path = FindPath(start, finish)
            PlayerProperties.zipline.FinalStop = finish

         elseif (start.valid and finish.valid and start.electric_network_id ~= finish.electric_network_id) then
            player.print({"zipline-stuff.NotOnSameNetwork"})

         else
            player.print({"zipline-stuff.MissingChoice"})
         end
         event.element.parent.parent.parent.destroy()
      else
         player.print({"zipline-stuff.MissingChoice"})
      end
	end,
	RTStartRenameTerminal = function(event, player)
		local PlayerProperties = storage.AllPlayers[player.index]
		local header = event.element.parent
		local TerminalName = event.element.parent.TerminalName.caption
		event.element.parent.TerminalName.destroy()
		event.element.destroy()
		header.add{type="textfield", name="TerminalName", text=TerminalName, clear_and_focus_on_right_click=true}.style.font = "heading-1"
		header.add{
			type = "sprite-button",
			style = "frame_action_button",
			sprite = "utility/check_mark_green",
			tooltip = {"zipline-stuff.ChangeName"},
			-- hovered_sprite = "utility/rename_icon_small_black",
			-- clicked_sprite = "utility/rename_icon_small_black",
			tags = {RTEffect="RTRenameTerminal"}
		}
	end,
	RTRenameTerminal = function(event, player)
		local PlayerProperties = storage.AllPlayers[player.index]
		local header = event.element.parent
		local TerminalName = event.element.parent.TerminalName.text
		storage.ZiplineTerminals[event.element.parent.parent.tags.ID].name = TerminalName
      if (storage.ZiplineTerminals[event.element.parent.parent.tags.ID].tag.valid) then
         storage.ZiplineTerminals[event.element.parent.parent.tags.ID].tag.text = TerminalName
      end
		event.element.parent.TerminalName.destroy()
		event.element.destroy()
		header.add{type="label", name="TerminalName", caption=TerminalName}.style.font = "heading-1"
		header.add{
			type = "sprite-button",
			style = "frame_action_button",
			sprite = "utility/rename_icon",
			hovered_sprite = "utility/rename_icon",
			clicked_sprite = "utility/rename_icon",
			tooltip = {"zipline-stuff.rename"},
			tags = {RTEffect="RTStartRenameTerminal"}
		}
	end,
   ZiplineCamera = function(event, player)
      local PlayerProperties = storage.AllPlayers[player.index]
      PlayerProperties.preferences.ZiplineTerminalPreview = "camera"
      event.element.parent.parent.scroller.layout.clear()
      local layout = event.element.parent.parent.scroller.layout
      local clicked = storage.ZiplineTerminals[event.element.parent.parent.tags.ID].entity
      local a = {}
      for each, terminal in pairs(storage.ZiplineTerminals) do
         table.insert(a, string.lower(copy(terminal.name)))
      end
      table.sort(a)
      local sorted = {}
      for each, name in pairs(a) do
         for each, terminal in pairs(storage.ZiplineTerminals) do
            if (string.lower(copy(terminal.name)) == name) then
               table.insert(sorted, terminal)
               break
            end
         end
      end
      for each, terminal in pairs(sorted) do
         local entity = terminal.entity
         if (entity.valid == true and entity.electric_network_id == clicked.electric_network_id and entity.unit_number ~= clicked.unit_number) then
            local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAutoPath", start=script.register_on_object_destroyed(clicked), finish=script.register_on_object_destroyed(entity)}}
               TerminalButton.style.font = "heading-1"
               TerminalButton.style.horizontally_stretchable = true
            local cam = layout.add{type="camera", caption="caption", position=entity.position, zoom=0.4}
               cam.style.width = 175
               cam.style.height = 175
            layout.add{type="line"}
            layout.add{type="line"}
         elseif (entity.valid == false) then
            storage.ZiplineTerminals[each] = nil
         end
      end
   end,
   ZiplineMinimap = function(event, player)
      local PlayerProperties = storage.AllPlayers[player.index]
      PlayerProperties.preferences.ZiplineTerminalPreview = "minimap"
      event.element.parent.parent.scroller.layout.clear()
      local layout = event.element.parent.parent.scroller.layout
      local clicked = storage.ZiplineTerminals[event.element.parent.parent.tags.ID].entity
      local a = {}
      for each, terminal in pairs(storage.ZiplineTerminals) do
         table.insert(a, string.lower(copy(terminal.name)))
      end
      table.sort(a)
      local sorted = {}
      for each, name in pairs(a) do
         for each, terminal in pairs(storage.ZiplineTerminals) do
            if (string.lower(copy(terminal.name)) == name) then
               table.insert(sorted, terminal)
               break
            end
         end
      end
      for each, terminal in pairs(sorted) do
         local entity = terminal.entity
         if (entity.valid == true and entity.electric_network_id == clicked.electric_network_id and entity.unit_number ~= clicked.unit_number) then
            local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAutoPath", start=script.register_on_object_destroyed(clicked), finish=script.register_on_object_destroyed(entity)}}
               TerminalButton.style.font = "heading-1"
               TerminalButton.style.horizontally_stretchable = true
            local cam = layout.add{type="minimap", caption="caption", position=entity.position, zoom=1}
               cam.style.width = 175
               cam.style.height = 175
            layout.add{type="line"}
            layout.add{type="line"}
         elseif (entity.valid == false) then
            storage.ZiplineTerminals[each] = nil
         end
      end
   end,
   ZiplineNone = function(event, player)
      local PlayerProperties = storage.AllPlayers[player.index]
      PlayerProperties.preferences.ZiplineTerminalPreview = "none"
      event.element.parent.parent.scroller.layout.clear()
      local layout = event.element.parent.parent.scroller.layout
      local clicked = storage.ZiplineTerminals[event.element.parent.parent.tags.ID].entity
      local a = {}
      for each, terminal in pairs(storage.ZiplineTerminals) do
         table.insert(a, string.lower(copy(terminal.name)))
      end
      table.sort(a)
      local sorted = {}
      for each, name in pairs(a) do
         for each, terminal in pairs(storage.ZiplineTerminals) do
            if (string.lower(copy(terminal.name)) == name) then
               table.insert(sorted, terminal)
               break
            end
         end
      end
      for each, terminal in pairs(sorted) do
         local entity = terminal.entity
         if (entity.valid == true and entity.electric_network_id == clicked.electric_network_id and entity.unit_number ~= clicked.unit_number) then
            local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAutoPath", start=script.register_on_object_destroyed(clicked), finish=script.register_on_object_destroyed(entity)}}
               TerminalButton.style.font = "heading-1"
               TerminalButton.style.horizontally_stretchable = true
            layout.add{type="label", caption=""}
         elseif (entity.valid == false) then
            storage.ZiplineTerminals[each] = nil
         end
      end
   end,
}

-- element :: LuaGuiElement: The clicked element.
-- player_index :: uint: The player who did the clicking.
-- button :: defines.mouse_button_type: The mouse button used if any.
-- alt :: boolean: If alt was pressed.
-- control :: boolean: If control was pressed.
-- shift :: boolean: If shift was pressed.
local function ClickGUI(event)
local player = game.players[event.player_index]
	local TriggerEffect = event.element.tags.RTEffect
	if (ClickableStuff[TriggerEffect]) then
		ClickableStuff[TriggerEffect](event, player)
	end
end

return ClickGUI

-- RTZiplineTerminalGUI
	-- TerminalHeader
		-- Terminal
		-- name
		-- rename button
	-- scroller
		-- layout table
			-- button
			-- camera

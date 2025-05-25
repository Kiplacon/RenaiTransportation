local function add_titlebar(gui, caption, close_button_name)
local titlebar = gui.add{type = "flow"}
titlebar.drag_target = gui
titlebar.add{
   type = "label",
   style = "frame_title",
   caption = caption,
   ignored_by_interaction = true,
}
local filler = titlebar.add{
   type = "empty-widget",
   style = "draggable_space",
   ignored_by_interaction = true,
}
filler.style.height = 24
filler.style.horizontally_stretchable = true
titlebar.add{
   type = "sprite-button",
   name = close_button_name,
   style = "frame_action_button",
   sprite = "utility/close",
   hovered_sprite = "utility/close_black",
   clicked_sprite = "utility/close_black",
   tooltip = {"gui.close-instruction"},
   tags = {RTEffect="RTCloseGUI"}
}
end

function ShowZiplineTerminalGUI(player, clicked)
   if (player.gui.screen.RTZiplineTerminalGUI) then
      player.gui.screen.RTZiplineTerminalGUI.destroy()
   end
   player.play_sound{
      path="utility/wire_pickup",
      position=player.position,
      volume_modifier=1
   }
   local PlayerProperties = storage.AllPlayers[player.index]
   local TerminalProperties = storage.ZiplineTerminals[script.register_on_object_destroyed(clicked)]
   local frame = player.gui.screen.add{type="frame", name="RTZiplineTerminalGUI", direction="vertical", tags={ID=script.register_on_object_destroyed(clicked)}}
   frame.force_auto_center()
   add_titlebar(player.gui.screen.RTZiplineTerminalGUI, {"zipline-stuff.select"}, "stigma")
      if (clicked.name == "RTZiplineTerminal") then
         local TerminalHeader = player.gui.screen.RTZiplineTerminalGUI.add{type="table", name="TerminalHeader", column_count=3}
            local ttt = TerminalHeader.add{type="label", caption={"zipline-stuff.terminal"}}
               ttt.style.font = "heading-1"
            TerminalHeader.add{type="label", name="TerminalName", caption=TerminalProperties.name}.style.font = "heading-1"
            TerminalHeader.add{
               type = "sprite-button",
               style = "frame_action_button",
               sprite = "utility/rename_icon",
               hovered_sprite = "utility/rename_icon",
               clicked_sprite = "utility/rename_icon",
               tooltip = {"zipline-stuff.rename"},
               tags = {RTEffect="RTStartRenameTerminal"}
            }

         ------------- preview selection
         local PreviewHeader = player.gui.screen.RTZiplineTerminalGUI.add{type="table", name="PreviewHeader", column_count=3}
         PreviewHeader.add{type="button", name="cam", caption="Camera", tags={RTEffect="ZiplineCamera"}}
         PreviewHeader.add{type="button", name="map", caption="Minimap", tags={RTEffect="ZiplineMinimap"}}
         PreviewHeader.add{type="button", name="none", caption="None", tags={RTEffect="ZiplineNone"}}
      end

      local scroller = player.gui.screen.RTZiplineTerminalGUI.add{type="scroll-pane", name="scroller"}
         scroller.style.height = 700
         --scroller.style.width = 315
      local layout = scroller.add{type="table", name="layout", column_count=2}
         local a = {}
         for each, terminal in pairs(storage.ZiplineTerminals) do
            if (terminal.name) then
               table.insert(a, string.lower(copy(terminal.name)))
            end
         end
         table.sort(a)
         local sorted = {}
         for each, name in pairs(a) do
            for each, terminal in pairs(storage.ZiplineTerminals) do
               if (terminal.name and string.lower(copy(terminal.name)) == name) then
                  table.insert(sorted, terminal)
                  break
               end
            end
         end
         for each, terminal in pairs(sorted) do
            local entity = terminal.entity
            if (entity.valid == true and entity.electric_network_id == clicked.electric_network_id and entity.unit_number ~= clicked.unit_number) then
               if (PlayerProperties.preferences == nil or PlayerProperties.preferences.ZiplineTerminalPreview == nil or PlayerProperties.preferences.ZiplineTerminalPreview == "camera") then
                  if (PlayerProperties.preferences == nil) then
                     PlayerProperties.preferences = {}
                  end
                  local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAutoPath", start=script.register_on_object_destroyed(clicked), finish=script.register_on_object_destroyed(entity)}}
                     TerminalButton.style.font = "heading-1"
                     TerminalButton.style.horizontally_stretchable = true
                  local cam = layout.add{type="camera", caption="caption", position=entity.position, zoom=0.4}
                     cam.style.width = 175
                     cam.style.height = 175
                  layout.add{type="line"}
                  layout.add{type="line"}
               elseif (PlayerProperties.preferences.ZiplineTerminalPreview == "minimap") then
                  local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAutoPath", start=script.register_on_object_destroyed(clicked), finish=script.register_on_object_destroyed(entity)}}
                     TerminalButton.style.font = "heading-1"
                     TerminalButton.style.horizontally_stretchable = true
                  local cam = layout.add{type="minimap", caption="caption", position=entity.position, zoom=1}
                     cam.style.width = 175
                     cam.style.height = 175
                  layout.add{type="line"}
                  layout.add{type="line"}
               elseif (PlayerProperties.preferences.ZiplineTerminalPreview == "none") then
                  local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAutoPath", start=script.register_on_object_destroyed(clicked), finish=script.register_on_object_destroyed(entity)}}
                     TerminalButton.style.font = "heading-1"
                     TerminalButton.style.horizontally_stretchable = true
                  layout.add{type="label", caption=""}
               end
            elseif (entity.valid == false) then
               storage.ZiplineTerminals[each] = nil
            end
         end
   player.opened = frame
end

function AIZiplineControllerTerminalList(player, CurrentPole)
   if (player.gui.screen.RTZiplineTerminalGUI) then
      player.gui.screen.RTZiplineTerminalGUI.destroy()
   end
   player.play_sound{
      path="utility/wire_pickup",
      position=player.position,
      volume_modifier=1
   }
   local PlayerProperties = storage.AllPlayers[player.index]
   local frame = player.gui.screen.add{type="frame", name="RTZiplineTerminalGUI", direction="vertical", tags={ID=script.register_on_object_destroyed(CurrentPole)}}
   frame.location = {x=player.display_resolution.width/8, y=player.display_resolution.height/8}
   add_titlebar(player.gui.screen.RTZiplineTerminalGUI, {"zipline-stuff.select"}, "stigma")

      ------------- preview selection
      local PreviewHeader = player.gui.screen.RTZiplineTerminalGUI.add{type="table", name="PreviewHeader", column_count=3}
      PreviewHeader.add{type="button", name="cam", caption="Camera", tags={RTEffect="ZiplineCamera", type="ZiplineAIAutoPath"}}
      PreviewHeader.add{type="button", name="map", caption="Minimap", tags={RTEffect="ZiplineMinimap", type="ZiplineAIAutoPath"}}
      PreviewHeader.add{type="button", name="none", caption="None", tags={RTEffect="ZiplineNone", type="ZiplineAIAutoPath"}}
      
      local scroller = player.gui.screen.RTZiplineTerminalGUI.add{type="scroll-pane", name="scroller"}
         scroller.style.height = 700
         --scroller.style.width = 315
      local layout = scroller.add{type="table", name="layout", column_count=2}
         local a = {}
         for each, terminal in pairs(storage.ZiplineTerminals) do
            if (terminal.name) then
               table.insert(a, string.lower(copy(terminal.name)))
            end
         end
         table.sort(a)
         local sorted = {}
         local AttachedToTerminal = false
         for each, name in pairs(a) do
            for each, terminal in pairs(storage.ZiplineTerminals) do
               if (terminal.name and string.lower(copy(terminal.name)) == name) then
                  table.insert(sorted, terminal)
                  break
               end
            end
         end
         local TerminalsOnNetwork = 0
         for each, terminal in pairs(sorted) do
            local entity = terminal.entity
            if (entity.valid == true and entity.electric_network_id == CurrentPole.electric_network_id and entity.unit_number ~= CurrentPole.unit_number) then
               TerminalsOnNetwork = TerminalsOnNetwork + 1
               if (storage.ZiplineTerminals[script.register_on_object_destroyed(CurrentPole)] == nil) then
                  storage.ZiplineTerminals[script.register_on_object_destroyed(CurrentPole)] = {entity=CurrentPole}
               end
               if (PlayerProperties.preferences == nil or PlayerProperties.preferences.ZiplineTerminalPreview == nil or PlayerProperties.preferences.ZiplineTerminalPreview == "camera") then
                  if (PlayerProperties.preferences == nil) then
                     PlayerProperties.preferences = {}
                  end
                  local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAIAutoPath", start=script.register_on_object_destroyed(CurrentPole), finish=script.register_on_object_destroyed(entity)}}
                     TerminalButton.style.font = "heading-1"
                     TerminalButton.style.horizontally_stretchable = true
                  local cam = layout.add{type="camera", caption="caption", position=entity.position, zoom=0.4}
                     cam.style.width = 175
                     cam.style.height = 175
                  layout.add{type="line"}
                  layout.add{type="line"}
               elseif (PlayerProperties.preferences.ZiplineTerminalPreview == "minimap") then
                  local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAIAutoPath", start=script.register_on_object_destroyed(CurrentPole), finish=script.register_on_object_destroyed(entity)}}
                     TerminalButton.style.font = "heading-1"
                     TerminalButton.style.horizontally_stretchable = true
                  local cam = layout.add{type="minimap", caption="caption", position=entity.position, zoom=1}
                     cam.style.width = 175
                     cam.style.height = 175
                  layout.add{type="line"}
                  layout.add{type="line"}
               elseif (PlayerProperties.preferences.ZiplineTerminalPreview == "none") then
                  local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAIAutoPath", start=script.register_on_object_destroyed(CurrentPole), finish=script.register_on_object_destroyed(entity)}}
                     TerminalButton.style.font = "heading-1"
                     TerminalButton.style.horizontally_stretchable = true
                  layout.add{type="label", caption=""}
               end
            elseif (entity.valid == false) then
               storage.ZiplineTerminals[each] = nil
            elseif (entity.unit_number == CurrentPole.unit_number) then
               AttachedToTerminal = true
               TerminalsOnNetwork = TerminalsOnNetwork + 1
            end
         end
   player.opened = frame
   if (TerminalsOnNetwork == 0 or (TerminalsOnNetwork == 1 and AttachedToTerminal == true)) then
      player.opened = nil
   end
end


function ShowDirectorGUI(player, DirectorPad)
   if (player.gui.screen.RTDirectorPadGUI) then
      player.gui.screen.RTDirectorPadGUI.destroy()
   end
   local PlayerProperties = storage.AllPlayers[player.index]
   player.play_sound{
      path="utility/wire_connect_pole",
      position=player.position,
      volume_modifier=1
   }
   local DirectorPadDestroyNumber = script.register_on_object_destroyed(DirectorPad)
   local frame = player.gui.screen.add{type="frame", name="RTDirectorPadGUI", direction="vertical", tags={ID=DirectorPadDestroyNumber}}
   frame.force_auto_center()
   add_titlebar(player.gui.screen.RTDirectorPadGUI, "Director Bounce Pad Filters", "stigma")

   local sets = {{"Up",2}, {"Right",3}, {"Down",4}, {"Left",5}}
   for ligma, balls in pairs(sets) do
      local direction = balls[1]
      local section = balls[2]
      frame.add{type="label", caption="Going "..direction.." [virtual-signal=DirectorBouncePlate"..direction.."]"}
      local UpRow = player.gui.screen.RTDirectorPadGUI.add{type="table", name=direction.."Row", column_count=10}
         for i = 1, 10 do
            local ItemName
            local setting = DirectorPad.get_or_create_control_behavior().get_section(section).get_slot(i).value
            if (setting and setting.name) then
               ItemName = setting.name
            end
            UpRow.add{type="choose-elem-button", elem_type="item", item=ItemName, tags={section=section, slot=i}}
         end
   end
   player.opened = frame
end
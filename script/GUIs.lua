local function add_titlebar(gui, caption, close_button_name)
  local titlebar = gui.add{type = "flow"}
  --titlebar.drag_target = gui
  titlebar.add{
    type = "label",
    style = "frame_title",
    caption = caption,
    ignored_by_interaction = true,
  }
  local filler = titlebar.add{
    type = "empty-widget",
    --style = "draggable_space",
    ignored_by_interaction = true,
  }
  filler.style.height = 24
  filler.style.horizontally_stretchable = true
  titlebar.add{
    type = "sprite-button",
    name = close_button_name,
    style = "frame_action_button",
    sprite = "utility/close_white",
    hovered_sprite = "utility/close_black",
    clicked_sprite = "utility/close_black",
    --tooltip = {"gui.close-instruction"},
    tags = {RTEffect="RTCloseGUI"}
  }
end

function ShowZiplineTerminalGUI(player, clicked)
   if (player.gui.center.RTZiplineTerminalGUI) then
      player.gui.center.RTZiplineTerminalGUI.destroy()
   end
   local PlayerProperties = global.AllPlayers[player.index]
   player.gui.center.add{type="frame", name="RTZiplineTerminalGUI", direction="vertical", tags={ID=clicked.unit_number}}
   add_titlebar(player.gui.center.RTZiplineTerminalGUI, {"zipline-stuff.select"}, "stigma")
      if (clicked.name == "RTZiplineTerminal") then
         local TerminalHeader = player.gui.center.RTZiplineTerminalGUI.add{type="table", name="TerminalHeader", column_count=3}
            local ttt = TerminalHeader.add{type="label", caption={"zipline-stuff.terminal"}}
               ttt.style.font = "heading-1"
            TerminalHeader.add{type="label", name="TerminalName", caption=global.ZiplineTerminals[clicked.unit_number].name}.style.font = "heading-1"
            TerminalHeader.add{
               type = "sprite-button",
               style = "frame_action_button",
               sprite = "utility/rename_icon_small_white",
               hovered_sprite = "utility/rename_icon_small_black",
               clicked_sprite = "utility/rename_icon_small_black",
               tooltip = {"zipline-stuff.rename"},
               tags = {RTEffect="RTStartRenameTerminal"}
            }

         ------------- preview selection
         local PreviewHeader = player.gui.center.RTZiplineTerminalGUI.add{type="table", name="PreviewHeader", column_count=3}
         PreviewHeader.add{type="button", name="cam", caption="Camera", tags={RTEffect="ZiplineCamera"}}
         PreviewHeader.add{type="button", name="map", caption="Minimap", tags={RTEffect="ZiplineMinimap"}}
         PreviewHeader.add{type="button", name="none", caption="None", tags={RTEffect="ZiplineNone"}}
      end

      local scroller = player.gui.center.RTZiplineTerminalGUI.add{type="scroll-pane", name="scroller"}
         scroller.style.height = 700
         --scroller.style.width = 315
      local layout = scroller.add{type="table", name="layout", column_count=2}
         local a = {}
         for each, terminal in pairs(global.ZiplineTerminals) do
            table.insert(a, string.lower(copy(terminal.name)))
         end
         table.sort(a)
         local sorted = {}
         for each, name in pairs(a) do
            for each, terminal in pairs(global.ZiplineTerminals) do
               if (string.lower(copy(terminal.name)) == name) then
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
                  local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAutoPath", start=clicked.unit_number, finish=entity.unit_number}}
                     TerminalButton.style.font = "heading-1"
                     TerminalButton.style.horizontally_stretchable = true
                  local cam = layout.add{type="camera", caption="caption", position=entity.position, zoom=0.4}
                     cam.style.width = 175
                     cam.style.height = 175
                  layout.add{type="line"}
                  layout.add{type="line"}
               elseif (PlayerProperties.preferences.ZiplineTerminalPreview == "minimap") then
                  local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAutoPath", start=clicked.unit_number, finish=entity.unit_number}}
                     TerminalButton.style.font = "heading-1"
                     TerminalButton.style.horizontally_stretchable = true
                  local cam = layout.add{type="minimap", caption="caption", position=entity.position, zoom=1}
                     cam.style.width = 175
                     cam.style.height = 175
                  layout.add{type="line"}
                  layout.add{type="line"}
               elseif (PlayerProperties.preferences.ZiplineTerminalPreview == "none") then
                  local TerminalButton = layout.add{type="button", name=each, caption=terminal.name, tags={RTEffect="ZiplineAutoPath", start=clicked.unit_number, finish=entity.unit_number}}
                     TerminalButton.style.font = "heading-1"
                     TerminalButton.style.horizontally_stretchable = true
                  layout.add{type="label", caption=""}
               end
            elseif (entity.valid == false) then
               global.ZiplineTerminals[each] = nil
            end
         end
end

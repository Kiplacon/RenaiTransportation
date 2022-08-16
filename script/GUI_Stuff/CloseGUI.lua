-- player_index :: uint: The player.
-- gui_type :: defines.gui_type: The GUI type that was open.
-- entity :: LuaEntity (optional): The entity that was open
-- item :: LuaItemStack (optional): The item that was open
-- equipment :: LuaEquipment (optional): The equipment that was open
-- other_player :: LuaPlayer (optional): The other player that was open
-- element :: LuaGuiElement (optional): The custom GUI element that was open
-- technology :: LuaTechnology (optional): The technology that was automatically selected when opening the research GUI
-- tile_position :: TilePosition (optional): The tile position that was open
local function on_GUI_close(event)
	local player = game.players[event.player_index]
	if (player.gui.screen.ItemPicker) then
		player.gui.screen.ItemPicker.destroy()
	end

end

return on_GUI_close
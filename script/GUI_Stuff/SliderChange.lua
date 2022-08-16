-- element :: LuaGuiElement: The element whose value changed.
-- player_index :: uint: The player who did the change.
local function on_slider(event)
	local player = game.players[event.player_index]
	if (event.element.name == "SelectorSlider") then
		player.gui.screen.ItemPicker.ConfirmStuff.SelectedQuantity.text = tostring(event.element.slider_value)

	end
end

return on_slider
ClickableStuff = {
	LinkAssemblyDropOff = function(event, player)
		local PlayerProperties = GetOrRegisterPlayerProperties(player)
		local AssemblyWorkstation = global.workplaces[player.force.name][player.surface.name][event.element.tags.entity].entity
		local char = player.character
		player.clear_cursor()
		player.character = nil
		player.character = char
		PlayerProperties.action = {name="LinkAssemblyDropOff", assembler=AssemblyWorkstation, slot=event.element.tags.slot}
		player.print("Select drop off")
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
	ThingClicked = event.element.name
	if (string.find(event.element.name, "LinkAssemblyDropOff")) then
		ThingClicked = "LinkAssemblyDropOff"
	end
	if (ClickableStuff[ThingClicked]) then
		ClickableStuff[ThingClicked](event, player)
	end
end

return ClickGUI

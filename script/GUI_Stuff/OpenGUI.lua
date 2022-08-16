-- player_index :: uint: The player.
-- gui_type :: defines.gui_type: The GUI type that was opened.
-- entity :: LuaEntity (optional): The entity that was opened
-- item :: LuaItemStack (optional): The item that was opened
-- equipment :: LuaEquipment (optional): The equipment that was opened
-- other_player :: LuaPlayer (optional): The other player that was opened
-- element :: LuaGuiElement (optional): The custom GUI element that was opened
local function on_gui_open(event)
	local player = game.players[event.player_index]
	if (player.gui.relative.CraftingList) then
		player.gui.relative.CraftingList.destroy() -- because for some reason anchored gui doesn close when the anchor is closed
	end
	if (event.entity and (event.entity.name == "FPAssemblyWorkstation")) then
		local properties = global.workplaces[event.entity.force.name][event.entity.surface.name][event.entity.unit_number]
		player.gui.relative.add{type="frame", name="CraftingList", direction="vertical", caption="Crafting List", anchor={gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.right}, tags={UnitNumber=event.entity.unit_number} }
		player.gui.relative.CraftingList.add{type="table", name="layout", column_count=2, draw_horizontal_lines=true, vertical_centering=true, horizontal_centering=true}
			player.gui.relative.CraftingList.layout.add{type="label", caption="Item         ", tooltip="choose item"}
			player.gui.relative.CraftingList.layout.add{type="label", caption="Drop Target", tooltip="choose place to bring"}
			for i = 1, 10 do
				local item = nil
				local link = "FaPBlank"
				if (properties.DropOffLinks[i]) then
					if (properties.DropOffLinks[i].entity and properties.DropOffLinks[i].entity.valid == true) then
						link = "item/"..properties.DropOffLinks[i].entity.prototype.mineable_properties.products[1].name
					end
					if (properties.DropOffLinks[i].item) then
						item = properties.DropOffLinks[i].item
					end
				elseif (properties.DropOffLinks[i] and properties.DropOffLinks[i].entity.valid == false) then
					properties.DropOffLinks[i] = {}
				elseif (properties.DropOffLinks[i] == nil) then
					properties.DropOffLinks[i] = {}
				end
				player.gui.relative.CraftingList.layout.add{type="choose-elem-button", name="ItemCrafting"..i, elem_type="item", tooltip="23r", tags={entity=event.entity.unit_number, slot=i}}.elem_value=item
				player.gui.relative.CraftingList.layout.add{type="sprite-button", name="LinkAssemblyDropOff"..i, sprite=link, tooltip="cwef", tags={entity=event.entity.unit_number, slot=i}}
			end
	end
end

return on_gui_open

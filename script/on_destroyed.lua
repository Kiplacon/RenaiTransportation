-- registration_number :: uint64
-- unit_number :: uint (optional)
local function on_destroy(event)
	--======== Colonist death currently handled on control.lua on_death ===============
   if (global.TrackingLists.ClearOnDestroy[event.unit_number]) then
      for each, ColonistProperties in pairs(global.AllColonists) do
         if (type(ColonistProperties.WorkingWith.workplace) == "number" and ColonistProperties.WorkingWith.workplace == event.unit_number) then
            ColonistProperties.ActionPlan.state = "interrupted"
         end
      end
      for each, connection in pairs(global.TrackingLists.ClearOnDestroy[event.unit_number]) do
         if (connection.type == "GlobalWorkplace" and global.workplaces[connection.force][connection.surface][connection.number]) then
            global.workplaces[connection.force][connection.surface][connection.number] = nil
         elseif (connection.type == "LinkedSciCenter" and global.workplaces[connection.force][connection.surface][connection.number] and global.workplaces[connection.force][connection.surface][connection.number].ConnectedLabs[connection.lab]) then
            global.workplaces[connection.force][connection.surface][connection.number].ConnectedLabs[connection.lab] = nil
         elseif (connection.type == "entity") then
            if (connection.entity and connection.entity.valid) then
               connection.entity.destroy()
            end
         elseif (connection.type == "GlobalItemReservation") then
            global.reservations.items[connection.number] = nil
         elseif (connection.type == "GlobalEntityReservation") then
            global.reservations.entities[connection.number] = nil
         elseif (connection.type == "ProviderPole") then
            global.PoleNetwork.ProviderPoles[connection.number] = nil
         elseif (connection.type == "SupplierPole") then
            global.PoleNetwork.SupplierPoles[connection.number] = nil
         end
      end
      global.TrackingLists.ClearOnDestroy[event.unit_number] = nil
   end
end

return on_destroy

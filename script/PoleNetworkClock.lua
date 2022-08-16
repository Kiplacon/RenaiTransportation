local function FindPath(start, finish)
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
      return path
   end
end



local function PoleNetworkClock(event)
   for SupplierNumber, SupplierProperties in pairs(global.PoleNetwork.SupplierPoles) do
      -- number = unit_number of the pole
      -- SupplierProperties.entity = the pole entity
      -- SupplierProperties.interface = requester chest proxy
      -- SupplierProperties.paths = list of providers by [path length] = {[unit_number] = {node.unit_number, node.unit_number, ...}, [unit_number] = {node.unit_number,...}}
      -- SupplierProperties.PathsCalculated = true/false
      -- SupplierProperties.analyzed = list of unit_number of ones checked
      local proxy = SupplierProperties.interface
      local pole = SupplierProperties.entity
      if (SupplierProperties.PathsCalculated == false) then
         for ProviderNumber, ProviderProperties in pairs(global.PoleNetwork.ProviderPoles) do
            SupplierProperties.PathsCalculated = false
            if (ProviderProperties.entity.electric_network_id == SupplierProperties.entity.electric_network_id and SupplierProperties.analyzed[ProviderNumber] == nil) then
               SupplierProperties.analyzed[ProviderNumber] = "dragon"
               local path = FindPath(SupplierProperties.entity, ProviderProperties.entity)
               if (SupplierProperties.paths[#path] == nil) then
                  SupplierProperties.paths[#path] = {}
               end
               SupplierProperties.paths[#path][ProviderNumber] = path
               break
            end
            SupplierProperties.PathsCalculated = true
         end

      elseif (SupplierProperties.PathsCalculated == true) then
         local SurroundingEntities = proxy.surface.find_entities_filtered
            {
               area = {{proxy.position.x-1, proxy.position.y-1}, {proxy.position.x+1, proxy.position.y+1}},
               force = pole.force,
               ghost_name = nil
            }
         for each, AdjacentEntity in pairs(SurroundingEntities) do
            if (AdjacentEntity.get_inventory(defines.inventory.item_main) ~= nil) then
               for i = 1, 30 do
                  if (proxy.get_request_slot(i) ~= nil) then
                     local RequestedItem = proxy.get_request_slot(i).name
                     local RequestedAmount = proxy.get_request_slot(i).count
                     local ItemReservations = GetOrRegisterItemReservationTracker(AdjacentEntity)
                        -- .taking = list of [item]=amount
                        -- .bringing = list of [item]=amount
                        local IncomingAmount = ItemReservations.bringing[RequestedItem]
                        if (IncomingAmount == nil) then
                           IncomingAmount = 0
                           ItemReservations.bringing[RequestedItem] = 0
                        end
                     local CurrentAmmount = AdjacentEntity.get_inventory(defines.inventory.item_main).get_item_count(RequestedItem)
                     if (CurrentAmmount < RequestedAmount-IncomingAmount and AdjacentEntity.can_insert({name=RequestedItem, count=RequestedAmount-IncomingAmount})) then
                        -- select closest provider pole that hasnt been tried yet
                        local deficit = RequestedAmount - CurrentAmmount - IncomingAmount
                        for length, paths in pairs(SupplierProperties.paths) do
                           for ID, path in pairs(paths) do
                              if (deficit > 0) then
                                 local ProviderPole = global.PoleNetwork.ProviderPoles[ID].entity
                                 local SurroundingChests = ProviderPole.surface.find_entities_filtered
                                    {
                                       area = {{ProviderPole.position.x-1, ProviderPole.position.y-1}, {ProviderPole.position.x+1, ProviderPole.position.y+1}},
                                       force = ProviderPole.force,
                                       ghost_name = nil
                                    }
                                 for eachh, thing in pairs(SurroundingChests) do
                                    if (thing.get_output_inventory() ~= nil
                                    and deficit > 0
                                    and thing.get_output_inventory().get_item_count(RequestedItem) > 0
                                    and (GetOrRegisterItemReservationTracker(thing).taking[RequestedItem] == nil or thing.get_output_inventory().get_item_count(RequestedItem)-GetOrRegisterItemReservationTracker(thing).taking[RequestedItem] > 0)) then
                                       local AlreadyTaking = GetOrRegisterItemReservationTracker(thing).taking[RequestedItem] or 0
                                       local TakeAmount = math.min(deficit, thing.get_output_inventory().get_item_count(RequestedItem)-AlreadyTaking)
                                       table.insert(global.PoleNetwork.ProviderPoles[ID].requests, {item=RequestedItem, count=TakeAmount, path=path})
                                       GetOrRegisterItemReservationTracker(thing).taking[RequestedItem] = AlreadyTaking+TakeAmount
                                       ItemReservations.bringing[RequestedItem] = ItemReservations.bringing[RequestedItem]+TakeAmount
                                       deficit = deficit - TakeAmount
                                    end
                                 end
                              end
                           end
                        end
                        -- record request in provider pole and global
                     end
                  end
               end
            end
         end
      end
   end
end

return PoleNetworkClock

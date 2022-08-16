local function on_init()
   global.AllPlayers = {}
   global.AllColonists = {}
   global.TrackingLists = {UsedNames={}, NumberToColonistName={}, ClearOnDestroy={}}
   global.reservations = {items={}, entities={}} --items[unit_number of thing with inventory] = {taking={}, bringing={}}
   RefreshReferenceLists()
   global.workplaces = {}
   global.PoleNetwork = {ProviderPoles={}, SupplierPoles={}, packages={}}
   for each, force in pairs(game.forces) do
      global.workplaces[force.name] = {}
      for every, surface in pairs(game.surfaces) do
         global.workplaces[force.name][surface.name] = {}
         --setup existing pole network
      end
   end
end

return on_init

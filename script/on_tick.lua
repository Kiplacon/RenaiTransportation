local ColonistClock = require("__FactoryPlanet__.script.ColonistFunctions.ColonistClock")
local PoleNetworkClock = require("__FactoryPlanet__.script.PoleNetworkClock")

local function on_tick(event)
   --event.tick is the only property
   PoleNetworkClock(event)
   ColonistClock(event)
   for each, PlayerProperties in pairs(global.AllPlayers) do
      local player = PlayerProperties.player
      if (PlayerProperties.CloseGUIs) then
         local char = player.character
         player.character = nil
         player.character = char
         PlayerProperties.CloseGUIs = nil
      end
      if (PlayerProperties.SwapToGUI) then
         player.opened = PlayerProperties.SwapToGUI
         PlayerProperties.SwapToGUI = nil
      end
      if (PlayerProperties.action ~= nil) then
         if (PlayerProperties.action == "ffff") then

         end
      end
   end
end

return on_tick

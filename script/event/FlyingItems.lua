if script.active_mods["Ultracube"] then CubeFlyingItems = require("script.ultracube.cube_flying_items") end

local function on_tick(event)

   for FlightID, _ in pairs(storage.CustomPathFlyingItemSprites) do
      local FlyingItem = storage.FlyingItems[FlightID]
      if (FlyingItem and FlyingItem.sprite and event.tick < FlyingItem.LandTick) then -- for now only impact unloader items have sprites and need animating like this
         local duration = event.tick-FlyingItem.StartTick
         local x_coord = FlyingItem.path[duration].x
         local y_coord = FlyingItem.path[duration].y
         local height = -FlyingItem.path[duration].height -- negative because in factorio +y is south
         local orientation = FlyingItem.spin*duration
         FlyingItem.sprite.target = {x_coord, y_coord + height}
         FlyingItem.sprite.orientation = orientation
         if (FlyingItem.space == false and FlyingItem.shadow) then
            FlyingItem.shadow.target = {x_coord - height, y_coord}
            FlyingItem.shadow.orientation = orientation
            local shadowScaleDelta = math.abs(height) * 0.025
            FlyingItem.shadow.x_scale = 0.25 + shadowScaleDelta
            FlyingItem.shadow.y_scale = 0.5 + shadowScaleDelta
            FlyingItem.shadow.color = {0, 0, 0, 2.5/(5-height)}
         end

         if storage.Ultracube and FlyingItem.cube_should_hint then
            CubeFlyingItems.item_with_path_update(FlyingItem, duration)
         end

      elseif (FlyingItem and event.tick == FlyingItem.LandTick and FlyingItem.space == false) then
         ResolveThrownItem(FlyingItem)

      elseif (FlyingItem and event.tick == FlyingItem.LandTick and FlyingItem.space == true) then
         --ResolveThrownItem(FlyingItem)
         -- space items just disappear
         if (FlyingItem.sprite) then
            FlyingItem.sprite.destroy()
         end
         if (FlyingItem.shadow) then
            FlyingItem.shadow.destroy()
         end
         storage.FlyingItems[FlightID] = nil
         storage.CustomPathFlyingItemSprites[FlightID] = nil
      end
   end

   if (storage.Ultracube) then
      for each, FlyingItem in pairs(storage.FlyingItems) do
         if FlyingItem.cube_should_hint and event.tick < (FlyingItem.StartTick + FlyingItem.AirTime) then
            -- Ultracube non-sprite item position updating. Only done for items that require hinting as those are the ones the cube camera follows
            if FlyingItem.path then
               CubeFlyingItems.item_with_path_update(FlyingItem, event.tick - FlyingItem.StartTick)
            elseif FlyingItem.type == "ReskinnedStream" then
               CubeFlyingItems.item_with_stream_update(FlyingItem)
            elseif FlyingItem.type == "ItemShell" then
               CubeFlyingItems.item_with_shell_update(FlyingItem)
            end
         end
      end
   end
end

return on_tick

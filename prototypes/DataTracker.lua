data:extend({
   {
      type = "constant-combinator",
      name = "RTDataTracker",
      icon = "__RenaiTransportation__/graphics/nothing.png",
      icon_size = 1,
      flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-rotatable", "hidden", "not-on-map", "not-deconstructable", "not-in-kill-statistics", "not-flammable"},
      collision_mask = {},
      selection_box = {{-0.49, -0.59}, {0.49, 0.49}},
      collision_box = {{-0.45, -0.45}, {0.45, 0.45}},
      selection_priority = 1,
      placeable_by = {item="RTDataTrackerItem", count=0},
      item_slot_count = 40,
      sprites = {filename = "__RenaiTransportation__/graphics/nothing.png", size = 1},
      activity_led_sprites = {filename = "__RenaiTransportation__/graphics/nothing.png", size = 1},
      activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
      circuit_wire_connection_points = {{wire={}, shadow={}},{wire={}, shadow={}},{wire={}, shadow={}},{wire={}, shadow={}}}
   },
   {
      type = "item",
      name = "RTDataTrackerItem",
      icon = "__RenaiTransportation__/graphics/nothing.png",
      icon_size = 1,
      flags = {"hidden"},
      --subgroup = "train-transport",
      --order = "x",
      --place_result = "RoomTileMarker",
      stack_size = 69
   }
})

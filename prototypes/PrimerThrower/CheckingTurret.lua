data:extend({
{
  type = "turret",
  name = "RTPrimerThrowerDetector",
  icon = "__base__/graphics/icons/big-worm.png",
  icon_size = 64, icon_mipmaps = 4,
  flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "hidden", "not-selectable-in-game"},
  max_health = 750,
  alert_when_attacking = false,
  resistances =
  {
    {
     type = "physical",
     percent = 100
    },
    {
     type = "explosion",
     percent = 100
    },
    {
     type = "fire",
     percent = 100
    }
  },
  --selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
  rotation_speed = 1,
  folded_animation = {direction_count=4, filename = "__RenaiTransportation__/graphics/nothing.png", size=1},
  starting_attack_speed = 0.5,
  ending_attack_speed = 0.5,
  allow_turning_when_starting_attack = true,
  attack_parameters =
  {
    type = "projectile",
    cooldown = 3, --matches the thrower hand position check so they feel the same
    range = 50,
    min_range = 25,
    turn_range = 0.15,
    ammo_type =
    {
     category = "biological",
     action =
     {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
             type = "script",
             effect_id = "PrimerThrowerCheck"
          }
        }
     }
    }
  },
  call_for_help_radius = 40,
}

})

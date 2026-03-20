Glide.SetupInputGroup( "hoverbike_controls" )

Glide.AddInputAction( "hoverbike_controls", "steer_left", KEY_A )
Glide.AddInputAction( "hoverbike_controls", "steer_right", KEY_D )
Glide.AddInputAction( "hoverbike_controls", "accelerate", KEY_W )
Glide.AddInputAction( "hoverbike_controls", "brake", KEY_S )

Glide.AddInputAction( "hoverbike_controls", "attack_alt", KEY_SPACE )
Glide.AddInputAction( "hoverbike_controls", "throttle_modifier", KEY_LSHIFT )

Glide.AddInputAction( "hoverbike_controls", "horn", KEY_R )
Glide.AddInputAction( "hoverbike_controls", "siren", KEY_L )

Glide.AddInputAction( "hoverbike_controls", "lean_forward", KEY_UP )
Glide.AddInputAction( "hoverbike_controls", "lean_back", KEY_DOWN )

Glide.AddInputAction( "hoverbike_controls", "roll_left", KEY_LEFT )
Glide.AddInputAction( "hoverbike_controls", "roll_right", KEY_RIGHT )

Glide.AddInputAction( "hoverbike_controls", "landing_gear", KEY_G )
Glide.AddInputAction( "hoverbike_controls", "countermeasures", KEY_F )

if CLIENT then
    language.Add( "glide.input.hoverbike_controls", "Hoverbike Controls" )
end

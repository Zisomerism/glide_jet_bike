include( "shared.lua" )

DEFINE_BASECLASS( "base_glide_car" )

--- Implement this base class function.
function ENT:AllowFirstPersonMuffledSound()
    return false
end

--- Implement this base class function.
function ENT:AllowWindSound()
    return true, 1
end

local DRIVER_POSE_DATA = {
    ["ValveBiped.Bip01_L_UpperArm"] = Angle( -8, 10, 0 ),
    ["ValveBiped.Bip01_R_UpperArm"] = Angle( 10, 8, 5 ),

    ["ValveBiped.Bip01_L_Thigh"] = Angle( -5, 2, 0 ),
    ["ValveBiped.Bip01_L_Calf"] = Angle( -20, 60, 0 ),
    ["ValveBiped.Bip01_R_Thigh"] = Angle( 5, 2, 0 ),
    ["ValveBiped.Bip01_R_Calf"] = Angle( 20, 60, 0 )
}

--- Implement this base class function.
function ENT:GetSeatBoneManipulations()
    return DRIVER_POSE_DATA
end
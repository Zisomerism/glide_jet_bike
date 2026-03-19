ENT.Type = "anim"
ENT.Base = "base_glide_car"

ENT.PrintName = "Glide JetBike"
ENT.AdminOnly = false

-- Change vehicle type
ENT.VehicleType = Glide.VEHICLE_TYPE.MOTORCYCLE

ENT.MaxChassisHealth = 600

DEFINE_BASECLASS( "base_glide_car" )

ENT.UneditableNWVars = {
    WheelRadius = true,
    SuspensionLength = true,
    PowerDistribution = true,
    ForwardTractionBias = true
}

function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    local order = 0
    local function AddFloatVar( key, min, max, category )
        order = order + 1

        local editData = Either( 
            category == nil,
            nil,
            {
            KeyName = key,
            Edit = { type = "Float", order = order, min = min, max = max, category = category }
            }
        )

        self:NetworkVar( "Float", key, editData )
    end

    AddFloatVar( "ThrustMaxSpeed", 100, 10000, "#glide.editvar.engine" )
    AddFloatVar( "AirThrustReductionFactor", 1, 100, "#glide.editvar.engine" )
    AddFloatVar( "ThrustReductionFactor", 1, 100, "#glide.editvar.engine" )
end

--- Override this base class function.
function ENT:GetPlayerSitSequence( seatIndex )
    return seatIndex > 1 and "sit" or "drive_airboat"
end

if CLIENT then
    ENT.EngineSmokeMaxZVel = 20
    ENT.WheelSkidmarkScale = 0.3

    -- Change default sounds
    ENT.StartSound = "glide/aircraft/start_4.wav"
    ENT.DistantSoundPath = "glide/aircraft/jet_stream.wav"
    ENT.HornSound = "glide/horns/car_horn_light_1.wav"
    ENT.ExternalGearSwitchSound = ""
    ENT.InternalGearSwitchSound = ""
end

if SERVER then
    -- Change default car variables
    ENT.ChassisMass = 300
    ENT.AngularDrag = Vector( 0, -2, -6 ) -- Roll, pitch, yaw

    ENT.FallOnCollision = true
    ENT.FallWhileUnderWater = true

    ENT.SuspensionHeavySound = "Glide.Suspension.CompressBike"
    ENT.SuspensionLandFromFall = "Glide.OnLand.Bike"

    ENT.AirControlForce = Vector( 0.8, 3, 1.5 ) -- Roll, pitch, yaw
    ENT.AirMaxAngularVelocity = Vector( 600, 600, 500 ) -- Roll, pitch, yaw

    -- Bike-specific variables
    ENT.TiltForce = 550
    ENT.KeepUprightForce = 1500
    ENT.KeepUprightDrag = -3

    ENT.WheelieMaxAng = 45
    ENT.WheelieDrag = -15
    ENT.WheelieForce = 550

    --- Override this base class function.
    function ENT:GetAirInputs()
        return 0, self:GetInputFloat( 1, "lean_pitch" ), -self:GetInputFloat( 1, "steer" )
    end

    --- Override this base class function.
    function ENT:GetGears()
        return {
            [0] = 0, -- Neutral (this number has no effect)
            [1] = 1
        }
    end
end
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

    self:NetworkVar( "Float", "FlightValue" )

    local order = 0
    local uneditable = self.UneditableNWVars

    local function AddBoolVar( key, category )
        order = order + 1

        self:NetworkVar( "Bool", key, {
            KeyName = key,
            Edit = Either(
            uneditable[key] == true or category == nil,
            nil,
            { type = "Bool", order = order, category = category } )
        } )
    end

    local function AddIntVar( key, min, max, category )
        order = order + 1

        local editData = Either(
            uneditable[key] == true or category == nil,
            nil,
            {
            KeyName = key,
            Edit = { type = "Int", order = order, min = min, max = max, category = category }
            }
        )

        self:NetworkVar( "Int", key, editData )
    end
    AddBoolVar( "EnableHoverBike", "#glide.editvar.engine" )
    AddIntVar( "ThrustMaxSpeed", 100, 10000, "#glide.editvar.engine" )
    AddIntVar( "AirThrustReductionFactor", 1, 100, "#glide.editvar.engine" )
    AddIntVar( "ThrustReductionFactor", 1, 100, "#glide.editvar.engine" )

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

    ENT.IsHoverActive = false
    ENT.contactHoverPointCount = 0

    ENT.HoverParams = {
        linearDrag = Vector( 0.2, 1.5, 2.0 ), -- (Forward, right, up)
        angularDrag = Vector( -5, -15, -5 ), -- (Roll, pitch, yaw)

        hoverForce = 10,         -- How strong is the hover force on each hover point?
        hoverDistance = 100,     -- How far from surfaces each hover point has to be for the `hoverForce` to fully apply?
        hoverZDrag = 0.03,       -- Extra upwards drag to apply on each hover point

        maxSpeed = 1700,        -- Stop applying `engineForce` once the vehicle hits this speed
        engineForce = 450,
        turnForce = 900,
        pitchForce = 600,
        uprightForce = 600
    }

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
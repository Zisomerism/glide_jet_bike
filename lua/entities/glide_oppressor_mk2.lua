AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_jetbike"
ENT.PrintName = "Oppressor Mk2"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/desu/vehicles/oppressor_mk2/oppressor_mk2.mdl"

DEFINE_BASECLASS( "base_glide_jetbike" )

-- Override the default first person offset for all seats
function ENT:GetFirstPersonOffset( _, localEyePos )
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -170, 0, 50 )
    ENT.AfterburnerOrigin = Vector( -38, 0, 1 )

    ENT.ExhaustOffsets = {
        { pos = Vector( -30, 0, 14 ), scale = 1 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( -40.2, 0, 23.5 ), angle = Angle( 40, 180, 0 ), width = 2 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -28, 5, 24 ), angle = Angle( 90, 90, 0 ), scale = 0.4 },
        { offset = Vector( -10, -5, 10 ), angle = Angle( 90, 270, 0 ), scale = 0.4 }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 45, 0, 18.4 ), dir = Vector( 1, 0, 0 ) }
    }

    ENT.Headlights = {
        { offset = Vector( 48, 0, 18.4 ) }
    }

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( 5, 0, 0 )
        stream:LoadPreset( "lonewanderer" )
    end

    local Effect = util.Effect
    function ENT:OnUpdateParticles()
        BaseClass.OnUpdateParticles( self )

        local power = self:GetEngineThrottle()
        if power < 0.6 then return end
        local rpm = self:GetEngineRPM()

        local eff = EffectData()
        eff:SetEntity( self )
        eff:SetOrigin( self:LocalToWorld( self.AfterburnerOrigin ) )
        eff:SetAngles( self:GetAngles() )
        eff:SetScale( 0.4 )
        eff:SetMagnitude( rpm / self:GetMaxRPM() )
        Effect( "glide_afterburner", eff, true )

        if power < 1 then return end
        eff:SetMagnitude( power )
        eff:SetRadius( 2 ) -- This is actually a offset for the flare effect
        Effect( "glide_afterburner_flame", eff, true )
    end

    local DRIVER_POSE_DATA = {
        ["ValveBiped.Bip01_Pelvis"] = Angle( 0, 0, 20 ),
        ["ValveBiped.Bip01_Spine"] = Angle( 0, 10, 0 ),

        ["ValveBiped.Bip01_L_UpperArm"] = Angle( -20, -30, 0 ),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle( 13, -30, 0 ),
        ["ValveBiped.Bip01_L_Forearm"] = Angle( 0, 30, -60 ),
        ["ValveBiped.Bip01_R_Forearm"] = Angle( 0, 30, 60 ),

        ["ValveBiped.Bip01_L_Thigh"] = Angle( -5, 2, 0 ),
        ["ValveBiped.Bip01_L_Calf"] = Angle( -20, 60, 0 ),
        ["ValveBiped.Bip01_R_Thigh"] = Angle( 5, 2, 0 ),
        ["ValveBiped.Bip01_R_Calf"] = Angle( 20, 60, 0 )
    }

    function ENT:GetSeatBoneManipulations()
        return DRIVER_POSE_DATA
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 60 )
    ENT.StartupTime = 2

    ENT.HoverParams = {
        linearDrag = Vector( 1.2, 3, 1.5 ), -- (Forward, right, up)
        angularDrag = Vector( -1, -1, -1 ), -- (Roll, pitch, yaw)

        hoverForce = 24,         -- How strong is the hover force on each hover point?
        hoverDistance = 100,     -- How far from surfaces each hover point has to be for the `hoverForce` to fully apply?
        hoverZDrag = 0.04,       -- Extra upwards drag to apply on each hover point

        maxSpeed = 1700,        -- Stop applying `engineForce` once the vehicle hits this speed
        engineForce = 450,
        turnForce = 200,
        pitchForce = 400,
        uprightForce = 600
    }

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 0, 0, 0 ) )
    end

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 2, subModelId = 1 }
    }

    function ENT:CreateFeatures()
        self:SetSkin( math.random( 0, self:SkinCount() - 1 ) )
        self:SetEnableHoverBike( true )
        self:SetThrustMaxSpeed( 1700 )
        self:SetAirThrustReductionFactor( 5 )
        self:SetThrustReductionFactor( 30 )
        self:SetBrakePower( 2400 )
        self:SetMaxSteerAngle( 25 )

        self:SetMinRPM( 300 )
        self:SetMaxRPM( 6000 )

        self:SetSpringStrength( 700 )
        self:SetSpringDamper( 3000 )
        self:SetSuspensionLength( 5 )

        self:CreateSeat( Vector( -17, 0, 12 ), Angle( 0, 270, -16 ), Vector( 0, 60, 0 ), true )

        self:CreateWeapon( "missile_launcher", {
            MaxAmmo = 20,
            AmmoType = "missile",
            AmmoTypeShareCapacity = true,
            FireDelay = 1.0,
            ReloadDelay = 6.0,
            ProjectileOffsets = {
                Vector( 150, 2, 12 ),
                Vector( 150, -2, 12 )
            }
        } )

        self:CreateWeapon( "base", {
            Spread = 0.5,
            Damage = 6,
            TracerScale = 0.5,
            SingleShotSound = "Glide.JB700.Fire",
            FireDelay = 0.1,
            ProjectileOffsets = {
                Vector( 46, 3, 18 ),
                Vector( 46, -3, 18 )
                }
        } )

        -- Calculate local positions on the vehicle where hover forces are applied
        local phys = self:GetPhysicsObject()
        if not IsValid( phys ) then return end

        local center = phys:GetMassCenter()
        local mins, maxs = phys:GetAABB()
        local size = ( maxs - mins ) * 1

        local spacingX = 0.5
        local spacingY = 0.4
        local offsetZ = 18

        center[3] = -size[3] * 0.5

        self.hoverPoints = {
            center + Vector( size[1] * spacingX, size[2] * spacingY, offsetZ ), -- Front left
            center + Vector( size[1] * spacingX, size[2] * -spacingY, offsetZ ), -- Front right
            center + Vector( size[1] * -spacingX, size[2] * spacingY, offsetZ ), -- Rear left
            center + Vector( size[1] * -spacingX, size[2] * -spacingY, offsetZ ) -- Rear right
        }
    end

end
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_jetbike"
ENT.PrintName = "Lone Wanderer"
ENT.Author = "desu"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/desu/vehicles/lonewanderer/lonewanderer.mdl"

DEFINE_BASECLASS( "base_glide_jetbike" )

-- Override the default first person offset for all seats
function ENT:GetFirstPersonOffset( _, localEyePos )
    localEyePos[3] = localEyePos[3] - 4

    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -200, 0, 60 )
    ENT.WheelSkidmarkScale = 0.45

    ENT.AfterburnerOrigin = Vector( -40.2, 0, 23.5 )

    ENT.ExhaustOffsets = {
        { pos = Vector( -42, 0, 23.5 ), scale = 1 },
        { pos = Vector( -40, 0, 23.5 ), scale = 0.5 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( -40.2, 0, 23.5 ), angle = Angle( 40, 180, 0 ), width = 2 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -28, 5, 24 ), angle = Angle( 90, 90, 0 ), scale = 0.4 },
        { offset = Vector( -10, -5, 10 ), angle = Angle( 90, 270, 0 ), scale = 0.4 }
    }

    ENT.LightSprites = {
        { type = "brake", offset = Vector( -45.5, 0, 13 ), dir = Vector( -1, 0, 0 ), lightRadius = 50 },
        { type = "taillight", offset = Vector( -45.5, 0, 13 ), dir = Vector( -1, 0, 0 ), size = 15 },
        { type = "headlight", offset = Vector( 27, 0, 31 ), dir = Vector( 1, 0, 0 ) }
    }

    ENT.Headlights = {
        { offset = Vector( 28, 0, 31 ) }
    }

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( 5, 0, 0 )
        stream:LoadPreset( "lonewanderer" )
    end

    local DRIVER_POSE_DATA = {
        ["ValveBiped.Bip01_L_UpperArm"] = Angle( -20, 35, -15 ),
        ["ValveBiped.Bip01_L_Forearm"] = Angle( 20, -10, -80 ),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle( 20, 40, 30 ),
        ["ValveBiped.Bip01_R_Forearm"] = Angle( -20, -18, 80 ),

        ["ValveBiped.Bip01_L_Thigh"] = Angle( -10, -12, 20 ),
        ["ValveBiped.Bip01_L_Calf"] = Angle( -5, 50, 0 ),
        ["ValveBiped.Bip01_L_Foot"] = Angle( 0, -40, 0 ),

        ["ValveBiped.Bip01_R_Thigh"] = Angle( 10, -12, -20 ),
        ["ValveBiped.Bip01_R_Calf"] = Angle( 5, 50, 0 ),
        ["ValveBiped.Bip01_R_Foot"] = Angle( 0, -40, 0 ),
    }

    function ENT:GetSeatBoneManipulations()
        return DRIVER_POSE_DATA
    end

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.frontBoneId = self:LookupBone( "wheel_f" )
        self.rearBoneId = self:LookupBone( "wheel_r" )
        self.throttleId = self:LookupBone( "throttle" )
        self.kickstandId = self:LookupBone( "kickstand" )
    end

    local kickstandAng = Angle()
    local FrameTime = FrameTime
    local ExpDecayAngle = Glide.ExpDecayAngle
    local decay = 5

    function ENT:OnUpdateMisc()
        BaseClass.OnUpdateMisc( self )
        if LocalPlayer() ~= self:GetDriver() then return end
        local resting = self:GetVelocity():Length() < 30
        local dt = FrameTime()
        kickstandAng[1] = ExpDecayAngle( kickstandAng[1], resting and -90 or 0, decay, dt )
        self:ManipulateBoneAngles( self.kickstandId, kickstandAng, false )
    end

    local spinAng = Angle()
    local throttleAng = Angle()

    function ENT:OnUpdateAnimations()
        -- Call the base class' `OnUpdateAnimations`
        -- to automatically update the steering pose parameter.
        BaseClass.OnUpdateAnimations( self )

        if not self.frontBoneId then return end

        -- The wheels are part of the model, so we have to
        -- rotate their bones to match the actual wheels.
        spinAng[3] = -self:GetWheelSpin( 1 )
        self:ManipulateBoneAngles( self.frontBoneId, spinAng, false )

        spinAng[3] = -self:GetWheelSpin( 2 )
        self:ManipulateBoneAngles( self.rearBoneId, spinAng, false )

        throttleAng[1] = self:GetEngineThrottle() * 90
        self:ManipulateBoneAngles( self.throttleId, throttleAng, false )
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
        eff:SetScale( 0.25 )
        eff:SetMagnitude( rpm / self:GetMaxRPM() )
        Effect( "glide_afterburner", eff, true )

        if power < 1 then return end
        eff:SetMagnitude( power )
        eff:SetRadius( 2 ) -- This is actually a offset for the flare effect
        Effect( "glide_afterburner_flame", eff, true )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 30 )
    ENT.StartupTime = 0.5

    ENT.BurnoutForce = 55
    ENT.WheelieForce = 400

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 0, 0, 0 ) )
    end

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 2, subModelId = 1 },
    }

    function ENT:CreateFeatures()
        self:SetBrakePower( 2400 )
        self:SetMaxSteerAngle( 25 )

        self:SetForwardTractionMax( 2600 )
        self:SetSideTractionMultiplier( 60 )
        self:SetSideTractionMaxAng( 60 )
        self:SetSideTractionMin( 1000 )

        self:SetMinRPM( 3000 )
        self:SetMaxRPM( 12000 )

        self:SetSpringStrength( 700 )
        self:SetSpringDamper( 3000 )
        self:SetSuspensionLength( 8 )

        self:CreateSeat( Vector( -22, 0, 21 ), Angle( 0, 270, -16 ), Vector( 0, 60, 0 ), true )

        -- Front
        self:CreateWheel( Vector( 39, 0, 12 ), {
            steerMultiplier = 1
        } )

        -- Rear
        self:CreateWheel( Vector( -32, 0, 12 ) )

        -- Since the model already has a visual representation
        -- for the wheels, hide the actual wheels.
        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end

        self:ChangeWheelRadius( 13 )
    end

    function ENT:GetSpawnColor()
        return self.Color
    end

end
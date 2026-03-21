AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_jetbike"
ENT.PrintName = "Horse"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/desu/vehicles/honse/honse.mdl"

DEFINE_BASECLASS( "base_glide_jetbike" )

-- Override the default first person offset for all seats
function ENT:GetFirstPersonOffset( _, localEyePos )
    localEyePos[1] = localEyePos[1] + 10
    localEyePos[3] = localEyePos[3] - 5
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -170, 0, 80 )
    ENT.StartSound = "Glide.Engine.BikeStart1"

    ENT.ExhaustOffsets = {
        { pos = Vector( -40, 4, 40 ), angle = Angle( 10, 0, 0 ), scale = 0.7 },
        { pos = Vector( -40, -4, 40 ), angle = Angle( 10, 0, 0 ), scale = 0.7 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( -40, 0, 40 ), angle = Angle( 40, 180, 0 ), width = 8 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -3, 0, 40 ), angle = Angle( 90, 90, 0 ), scale = 0.4 }
    }

    ENT.Headlights = {
        { offset = Vector( 64, 0, 48 ) }
    }

    ENT.StoppedSound = "Glide.Sanchez.EngineStop"

    Glide.AddSoundSet( "Glide.Sanchez.EngineStop", 80, 100, 100, {
        "glide/streams/sanchez/turn_off_1.wav",
        "glide/streams/sanchez/turn_off_2.wav"
    } )

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( 5, 0, 0 )
        stream:LoadPreset( "sanchez" )
    end

    local DRIVER_POSE_DATA = {
        ["ValveBiped.Bip01_Pelvis"] = Angle( 0, 0, 10 ),
        ["ValveBiped.Bip01_Spine"] = Angle( 0, 10, 0 ),
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

        self.frontLBoneId = self:LookupBone( "walky_f_l" )
        self.rearLBoneId = self:LookupBone( "walky_r_l" )
        self.frontRBoneId = self:LookupBone( "walky_f_r" )
        self.rearRBoneId = self:LookupBone( "walky_r_r" )
    end

    local spinAng = Angle()

    function ENT:OnUpdateAnimations()
        -- Call the base class' `OnUpdateAnimations`
        -- to automatically update the steering pose parameter.
        BaseClass.OnUpdateAnimations( self )

        if not self.frontLBoneId then return end

        -- The wheels are part of the model, so we have to
        -- rotate their bones to match the actual wheels.
        spinAng[3] = -self:GetWheelSpin( 1 )
        self:ManipulateBoneAngles( self.frontLBoneId, spinAng, false )
        self:ManipulateBoneAngles( self.frontRBoneId, spinAng, false )

        spinAng[3] = -self:GetWheelSpin( 2 )
        self:ManipulateBoneAngles( self.rearLBoneId, spinAng, false )
        self:ManipulateBoneAngles( self.rearRBoneId, spinAng, false )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )
    ENT.StartupTime = 0.4
    ENT.BurnoutForce = 50

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 0, 0, 0 ) )
    end

    function ENT:CreateFeatures()
        self:SetThrustMaxSpeed( 1700 )
        self:SetAirThrustReductionFactor( 14 )
        self:SetThrustReductionFactor( 28 )

        self:SetDifferentialRatio( 1.2 )
        self:SetPowerDistribution( -1 )
        self:SetTransmissionEfficiency( 0.7 )
        self:SetBrakePower( 2000 )

        self:SetMinRPM( 500 )
        self:SetMaxRPM( 6000 )
        self:SetMinRPMTorque( 1500 )
        self:SetMaxRPMTorque( 1800 )

        self:SetSpringStrength( 600 )
        self:SetSpringDamper( 3000 )
        self:SetSuspensionLength( 7 )

        self:CreateSeat( Vector( -10, 0, 45 ), Angle( 0, 270, -16 ), Vector( 0, 60, 0 ), true )
        self:CreateSeat( Vector( -26, 0, 45 ), Angle( 0, 270, -5 ), Vector( 0, -60, 0 ), true )

        -- Front
        self:CreateWheel( Vector( 36, 0, 30 ), {
            steerMultiplier = 1,
            radius = 34
        } )

        -- Rear
        self:CreateWheel( Vector( -29, 0, 30 ), {
            radius = 40
        } )

        -- Since the model already has a visual representation
        -- for the wheels, hide the actual wheels.
        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end

    end

    function ENT:GetGears()
        return {
            [0] = 0, -- Neutral (this number has no effect)
            [1] = 2.8,
            [2] = 1.6
        }
    end

    function ENT:GetSpawnColor()
        return self.Color
    end

end
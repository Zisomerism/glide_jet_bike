AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_plane"
ENT.PrintName = "The War Bird"

ENT.GlideCategory = "Desu's Glide Stuff"
ENT.ChassisModel = "models/tf2enhanced/thewarbird.mdl"

ENT.PropOffset = Vector( 132, 0, 0 )

if CLIENT then
    ENT.CameraOffset = Vector( -500, 0, 75 )
    ENT.StallHornVolume = 0
    ENT.CrosshairInfo = {
        { traceOrigin = Vector( 130, 7, 15 ) },
        { traceOrigin = Vector( 130, -7, 15 ) }
    }

    ENT.ExhaustPositions = {
        Vector( 100, 16, 0 ),
        Vector( 100, -16, 0 ),
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 110, -15, 0 ), angle = Angle( 90, 0, 50 ), scale = 0.2 },
        { offset = Vector( 110, 15, 0 ), angle = Angle( 90, 0, -50 ), scale = 0.2 }
    }

    DEFINE_BASECLASS( "base_glide_plane" )
end

if SERVER then
    ENT.ChassisMass = 600
    ENT.SpawnPositionOffset = Vector( 0, 0, 70 )
    ENT.BulletDamageMultiplier = 2
    ENT.AngularDrag = Vector( -2, -2, -6 ) -- Roll, pitch, yaw

    ENT.PlaneParams = {
        liftAngularDrag = Vector( -6, -20, -6 ), -- (Roll, pitch, yaw)
        liftForwardDrag = 0.5,
        liftSideDrag = 3,

        liftFactor = 0.5,
        maxSpeed = 1800,
        liftSpeed = 1300,
        engineForce = 300,

        pitchForce = 2000,
        yawForce = 1000,
        rollForce = 1000
    }

    ENT.PropModel = "models/tf2enhanced/thewarbird_propeller_slow.mdl"
    ENT.PropFastModel = "models/tf2enhanced/thewarbird_propeller_fast.mdl"
    ENT.PropRadius = 35

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 30, 0, 0 ) )
    end

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 48, 0, -12 ), Angle( 0, 270, 10 ), Vector( -50, 120, 0 ), true )
        self:CreateSeat( Vector( 0, 0, -8 ), Angle( 0, 90, 10 ), Vector( -50, 120, 0 ), true )

        -- Front left
        self:CreateWheel( Vector( 78, 25, -38 ), {
            model = "models/tf2enhanced/thewarbird_wheel.mdl",
            modelScale = Vector( 1, 0.4, 1 ),
            radius = 8
        } )

        -- Front right
        self:CreateWheel( Vector( 78, -25, -38 ), {
            model = "models/tf2enhanced/thewarbird_wheel.mdl",
            modelScale = Vector( 1, -0.4, 1 ),
            radius = 8
        } )

        -- Rear
        self:CreateWheel( Vector( -112, 2, -15 ), {
            model = "models/tf2enhanced/thewarbird_wheel.mdl",
            modelScale = Vector( 1, 0.4, 1 ),
            steerMultiplier = -1,
            radius = 5
        } )

        self:CreateWeapon( "base", {
            Spread = 0.4,
            Damage = 100,
            TracerScale = 0.8,
            SingleShotSound = "Glide.JB700.Fire",
            FireDelay = 0.15,
            ProjectileOffsets = {
                Vector( 130, 7, 15 ),
                Vector( 130, -7, 15 )
            }
        } )

    end

    function ENT:OnDriverEnter()
        if self.mainProp:GetSkin() ~= self:GetSkin() then
            self.mainProp:SetSkin( self:GetSkin() )
        end

        self:TurnOn()
    end

    function ENT:GetSpawnColor()
        return self.Color
    end
end
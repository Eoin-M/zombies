SWEP.PrintName = "Fists"
SWEP.Author = "GbrosMC"
SWEP.Primary.Ammo = "None"
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Secondary.Ammo = "None"
SWEP.Secondary.Automatic = true
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.UseHands = true
SWEP.Base = "weapon_base"
SWEP.Category = "GbrosMC"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.HoldType = "knife"
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = ""

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "draw" ) )
	self:SetNextPrimaryFire(CurTime() + 1)
	self:UpdateNextIdle()
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 1, "NextIdle" )
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() )
end

function SWEP:PreDrawViewModel( vm, wep, ply )
	vm:SetMaterial( "engine/occlusionproxy" )
end

function SWEP:Holster()
	if ( IsValid( self.Owner ) && CLIENT && self.Owner:IsPlayer() ) then
		local vm = self.Owner:GetViewModel()
		if ( IsValid( vm ) ) then
			vm:SetMaterial( "" )
		end
	end
	return true
end

function SWEP:Initialize()
	print("Fists")
	self:SetHoldType(self.HoldType)
	if SERVER then 
		self:SetHoldType(self.HoldType)
	end
	if CLIENT then
		self:SetHoldType(self.HoldType)
	end
end

function SWEP:PrimaryAttack()
	local tr = self.Owner:GetEyeTrace()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "stab_miss" ) )
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if tr.HitPos:Distance(self.Owner:GetShootPos()) <= 35 then
		self:EmitSound("Flesh.ImpactHard")
		if SERVER then
			local phys = tr.Entity:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(self.Owner:GetRight() * -80 + self.Owner:GetForward() * 80)
			end
			tr.Entity:TakeDamage(math.random(5,10),self.Owner)
		end
	else
		self:EmitSound("npc/zombie/claw_miss"..math.random(1,2)..".wav")
	end
	self:SetNextPrimaryFire(CurTime() + 0.8)
	self:UpdateNextIdle()
end
	
function SWEP:OnDrop()
	self:Remove()
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
	if SERVER then
		self:SetHoldType(self.HoldType)
	end
	if CLIENT then
		self:SetHoldType(self.HoldType)
	end
	self:SetHoldType(self.HoldType)
	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = self:GetNextIdle()
	if ( idletime > 0 && CurTime() > idletime ) then
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "idle_cycle" ) )
		self:UpdateNextIdle()
	end
end

SWEP.SwayScale = 0
GBRP_SwayX = 0
GBRP_SwayY = 0
local GBRP_BobX = 0
local GBRP_BobY = 0
local GBRP_EyeX = 0
local GBRP_EyeY = 0

function SWEP:CalculateSway( pos, ang )
	local PL = LocalPlayer()
	local RFT = RealFrameTime()
	if not IsValid(PL) then return end
	local EYE = PL:EyeAngles()
	local Right = ang:Right()
	local Up = ang:Up()
	local Forward = ang:Forward()
	local Increase = 0.12
	local Decrease = 0.92
	local AngleDifference_X = math.AngleDifference( GBRP_EyeX, EYE.y )
	local AngleDifference_Y = math.AngleDifference( GBRP_EyeY, EYE.p )
	if AngleDifference_X != 0 or AngleDifference_Y != 0 then
		GBRP_SwayX = math.Clamp( GBRP_SwayX + (AngleDifference_X*Increase), -25, 25 )
		GBRP_SwayY = math.Clamp( GBRP_SwayY + (AngleDifference_Y*Increase), -20, 20 )
		AngleDifference_X = 0 AngleDifference_Y = 0
	end
	local OVSPEED = 6
	if GBRP_SwayX > 0 then
		local SPEED = math.Clamp( GBRP_SwayX*OVSPEED, 0.1, 500 )
		GBRP_SwayX = math.Clamp(GBRP_SwayX - RFT*SPEED,0,100)
	elseif GBRP_SwayX < 0 then
		local SPEED = math.Clamp( -GBRP_SwayX*OVSPEED, 0.1, 500 )
		GBRP_SwayX = math.Clamp(GBRP_SwayX + RFT*SPEED,-100,0)
	end
	if GBRP_SwayY > 0 then
		local SPEED = math.Clamp( GBRP_SwayY*OVSPEED, 0.1, 500 )
		GBRP_SwayY = math.Clamp(GBRP_SwayY - RFT*SPEED,0,100)
	elseif GBRP_SwayY < 0 then
		local SPEED = math.Clamp( -GBRP_SwayY*OVSPEED, 0.1, 500 )
		GBRP_SwayY = math.Clamp(GBRP_SwayY + RFT*SPEED,-100,0)
	end
	GBRP_EyeX = EYE.y GBRP_EyeY = EYE.p pos = pos + Up*(GBRP_SwayY*0.5)
	pos = pos + Right*(GBRP_SwayX*0.5)
	ang:RotateAroundAxis( Up, GBRP_SwayX*3 )
	ang:RotateAroundAxis( Forward, GBRP_SwayX*-1 )
	ang:RotateAroundAxis( Right, GBRP_SwayY*-5 )
	return pos, ang
end

function SWEP:CustomIdle( pos, ang )
	local PL = LocalPlayer()
	if not IsValid(PL) then return end
	local EYE = PL:EyeAngles()
	local Right = ang:Right()
	local Up = ang:Up()
	local Forward = ang:Forward()
	local RFT = RealFrameTime()
	local CT = UnPredictedCurTime()
	local Speed = 0.2
	if GBRP_BobX < Speed then
		local Blend = math.Clamp( (Speed - GBRP_BobX), 0.1, 500 )
		GBRP_BobX = math.Clamp( GBRP_BobX + RFT*Blend, 0, 1 )
	elseif GBRP_BobX > Speed then
		local Blend = math.Clamp( (GBRP_BobX - Speed)*2.5, 0.1, 500 )
		GBRP_BobX = math.Clamp( GBRP_BobX - RFT*Blend, 0, 1 )
	end
	local Sine_BobX = math.sin( CT*2.5 + 0.1 )*GBRP_BobX local
	Sine_BobY = math.sin( CT*2.5 - 2.1 )*GBRP_BobX
	pos = pos + Up*(Sine_BobY*1)
	pos = pos + Forward*(Sine_BobY*1)
	pos = pos + Right*(Sine_BobX*1)
	return pos, ang
end

SWEP.ViewModelDefPos = Vector(0, -7, 1)
SWEP.ViewModelDefAng = Vector(0, 0, 0)

function SWEP:GetViewModelPosition(pos, ang)
	pos, ang = self:CalculateSway( pos, ang )
	pos, ang = self:CustomIdle( pos, ang )
	if SERVER then
		return Vector(0,0,0), Angle(0,0,0)
	end
	local DefPos = self.ViewModelDefPos
	local DefAng = self.ViewModelDefAng
	if DefAng then
		ang = ang * 1
		ang:RotateAroundAxis (ang:Right(), DefAng.x)
		ang:RotateAroundAxis (ang:Up(), DefAng.y)
		ang:RotateAroundAxis (ang:Forward(), DefAng.z)
	end
	if DefPos then
		local Right = ang:Right() 
		local Up = ang:Up()
		local Forward = ang:Forward()
		pos = pos + DefPos.x * Right
		pos = pos + DefPos.y * Forward
		pos = pos + DefPos.z * Up
	end
	return pos, ang
end  
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/molotov3rd_zm.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	self:GetPhysicsObject():Wake()
	self:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
	
	local fireTrail = ents.Create("env_fire_trail")
	fireTrail:SetPos(self:GetPos())
	fireTrail:SetParent(self)
	fireTrail:Spawn()
	fireTrail:Activate()
end

function ENT:PhysicsCollide(data, physObject)
	if self.bRemove then return end
	
	local contents = util.PointContents(self:GetPos())
	if bit.band(contents, MASK_WATER) ~= 0 then
		self.bRemove = true
		return
	end
	
	local dmginfo = DamageInfo()
		dmginfo:SetAttacker(self.Owner)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(40)
		dmginfo:SetDamagePosition(self:GetPos())
		dmginfo:SetDamageType(DMG_BURN)
	util.BlastDamageInfo(dmginfo, self:GetPos(), 128)
	
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("HelicopterMegaBomb", effectdata)
	
	self:EmitSound("Grenade_Molotov.Detonate")
	self:EmitSound("Grenade_Molotov.Detonate2")
	
	self.bRemove = true
end

function ENT:Think()
	if self.bRemove then
		self:Remove()
	end
end

function ENT:OnRemove()
	local owner = self:GetOwner()
    for _, v in pairs(ents.FindInSphere(self:GetPos(), 128)) do
		if v:IsNPC() then
			v:Ignite(100)
		elseif v == owner then
			v:Ignite(3)
		end
    end
	
	for i = 1, 10 do
		local fire = ents.Create("env_fire")
		fire:SetPos(self:GetPos() +Vector(math.random(-80, 80), math.random(-80, 80), 0))
		fire:SetKeyValue("health", 25)
		fire:SetKeyValue("firesize", "60")
		fire:SetKeyValue("fireattack", "2")
		fire:SetKeyValue("damagescale", "4.0")
		fire:SetKeyValue("StartDisabled", "0")
		fire:SetKeyValue("firetype", "0" )
		fire:SetKeyValue("spawnflags", "132")
		fire:Spawn()
		fire:Fire("StartFire", "", 0)
		fire:SetOwner(owner)
		
		if owner:IsPlayer() then
			fire.OwnerTeam = owner:Team()
		else
			fire.OwnerTeam = TEAM_SURVIVOR
		end
	end
	
	for i=1, 8 do
		local sparks = ents.Create( "env_spark" )
		sparks:SetPos( self:GetPos() + Vector( math.random( -40, 40 ), math.random( -40, 40 ), math.random( -40, 40 ) ) )
		sparks:SetKeyValue( "MaxDelay", "0" )
 		sparks:SetKeyValue( "Magnitude", "2" )
		sparks:SetKeyValue( "TrailLength", "3" )
		sparks:SetKeyValue( "spawnflags", "0" )
		sparks:Spawn()
		sparks:Fire( "SparkOnce", "", 0 )
	end	
end
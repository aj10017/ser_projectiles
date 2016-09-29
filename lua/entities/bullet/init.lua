AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()


	self.Entity:SetModel( "models/hunter/plates/plate.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:GetPhysicsObject():SetMass(1)
	self.Entity:GetPhysicsObject():SetDragCoefficient(10)
	self.Origin = self:GetPos()
	util.SpriteTrail(self.Entity,0,Color(255,255,255,150),false,0.5,0,0.6,4 / ( 20 + 0 ) * 0.5,"trails/smoke.vmt")
	local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
	self.Entity:SetGravity(0.01)
	self.Time = CurTime()
	PrecacheParticleSystem("smoke_trail_tfa")
	ParticleEffectAttach("smoke_trail_tfa",2,self,0)
	local ef = EffectData()
	ef:SetEntity(self)
	ef:SetMagnitude(1)
	ef:SetAttachment(0)
	util.Effect("tfa_particle_smoketrail", ef)
end

function ENT:PhysicsCollide(data,phy)
	local ang = ((data.HitPos+data.HitNormal)-data.OurOldVelocity):Angle()
	local dir = (self:GetPos()-(self:GetPos()+data.OurOldVelocity)):Angle()
	--ang = WorldToLocal(Vector(0,0,0),ang,Vector(0,0,0),dir)
	--print(ang,dir)

	local dmg = DamageInfo()
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self.Owner:GetActiveWeapon())
	dmg:SetDamageType(2)
	dmg:IsExplosionDamage(false)
	dmg:SetDamage(self.dmg or 10)
	if data.HitEntity~=nil and data.HitEntity:GetClass()~="bullet" then
		data.HitEntity:TakeDamageInfo(dmg)
		if data.HitEntity:IsPlayer() then
			if data.HitEntity:Armor() > 0 then
				self.Owner:SendLua("surface.PlaySound('ui/shield/heavy/hit"..math.random(1,7)..".wav')")
			else
				self.Owner:SendLua("surface.PlaySound('sri/hurt.wav')")
			end
			dmg:GetAttacker():SendLua("hitmarker_alpha = 255")
		end
	end
	self:Remove()
	--self:Detonate()
end

--function ENT:Touch(ent)
--if ent:IsValid() then
	--self.Entity:Fire("kill", "", 0)
	--ParticleEffect("chappi_explosion",ent:GetPos(),Angle(0,math.Rand(180,-180),0),nil)
	--self:Remove()
	--end
--end

function ENT:Detonate()
	self.Entity:EmitSound(Sound( "npc/strider/strider_minigun.wav" ),75,90+math.Rand(0,20))

	--util.BlastDamage(self,self.Owner,self:GetPos(),50,7.5)

	local dmg = DamageInfo()
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	dmg:SetDamageType(67108864)
	dmg:IsExplosionDamage(true)
	dmg:SetDamage(240+((CurTime()-self.Time)*500))
	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetAngles():Forward() * 10000})
	if tr.Entity:IsValid() then tr.Entity:TakeDamage(dmg) end
	util.BlastDamageInfo(dmg,self:GetPos(),90+((CurTime()-self.Time)*90))

	local effectdata = EffectData()
	effectdata:SetOrigin( self.Entity:GetPos() )
	util.Effect( "plasma_boom2", effectdata )
	local bullet = {}
	bullet.Num = 5
	bullet.Src    = self:GetPos()
	bullet.Dir    = self:GetVelocity()*-1
	bullet.Spread = Vector( 10000, 10000, 10000 )
	bullet.Tracer = 1
	bullet.TracerName = "chargerifle"
	bullet.Damage = 150
	bullet.Force = 50
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(ply, tr, dmg)
		dmg:SetAttacker(self.Owner)
	end
	--self:FireBullets(bullet)

	self:Remove()
end

function ENT:Think()
	if !IsValid(self.Owner) then self:Remove() end


	self.Entity:GetPhysicsObject():ApplyForceCenter((Vector(0,0,0))*1)

	self.Entity:SetGravity(0.01)
	for k, v in pairs(ents.FindByClass("gmod_shieldgen_large")) do
		if self:GetPos():Distance(v:GetPos()) < 1000*(v:GetNWInt("radius")/v:GetNWInt("defrad")) and self.Owner:GetPos():Distance(v:GetPos()) > 1000*(v:GetNWInt("radius")/v:GetNWInt("defrad")) then
			v:SetNWFloat("Power",v:GetNWFloat("Power",0)-(240+(CurTime()-self.Time)))
			v:SetNWFloat("Alpha",255)
			sound.Play("ui/shield/heavy/hit"..math.random(1,6)..".wav",self:GetPos(),90,70,1)
			self:Detonate()
		end
	end
	for k, v in pairs(ents.FindByClass("gmod_shieldgen_small")) do
		if self:GetPos():Distance(v:GetPos()) < 1000*(v:GetNWInt("radius")/v:GetNWInt("defrad")) and self.Owner:GetPos():Distance(v:GetPos()) > 1000*(v:GetNWInt("radius")/v:GetNWInt("defrad")) then
			self:Detonate()
			v:SetNWFloat("Power",v:GetNWFloat("Power",0)-(((Bullet.Flight:Length()/8)/ACF.VelScale)*(Bullet.ProjMass*2))/200)
			v:SetNWFloat("Alpha",255)
			sound.Play("ui/shield/heavy/hit"..math.random(1,6)..".wav",Bullet.Pos,90,70,1)
		end
	end
	self:NextThink( CurTime() + 0.01 )
	return true -- Note: You need to return true to override the default next think time
end

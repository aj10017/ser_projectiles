AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

hook.Add("ShouldCollide","bullet_pen",function(ent1,ent2)
	--print("called")
	bull = nil
	hit = nil
	if ent1:GetClass()=="bullet" then
		bull = ent1
		hit = ent2
	else
		bull = ent2
		hit = ent1
	end
	if hit:GetClass() == "func_brush" or hit:GetClass() == "worldspawn" or hit:GetClass() == "player"  then return end
	if hit:GetClass()~="prop_physics" then return end
	if bull.dmg < 50 or bull:GetPhysicsObject():GetVelocity():Length() < 10000 or bull:GetPos():Distance(hit:GetPos())>4000 then return end
	dems = (hit:OBBMaxs()-hit:OBBMins())
--	if bull:GetPhysicsObject():GetPos():WithinAABox(hit:GetPhysicsObject():GetPos()+hit:OBBMins(),hit:GetPhysicsObject():GetPos()+hit:OBBMaxs()) == false then return end
	--print(dems,hit)
	if dems.x < 10 or dems.y < 10 or dems.z < 10  then
		return false
	end
	return
end)

function ENT:Initialize()


	self.Entity:SetModel( "models/hunter/plates/plate.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:GetPhysicsObject():SetMass(1)
	self.Entity:GetPhysicsObject():SetDragCoefficient(10)
	self:SetCustomCollisionCheck(true)
	self:CollisionRulesChanged()
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
	if IsValid(self.Owner:GetActiveWeapon()) == false then
		dmg:SetInflictor(self.Owner)
	else
		dmg:SetInflictor(self.Owner:GetActiveWeapon())
	end
	dmg:SetDamageType(2)
	dmg:IsExplosionDamage(false)
	dmg:SetDamage(self.dmg or 10)
	if data.HitEntity~=nil and data.HitEntity:GetClass()~="bullet" then
		data.HitEntity:TakeDamageInfo(dmg)
		if data.HitEntity:IsPlayer() then
			self.Owner:SendLua("surface.PlaySound('buttons/button16.wav')")
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
	if IsValid(self.Owner)==false then self:Remove() end


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

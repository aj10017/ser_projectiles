include('shared.lua')

function ENT:Initialize()
--game.AddParticles( "particles/chappi_explosion.pcf" )
self.Entity:SetModel( "models/dav0r/hoverball.mdl" )
self.White4 = Color(255,255,0,255)
self.Time = CurTime()
self.max = 0
self.Origin = self:GetPos()
end

function ENT:Draw()
	if self.Origin == nil then
		self.Origin = self:GetPos()
	end
	if self.Vel == nil then self.Vel = self:GetVelocity() end
	self.max = Lerp(RealFrameTime()*5,self.max,20)
	self.White4.a = self.max * 10
	--self:DrawModel()
	self.Entity:SetModelScale(0.5,0)
	render.SetMaterial(Material("sprites/glow04_noz"))
	render.DrawSprite(self.Entity:GetPos(),self.max,self.max,self.White4)
	render.DrawSprite(self.Entity:GetPos(),self.max,self.max,self.White4)
	render.DrawSprite(self.Entity:GetPos(),self.max,self.max,self.White4)
	local pos = util.IntersectRayWithPlane(self.Origin,self:GetVelocity(),LocalPlayer():EyePos(),self:GetVelocity()*-1)

	--print(pos)
	--print(self:GetOwner())
	if pos ~= nil then
		if self.crack == nil then
			if pos:Distance(LocalPlayer():EyePos()) < 400 then
				self.crack = true
				self.vel = self:GetVelocity():Angle():Forward()*-100
				--print(self.Origin:Distance(EyePos())/25000)
				timer.Simple(self.Origin:Distance(EyePos())/25000,function()
					local lp = Vector(0,0,0)
					if IsValid(self) then
						lp = WorldToLocal(pos,(self.Vel*-1):Angle(),EyePos(),(self.Vel*-1):Angle())
					else
						lp = Vector(0,math.Rand(50,-50),math.Rand(50,-50))
					end
					--print(lp)
					LocalPlayer().vpa = Angle(lp.z*-1,lp.y,0)
					LocalPlayer().vpa.p = LocalPlayer().vpa.p / 50
					LocalPlayer().vpa.y = LocalPlayer().vpa.y / 50
					LocalPlayer().vpa.r = 0
					sound.Play("cracks/crack_-0"..math.random(1,6)..".wav",pos,100,100,1)
				end)
			end
		end
	end
end
hook.Remove("Think","adjusteyeangles")
hook.Add("Think","adjusteyeangles",function()
	if LocalPlayer().vpal == nil then LocalPlayer().vpal = Angle(0,0,0) end
	if LocalPlayer().vpa == nil then LocalPlayer().vpa = Angle(0,0,0) end
	LocalPlayer().vpal = LerpAngle(RealFrameTime()*12,LocalPlayer().vpal,LocalPlayer().vpa)
	LocalPlayer().vpa = LerpAngle(RealFrameTime()*12,LocalPlayer().vpa,Angle(0,0,0))
	LocalPlayer().vpal.r = 0
	local lpos, lang = WorldToLocal(Vector(0,0,0),EyeAngles()+LocalPlayer().vpal,Vector(0,0,0),EyeAngles())
	--print(lang)
	lang.r = 0
	if not LocalPlayer():InVehicle() then
		--LocalPlayer():SetEyeAngles((EyeAngles()-LocalPlayer():GetViewPunchAngles())+lang)
	end
end)

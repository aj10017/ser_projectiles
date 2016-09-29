
hook.Add("InitPostEntity","setvphysicsspeed",function()
	local tbl = physenv.GetPerformanceSettings()
	tbl.MaxVelocity = 60500
	tbl.LookAheadTimeObjectVsObject = 0.001
	tbl.LookAheadTimeObjectVsWorld = 0.001
	physenv.SetPerformanceSettings(tbl)
	physenv.SetAirDensity(0)
end)
hook.Add("EntityFireBullets","projectilebullets",function(ent,data)
	local fire = nil
	local override = false
	if ent:IsPlayer() then
		if ent:GetActiveWeapon():IsScripted() then
			if ent:GetActiveWeapon().Base=="fas2_base" then return end
			if ent:GetActiveWeapon().Base=="bobs_scoped_base" or ent:GetActiveWeapon().Base=="bobs_gun_base" or ent:GetActiveWeapon().Base~="weapon_sbase" then
				fire = ent:GetActiveWeapon()
			end
		end
	end
	if ent:IsWeapon() then
		if ent:IsScripted() then
			if ent.Base == "fas2_base" then return end
			if ent.Base == "bobs_scoped_base" or ent.Base == "bobs_gun_base" or (ent.Base~="weapon_sbase" or ent.Base~="fas2_base") then
				fire = ent
			end
		end
	end
	if ent:GetClass()=="gmod_allydrone" and ent.weapontype=="generic_fallback" then
		fire = ent
		override = false
	end
	if fire~=nil and override==false then
		local self = fire
		local muzzlepos = fire.Owner:GetShootPos() + (fire.Owner:GetForward()*25+fire.Owner:GetRight()*1+fire.Owner:GetUp()*-1)
		if SERVER then
			for i=1,(math.Clamp(data.Num/2,1,999) or 1) do
			local plasma = ents.Create("bullet")
			plasma:SetPos(muzzlepos)
			plasma:SetOwner(self.Owner)
			plasma.dmg = data.Damage/1
			if data.Num/2 >= 1 then
				--plasma.dmg = plasma.dmg * 1.4
				--timer.Simple(i*0.005,function()
					plasma:SetPos(muzzlepos)
					plasma:Spawn()

					local phys = plasma:GetPhysicsObject()
					local VelL = data.Num/2500
					--if self.SC == true then phys:ApplyForceCenter((self.Owner:GetAimVector()+Vector(math.Rand(0.03,-0.03),math.Rand(0.03,-0.03),math.Rand(0.03,-0.03))) * 120000 ) end
					phys:ApplyForceCenter(((self.Owner:GetAimVector())+Vector(math.Rand(VelL,VelL*-1)*data.Num/2,math.Rand(VelL,VelL*-1)*data.Num/2,math.Rand(VelL,VelL*-1)*data.Num/2)) * (180000/(1+(data.Num/2*3)+data.Damage/50)) )

				--end)
			else
				plasma:SetPos(muzzlepos)
				plasma:Spawn()

				local phys = plasma:GetPhysicsObject()
				local VelL = data.Num/3000
				--if self.SC == true then phys:ApplyForceCenter((self.Owner:GetAimVector()+Vector(math.Rand(0.03,-0.03),math.Rand(0.03,-0.03),math.Rand(0.03,-0.03))) * 120000 ) end
				phys:ApplyForceCenter(((self.Owner:GetAimVector())+Vector(math.Rand(VelL,VelL*-1)*data.Num,math.Rand(VelL,VelL*-1)*data.Num,math.Rand(VelL,VelL*-1)*data.Num)) * ((30000*(1+data.Damage/30))/(1+(data.Num*3))) )
			end

			end
		end
		data.TracerName = ""
		data.Tracer = 9999
		data.Damage = 0
		data.Src = Vector(0,0,0)
		data.Dir = Angle(0,0,0):Up()
		return false
	elseif override==true then
		local self = fire
		local muzzlepos = fire:GetPos() + (fire:GetForward()*5+fire:GetRight()*1)
		if SERVER then
			for i=1,1 do
			local plasma = ents.Create("bullet")
			plasma:SetPos(muzzlepos)
			plasma:SetOwner(self.owner)

			plasma:Spawn()
			plasma.dmg = data.Damage/1.4
			local phys = plasma:GetPhysicsObject()
			local VelL = data.Spread*1
			--if self.SC == true then phys:ApplyForceCenter((self.Owner:GetAimVector()+Vector(math.Rand(0.03,-0.03),math.Rand(0.03,-0.03),math.Rand(0.03,-0.03))) * 120000 ) end
			phys:ApplyForceCenter(((self:GetForward())+Vector(math.Rand(VelL/2700,VelL/2700*-1),math.Rand(VelL/2700,VelL/2700*-1),0.001)) * 180000 )
			end
		end
		data.TracerName = ""
		data.Tracer = 9999
		data.Damage = 0
		data.Src = Vector(0,0,0)
		data.Dir = Angle(0,0,0):Up()
		return false
	end
end)

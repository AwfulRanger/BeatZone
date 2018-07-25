DEFINE_BASECLASS( "base_anim" )

AddCSLuaFile()



if CLIENT then language.Add( "bz_turret", "Turret" ) end

ENT.Base = "base_anim"
ENT.PrintName = "#bz_turret"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = Model( "models/items/crystal_ball_pickup.mdl" )
ENT.ShootSound = Sound( "weapons/capper_shoot.wav" )
ENT.NewTargetTime = 1
ENT.ShootTime = 0.2

function ENT:Initialize()
	
	self:SetModel( self.Model )
	
end

if SERVER then
	
	function ENT:Think()
		
		if self.DieTime ~= nil and CurTime() > self.DieTime then self:Remove() return end
		
		if self.LastTarget == nil or self.Target == NULL or CurTime() > self.LastTarget + self.NewTargetTime then
			
			self.Target = self:NewTarget()
			self.LastTarget = CurTime()
			
		end
		
		if IsValid( self.Target ) == true and ( self.LastShoot == nil or CurTime() > self.LastShoot + self.ShootTime ) then
			
			local pos = self:GetShootPos()
			self:FireBullets( {
				
				Attacker = self:GetOwner(),
				Damage = 10,
				Src = pos,
				Dir = ( self.Target:BodyTarget( pos ) - pos ):GetNormalized(),
				IgnoreEntity = self,
				
			} )
			
			self.LastShoot = CurTime()
			
			self:EmitSound( self.ShootSound )
			
		end
		
	end
	
	function ENT:GetShootPos()
		
		return self:GetPos() + Vector( 0, 0, 32 )
		
	end
	
	function ENT:NewTarget()
		
		local enemies = gmod.GetGamemode().Skeletons
		if enemies == nil then return end
		
		local dist
		local enemy
		for i = 1, #enemies do
			
			local ent = enemies[ i ]
			local d = ent:GetPos():Distance( self:GetPos() )
			if ent:Visible( self ) == true and ( dist == nil or d < dist ) then
				
				dist = d
				enemy = ent
				
			end
			
		end
		
		return enemy
		
	end
	
end
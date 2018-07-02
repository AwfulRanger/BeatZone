DEFINE_BASECLASS( "base_anim" )

AddCSLuaFile()



game.AddParticles( "particles/explosion.pcf" )
game.AddParticles( "particles/flamethrower.pcf" )

if CLIENT then language.Add( "bz_fireball", "Fireball" ) end

ENT.Base = "base_anim"
ENT.PrintName = "#bz_fireball"
ENT.Model = Model( "models/weapons/w_models/w_grenade_grenadelauncher.mdl" )

ENT.HitSounds = { Sound( "misc/flame_engulf.wav" ) }

function ENT:Initialize()
	
	self:SetModel( self.Model )
	
	if SERVER then
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		
		self:SetTrigger( true )
		
		if self.TrailParticle ~= nil then
			
			local attach = self:LookupAttachment( "trail" )
			ParticleEffectAttach( self.TrailParticle, PATTACH_POINT_FOLLOW, self, attach )
			
		end
		
	end
	
end

if SERVER then
	
	ENT.Duration = 3
	function ENT:SetDuration( duration ) self.Duration = duration end
	function ENT:GetDuration() return self.Duration end
	
	ENT.Radius = 40
	function ENT:SetRadius( radius ) self.Radius = radius end
	function ENT:GetRadius() return self.Radius end
	
	ENT.HitParticle = "projectile_fireball"
	ENT.TrailParticle = "new_flame"
	
	function ENT:OnCollide( skybox, ent )
		
		if self.HasCollided == true then return end
		self.HasCollided = true
		
		if skybox ~= true then
			
			if IsValid( ent ) == true then ent:Ignite( self:GetDuration(), self:GetRadius() ) end
			
			self:EmitSound( self.HitSounds[ math.random( #self.HitSounds ) ], 140 )
			ParticleEffect( self.HitParticle, self:GetPos(), self:GetAngles() )
			
		end
		
		SafeRemoveEntityDelayed( self, 0 )
		
	end
	
	function ENT:PhysicsCollide( data, collider )
		
		self:OnCollide( util.TraceLine( { start = data.HitPos, endpos = data.HitPos + data.HitNormal } ).HitSky, data.HitEntity )
		
	end
	
	function ENT:StartTouch( ent )
		
		if ent ~= self:GetOwner() then self:OnCollide( false, ent ) end
		
	end
	
end

if CLIENT then
	
	function ENT:Draw() end
	
end
DEFINE_BASECLASS( "base_anim" )

AddCSLuaFile()



game.AddParticles( "particles/explosion.pcf" )
game.AddParticles( "particles/rockettrail.pcf" )

if CLIENT then language.Add( "bz_rocket", "Rocket" ) end

ENT.Base = "base_anim"
ENT.PrintName = "#bz_rocket"
ENT.Model = Model( "models/weapons/w_models/w_rocket.mdl" )
ENT.Skin = 0

function ENT:Initialize()
	
	self:SetModel( self.Model )
	self:SetSkin( self.Skin )
	
	if SERVER then
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) == true then phys:EnableGravity( false ) end
		
		self:SetTrigger( true )
		
		if self.TrailParticle ~= nil then
			
			local attach = self:LookupAttachment( "trail" )
			ParticleEffectAttach( self.TrailParticle, PATTACH_POINT_FOLLOW, self, attach )
			
		end
		
	end
	
end

if SERVER then
	
	ENT.Radius = 100
	function ENT:SetRadius( radius ) self.Radius = radius end
	function ENT:GetRadius() return self.Radius end
	
	ENT.Damage = 10
	function ENT:SetDamage( damage ) self.Damage = damage end
	function ENT:GetDamage() return self.Damage end
	
	ENT.ExplodeSounds = {
		
		Sound( "weapons/explode1.wav" ),
		Sound( "weapons/explode2.wav" ),
		Sound( "weapons/explode3.wav" ),
		
	}
	ENT.ExplodeParticle = "explosioncore_midair"
	ENT.TrailParticle = "rockettrail"
	
	function ENT:OnCollide( skybox )
		
		if skybox ~= true then
			
			local attacker = self
			if IsValid( self:GetOwner() ) == true then attacker = self:GetOwner() end
			util.BlastDamage( self, attacker, self:GetPos(), self:GetRadius(), self:GetDamage() )
			
			self:EmitSound( self.ExplodeSounds[ math.random( #self.ExplodeSounds ) ], 140 )
			ParticleEffect( self.ExplodeParticle, self:GetPos(), self:GetAngles() )
			
		end
		
		SafeRemoveEntityDelayed( self, 0 )
		
	end
	
	function ENT:PhysicsCollide( data, collider )
		
		self:OnCollide( util.TraceLine( { start = data.HitPos, endpos = data.HitPos + data.HitNormal } ).HitSky )
		
	end
	
	function ENT:StartTouch( ent )
		
		if ent ~= self:GetOwner() then self:OnCollide( false ) end
		
	end
	
end
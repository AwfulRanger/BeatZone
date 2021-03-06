DEFINE_BASECLASS( "base_anim" )

AddCSLuaFile()



game.AddParticles( "particles/explosion.pcf" )
game.AddParticles( "particles/stickybomb.pcf" )

if CLIENT then language.Add( "bz_grenade", "Grenade" ) end

ENT.Base = "base_anim"
ENT.PrintName = "#bz_grenade"
ENT.Model = Model( "models/weapons/w_models/w_grenade_grenadelauncher.mdl" )
ENT.Skin = 0

ENT.ExplodeParticle = "explosioncore_midair"

ENT.ExplodeSounds = {
	
	Sound( "weapons/explode1.wav" ),
	Sound( "weapons/explode2.wav" ),
	Sound( "weapons/explode3.wav" ),
	
}

function ENT:Initialize()
	
	self:SetModel( self.Model )
	self:SetSkin( self.Skin )
	
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
	
	ENT.Radius = 100
	function ENT:SetRadius( radius ) self.Radius = radius end
	function ENT:GetRadius() return self.Radius end
	
	ENT.Damage = 25
	function ENT:SetDamage( damage ) self.Damage = damage end
	function ENT:GetDamage() return self.Damage end
	
	function ENT:OnCollide( skybox )
		
		if self.HasCollided == true then return end
		self.HasCollided = true
		
		if skybox ~= true then
			
			local attacker = self
			if IsValid( self:GetOwner() ) == true then attacker = self:GetOwner() end
			util.BlastDamage( self, attacker, self:GetPos(), self:GetRadius(), self:GetDamage() )
			
			self:EmitSound( self.ExplodeSounds[ math.random( #self.ExplodeSounds ) ] )
			ParticleEffect( self.ExplodeParticle, self:GetPos(), self:GetAngles() )
			
		end
		
		self:Remove()
		
	end
	
	function ENT:PhysicsCollide( data, collider )
		
		self:OnCollide( util.TraceLine( { start = data.HitPos, endpos = data.HitPos + data.HitNormal } ).HitSky )
		
	end
	
	function ENT:StartTouch( ent )
		
		if ent ~= self:GetOwner() then self:OnCollide( false ) end
		
	end
	
end
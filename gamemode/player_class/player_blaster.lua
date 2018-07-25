DEFINE_BASECLASS( "player_bz" )



game.AddParticles( "particles/explosion.pcf" )

local PLAYER = {}


PLAYER.DisplayName = "Blaster"
PLAYER.Description = [[Crowd control class, focuses on eliminating multiple targets rapidly with heavy weapons.]]

PLAYER.WalkSpeed = 320
PLAYER.RunSpeed = 320

function PLAYER:InitializePerks()
	
	BaseClass.InitializePerks( self )
	
	self:AddPerk( "perk_damage_bullet" )
	self:AddPerk( "perk_damage_blast" )
	self:AddPerk( "perk_resist_blast" )
	self:AddPerk( "perk_shield" )
	self:AddPerk( "perk_maxammo" )
	self:AddPerk( "perk_attackspeed" )
	
end

local explodesounds = {
	
	Sound( "weapons/explode1.wav" ),
	Sound( "weapons/explode2.wav" ),
	Sound( "weapons/explode3.wav" ),
	
}
local explodeparticle = "explosioncore_midair"
function PLAYER:InitializeAbilities()
	
	BaseClass.InitializeAbilities( self )
	
	self:AddAbility( "frag", {
		
		Name = "Frag",
		Description = "Adds blast damage bonuses to all damage done within 5 seconds of activation",
		Cooldown = 10,
		Bind = "+menu",
		OnActivate = function( self, ply )
			
			ply.BZ_AbilityFragTime = CurTime() + 5
			
		end,
		
	} )
	
	self:AddAbility( "blast", {
		
		Name = "Blast",
		Description = "Causes an explosion at your feet that propels you upwards and damages nearby units",
		Cooldown = 5,
		Bind = "+speed",
		OnActivate = function( self, ply )
			
			ply:SetVelocity( Vector( 0, 0, 256 ) )
			
			if CLIENT then return end
			
			util.BlastDamage( ply, ply, ply:GetPos(), 150, 25 )
			
			ply:EmitSound( explodesounds[ math.random( #explodesounds ) ] )
			ParticleEffect( explodeparticle, ply:GetPos(), ply:GetAngles() )
			
		end,
		
	} )
	
end


player_manager.RegisterClass( "player_blaster", PLAYER, "player_bz" )
DEFINE_BASECLASS( "player_bz" )



game.AddParticles( "particles/blood_impact.pcf" )

local PLAYER = {}


PLAYER.DisplayName = "Ripper"
PLAYER.Description = [[Brute class, focuses on tanking damage and eliminating enemies with melee weapons.]]

PLAYER.WalkSpeed = 320
PLAYER.RunSpeed = 320

function PLAYER:InitializePerks()
	
	BaseClass.InitializePerks( self )
	
	self:AddPerk( "perk_damage_melee" )
	self:AddPerk( "perk_resist_all" )
	self:AddPerk( "perk_health" )
	self:AddPerk( "perk_movespeedspecial_damagetaken" )
	self:AddPerk( "perk_healthregenspecial_enemykilled" )
	self:AddPerk( "perk_enemybleed" )
	
end

local equalizesound = Sound( "weapons/cleaver_hit_02.wav" )
local bloodbathsound = Sound( "weapons/samurai/tf_katana_slice_03.wav" )
local bleedparticle = "blood_impact_red_01"
function PLAYER:InitializeAbilities()
	
	BaseClass.InitializeAbilities( self )
	
	self:AddAbility( "equalize", {
		
		Name = "Equalize",
		Description = "Damages target unit equal to your missing health, and gives back half of damage done as health",
		Cooldown = 5,
		Bind = "+menu",
		OnActivate = function( self, ply )
			
			if CLIENT then return end
			
			local miss = ply:GetMaxHealth() - ply:Health()
			if miss > 0 then
				
				local tr = ply:GetEyeTrace()
				local ent = tr.Entity
				if IsValid( ent ) == true and ent:Health() > 0 then
					
					local dmg = DamageInfo()
					dmg:SetDamageBonus( miss )
					dmg:SetDamageType( DMG_GENERIC )
					dmg:SetAttacker( ply )
					dmg:SetDamagePosition( tr.HitPos )
					ent:TakeDamageInfo( dmg )
					
					ply:SetHealth( ply:Health() + math.min( math.floor( miss * 0.5 ), ply:GetMaxHealth() ) )
					
					ParticleEffect( bleedparticle, ent:GetPos() + ent:OBBCenter(), ent:GetAngles() )
					
				end
				
			end
			
			ply:EmitSound( equalizesound )
			
		end,
		
	} )
	
	self:AddAbility( "bloodbath", {
		
		Name = "Bloodbath",
		Description = "Causes all nearby units, including yourself, to bleed for 5 seconds",
		Cooldown = 10,
		Bind = "+speed",
		OnActivate = function( self, ply )
			
			if CLIENT then return end
			
			local entslist = ents.GetAll()
			for i = 1, #entslist do
				
				local ent = entslist[ i ]
				if ent:Health() > 0 and ent:GetPos():Distance( ply:GetPos() ) < 256 then
					
					ent:StartBleed( 5, 5, ply )
					ParticleEffect( bleedparticle, ent:GetPos() + ent:OBBCenter(), ent:GetAngles() )
					
				end
				
			end
			
			ply:EmitSound( bloodbathsound )
			
		end,
		
	} )
	
end


player_manager.RegisterClass( "player_ripper", PLAYER, "player_bz" )
DEFINE_BASECLASS( "player_bz" )



local PLAYER = {}


PLAYER.DisplayName = "Tuner"
PLAYER.Description = [[Precision shooting class, focuses on eliminating targets one at a time with accurate weapons.]]

PLAYER.WalkSpeed = 320
PLAYER.RunSpeed = 320

function PLAYER:InitializePerks()
	
	BaseClass.InitializePerks( self )
	
	self:AddPerk( "perk_damage_bullet" )
	self:AddPerk( "perk_damage_critical" )
	self:AddPerk( "perk_resistspecial_crouch" )
	self:AddPerk( "perk_resistspecial_immobile" )
	self:AddPerk( "perk_maxammo" )
	self:AddPerk( "perk_enemybleed" )
	
end

local snipesound = Sound( "weapons/csgo_awp_shoot.wav" )
local grapplesound = Sound( "weapons/grappling_hook_shoot.wav" )
function PLAYER:InitializeAbilities()
	
	BaseClass.InitializeAbilities( self )
	
	self:AddAbility( "snipe", {
		
		Name = "Snipe",
		Description = "Fires a precise bullet that deals critical damage and penetrates units",
		Cooldown = 5,
		Bind = "+menu",
		OnActivate = function( self, ply )
			
			if CLIENT then return end
			
			local dmg = DamageInfo()
			dmg:SetDamage( 15 )
			dmg:SetDamageType( DMG_BULLET )
			dmg:SetAttacker( ply )
			dmg:SetDamageCustom( DMGCUSTOM_CRIT )
			
			local startpos = ply:GetShootPos()
			
			local dir = ply:GetAimVector() * 32768
			local filter = { ply }
			local tr = util.TraceLine( {
				
				start = startpos,
				endpos = startpos + dir,
				filter = filter,
				
			} )
			while IsValid( tr.Entity ) == true and tr.Entity:Health() > 0 do
				
				dmg:SetDamagePosition( tr.HitPos )
				if SERVER then tr.Entity:TakeDamageInfo( dmg ) end
				
				table.insert( filter, tr.Entity )
				
				tr = util.TraceLine( {
					
					start = tr.HitPos,
					endpos = startpos + dir,
					filter = filter,
					
				} )
				
			end
			
			local ent = ply
			local attach = -1
			if IsValid( ply:GetActiveWeapon() ) == true then
				
				ent = ply:GetActiveWeapon()
				attach = ent:LookupAttachment( "muzzle" )
				
			end
			
			local pos = startpos
			local attachment = ent:GetAttachment( attach )
			if attachment ~= nil then pos = attachment.Pos end
			
			local effect = EffectData()
			effect:SetOrigin( tr.HitPos )
			effect:SetStart( pos )
			effect:SetEntity( ent )
			effect:SetAttachment( attach )
			effect:SetScale( 16384 )
			util.Effect( "bz_snipetracer", effect )
			
			ply:EmitSound( snipesound, 140 )
			
		end,
		
	} )
	
	self:AddAbility( "grapple", {
		
		Name = "Grapple",
		Description = "Fires a quick grappling hook that propels you towards whatever it hits",
		Cooldown = 5,
		Bind = "+speed",
		OnActivate = function( self, ply )
			
			local startpos = ply:GetShootPos()
			
			local tr = ply:GetEyeTrace()
			if tr.Hit == true and tr.HitSky ~= true then
				
				ply:SetVelocity( ( tr.HitPos - startpos ):GetNormalized() * 256 )
				
			end
			
			if CLIENT then return end
			
			local ent = ply
			local attach = -1
			if IsValid( ply:GetActiveWeapon() ) == true then
				
				ent = ply:GetActiveWeapon()
				attach = ent:LookupAttachment( "muzzle" )
				
			end
			
			local pos = startpos
			local attachment = ent:GetAttachment( attach )
			if attachment ~= nil then pos = attachment.Pos end
			
			local effect = EffectData()
			effect:SetOrigin( tr.HitPos )
			effect:SetStart( pos )
			effect:SetEntity( ent )
			effect:SetAttachment( attach )
			effect:SetScale( 16384 )
			util.Effect( "bz_grapplehook", effect )
			
			ply:EmitSound( grapplesound, 140 )
			
		end,
		
	} )
	
end


player_manager.RegisterClass( "player_tuner", PLAYER, "player_bz" )
DEFINE_BASECLASS( "player_bz" )



local PLAYER = {}


PLAYER.DisplayName = "Burner"
PLAYER.Description = [[Debuffer class, focuses on dealing damage over time with flames.]]

PLAYER.WalkSpeed = 320
PLAYER.RunSpeed = 320

function PLAYER:InitializePerks()
	
	BaseClass.InitializePerks( self )
	
	self:AddPerk( "perk_damage_fire" )
	self:AddPerk( "perk_resist_fire" )
	self:AddPerk( "perk_enemyignite" )
	self:AddPerk( "perk_enemymovespeedignited" )
	self:AddPerk( "perk_damagespecial_onfire" )
	self:AddPerk( "perk_maxammo" )
	
end

local eruptsound = Sound( "weapons/dragons_fury_impact.wav" )
function PLAYER:InitializeAbilities()
	
	BaseClass.InitializeAbilities( self )
	
	self:AddAbility( "erupt", {
		
		Name = "Erupt",
		Description = "Ignite units in a short radius in front of you",
		Cooldown = 5,
		Bind = "+menu",
		OnActivate = function( self, ply )
			
			if CLIENT then return end
			
			local entslist = ents.FindInCone( ply:GetShootPos(), ply:GetAimVector(), 256, 0 )
			for i = 1, #entslist do
				
				local ent = entslist[ i ]
				if ent:Health() > 0 and ent ~= ply then
					
					ent:StartIgnite( 5, 5, ply )
					
				end
				
			end
			
			ply:EmitSound( eruptsound )
			
		end,
		
	} )
	
	self:AddAbility( "blaze", {
		
		Name = "Blaze",
		Description = "Increases movement speed for 5 seconds",
		Cooldown = 10,
		Bind = "+speed",
		OnActivate = function( self, ply )
			
			ply.BZ_AbilityBlazeTime = CurTime() + 5
			
		end,
		
	} )
	
end


player_manager.RegisterClass( "player_burner", PLAYER, "player_bz" )
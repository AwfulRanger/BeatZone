DEFINE_BASECLASS( "player_bz" )



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
	self:AddPerk( "perk_armor" )
	self:AddPerk( "perk_clipsize" )
	self:AddPerk( "perk_firerate" )
	
end


player_manager.RegisterClass( "player_blaster", PLAYER, "player_bz" )
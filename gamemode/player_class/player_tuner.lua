DEFINE_BASECLASS( "player_bz" )



local PLAYER = {}


PLAYER.WalkSpeed = 320
PLAYER.RunSpeed = 320

function PLAYER:InitializePerks()
	
	BaseClass.InitializePerks( self )
	
	self:AddPerk( "perk_damage_bullet" )
	self:AddPerk( "perk_damage_critical" )
	self:AddPerk( "perk_resistspecial_crouch" )
	self:AddPerk( "perk_resistspecial_immobile" )
	
end


player_manager.RegisterClass( "player_tuner", PLAYER, "player_bz" )
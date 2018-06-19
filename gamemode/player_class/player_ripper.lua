DEFINE_BASECLASS( "player_bz" )



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


player_manager.RegisterClass( "player_ripper", PLAYER, "player_bz" )
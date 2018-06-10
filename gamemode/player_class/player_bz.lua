DEFINE_BASECLASS( "player_default" )



local PLAYER = {}


PLAYER.WalkSpeed = 320
PLAYER.RunSpeed = 320


player_manager.RegisterClass( "player_bz", PLAYER, "player_default" )
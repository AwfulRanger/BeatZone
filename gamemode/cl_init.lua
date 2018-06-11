DEFINE_BASECLASS( "gamemode_base" )

include( "shared.lua" )
include( "cl_round.lua" )
include( "cl_player.lua" )
include( "cl_hud.lua" )
include( "cl_track.lua" )



function GM:Think()
	
	self:HandleTrack()
	
end
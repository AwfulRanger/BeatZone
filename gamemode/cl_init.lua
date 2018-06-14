DEFINE_BASECLASS( "gamemode_base" )

include( "shared.lua" )
include( "cl_round.lua" )
include( "cl_player.lua" )
include( "cl_hud.lua" )
include( "cl_track.lua" )



function GM:InitPostEntity()
	
	self:ResetPlayerCharacter( LocalPlayer() )
	
end

function GM:Think()
	
	if self:GetRoundState() == ROUND_INITIALIZING then self:SetRoundState( ROUND_INTERMISSION ) end
	self:HandleTrack()
	
end
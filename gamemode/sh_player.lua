DEFINE_BASECLASS( "gamemode_base" )



function GM:GetPlayers()
	
	return team.GetPlayers( TEAM_BEAT )
	
end
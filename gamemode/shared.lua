DeriveGamemode( "base" )

DEFINE_BASECLASS( "gamemode_base" )



GM.Name = "BeatZone"
GM.Author = "AwfulRanger"
GM.TeamBased = true
GM.SecondsBetweenTeamSwitches = 1

TEAM_BEAT = 1
function GM:CreateTeams()
	
	team.SetUp( TEAM_BEAT, "Beat", Color( 0, 255, 0 ) )
	
end
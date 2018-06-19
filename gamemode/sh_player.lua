DEFINE_BASECLASS( "gamemode_base" )

include( "sh_item.lua" )
include( "sh_perk.lua" )
include( "sh_class.lua" )



function GM:GetPlayers()
	
	return team.GetPlayers( TEAM_BEAT )
	
end

function GM:ResetPlayerCharacter( ply )
	
	ply.Loadout = {}
	ply.LoadoutNames = {}
	ply.LoadoutPoints = 10
	ply.Perks = {}
	ply.PerkNames = {}
	ply.PerkNum = {}
	ply.PerkPoints = 10
	
	if SERVER then
		
		net.Start( "BZ_ResetPlayer" )
			
			net.WriteEntity( ply )
			
		net.Broadcast()
		
	end
	
end
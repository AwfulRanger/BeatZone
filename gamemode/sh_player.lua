DEFINE_BASECLASS( "gamemode_base" )

include( "sh_item.lua" )
include( "sh_perk.lua" )



function GM:GetPlayers()
	
	return team.GetPlayers( TEAM_BEAT )
	
end

function GM:SetPlayerClass( ply, class )
	
	if IsValid( ply ) ~= true then return end
	
	player_manager.SetPlayerClass( ply, class )
	player_manager.RunClass( ply, "InitializePerks" )
	
	if SERVER then
		
		net.Start( "BZ_SetClass" )
			
			net.WriteEntity( ply )
			net.WriteString( class )
			
		net.Broadcast()
		
	end
	
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
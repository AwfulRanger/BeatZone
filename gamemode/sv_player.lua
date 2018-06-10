DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "cl_player.lua" )
AddCSLuaFile( "player_class/player_bz.lua" )

include( "player_class/player_bz.lua" )



util.AddNetworkString( "BZ_RoundInfo" )


function GM:PlayerSetModel( ply )
	
	ply:SetModel( player_manager.TranslatePlayerModel( ply:GetInfo( "cl_playermodel" ) ) )
	
	ply:SetSkin( ply:GetInfoNum( "cl_playerskin", 0 ) )
	
	local groups = string.Explode( " ", ply:GetInfo( "cl_playerbodygroups" ) or "" )
	for i = 0, ply:GetNumBodyGroups() - 1 do ply:SetBodygroup( i, tonumber( groups[ i + 1 ] ) or 0 ) end
	
	ply:SetPlayerColor( Vector( ply:GetInfo( "cl_playercolor" ) ) )
	
	local wcol = Vector( ply:GetInfo( "cl_weaponcolor" ) )
	if wcol:Length() == 0 then col = Vector( 0.001, 0.001, 0.001 ) end
	ply:SetWeaponColor( wcol )
	
end

--Send info about the round to the player
function GM:PlayerSendInfo( ply )
	
	net.Start( "BZ_RoundInfo" )
		
		net.WriteInt( self:GetRoundState(), 3 )
		
	net.Send( ply )
	
end

function GM:PlayerInitialSpawn( ply )
	
	self:PlayerSendInfo( ply )
	
	BaseClass.PlayerInitialSpawn( self, ply )
	
end

function GM:GetFallDamage( ply, speed )
	
	return 0
	
end

function GM:PlayerCanJoinTeam( ply, teamid )
	
	local time = self.SecondsBetweenTeamSwitches or 1
	if ply.LastTeamSwitch ~= nil and RealTime() < ply.LastTeamSwitch + time then return false end
	
	if ply:Team() == teamid then return false end
	
	return true
	
end
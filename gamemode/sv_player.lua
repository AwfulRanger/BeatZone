DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "cl_player.lua" )



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
	
	BaseClass.PlayerInitialSpawn( self, ply )
	
	self:PlayerSendInfo( ply )
	
end
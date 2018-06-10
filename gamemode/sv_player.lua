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



----
--Get player spawn points
----
GM.PlayerSpawns = GM.PlayerSpawns or {}

local bzplayerspawn = "bz_playerspawn"
GM.BZPlayerSpawnFound = false --don't add other spawns if this map has our spawns
local spawnclass = {
	
	[ "info_player_spawn" ] = true,
	[ "info_player_deathmatch" ] = true,
	[ "info_player_combine" ] = true,
	[ "info_player_rebel" ] = true,
	[ "info_player_counterterrorist" ] = true,
	[ "info_player_terrorist" ] = true,
	[ "info_player_axis" ] = true,
	[ "info_player_allies" ] = true,
	[ "gmod_player_start" ] = true,
	[ "ins_spawnpoint" ] = true,
	[ "aoc_spawnpoint" ] = true,
	[ "dys_spawn_point" ] = true,
	[ "info_player_pirate" ] = true,
	[ "info_player_viking" ] = true,
	[ "info_player_knight" ] = true,
	[ "diprip_start_team_blue" ] = true,
	[ "diprip_start_team_red" ] = true,
	[ "info_player_red" ] = true,
	[ "info_player_blue" ] = true,
	[ "info_player_coop" ] = true,
	[ "info_player_human" ] = true,
	[ "info_player_zombie" ] = true,
	[ "info_player_zombiemaster" ] = true,
	[ "info_survivor_position" ] = true,
	
}
local spawnkeyvalue = {
	
	[ "info_player_teamspawn" ] = { key = "TeamNum", value = "2" }
	
}
function GM:ShouldAddPlayerSpawn( ent, key, value )
	
	local class = ent:GetClass()
	if class == bzplayerspawn then
		
		if self.BZPlayerSpawnFound ~= true then
			
			self.PlayerSpawns = {}
			self.BZPlayerSpawnFound = true
			
		end
		
		table.insert( self.PlayerSpawns, ent )
		
	elseif self.BZPlayerSpawnFound ~= true then
		
		local kv = spawnkeyvalue[ class ]
		if ( kv ~= nil and key == kv.key and value == kv.value ) or spawnclass[ class ] == true then table.insert( self.PlayerSpawns, ent ) end
		
	end
	
end

function GM:PlayerSelectSpawn( ply )
	
	local count = #self.PlayerSpawns
	if count <= 0 then Msg( "[PlayerSelectSpawn] Error! No spawn points!\n" ) return end
	
	local tryspawns = {}
	for i = 1, #self.PlayerSpawns do tryspawns[ i ] = self.PlayerSpawns[ i ] end
	
	for i = 1, #tryspawns do
		
		local index = math.random( #tryspawns )
		local spawn = tryspawns[ index ]
		
		if IsValid( spawn ) == true and hook.Run( "IsSpawnpointSuitable", ply, spawn, i == count ) == true then return spawn end
		
		table.remove( tryspawns, index )
		
	end
	
end
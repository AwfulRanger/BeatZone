DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "sh_item.lua" )
AddCSLuaFile( "sh_perk.lua" )
AddCSLuaFile( "sh_class.lua" )
AddCSLuaFile( "sh_ability.lua" )
AddCSLuaFile( "sh_player.lua" )
AddCSLuaFile( "cl_player.lua" )

include( "sh_player.lua" )



util.AddNetworkString( "BZ_FullUpdate" )
util.AddNetworkString( "BZ_SetClass" )
util.AddNetworkString( "BZ_ResetPlayer" )
util.AddNetworkString( "BZ_BuyItem" )
util.AddNetworkString( "BZ_SellItem" )
util.AddNetworkString( "BZ_BuyPerk" )
util.AddNetworkString( "BZ_SellPerk" )
util.AddNetworkString( "BZ_ActivateAbility" )
util.AddNetworkString( "BZ_PlayerDeath" )

net.Receive( "BZ_FullUpdate", function( len, ply )
	
	if ply.FullyUpdated == true then return end
	
	ply.FullyUpdated = true
	
	print( "Updating " .. ply:Nick() )
	gmod.GetGamemode():PlayerSendInfo( ply )
	
end )

net.Receive( "BZ_SetClass", function( len, ply )
	
	local gm = gmod.GetGamemode()
	local class = gm:GetClass( net.ReadUInt( 32 ) )
	if class == nil or player_manager.GetPlayerClass( ply ) == class then return end
	
	if gm:CanChangeClass( ply, class ) == true then gm:SetPlayerClass( ply, class, true ) end
	
end )

net.Receive( "BZ_ResetPlayer", function( len, ply )
	
	local gm = gmod.GetGamemode()
	
	if gm:CanChangeClass( ply, player_manager.GetPlayerClass( ply ) ) == true then gm:ResetPlayerCharacter( ply, true ) end
	
end )

net.Receive( "BZ_BuyItem", function( len, ply )
	
	local gm = gmod.GetGamemode()
	local item = gm:GetItem( net.ReadUInt( 32 ) )
	if item == nil then return end
	
	if gm:PlayerCanBuyItem( ply, item ) == true then gm:PlayerBuyItem( ply, item, true ) end
	
end )

net.Receive( "BZ_SellItem", function( len, ply )
	
	local gm = gmod.GetGamemode()
	local item = gm:GetItem( net.ReadUInt( 32 ) )
	if item == nil then return end
	
	if gm:PlayerCanSellItem( ply, item ) == true then gm:PlayerSellItem( ply, item, true ) end
	
end )

net.Receive( "BZ_BuyPerk", function( len, ply )
	
	local gm = gmod.GetGamemode()
	local perk = gm:GetPerk( net.ReadUInt( 32 ) )
	if perk == nil then return end
	
	if gm:PlayerCanBuyPerk( ply, perk ) == true then gm:PlayerBuyPerk( ply, perk, true ) end
	
end )

net.Receive( "BZ_SellPerk", function( len, ply )
	
	local gm = gmod.GetGamemode()
	local perk = gm:GetPerk( net.ReadUInt( 32 ) )
	if perk == nil then return end
	
	if gm:PlayerCanSellPerk( ply, perk ) == true then gm:PlayerSellPerk( ply, perk, true ) end
	
end )

net.Receive( "BZ_ActivateAbility", function( len, ply )
	
	local gm = gmod.GetGamemode()
	local ability = gm:PlayerGetAbility( ply, net.ReadUInt( 32 ) )
	if ability == nil then return end
	
	if gm:PlayerCanActivateAbility( ply, ability ) == true then gm:PlayerActivateAbility( ply, ability ) end
	
end )



function GM:PlayerLoadout( ply )
	
	ply:StripWeapons()
	ply:StripAmmo()
	ply:Give( "weapon_crowbar", true )
	local pistol = ply:Give( "weapon_pistol", true )
	pistol:SetClip1( pistol:GetMaxClip1() )
	
	for i = 1, self:PlayerGetItemCount( ply ) do
		
		local item = self:PlayerGetItem( ply, i )
		if item ~= nil then item:OnBuy( ply, self ) end
		
	end
	
	for i = 1, self:GetAmmoTypes() do ply:SetAmmo( self:GetPlayerMaxAmmo( ply, i ), i ) end
	
	self:SetPlayerHealth( ply )
	self:SetPlayerShield( ply )
	
end

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

function GM:PlayerSetHandsModel( ply, ent )
	
	local hands = player_manager.TranslatePlayerHands( ply:GetInfo( "cl_playermodel" ) )
	if hands ~= nil then
		
		ent:SetModel( hands.model )
		ent:SetSkin( hands.skin )
		ent:SetBodyGroups( hands.body )
		
	end
	
end

--Send info about the round to the player
function GM:PlayerSendInfo( ply )
	
	--send round state
	net.Start( "BZ_RoundState" )
		
		net.WriteInt( self:GetRoundState(), 3 )
		
	net.Send( ply )
	
	--send ready players
	for i = 1, self.ReadyPlayers.Count do
		
		net.Start( "BZ_PlayerReady" )
			
			local ply = self.ReadyPlayers.Players[ i ]
			net.WriteEntity( ply )
			net.WriteBool( self:PlayerIsReady( ply ) )
			
		net.Send( ply )
		
	end
	
	--send ready time
	if self.FirstReadyTime ~= nil then
		
		net.Start( "BZ_FirstReadyTime" )
			
			net.WriteBool( true )
			net.WriteFloat( self.FirstReadyTime )
			
		net.Send( ply )
		
	end
	
	--send round
	net.Start( "BZ_SetRound" )
		
		net.WriteUInt( self:GetRound(), 32 )
		
	net.Send( ply )
	
	--send track
	local track = self.CurrentTrack
	if track ~= nil and track.Track ~= nil then
		
		net.Start( "BZ_PlayTrack" )
			
			net.WriteUInt( track.Track.Index, 32 )
			net.WriteFloat( track.Time or CurTime() )
			
		net.Send( ply )
		
	end
	
	--send player characters
	local plys = player.GetAll()
	for i = 1, #plys do
		
		local ply_ = plys[ i ]
		
		net.Start( "BZ_ResetPlayer" )
			
			net.WriteEntity( ply_ )
			
		net.Send( ply )
		
		for i_ = 1, self:PlayerGetItemCount( ply_ ) do
			
			net.Start( "BZ_BuyItem" )
				
				net.WriteEntity( ply_ )
				net.WriteUInt( self:PlayerGetItem( ply_, i_ ).Index, 32 )
				
			net.Send( ply )
			
		end
		
		for i_ = 1, self:PlayerGetPerkCount( ply_ ) do
			
			net.Start( "BZ_BuyPerk" )
				
				local perk = self:PlayerGetPerk( ply_, i_ )
				
				net.WriteEntity( ply_ )
				net.WriteUInt( perk.Index, 32 )
				net.WriteUInt( self:PlayerGetPerkNum( ply_, perk ), 32 )
				
			net.Send( ply )
			
		end
		
	end
	
	--send boss
	net.Start( "BZ_SetBoss" )
		
		local boss = self.EnemyBoss
		local set = boss ~= nil
		net.WriteBool( set )
		if set == true then net.WriteEntity( boss ) end
		
	net.Send( ply )
	
	--send vote
	local vote = self:GetVote()
	if vote ~= nil then
		
		net.Start( "BZ_StartVote" )
			
			net.WriteUInt( vote.Index, 32 )
			net.WriteEntity( self.VotePlayer )
			vote:NetSend( self.VoteOptions )
			net.WriteFloat( self.VoteTime )
			
		net.Send( ply )
		
	end
	
	--send voting players
	for i = 1, self.VotingPlayers.Count do
		
		local vply = self.VotingPlayers.Players[ i ]
		local vote = self.VotingPlayers.PlayerVotes[ vply ]
		
		net.Start( "BZ_PlayerVote" )
			
			net.WriteEntity( vply )
			net.WriteBool( vote == nil )
			if vote ~= nil then net.WriteBool( vote ) end
			
		net.Send( ply )
		
	end
	
end

function GM:PlayerInitialSpawn( ply )
	
	self:ResetPlayerCharacter( ply )
	self:PlayerSendInfo( ply )
	
	ply:SetTeam( TEAM_SPECTATOR )
	self:OnPlayerChangedTeam( ply, TEAM_UNASSIGNED, TEAM_SPECTATOR )
	
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

function GM:OnPlayerChangedTeam( ply, old, new )
	
	self:ResetPlayerCharacter( ply )
	
	PrintMessage( HUD_PRINTTALK, string.format( "%s joined '%s'", ply:Nick(), team.GetName( new ) ) )
	
	if new == TEAM_SPECTATOR then
		
		player_manager.ClearPlayerClass( ply )
		
		local pos = ply:EyePos()
		local ang = ply:EyeAngles()
		
		ply:Spawn()
		ply:SetPos( pos )
		ply:SetEyeAngles( ang )
		
		return
		
	end
	
	self:SetPlayerClass( ply, "player_tuner" )
	
	local state = self:GetRoundState()
	if state ~= ROUND_ONGOING and state ~= ROUND_ENDING then ply:Spawn() end
	
end



----
--Get player spawn points
----
GM.PlayerSpawns = GM.PlayerSpawns or {}

local bzplayerspawn = "bz_playerspawn"
GM.BZPlayerSpawnFound = false --don't add other spawns if this map has our spawns
local spawnclass = {
	
	[ "info_player_start" ] = true,
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

local keys = { IN_ATTACK, IN_ATTACK2, IN_JUMP }
function GM:PlayerDeathThink( ply )
	
	local state = self:GetRoundState()
	if state == ROUND_ONGOING or state == ROUND_ENDING then return false end
	
	if ply:Team() == TEAM_SPECTATOR or ply:IsBot() == true then ply:Spawn() return end
	for i = 1, #keys do if ply:KeyPressed( keys[ i ] ) == true then ply:Spawn() return end end
	
end

function GM:PlayerDeath( ply, inflictor, attacker )
	
	net.Start( "BZ_PlayerDeath" )
		
		net.WriteEntity( ply )
		net.WriteEntity( attacker )
		
	net.Broadcast()
	
	BaseClass.PlayerDeath( self, ply, inflictor, attacker )
	
end



local obsmode = {
	
	OBS_MODE_ROAMING,
	OBS_MODE_IN_EYE,
	OBS_MODE_CHASE,
	
}
local function cycleobstarget( gm, ply, num )
	
	local players = gm:GetPlayers()
	local targets = {}
	for i = 1, #players do
		
		local ply = players[ i ]
		if ply:Alive() == true then table.insert( targets, ply ) end
		
	end
	local targetsnum = #targets
	
	if num == nil then num = 1 end
	if ply.BZ_OBSTarget == nil then ply.BZ_OBSTarget = 0 end
	ply.BZ_OBSTarget = ply.BZ_OBSTarget + num
	if targetsnum > 0 then
		
		if ply.BZ_OBSTarget > targetsnum then ply.BZ_OBSTarget = 1 end
		if ply.BZ_OBSTarget < 1 then ply.BZ_OBSTarget = targetsnum end
		
	end
	
	local target = targets[ ply.BZ_OBSTarget ]
	if IsValid( target ) == true then
		
		ply:SpectateEntity( target )
		ply:SetupHands( target )
		
	end
	
end
local function cycleobsmode( gm, ply )
	
	if ply.BZ_OBSMode == nil then ply.BZ_OBSMode = 0 end
	ply.BZ_OBSMode = ply.BZ_OBSMode + 1
	if ply.BZ_OBSMode > #obsmode then ply.BZ_OBSMode = 1 end
	
	ply:Spectate( obsmode[ ply.BZ_OBSMode ] )
	cycleobstarget( gm, ply, 0 )
	
end
function GM:KeyPress( ply, key )
	
	if ply:Alive() == true and ply:Team() ~= TEAM_SPECTATOR then return end
	
	if key == IN_JUMP then cycleobsmode( self, ply ) end
	if key == IN_ATTACK then cycleobstarget( self, ply, 1 ) end
	if key == IN_ATTACK2 then cycleobstarget( self, ply, -1 ) end
	
end

function GM:OnDamagedByExplosion( ply, dmg )
end

function GM:PlayerShouldTakeDamage( ply, attacker )
	
	if ply ~= attacker and attacker:IsPlayer() == true and GetConVar( "bz_friendlyfire" ):GetInt() < 2 then return false end
	
	return BaseClass.PlayerShouldTakeDamage( ply, attack )
	
end



local function domult( gm, mult, ply, perk )
	
	if isstring( perk ) == true then perk = gm:GetPerk( perk ) end
	if gm:PlayerHasPerk( ply, perk ) ~= true then return mult end
	
	return mult * ( 1 + gm:GetPerkTotal( ply, perk ) )
	
end
function GM:SetPlayerHealth( ply, m )
	
	local mult = m or 1
	if m == nil then
		
		mult = domult( self, mult, ply, "perk_health" )
		
	end
	
	local health = 10000 * mult
	
	ply:SetMaxHealth( health )
	ply:SetHealth( health )
	
end
function GM:SetPlayerShield( ply, m )
	
	local mult = m or 1
	if m == nil then
		
		mult = domult( self, mult, ply, "perk_shield" )
		
	end
	
	local shield = 10000 * mult
	
	ply:SetMaxShield( shield )
	ply:SetShield( shield )
	
end
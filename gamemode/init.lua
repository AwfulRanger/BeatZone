DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_editplayer.lua" )

include( "shared.lua" )
include( "sv_round.lua" )
include( "sv_player.lua" )
include( "sv_enemy.lua" )
include( "sv_track.lua" )



util.AddNetworkString( "BZ_UISound" )
util.AddNetworkString( "BZ_EntityDamaged" )



----
--Keys for showing menus (F1-F4)
----
util.AddNetworkString( "BZ_ShowMenu" )

local function sendbutton( n, ply )
	
	net.Start( "BZ_ShowMenu" )
		
		net.WriteUInt( n, 2 )
		
	net.Send( ply )
	
end

function GM:ShowHelp( ply ) sendbutton( 0, ply ) end
function GM:ShowTeam( ply ) sendbutton( 1, ply ) end
function GM:ShowSpare1( ply ) sendbutton( 2, ply ) end
function GM:ShowSpare2( ply ) sendbutton( 3, ply ) end



function GM:Initialize()
	
	self:StartIntermission()
	
end

function GM:Think()
	
	self:HandleRound()
	self:HandleTrack()
	
	local plys = player.GetAll()
	for i = 1, #plys do self:HandlePlayerShield( plys[ i ] ) end
	
end

function GM:OnEntityCreated( ent )
	
	hook.Run( "ShouldAddEnemySpawn", ent )
	hook.Run( "ShouldAddPlayerSpawn", ent )
	
end

function GM:EntityKeyValue( ent, key, value )
	
	hook.Run( "ShouldAddEnemySpawn", ent, key, value )
	hook.Run( "ShouldAddPlayerSpawn", ent, key, value )
	
end

local resperks = {
	
	[ DMG_BULLET ] = "perk_resist_bullet",
	[ DMG_BLAST ] = "perk_resist_blast",
	[ DMG_BURN ] = "perk_resist_fire",
	[ DMG_CLUB ] = "perk_resist_melee",
	
}
local function dores( gm, dmg, ply, perk )
	
	if isstring( perk ) == true then perk = gm:GetPerk( perk ) end
	if gm:PlayerHasPerk( ply, perk ) ~= true then return end
	dmg:ScaleDamage( 1 - gm:GetPerkTotal( ply, perk ) )
	
end
local dmgperks = {
	
	[ DMG_BULLET ] = "perk_damage_bullet",
	[ DMG_BLAST ] = "perk_damage_blast",
	[ DMG_BURN ] = "perk_damage_fire",
	[ DMG_CLUB ] = "perk_damage_melee",
	
}
local function dodmg( gm, dmg, ply, perk )
	
	if isstring( perk ) == true then perk = gm:GetPerk( perk ) end
	if gm:PlayerHasPerk( ply, perk ) ~= true then return end
	dmg:ScaleDamage( 1 + gm:GetPerkTotal( ply, perk ) )
	
end
function GM:EntityTakeDamage( ent, dmg )
	
	if ent:IsPlayer() == true then
		
		dores( self, dmg, ent, "perk_resist_all" )
		local resperk = resperks[ dmg:GetDamageType() ]
		if resperk ~= nil then dores( self, dmg, ent, resperk ) end
		
		if ent:Crouching() == true then dores( self, dmg, ent, "perk_resistspecial_crouch" ) end
		if ent:GetVelocity():LengthSqr() == 0 then dores( self, dmg, ent, "perk_resistspecial_immobile" ) end
		if ent.LastEnemyKilled ~= nil and CurTime() < ent.LastEnemyKilled + 1 then dores( self, dmg, ent, "perk_resistspecial_enemykilled" ) end
		
	end
	
	local attacker = dmg:GetAttacker()
	if IsValid( attacker ) == true and attacker:IsPlayer() ~= true then attacker = attacker:GetOwner() end
	if attacker:IsPlayer() == true then
		
		dodmg( self, dmg, attacker, "perk_damage_all" )
		local dmgperk = dmgperks[ dmg:GetDamageType() ]
		if dmgperk ~= nil then dodmg( self, dmg, attacker, dmgperk ) end
		
		local crit = self:GetPlayerCrit( attacker )
		if crit == true then
			
			dmg:ScaleDamage( 2 )
			dodmg( self, dmg, attacker, "perk_damage_critical" )
			
		end
		
		if ent:IsPlayer() ~= true or self:PlayerShouldTakeDamage( ent, attacker ) == true then
			
			net.Start( "BZ_EntityDamaged" )
				
				net.WriteEntity( ent )
				net.WriteInt( dmg:GetDamage(), 32 )
				net.WriteVector( dmg:GetDamagePosition() )
				net.WriteBool( crit )
				
			net.Send( attacker )
			
		elseif GetConVar( "bz_friendlyfire" ):GetInt() == 1 and ent:GetShield() > 0 then
			
			net.Start( "BZ_EntityDamaged" )
				
				net.WriteEntity( ent )
				net.WriteInt( math.min( dmg:GetDamage(), ent:GetShield() ), 32 )
				net.WriteVector( dmg:GetDamagePosition() )
				net.WriteBool( crit )
				
			net.Send( attacker )
			
		end
		
	end
	
	--shield damage
	if ent:IsPlayer() == true and ( attacker:IsPlayer() ~= true or GetConVar( "bz_friendlyfire" ):GetInt() > 0 ) then
		
		ent:SetDamagedTime( CurTime() )
		
		local damage = dmg:GetDamage()
		local shield = ent:GetShield()
		local block = math.min( damage, shield )
		if block > 0 then
			
			dmg:SetDamage( damage - block )
			ent:SetShield( shield - block )
			
		end
		
	end
	
end
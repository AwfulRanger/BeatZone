DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "sh_config.lua" )
AddCSLuaFile( "cl_settings.lua" )
AddCSLuaFile( "sh_mapcustom.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_help.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "hud/hud.lua" )
AddCSLuaFile( "hud/damagenumber.lua" )
AddCSLuaFile( "hud/notification.lua" )
AddCSLuaFile( "hud/targetid.lua" )
AddCSLuaFile( "hud/gamemenu.lua" )
AddCSLuaFile( "hud/gamemenu_help.lua" )
AddCSLuaFile( "hud/gamemenu_character.lua" )
AddCSLuaFile( "hud/gamemenu_vote.lua" )
AddCSLuaFile( "hud/gamemenu_settings.lua" )
AddCSLuaFile( "hud/editplayer.lua" )
AddCSLuaFile( "hud/contextmenu.lua" )
AddCSLuaFile( "hud/scoreboard.lua" )

include( "shared.lua" )
include( "sv_round.lua" )
include( "sv_player.lua" )
include( "sv_enemy.lua" )
include( "sv_track.lua" )
include( "sv_vote.lua" )



util.AddNetworkString( "BZ_UISound" )
util.AddNetworkString( "BZ_EntityDamaged" )
util.AddNetworkString( "BZ_ItemPickup" )



GM.IgnitedEntity = {}
GM.IgnitedEntitySeq = {}
GM.BleedingEntity = {}
GM.BleedingEntitySeq = {}

local function tblremove( seq, tbl, key )
	
	table.remove( seq, key )
	for _, v in pairs( tbl ) do if v > key then tbl[ _ ] = v - 1 end end
	
end

function GM:HandleEntityIgnite()
	
	local remove = {}
	
	for i = 1, #self.IgnitedEntitySeq do
		
		local ent = self.IgnitedEntitySeq[ i ]
		
		if IsValid( ent ) ~= true then
			
			table.insert( remove, i )
			
		else
			
			local lastignite = ent:GetNW2Float( "BZ_LastIgnite", -1 )
			if lastignite == -1 then
				
				lastignite = CurTime()
				ent:SetNW2Float( "BZ_LastIgnite", lastignite )
				
			end
			
			if ent.BZ_CurIgniteDamage == nil then ent.BZ_CurIgniteDamage = 0 end
			if ent.BZ_MaxIgniteDamage == nil then ent.BZ_MaxIgniteDamage = 0 end
			
			if ent:IsIgnited() ~= true then
				
				if ent.BZ_CurIgniteDamage < ent.BZ_MaxIgniteDamage then
					
					local attacker = ent:GetIgniteAttacker()
					if IsValid( attacker ) ~= true then attacker = ent end
					
					local dmg = DamageInfo()
					dmg:SetDamage( ent.BZ_MaxIgniteDamage - ent.BZ_CurIgniteDamage )
					dmg:SetDamageType( DMG_BURN )
					dmg:SetAttacker( attacker )
					dmg:SetDamagePosition( ent:GetPos() + ent:OBBCenter() )
					
					ent:TakeDamageInfo( dmg )
					
				end
				
				ent:StopIgnite()
				self.IgnitedEntity[ ent ] = nil
				table.insert( remove, i )
				
			else
				
				local idamage = ent:GetIgniteDamage()
				local damage = idamage * ( CurTime() - lastignite )
				local fdamage = math.floor( damage )
				
				if fdamage > 0 then
					
					ent:SetNW2Float( "BZ_LastIgnite", CurTime() - ( damage - fdamage ) / idamage )
					ent.BZ_CurIgniteDamage = ent.BZ_CurIgniteDamage + fdamage
					
					local attacker = ent:GetIgniteAttacker()
					if IsValid( attacker ) ~= true then attacker = ent end
					
					local dmg = DamageInfo()
					dmg:SetDamage( fdamage )
					dmg:SetDamageType( DMG_BURN )
					dmg:SetAttacker( attacker )
					dmg:SetDamagePosition( ent:GetPos() + ent:OBBCenter() )
					
					ent:TakeDamageInfo( dmg )
					
				end
				
			end
			
		end
		
	end
	
	for i = 1, #remove do tblremove( self.IgnitedEntitySeq, self.IgnitedEntity, remove[ i ] ) end
	
end

function GM:HandleEntityBleed()
	
	local remove = {}
	
	for i = 1, #self.BleedingEntitySeq do
		
		local ent = self.BleedingEntitySeq[ i ]
		
		if IsValid( ent ) ~= true then
			
			table.insert( remove, i )
			
		else
			
			local lastbleed = ent:GetNW2Float( "BZ_LastBleed", -1 )
			if lastbleed == -1 then
				
				lastbleed = CurTime()
				ent:SetNW2Float( "BZ_LastBleed", lastbleed )
				
			end
			
			if ent.BZ_CurBleedDamage == nil then ent.BZ_CurBleedDamage = 0 end
			if ent.BZ_MaxBleedDamage == nil then ent.BZ_MaxBleedDamage = 0 end
			
			if ent:IsBleeding() ~= true then
				
				if ent.BZ_CurBleedDamage < ent.BZ_MaxBleedDamage then
					
					local attacker = ent:GetBleedAttacker()
					if IsValid( attacker ) ~= true then attacker = ent end
					
					local dmg = DamageInfo()
					dmg:SetDamage( ent.BZ_MaxBleedDamage - ent.BZ_CurBleedDamage )
					dmg:SetDamageType( DMG_SLASH )
					dmg:SetAttacker( attacker )
					dmg:SetDamagePosition( ent:GetPos() + ent:OBBCenter() )
					
					ent:TakeDamageInfo( dmg )
					
				end
				
				ent:StopBleed()
				self.BleedingEntity[ ent ] = nil
				table.insert( remove, i )
				
			else
				
				local bdamage = ent:GetBleedDamage()
				local damage = bdamage * ( CurTime() - lastbleed )
				local fdamage = math.floor( damage )
				
				if fdamage > 0 then
					
					ent:SetNW2Float( "BZ_LastBleed", CurTime() - ( damage - fdamage ) / bdamage )
					ent.BZ_CurBleedDamage = ent.BZ_CurBleedDamage + fdamage
					
					local attacker = ent:GetBleedAttacker()
					if IsValid( attacker ) ~= true then attacker = ent end
					
					local dmg = DamageInfo()
					dmg:SetDamage( fdamage )
					dmg:SetDamageType( DMG_SLASH )
					dmg:SetAttacker( attacker )
					dmg:SetDamagePosition( ent:GetPos() + ent:OBBCenter() )
					
					ent:TakeDamageInfo( dmg )
					
				end
				
			end
			
		end
		
	end
	
	for i = 1, #remove do tblremove( self.BleedingEntitySeq, self.BleedingEntity, remove[ i ] ) end
	
end



local meta = FindMetaTable( "Entity" )

function meta:StartIgnite( len, dmg, attacker )
	
	self:SetNW2Float( "BZ_IgniteTime", CurTime() + ( len or 0 ) )
	self:SetNW2Int( "BZ_IgniteDamage", math.floor( dmg or 0 ) )
	self:SetNW2Entity( "BZ_BleedAttacker", attacker )
	self.BZ_CurIgniteDamage = 0
	self.BZ_MaxIgniteDamage = math.floor( len * dmg )
	
	local gm = gmod.GetGamemode()
	
	local id = gm.IgnitedEntity[ self ]
	if id == nil then
		
		id = table.insert( gm.IgnitedEntitySeq, self )
		gm.IgnitedEntity[ self ] = id
		
	end
	
end
function meta:StopIgnite()
	
	self:SetNW2Float( "BZ_IgniteTime", -1 )
	self:SetNW2Float( "BZ_LastIgnite", -1 )
	self.BZ_CurIgniteDamage = nil
	self.BZ_MaxIgniteDamage = nil
	
	local gm = gmod.GetGamemode()
	
	local id = gm.IgnitedEntity[ self ]
	if id ~= nil then
		
		gm.IgnitedEntity[ self ] = nil
		tblremove( gm.IgnitedEntitySeq, gm.IgnitedEntity, id )
		
	end
	
end

function meta:StartBleed( len, dmg, attacker )
	
	self:SetNW2Float( "BZ_BleedTime", CurTime() + ( len or 0 ) )
	self:SetNW2Int( "BZ_BleedDamage", math.floor( dmg or 0 ) )
	self:SetNW2Entity( "BZ_BleedAttacker", attacker )
	self.BZ_CurBleedDamage = 0
	self.BZ_MaxBleedDamage = math.floor( len * dmg )
	
	local gm = gmod.GetGamemode()
	
	local id = gm.BleedingEntity[ self ]
	if id == nil then
		
		id = table.insert( gm.BleedingEntitySeq, self )
		gm.BleedingEntity[ self ] = id
		
	end
	
end
function meta:StopBleed()
	
	self:SetNW2Float( "BZ_BleedTime", -1 )
	self:SetNW2Float( "BZ_LastBleed", -1 )
	self.BZ_CurBleedDamage = nil
	self.BZ_MaxBleedDamage = nil
	
	local gm = gmod.GetGamemode()
	
	local id = gm.BleedingEntity[ self ]
	if id ~= nil then
		
		gm.BleedingEntity[ self ] = nil
		tblremove( gm.BleedingEntitySeq, gm.BleedingEntity, id )
		
	end
	
end



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
	
	self:HandleEntityIgnite()
	self:HandleEntityBleed()
	
	local plys = player.GetAll()
	for i = 1, #plys do self:HandlePlayer( plys[ i ] ) end
	
	self:HandleVote()
	
end

function GM:OnEntityCreated( ent )
	
	hook.Run( "ShouldAddEnemySpawn", ent )
	hook.Run( "ShouldAddPlayerSpawn", ent )
	
end

function GM:EntityKeyValue( ent, key, value )
	
	hook.Run( "ShouldAddEnemySpawn", ent, key, value )
	hook.Run( "ShouldAddPlayerSpawn", ent, key, value )
	
end



local dmgtypes = {
	
	DMG_BULLET,
	DMG_BLAST,
	DMG_BURN,
	DMG_CLUB,
	
}
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
local function doadd( gm, add, ply, perk )
	
	if isstring( perk ) == true then perk = gm:GetPerk( perk ) end
	if gm:PlayerHasPerk( ply, perk ) ~= true then return add end
	
	return add + gm:GetPerkTotal( ply, perk )
	
end
function GM:EntityTakeDamage( ent, dmg )
	
	local attacker = dmg:GetAttacker()
	if IsValid( attacker ) == true and attacker:IsPlayer() ~= true then attacker = attacker:GetOwner() end
	
	if IsValid( attacker ) == true and attacker.BZ_AbilityFragTime ~= nil and CurTime() < attacker.BZ_AbilityFragTime then
		
		dmg:SetDamageType( bit.bor( dmg:GetDamageType(), DMG_BLAST ) )
		
	end
	
	if ent:IsPlayer() == true or ent.IsBZEnemy == true then dmg:ScaleDamage( 100 ) end
	
	dmg:AddDamage( dmg:GetDamageBonus() )
	
	if ent:IsPlayer() == true then
		
		dores( self, dmg, ent, "perk_resist_all" )
		for i = 1, #dmgtypes do
			
			local d = dmgtypes[ i ]
			if dmg:IsDamageType( d ) == true and resperks[ d ] ~= nil then dores( self, dmg, ent, resperks[ d ] ) end
			
		end
		
		if ent:Crouching() == true then dores( self, dmg, ent, "perk_resistspecial_crouch" ) end
		if ent:GetVelocity():LengthSqr() == 0 then dores( self, dmg, ent, "perk_resistspecial_immobile" ) end
		if CurTime() < ent:GetEnemyKilledTime() + 1 then dores( self, dmg, ent, "perk_resistspecial_enemykilled" ) end
		
	end
	
	if attacker:IsPlayer() == true then
		
		dodmg( self, dmg, attacker, "perk_damage_all" )
		for i = 1, #dmgtypes do
			
			local d = dmgtypes[ i ]
			if dmg:IsDamageType( d ) == true and dmgperks[ d ] ~= nil then dodmg( self, dmg, attacker, dmgperks[ d ] ) end
			
		end
		
		local crit = self:GetPlayerCrit( attacker, dmg )
		if crit == true then
			
			dmg:ScaleDamage( 2 )
			dodmg( self, dmg, attacker, "perk_damage_critical" )
			if attacker:Crouching() == true then dodmg( self, dmg, attacker, "perk_damagespecial_criticalcrouch" ) end
			
		end
		
		if ent.IsBZEnemy == true then
			
			local dmgtype = dmg:GetDamageType()
			
			if dmgtype ~= DMG_BURN then
				
				local ignitetime = 0
				ignitetime = doadd( self, ignitetime, attacker, "perk_enemyignite" )
				if ignitetime > 0 then ent:StartIgnite( ignitetime, 5, attacker ) end
				
			end
			
			if dmgtype ~= DMG_SLASH then
				
				local bleedtime = 0
				bleedtime = doadd( self, bleedtime, attacker, "perk_enemybleed" )
				if bleedtime > 0 then ent:StartBleed( bleedtime, 5, attacker ) end
				
			end
			
		end
		
		if ent ~= attacker and ent:Health() > 0 then
			
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
		
		if attacker:IsPlayer() ~= true or GetConVar( "bz_friendlyfire" ):GetInt() > 1 then
			
			--mess with damage so force isn't so high
			local olddamage = math.Round( dmg:GetDamage() * 0.01 )
			ent:SetHealth( ent:Health() - dmg:GetDamage() + olddamage )
			dmg:SetDamage( olddamage )
			
		end
		
	elseif ent.IsBZEnemy == true then
		
		--mess with damage so force isn't so high
		local olddamage = math.Round( dmg:GetDamage() * 0.01 )
		ent:SetHealth( ent:Health() - dmg:GetDamage() + olddamage )
		dmg:SetDamage( olddamage )
		
	end
	
end
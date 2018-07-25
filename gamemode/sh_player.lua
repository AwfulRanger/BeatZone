DEFINE_BASECLASS( "gamemode_base" )

include( "sh_item.lua" )
include( "sh_perk.lua" )
include( "sh_class.lua" )
include( "sh_ability.lua" )



local meta = FindMetaTable( "Player" )

function meta:SetEnemyKilledTime( time ) self:SetNW2Float( "BZ_EnemyKilledTime", time ) end
function meta:GetEnemyKilledTime() return self:GetNW2Float( "BZ_EnemyKilledTime", -1 ) end

function meta:SetDamagedTime( time ) self:SetNW2Float( "BZ_DamagedTime", time ) end
function meta:GetDamagedTime() return self:GetNW2Float( "BZ_DamagedTime" ) end

function meta:SetHealthTime( time ) self:SetNW2Float( "BZ_HealthTime", time ) end
function meta:GetHealthTime() return self:GetNW2Float( "BZ_HealthTime" ) end

function meta:SetShieldTime( time ) self:SetNW2Float( "BZ_ShieldTime", time ) end
function meta:GetShieldTime() return self:GetNW2Float( "BZ_ShieldTime" ) end

function meta:SetShield( shield ) self:SetNW2Int( "BZ_Shield", math.floor( shield ) ) end
function meta:GetShield() return self:GetNW2Int( "BZ_Shield" ) end

function meta:SetMaxShield( max ) self:SetNW2Int( "BZ_MaxShield", math.floor( max ) ) end
function meta:GetMaxShield() return self:GetNW2Int( "BZ_MaxShield", 100 ) end



function GM:HandlePlayer( ply )
	
	self:HandlePlayerHealth( ply )
	self:HandlePlayerShield( ply )
	self:HandlePlayerAttackSpeed( ply )
	
end

local function doadd( gm, add, ply, perk )
	
	if isstring( perk ) == true then perk = gm:GetPerk( perk ) end
	if gm:PlayerHasPerk( ply, perk ) ~= true then return add end
	
	return add + gm:GetPerkTotal( ply, perk )
	
end

function GM:HandlePlayerHealth( ply )
	
	local health = ply:Health()
	local max = ply:GetMaxHealth()
	
	local hpregen = 0
	hpregen = doadd( self, hpregen, ply, "perk_healthregen" )
	if CurTime() < ply:GetEnemyKilledTime() + 1 then hpregen = doadd( self, hpregen, ply, "perk_healthregenspecial_enemykilled" ) end
	
	if ply:Alive() ~= true or ply:Team() ~= TEAM_BEAT then
		
		if health ~= 0 then ply:SetHealth( 0 ) end
		ply:SetHealthTime( CurTime() )
		
	elseif health < max and hpregen > 0 then
		
		local regen = math.floor( ( CurTime() - ply:GetHealthTime() ) * hpregen )
		if regen > 0 then
			
			ply:SetHealth( math.min( health + regen, max ) )
			ply:SetHealthTime( CurTime() )
			
		end
		
	else
		
		ply:SetHealthTime( CurTime() )
		
	end
	
end

function GM:HandlePlayerShield( ply )
	
	local shield = ply:GetShield()
	local max = ply:GetMaxShield()
	if ply:Alive() ~= true or ply:Team() ~= TEAM_BEAT then
		
		if shield ~= 0 then ply:SetShield( 0 ) end
		ply:SetShieldTime( CurTime() )
		
	elseif CurTime() > ply:GetDamagedTime() + 5 and shield < max then
		
		local regen = math.floor( ( CurTime() - ply:GetShieldTime() ) * 2500 )
		if regen > 0 then
			
			ply:SetShield( math.min( shield + regen, max ) )
			ply:SetShieldTime( CurTime() )
			
		end
		
	else
		
		ply:SetShieldTime( CurTime() )
		
	end
	
end

local function domult( gm, mult, ply, perk )
	
	if isstring( perk ) == true then perk = gm:GetPerk( perk ) end
	if gm:PlayerHasPerk( ply, perk ) ~= true then return mult end
	
	return mult * ( 1 - gm:GetPerkTotal( ply, perk ) )
	
end

--absolutely disgusting btw
function GM:HandlePlayerAttackSpeed( ply )
	
	local wep = ply:GetActiveWeapon()
	if IsValid( wep ) ~= true then return end
	
	local mult = 1
	mult = domult( self, mult, ply, "perk_attackspeed" )
	
	if mult == 1 then return end
	
	local nextprimary = wep:GetNextPrimaryFire()
	if wep:GetNW2Float( "BZ_NextPrimaryFire", -1 ) == -1 then wep:SetNW2Float( "BZ_NextPrimaryFire", nextprimary ) end
	if wep:GetNW2Float( "BZ_NextPrimaryFire" ) ~= nextprimary and ( wep:Clip1() ~= 0 or wep:GetPrimaryAmmoType() < 0 ) then
		
		local newnextprimary = CurTime() + ( ( nextprimary - CurTime() ) * mult )
		
		wep:SetNW2Float( "BZ_NextPrimaryFire", newnextprimary )
		wep:SetNextPrimaryFire( newnextprimary )
		
	end
	
	local nextsecondary = wep:GetNextSecondaryFire()
	if wep:GetNW2Float( "BZ_NextSecondaryFire", -1 ) == -1 then wep:SetNW2Float( "BZ_NextSecondaryFire", nextsecondary ) end
	if wep:GetNW2Float( "BZ_NextSecondaryFire" ) ~= nextsecondary and ( wep:Clip2() ~= 0 or wep:GetSecondaryAmmoType() < 0 ) then
		
		local newnextsecondary = CurTime() + ( ( nextsecondary - CurTime() ) * mult )
		
		wep:SetNW2Float( "BZ_NextSecondaryFire", newnextsecondary )
		wep:SetNextSecondaryFire( newnextsecondary )
		
	end
	
end



function GM:GetPlayers()
	
	return team.GetPlayers( TEAM_BEAT )
	
end

function GM:GetLoadoutPoints( ply )
	
	return 10
	
end

function GM:GetPerkPoints( ply )
	
	return 10 + ( math.floor( math.max( 0, self:GetRound() - 1 ) / 6 ) * 10 )
	
end

function GM:ResetPlayerCharacter( ply, omit )
	
	if IsValid( ply ) ~= true then return end
	
	ply.Loadout = {}
	ply.LoadoutNames = {}
	ply:SetLoadoutPoints( self:GetLoadoutPoints( ply ) )
	ply.Perks = {}
	ply.PerkNames = {}
	ply.PerkNum = {}
	ply:SetPerkPoints( self:GetPerkPoints( ply ) )
	ply.AbilityTime = {}
	
	if SERVER then
		
		net.Start( "BZ_ResetPlayer" )
			
			net.WriteEntity( ply )
			
		if omit == true then
			
			net.SendOmit( ply )
			
		else
			
			net.Broadcast()
			
		end
		
	end
	
end



function GM:ScalePlayerDamage( ply, hitgroup, dmg )
end



local function doaddmult( gm, mult, ply, perk )
	
	if isstring( perk ) == true then perk = gm:GetPerk( perk ) end
	if gm:PlayerHasPerk( ply, perk ) ~= true then return mult end
	
	return mult * ( 1 + gm:GetPerkTotal( ply, perk ) )
	
end

function GM:GetPlayerCritChance( ply )
	
	local chance = self:GetConfig( "BaseCritChance" )
	
	if ply:GetVelocity():LengthSqr() == 0 then chance = doaddmult( self, chance, ply, "perk_criticalspecial_immobile" ) end
	
	return chance
	
end

function GM:GetPlayerCrit( ply, dmg )
	
	if dmg ~= nil and bit.band( dmg:GetDamageCustom(), DMGCUSTOM_CRIT ) == DMGCUSTOM_CRIT then return true end
	
	return math.Rand( 0, 1 ) < self:GetPlayerCritChance( ply )
	
end



local function dospeed( gm, mv, ply, perk )
	
	if isstring( perk ) == true then perk = gm:GetPerk( perk ) end
	if gm:PlayerHasPerk( ply, perk ) ~= true then return end
	local mult = 1 + gm:GetPerkTotal( ply, perk )
	mv:SetMaxClientSpeed( mv:GetMaxClientSpeed() * mult )
	mv:SetMaxSpeed( mv:GetMaxSpeed() * mult )
	
end
function GM:Move( ply, mv )
	
	dospeed( self, mv, ply, "perk_movespeed" )
	if CurTime() < ply:GetDamagedTime() + 1 then dospeed( self, mv, ply, "perk_movespeedspecial_damagetaken" ) end
	
	if ply.BZ_AbilityBlazeTime ~= nil and CurTime() < ply.BZ_AbilityBlazeTime then
		
		mv:SetMaxClientSpeed( mv:GetMaxClientSpeed() * 1.25 )
		mv:SetMaxSpeed( mv:GetMaxSpeed() * 1.25 )
		
	end
	
	local plys = self:GetPlayers()
	for i = 1, #plys do
		
		local p = plys[ i ]
		if p.BZ_AbilityHarmonyTime ~= nil and CurTime() < p.BZ_AbilityHarmonyTime and p:GetPos():Distance( ply:GetPos() ) < 512 then
			
			mv:SetMaxClientSpeed( mv:GetMaxClientSpeed() * 1.1 )
			mv:SetMaxSpeed( mv:GetMaxSpeed() * 1.1 )
			
		end
		
	end
	
end



function GM:GetAmmoTypes( refresh )
	
	if self.AmmoNum == nil or refresh == true then self.AmmoNum = 27 + #game.BuildAmmoTypes() end
	
	return self.AmmoNum
	
end

local function doaddmult( gm, mult, ply, perk )
	
	if isstring( perk ) == true then perk = gm:GetPerk( perk ) end
	if gm:PlayerHasPerk( ply, perk ) ~= true then return mult end
	
	return mult * ( 1 + gm:GetPerkTotal( ply, perk ) )
	
end

function GM:GetPlayerMaxAmmo( ply, id, m )
	
	local mult = m or 1
	if m == nil then
		
		mult = doaddmult( self, mult, ply, "perk_maxammo" )
		
	end
	
	return math.min( math.floor( game.GetAmmoMax( id ) * mult ), 9999 )
	
end
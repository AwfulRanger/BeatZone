DEFINE_BASECLASS( "gamemode_base" )

include( "sh_item.lua" )
include( "sh_perk.lua" )
include( "sh_class.lua" )



function GM:GetPlayers()
	
	return team.GetPlayers( TEAM_BEAT )
	
end

function GM:GetLoadoutPoints( ply )
	
	return 10
	
end

function GM:GetPerkPoints( ply )
	
	return 10 + ( math.floor( math.max( 0, self:GetRound() - 1 ) / 6 ) * 5 )
	
end

function GM:ResetPlayerCharacter( ply )
	
	ply.Loadout = {}
	ply.LoadoutNames = {}
	ply:SetLoadoutPoints( self:GetLoadoutPoints( ply ) )
	ply.Perks = {}
	ply.PerkNames = {}
	ply.PerkNum = {}
	ply:SetPerkPoints( self:GetPerkPoints( ply ) )
	
	if SERVER then
		
		net.Start( "BZ_ResetPlayer" )
			
			net.WriteEntity( ply )
			
		net.Broadcast()
		
	end
	
end

function GM:ScalePlayerDamage( ply, hitgroup, dmg )
end



local meta = FindMetaTable( "Player" )

function meta:SetLoadoutPoints( points ) self:SetNW2Int( "BZ_LoadoutPoints", math.Round( points ) ) end
function meta:GetLoadoutPoints() return self:GetNW2Int( "BZ_LoadoutPoints" ) end
function meta:AddLoadoutPoints( points ) self:SetLoadoutPoints( self:GetLoadoutPoints() + points ) end

function meta:SetPerkPoints( points ) self:SetNW2Int( "BZ_PerkPoints", math.Round( points ) )end
function meta:GetPerkPoints() return self:GetNW2Int( "BZ_PerkPoints" ) end
function meta:AddPerkPoints( points ) self:SetPerkPoints( self:GetPerkPoints() + points ) end

function meta:SetDamagedTime( time ) self:SetNW2Float( "BZ_DamagedTime", time ) end
function meta:GetDamagedTime() return self:GetNW2Float( "BZ_DamagedTime" ) end

function meta:SetShieldTime( time ) self:SetNW2Float( "BZ_ShieldTime", time ) end
function meta:GetShieldTime() return self:GetNW2Float( "BZ_ShieldTime" ) end

function meta:SetShield( shield ) self:SetNW2Int( "BZ_Shield", math.Round( shield ) ) end
function meta:GetShield() return self:GetNW2Int( "BZ_Shield" ) end

function meta:SetMaxShield( max ) self:SetNW2Int( "BZ_MaxShield", math.Round( max ) ) end
function meta:GetMaxShield() return self:GetNW2Int( "BZ_MaxShield", 100 ) end

function GM:HandlePlayerShield( ply )
	
	local shield = ply:GetShield()
	local max = ply:GetMaxShield()
	if ply:Alive() ~= true or ply:Team() ~= TEAM_BEAT then
		
		if shield ~= 0 then ply:SetShield( 0 ) end
		ply:SetShieldTime( CurTime() )
		
	elseif CurTime() > ply:GetDamagedTime() + 5 and shield < max then
		
		local regen = math.floor( ( CurTime() - ply:GetShieldTime() ) * 25 )
		if regen > 0 then
			
			ply:SetShield( math.min( shield + regen, max ) )
			ply:SetShieldTime( CurTime() )
			
		end
		
	else
		
		ply:SetShieldTime( CurTime() )
		
	end
	
end
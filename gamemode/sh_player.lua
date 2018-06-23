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

function GM:ScalePlayerDamage( ply, hitgroup, dmg )
end



local meta = FindMetaTable( "Player" )

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
	if CurTime() > ply:GetDamagedTime() + 5 and shield < max then
		
		local regen = math.floor( ( CurTime() - ply:GetShieldTime() ) * 25 )
		if regen > 0 then
			
			ply:SetShield( math.min( shield + regen, max ) )
			
			ply:SetShieldTime( CurTime() )
			
		end
		
	else
		
		ply:SetShieldTime( CurTime() )
		
	end
	
end
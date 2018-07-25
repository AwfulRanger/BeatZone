DeriveGamemode( "base" )

DEFINE_BASECLASS( "gamemode_base" )

include( "sh_config.lua" )
include( "sh_mapcustom.lua" )



game.AddParticles( "particles/burningplayer.pcf" )
PrecacheParticleSystem( "burningplayer_red" )

CreateConVar( "bz_friendlyfire", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enable friendly fire (0 = disabled, 1 = shields only, 2 = all)" )



DMGCUSTOM_CRIT = 1
DMGCUSTOM_IGNITE = 2
DMGCUSTOM_BLEED = 4



local meta = FindMetaTable( "Entity" )

function meta:IsIgnited() return CurTime() < self:GetNW2Float( "BZ_IgniteTime", -1 ) end
function meta:GetIgniteDamage() return self:GetNW2Int( "BZ_IgniteDamage" ) end
function meta:GetIgniteAttacker() return self:GetNW2Entity( "BZ_IgniteAttacker" ) end

function meta:IsBleeding() return CurTime() < self:GetNW2Float( "BZ_BleedTime", -1 ) end
function meta:GetBleedDamage() return self:GetNW2Int( "BZ_BleedDamage" ) end
function meta:GetBleedAttacker() return self:GetNW2Entity( "BZ_BleedAttacker" ) end



GM.Name = "BeatZone"
GM.Author = "AwfulRanger"
GM.TeamBased = true
GM.SecondsBetweenTeamSwitches = 1

TEAM_BEAT = 1
function GM:CreateTeams()
	
	team.SetUp( TEAM_BEAT, "Beat", Color( 200, 0, 255 ) )
	
end



function GM:InitPostEntity()
	
	if CLIENT then
		
		self:FullUpdate()
		
		local voice = g_VoicePanelList
		if IsValid( voice ) == true then
			
			local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.05 )
			local w = math.Round( ScrW() * 0.15 )
			voice:SetPos( ScrW() - w - spacing, spacing )
			voice:SetSize( w, ( ScrH() * 0.9 ) - ( spacing * 3 ) )
			
		end
		
	end
	self:SetupMapCustom()
	
end

function GM:PostCleanupMap()
	
	self:SetupMapCustom()
	
end



local ammoents = {
	
	"item_ammopack_small",
	"item_ammopack_medium",
	"item_ammopack_full",
	
}
for i = 1, #ammoents do
	
	local class = ammoents[ i ]
	if scripted_ents.GetStored( class ) == nil then
		
		scripted_ents.Register( {
			
			Base = "base_point",
			Initialize = function( self )
				
				local ent = ents.Create( "bz_ammo" )
				ent:SetPos( self:GetPos() )
				ent:SetAngles( self:GetAngles() )
				ent:Spawn()
				
				self:Remove()
				
			end,
			
		}, class )
		
	end
	
end

local healthents = {
	
	"item_healthkit_small",
	"item_healthkit_medium",
	"item_healthkit_full",
	
}
for i = 1, #healthents do
	
	local class = healthents[ i ]
	if scripted_ents.GetStored( class ) == nil then
		
		scripted_ents.Register( {
			
			Base = "base_point",
			Initialize = function( self )
				
				local ent = ents.Create( "bz_health" )
				ent:SetPos( self:GetPos() )
				ent:SetAngles( self:GetAngles() )
				ent:Spawn()
				
				self:Remove()
				
			end,
			
		}, class )
		
	end
	
end
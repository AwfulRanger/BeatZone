DeriveGamemode( "base" )

DEFINE_BASECLASS( "gamemode_base" )



GM.Name = "BeatZone"
GM.Author = "AwfulRanger"
GM.TeamBased = true
GM.SecondsBetweenTeamSwitches = 1

TEAM_BEAT = 1
function GM:CreateTeams()
	
	team.SetUp( TEAM_BEAT, "Beat", Color( 200, 0, 255 ) )
	
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
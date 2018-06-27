DEFINE_BASECLASS( "gamemode_base" )

include( "shared.lua" )
include( "cl_round.lua" )
include( "cl_player.lua" )
include( "cl_hud.lua" )
include( "cl_track.lua" )



net.Receive( "BZ_UISound", function()
	
	surface.PlaySound( net.ReadString() )
	
end )

net.Receive( "BZ_SetBoss", function()
	
	local boss = nil
	local set = net.ReadBool()
	if set == true then boss = net.ReadEntity() end
	gmod.GetGamemode().EnemyBoss = boss
	
end )



local bossclass = {
	
	[ "bz_boss_horseman" ] = true,
	
}
function GM:OnEntityCreated( ent )
	
	if self.EnemyBoss == NULL and bossclass[ ent:GetClass() ] == true then self.EnemyBoss = ent end
	
end

function GM:InitPostEntity()
	
	self:ResetPlayerCharacter( LocalPlayer() )
	
end

function GM:Think()
	
	if self:GetRoundState() == ROUND_INITIALIZING then self:SetRoundState( ROUND_INTERMISSION ) end
	self:HandleTrack()
	
	local plys = player.GetAll()
	for i = 1, #plys do self:HandlePlayerShield( plys[ i ] ) end
	
end
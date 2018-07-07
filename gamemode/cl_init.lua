DEFINE_BASECLASS( "gamemode_base" )

include( "cl_settings.lua" )
include( "shared.lua" )
include( "cl_round.lua" )
include( "cl_player.lua" )
include( "cl_hud.lua" )
include( "cl_track.lua" )
include( "cl_vote.lua" )



net.Receive( "BZ_UISound", function()
	
	surface.PlaySound( net.ReadString() )
	
end )

net.Receive( "BZ_SetBoss", function()
	
	local boss = nil
	local set = net.ReadBool()
	if set == true then boss = net.ReadEntity() end
	gmod.GetGamemode().EnemyBoss = boss
	
end )



GM.Skeletons = GM.Skeletons or {}
function GM:OnEntityCreated( ent )
	
	if self.EnemyBoss == NULL and self:GetConfig( "IsBossClass" )[ ent:GetClass() ] == true then self.EnemyBoss = ent end
	if self:GetConfig( "IsEnemyClass" )[ ent:GetClass() ] == true then table.insert( self.Skeletons, ent ) end
	
end
function GM:EntityRemoved( ent )

	if self:GetConfig( "IsEnemyClass" )[ ent:GetClass() ] == true then table.RemoveByValue( self.Skeletons, ent ) end
	
end

function GM:FullUpdate()
	
	for i = 1, self:GetSettingsDataCount() do self:GetSettingsData( i ):Load( self ) end
	
	self:ResetPlayerCharacter( LocalPlayer() )
	
	net.Start( "BZ_FullUpdate" )
	net.SendToServer()
	
	self:ShowTeam()
	
end

function GM:Think()
	
	if self:GetRoundState() == ROUND_INITIALIZING then self:SetRoundState( ROUND_INTERMISSION ) end
	self:HandleTrack()
	
	local plys = player.GetAll()
	for i = 1, #plys do self:HandlePlayer( plys[ i ] ) end
	
	self:HandleVote()
	
end
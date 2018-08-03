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

local igniteparticle = "burningplayer_red"
local ignitedentities = {}
local ignitedentityids = {}
net.Receive( "BZ_Ignite", function()
	
	local entid = net.ReadUInt( 32 )
	local ent = Entity( entid )
	
	local ignite = net.ReadBool()
	
	local tbl = ignitedentities[ entid ]
	if tbl == nil then
		
		local key = table.insert( ignitedentityids, entid )
		ignitedentities[ entid ] = { key = key }
		tbl = ignitedentities[ entid ]
		
	end
	
	if ignite == true then
		
		if IsValid( ent ) == true and IsValid( tbl.particle ) ~= true then tbl.particle = CreateParticleSystem( ent, igniteparticle, PATTACH_ABSORIGIN_FOLLOW ) end
		
	else
		
		if IsValid( tbl.particle ) == true then tbl.particle:StopEmission() end
		
		local key = tbl.key
		table.remove( ignitedentityids, key )
		for _, v in pairs( ignitedentities ) do
			
			if v.key > key then v.key = v.key - 1 end
			if v.key == key then ignitedentities[ _ ] = nil end
			
		end
		
	end
	
end )



GM.Skeletons = GM.Skeletons or {}
function GM:OnEntityCreated( ent )
	
	if self.EnemyBoss == NULL and self:GetConfig( "IsBossClass" )[ ent:GetClass() ] == true then self.EnemyBoss = ent end
	if self:GetConfig( "IsEnemyClass" )[ ent:GetClass() ] == true then table.insert( self.Skeletons, ent ) end
	
end
function GM:EntityRemoved( ent )

	if self:GetConfig( "IsEnemyClass" )[ ent:GetClass() ] == true then table.RemoveByValue( self.Skeletons, ent ) end
	
	local entid = ent:EntIndex()
	local tbl = ignitedentities[ entid ]
	if tbl ~= nil then
		
		if IsValid( tbl.particle ) == true then tbl.particle:StopEmission() end
		
		local key = tbl.key
		table.remove( ignitedentityids, key )
		for _, v in pairs( ignitedentities ) do
			
			if v.key > key then v.key = v.key - 1 end
			if v.key == key then ignitedentities[ _ ] = nil end
			
		end
		
	end
	
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
	
	--handle ignited entity particles
	local remove = {}
	
	for i = 1, #ignitedentityids do
		
		local entid = ignitedentityids[ i ]
		local ent = Entity( entid )
		local tbl = ignitedentities[ entid ]
		if tbl ~= nil then
			
			local particle = tbl.particle
			if IsValid( ent ) == true then
				
				if IsValid( particle ) ~= true then tbl.particle = CreateParticleSystem( ent, igniteparticle, PATTACH_ABSORIGIN_FOLLOW ) end
				
			else
				
				if IsValid( particle ) == true then particle:StopEmission() end
				table.insert( remove, i )
				
			end
			
		else
			
			table.insert( remove, i )
			
		end
		
	end
	
	for i = 1, #remove do
		
		local key = remove[ i ]
		table.remove( ignitedentityids, key )
		for _, v in pairs( ignitedentities ) do
			
			if v.key > key then v.key = v.key - 1 end
			if v.key == key then ignitedentities[ _ ] = nil end
			
		end
		
	end
	
end
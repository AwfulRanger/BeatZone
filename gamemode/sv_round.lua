DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "sh_round.lua" )
AddCSLuaFile( "cl_round.lua" )

include( "sh_round.lua" )



util.AddNetworkString( "BZ_RoundState" )
util.AddNetworkString( "BZ_ResetReady" )
util.AddNetworkString( "BZ_PlayerReady" )
util.AddNetworkString( "BZ_FirstReadyTime" )
util.AddNetworkString( "BZ_SetRound" )
util.AddNetworkString( "BZ_SetBoss" )



net.Receive( "BZ_PlayerReady", function( len, ply )
	
	gmod.GetGamemode():PlayerReady( ply, net.ReadBool() )
	
end )



GM.EnemiesKilled = 0
GM.EnemyCount = 40
function GM:GetRoundEnemyCount( round )
	
	round = round or self:GetRound()
	
	local base = self:GetConfig( "EnemyCount" )
	if round % self:GetConfig( "BossWave" ) == 0 then base = self:GetConfig( "BossEnemyCount" ) end
	
	return math.floor( base + ( round * 0.5 ) )
	
end

GM.EnemySpawnTime = 1
function GM:GetRoundEnemySpawnTime( round )
	
	round = round or self:GetRound()
	
	local base = self:GetConfig( "EnemySpawnTime" )
	for i = 2, round do base = base * 0.98 end
	
	return base
	
end

----
--Control round
----
function GM:StartIntermission()
	
	self.IsRoundLost = false
	self:SetRound()
	self:ResetReady()
	self:SetRoundState( ROUND_INTERMISSION )
	
	game.CleanUpMap()
	
	if self.GetPlayers == nil then return end
	local plys = self:GetPlayers()
	for i = 1, #plys do plys[ i ]:Spawn() end
	
end

function GM:StartRound()
	
	self:SetRoundState( ROUND_STARTING )
	self:ResetReady()
	
	local plys = self:GetPlayers()
	for i = 1, #plys do if plys[ i ]:Alive() ~= true then plys[ i ]:Spawn() end end
	
	self.EnemiesKilled = 0
	self.EnemyCount = self:GetRoundEnemyCount()
	self.EnemySpawnTime = self:GetRoundEnemySpawnTime()
	self.NextEnemySpawnTime = nil
	
end

function GM:RoundStarted()
	
	self:SetRoundState( ROUND_ONGOING )
	
end

function GM:EndRound()
	
	self.IsRoundLost = false
	self:SetRoundState( ROUND_ENDING )
	
	local add = 2
	if self:GetRound() % self:GetConfig( "BossWave" ) == 0 then add = 10 end
	local plys = self:GetPlayers()
	for i = 1, #plys do plys[ i ]:AddPerkPoints( add ) end
	
end

function GM:RoundEnded()
	
	self:SetRound()
	self:StartRound()
	
end

function GM:LoseRound()
	
	self.IsRoundLost = true
	self:SetRoundState( ROUND_ENDING )
	
end

function GM:RoundLost()
	
	local plys = player.GetAll()
	for i = 1, #plys do
		
		local ply = plys[ i ]
		ply:SetFrags( 0 )
		ply:SetDeaths( 0 )
		self:ResetPlayerCharacter( ply )
		
	end
	
	self:SetRound( 0 )
	self:StartIntermission()
	
	local skels = self.Skeletons
	for i = 1, #skels do skels[ i ]:Remove() end
	
end

function GM:HandleRound()
	
	local state = self:GetRoundState()
	if state == ROUND_INITIALIZING then
		
		self:StartIntermission()
		
	elseif state == ROUND_INTERMISSION then
		
		local plys = self.ReadyPlayers.Players
		for i = 1, #plys do
			
			local ply = plys[ i ]
			if ply:Team() ~= TEAM_BEAT then self:PlayerReady( ply, false ) end
			
		end
		
		local rply = self.ReadyPlayers
		if rply.Count <= 0 then
			
			if self.FirstReadyTime ~= nil then
				
				self.FirstReadyTime = nil
				net.Start( "BZ_FirstReadyTime" )
					
					net.WriteBool( false )
					
				net.Broadcast()
				
			end
			
		else
			
			if self.FirstReadyTime == nil then
				
				self.FirstReadyTime = CurTime()
				net.Start( "BZ_FirstReadyTime" )
					
					net.WriteBool( true )
					net.WriteFloat( self.FirstReadyTime )
					
				net.Broadcast()
				
			end
			
			local basetime = self:GetConfig( "ReadyTime" ) * ( #self:GetPlayers() - self.ReadyPlayers.Count )
			if CurTime() > self.FirstReadyTime + basetime then self:StartRound() end
			
		end
		
	elseif state == ROUND_STARTING then
		
		if self.RoundStartTime == nil then self.RoundStartTime = CurTime() end
		
		if CurTime() > self.RoundStartTime + 5 then
			
			self.RoundStartTime = nil
			self:RoundStarted()
			
		end
		
	elseif state == ROUND_ONGOING then
		
		local alive = false
		local plys = self:GetPlayers()
		for i = 1, #plys do if plys[ i ]:Alive() == true then alive = true break end end
		if alive ~= true then self:LoseRound() return end
		
		if self:GetRound() % self:GetConfig( "BossWave" ) == 0 then
			
			if self.EnemyBoss == nil then
				
				local boss = self:GetConfig( "BossClass" )
				self.EnemyBoss = self:SpawnEnemy( boss[ math.random( #boss ) ] )
				net.Start( "BZ_SetBoss" )
					
					net.WriteBool( true )
					net.WriteEntity( self.EnemyBoss )
					
				net.Broadcast()
				
			elseif IsValid( self.EnemyBoss ) ~= true then
				
				local skels = self.Skeletons
				for i = 1, #skels do skels[ i ]:Remove() end
				
				self:EndRound()
				
				return
				
			end
			
			self:HandleEnemySpawn( math.min( self:GetConfig( "MaxEnemies" ), self.EnemyCount ) )
			
		else
			
			if self.EnemiesKilled >= self.EnemyCount then self:EndRound() return end
			
			self:HandleEnemySpawn( math.min( self:GetConfig( "MaxEnemies" ), self.EnemyCount - self.EnemiesKilled ) )
			
		end
		
	elseif state == ROUND_ENDING then
		
		if self.RoundEndTime == nil then self.RoundEndTime = CurTime() end
		
		if CurTime() > self.RoundEndTime + 5 then
			
			self.EnemyBoss = nil
			net.Start( "BZ_SetBoss" )
				
				net.WriteBool( false )
				
			net.Broadcast()
			
			self.RoundEndTime = nil
			if self.IsRoundLost == true then
				
				self:RoundLost()
				
			elseif self:GetRound() % self:GetConfig( "BossWave" ) == 0 then
				
				self:StartIntermission()
				
			else
				
				self:RoundEnded()
				
			end
			
		end
		
	end
	
end
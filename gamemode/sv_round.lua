DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "sh_round.lua" )
AddCSLuaFile( "cl_round.lua" )

include( "sh_round.lua" )



util.AddNetworkString( "BZ_RoundState" )
util.AddNetworkString( "BZ_ResetReady" )
util.AddNetworkString( "BZ_PlayerReady" )
util.AddNetworkString( "BZ_FirstReadyTime" )
util.AddNetworkString( "BZ_SetRound" )



net.Receive( "BZ_PlayerReady", function( len, ply )
	
	gmod.GetGamemode():PlayerReady( ply, net.ReadBool() )
	
end )



GM.MaxEnemies = 20
GM.EnemiesKilled = 0
GM.EnemyCount = 20
function GM:GetRoundEnemyCount( round )
	
	round = round or self:GetRound()
	
	return math.floor( 20 + ( round * 0.2 ) )
	
end

----
--Control round
----
function GM:StartIntermission()
	
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
	
end

function GM:RoundStarted()
	
	self.EnemiesKilled = 0
	self.EnemyCount = self:GetRoundEnemyCount()
	self:SetRoundState( ROUND_ONGOING )
	
end

function GM:EndRound()
	
	self:SetRoundState( ROUND_ENDING )
	
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
			
			local basetime = 30 * ( #self:GetPlayers() - self.ReadyPlayers.Count )
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
		
		if self.EnemiesKilled >= self.EnemyCount then self:EndRound() return end
		
		local skel = NULL
		while ( #self.Skeletons < math.min( self.MaxEnemies, self.EnemyCount - self.EnemiesKilled ) ) and skel ~= nil do
			
			skel = self:SpawnSkeleton()
			
		end
		
	elseif state == ROUND_ENDING then
		
		if self.RoundEndTime == nil then self.RoundEndTime = CurTime() end
		
		if CurTime() > self.RoundEndTime + 5 then
			
			self.RoundEndTime = nil
			if self.IsRoundLost == true then
				
				self:RoundLost()
				local plys = player.GetAll()
				for i = 1, #plys do self:ResetPlayerCharacter( plys[ i ] ) end
				
			elseif self:GetRound() % 6 == 0 then
				
				self:StartIntermission()
				
			else
				
				self:RoundEnded()
				
			end
			
		end
		
	end
	
end
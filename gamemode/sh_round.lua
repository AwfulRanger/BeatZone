DEFINE_BASECLASS( "gamemode_base" )



----
--Set/get round state
----
ROUND_INITIALIZING = -1
ROUND_INTERMISSION = 0
ROUND_STARTING = 1
ROUND_ONGOING = 2
ROUND_ENDING = 3

GM.RoundState = GM.RoundState or ROUND_INITIALIZING

function GM:SetRoundState( state )
	
	self.RoundState = state
	if SERVER then
		
		net.Start( "BZ_RoundState" )
			
			net.WriteInt( state, 3 )
			
		net.Broadcast()
		
	end
	
end

function GM:GetRoundState()
	
	return self.RoundState
	
end

GM.CurrentRound = GM.CurrentRound or 0
function GM:SetRound( round )
	
	round = round or ( self:GetRound() + 1 )
	self.CurrentRound = round
	
	if SERVER then
		
		net.Start( "BZ_SetRound" )
			
			net.WriteUInt( round, 32 )
			
		net.Broadcast()
		
	end
	
end

function GM:GetRound()
	
	return self.CurrentRound
	
end



----
--Ready up
----
GM.ReadyPlayers = {
	
	Count = 0,
	Players = {},
	PlayerIndex = {},
	
}

function GM:ResetReady()
	
	self.ReadyPlayers = {
		
		Count = 0,
		Players = {},
		PlayerIndex = {},
		
	}
	
	if SERVER then
		
		net.Start( "BZ_ResetReady" )
		net.Broadcast()
		
	end
	
end

function GM:PlayerIsReady( ply )
	
	return self.ReadyPlayers.PlayerIndex[ ply ] ~= nil
	
end

function GM:PlayerReady( ply, ready )
	
	ready = ready or false
	if ready == self:PlayerIsReady( ply ) then return end
	
	if ready == true and ply:Team() ~= TEAM_BEAT then return end
	
	local rplys = self.ReadyPlayers
	if ready == true then
		
		rplys.PlayerIndex[ ply ] = table.insert( rplys.Players, ply )
		rplys.Count = #rplys.Players
		
	else
		
		table.remove( rplys.Players, rplys.PlayerIndex[ ply ] )
		rplys.PlayerIndex[ ply ] = nil
		rplys.Count = #rplys.Players
		
	end
	
	if SERVER then
		
		net.Start( "BZ_PlayerReady" )
			
			net.WriteEntity( ply )
			net.WriteBool( ready )
			
		net.Broadcast()
		
	end
	
end
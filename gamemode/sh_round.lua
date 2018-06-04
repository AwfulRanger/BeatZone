DEFINE_BASECLASS( "gamemode_base" )



----
--Set/get round state
----
ROUND_ERROR = -1
ROUND_INTERMISSION = 0
ROUND_STARTING = 1
ROUND_INPROGRESS = 2
ROUND_ENDING = 3

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
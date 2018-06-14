DEFINE_BASECLASS( "gamemode_base" )

include( "sh_round.lua" )



net.Receive( "BZ_RoundState", function()
	
	gmod.GetGamemode():SetRoundState( net.ReadInt( 3 ) )
	
end )

net.Receive( "BZ_ResetReady", function()
	
	gmod.GetGamemode():ResetReady()
	
end )

net.Receive( "BZ_PlayerReady", function()
	
	gmod.GetGamemode():PlayerReady( net.ReadEntity(), net.ReadBool() )
	
end )

net.Receive( "BZ_FirstReadyTime", function()
	
	local val = nil
	if net.ReadBool() == true then val = net.ReadFloat() end
	
	gmod.GetGamemode().FirstReadyTime = val
	
end )

net.Receive( "BZ_SetRound", function()
	
	gmod.GetGamemode():SetRound( net.ReadUInt( 32 ) )
	
end )



function GM:Ready()
	
	net.Start( "BZ_PlayerReady" )
		
		net.WriteBool( gmod.GetGamemode():PlayerIsReady( LocalPlayer() ) ~= true )
		
	net.SendToServer()
	
end

concommand.Add( "bz_toggleready", function()
	
	gmod.GetGamemode():Ready()
	
end )
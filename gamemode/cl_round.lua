DEFINE_BASECLASS( "gamemode_base" )

include( "sh_round.lua" )



net.Receive( "BZ_RoundState", function()
	
	gmod.GetGamemode():SetRoundState( net.ReadInt( 3 ) )
	
end )
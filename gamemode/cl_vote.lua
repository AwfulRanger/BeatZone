DEFINE_BASECLASS( "gamemode_base" )

include( "sh_vote.lua" )



net.Receive( "BZ_StartVote", function()
	
	local gm = gmod.GetGamemode()
	local vote = gm:GetVoteData( net.ReadUInt( 32 ) )
	gm:StartVote( vote, net.ReadEntity(), vote:NetReceive(), net.ReadFloat() )
	
end )

net.Receive( "BZ_FinishVote", function()
	
	gmod.GetGamemode():FinishVote( net.ReadBool() or false )
	
end )

net.Receive( "BZ_PlayerVote", function()
	
	local ply = net.ReadEntity()
	local vote = nil
	if net.ReadBool() ~= true then vote = net.ReadBool() end
	
	gmod.GetGamemode():PlayerVote( ply, vote )
	
end )



function GM:SendStartVote( vote, data )
	
	net.Start( "BZ_StartVote" )
		
		net.WriteUInt( vote.Index, 32 )
		vote:NetSend( data )
		
	net.SendToServer()
	
end

function GM:SendVote( vote )
	
	net.Start( "BZ_PlayerVote" )
		
		net.WriteBool( vote or false )
		
	net.SendToServer()
	
end
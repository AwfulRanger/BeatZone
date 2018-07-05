DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "sh_vote.lua" )
AddCSLuaFile( "cl_vote.lua" )

include( "sh_vote.lua" )



util.AddNetworkString( "BZ_StartVote" )
util.AddNetworkString( "BZ_FinishVote" )
util.AddNetworkString( "BZ_PlayerVote" )

net.Receive( "BZ_StartVote", function( len, ply )
	
	local gm = gmod.GetGamemode()
	
	local vote = gm:GetVoteData( net.ReadUInt( 32 ) )
	if vote == nil or gm:CanCallVote( ply, vote ) ~= true then return end
	
	gm:StartVote( vote, ply, vote:NetReceive() )
	
end )

net.Receive( "BZ_PlayerVote", function( len, ply )
	
	gmod.GetGamemode():PlayerVote( ply, net.ReadBool() or false )
	
end )
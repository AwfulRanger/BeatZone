DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "sh_round.lua" )
AddCSLuaFile( "cl_round.lua" )

include( "sh_round.lua" )



--[[
server starts
intermission state
players vote for round
timer starts when first player votes (length decreases when more people vote)
round starts
starting state
short timer
inprogress state
round ends
ending state
short timer
back to intermission state (skip players join)
]]--



util.AddNetworkString( "BZ_RoundState" )



----
--Control round
----
function GM:StartIntermission()
	
	
	
end

function GM:StartRound()
	
	
	
end

function GM:EndRound()
	
	
	
end
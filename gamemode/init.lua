DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_hud.lua" )

include( "shared.lua" )
include( "sv_round.lua" )
include( "sv_player.lua" )
include( "sv_enemy.lua" )



----
--Keys for showing menus (F1-F4)
----
util.AddNetworkString( "BZ_ShowMenu" )

local function sendbutton( n, ply )
	
	net.Start( "BZ_ShowMenu" )
		
		net.WriteUInt( n, 2 )
		
	net.Send( ply )
	
end

function GM:ShowHelp( ply ) sendbutton( 0, ply ) end
function GM:ShowTeam( ply ) sendbutton( 1, ply ) end
function GM:ShowSpare1( ply ) sendbutton( 2, ply ) end
function GM:ShowSpare2( ply ) sendbutton( 3, ply ) end



function GM:Initialize()
	
	self:StartIntermission()
	
end
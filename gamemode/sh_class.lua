DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "player_class/player_bz.lua" )
AddCSLuaFile( "player_class/player_tuner.lua" )
AddCSLuaFile( "player_class/player_blaster.lua" )
AddCSLuaFile( "player_class/player_ripper.lua" )

include( "player_class/player_bz.lua" )
include( "player_class/player_tuner.lua" )
include( "player_class/player_blaster.lua" )
include( "player_class/player_ripper.lua" )



GM.PlayerClasses = GM.PlayerClasses or {}
GM.PlayerClassNames = GM.PlayerClassNames or {}

function GM:AddClass( name )
	
	name = tostring( name )
	if self.PlayerClasses[ name ] == nil then self.PlayerClasses[ name ] = table.insert( self.PlayerClassNames, name ) end
	
end

function GM:GetClass( id )
	
	if isnumber( id ) == true then return self.PlayerClassNames[ id ] end
	
	id = tostring( id )
	if self.PlayerClasses[ id ] ~= nil then return self.PlayerClasses[ id ] end
	
end

function GM:GetClassCount()
	
	return #self.PlayerClassNames
	
end



function GM:CanChangeClass( ply, class )
	
	if ply:Team() ~= TEAM_BEAT then return false end
	if ply:Alive() ~= true then return false end
	if self:GetRoundState() == ROUND_ONGOING then return false end
	
	return true
	
end

function GM:SetPlayerClass( ply, class )
	
	if IsValid( ply ) ~= true then return end
	if isnumber( class ) == true then class = self:GetClass( class ) end
	
	player_manager.SetPlayerClass( ply, class )
	player_manager.RunClass( ply, "InitializePerks" )
	player_manager.RunClass( ply, "InitializeAbilities" )
	
	if SERVER then
		
		self:ResetPlayerCharacter( ply )
		
		net.Start( "BZ_SetClass" )
			
			net.WriteEntity( ply )
			net.WriteUInt( self:GetClass( class ), 32 )
			
		net.Broadcast()
		
	end
	
end



----
--Add classes
----
GM:AddClass( "player_tuner" )
GM:AddClass( "player_blaster" )
GM:AddClass( "player_ripper" )
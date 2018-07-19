DEFINE_BASECLASS( "player_default" )



local PLAYER = {}


PLAYER.WalkSpeed = 320
PLAYER.RunSpeed = 320



PLAYER.PerkList = {}
PLAYER.PerkNameList = {}
function PLAYER:AddPerk( name )
	
	self.PerkList[ name ] = self.PerkList[ name ] or table.insert( self.PerkNameList, name )
	
end
function PLAYER:GetPerkCount()
	
	return #self.PerkNameList
	
end
function PLAYER:GetPerk( id )
	
	if isnumber( id ) == true then return self.PerkNameList[ id ] end
	
	return self.PerkList[ id ]
	
end
function PLAYER:HasPerk( perk )
	
	return self.PerkList[ perk.IDName ] ~= nil
	
end

function PLAYER:InitializePerks()
	
	self.PerkList = {}
	self.PerkNameList = {}
	
end



PLAYER.AbilityList = {}
PLAYER.AbilityNameList = {}
function PLAYER:AddAbility( name, data )
	
	data = data or {}
	
	name = tostring( name )
	
	local index
	if self.AbilityList[ name ] == nil then
		
		index = table.insert( self.AbilityNameList, name )
		
	else
		
		index = self.AbilityList[ name ].Index
		
	end
	
	data.IDName = name
	data.Index = index
	data.Name = data.Name or ( "#" .. name )
	data.Cooldown = data.Cooldown or 5
	data.Bind = data.Bind or "+menu"
	data.OnActivate = data.OnActivate or function( self, ply ) end
	data.GetDescription = data.GetDescription or function( self, ply ) return self.Description or "" end
	
	self.AbilityList[ name ] = data
	
end

function PLAYER:GetAbilityCount()
	
	return #self.AbilityNameList
	
end

function PLAYER:GetAbility( id )
	
	if isnumber( id ) == true then return self.AbilityList[ self.AbilityNameList[ id ] ] end
	
	return self.AbilityList[ id ]
	
end

function PLAYER:InitializeAbilities()
	
	self.AbilityList = {}
	self.AbilityNameList = {}
	
end



function PLAYER:GetDescription( ply )
	
	return self.Description or ""
	
end


player_manager.RegisterClass( "player_bz", PLAYER, "player_default" )
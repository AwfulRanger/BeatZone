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
	
	return self.PerkNameList[ id ]
	
end
function PLAYER:HasPerk( perk )
	
	return self.PerkList[ perk.IDName ] ~= nil
	
end

function PLAYER:InitializePerks()
	
	self.PerkList = {}
	self.PerkNameList = {}
	
end

function PLAYER:GetDescription( ply )
	
	local desc = self.Description or ""
	
	desc = desc .. "\n\n\nPerks:\n"
	local count = self:GetPerkCount()
	local gm = gmod.GetGamemode()
	for i = 1, count do
		
		local perkname = self:GetPerk( i )
		local perk = gm:GetPerk( perkname )
		if perk ~= nil then perkname = perk.Name end
		desc = desc .. "\n" .. perkname
		
	end
	
	return desc
	
end


player_manager.RegisterClass( "player_bz", PLAYER, "player_default" )
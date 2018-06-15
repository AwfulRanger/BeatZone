GM.PlayerItems = GM.PlayerItems or {}
GM.PlayerItemNames = GM.PlayerItemNames or {}

function GM:AddItem( name, data )
	
	data = data or {}
	
	name = tostring( name )
	
	local index
	if self.PlayerItems[ name ] == nil then
		
		index = table.insert( self.PlayerItemNames, name )
		
	else
		
		index = self.PlayerItems[ name ].Index
		
	end
	
	data.IDName = name
	data.Index = index
	data.Name = data.Name or ( "#" .. name )
	data.Class = data.Class or name
	data.Cost = data.Cost or 1
	data.OnBuy = data.OnBuy or function( self, ply ) ply:Give( self.Class, true ) end
	data.OnSell = data.OnSell or function( self, ply ) ply:StripWeapon( self.Class ) end
	data.GetDescription = data.GetDescription or function( self ) return self.Description or "" end
	
	self.PlayerItems[ name ] = data
	
end

function GM:GetItem( id )
	
	if isnumber( id ) == true then return self.PlayerItems[ self.PlayerItemNames[ id ] ] end
	
	return self.PlayerItems[ tostring( id ) ]
	
end

function GM:GetItemCount()
	
	return #self.PlayerItemNames
	
end



function GM:PlayerBuyItem( ply, item )
	
	ply.LoadoutPoints = ply.LoadoutPoints - item.Cost
	local id = item.Index
	if ply.Loadout[ id ] == nil then ply.Loadout[ id ] = table.insert( ply.LoadoutNames, id ) end
	
	if SERVER then
		
		item:OnBuy( ply )
		
		net.Start( "BZ_BuyItem" )
			
			net.WriteEntity( ply )
			net.WriteUInt( id, 32 )
			
		net.Broadcast()
		
	end
	
end

function GM:PlayerSellItem( ply, item )
	
	ply.LoadoutPoints = ply.LoadoutPoints + item.Cost
	local id = item.Index
	table.remove( ply.LoadoutNames, ply.Loadout[ id ] )
	ply.Loadout[ id ] = nil
	
	if SERVER then
		
		item:OnSell( ply )
		
		net.Start( "BZ_SellItem" )
			
			net.WriteEntity( ply )
			net.WriteUInt( id, 32 )
			
		net.Broadcast()
		
	end
	
end

function GM:PlayerGetItem( ply, id )
	
	if ply.LoadoutNames == nil then return end
	
	return self:GetItem( ply.LoadoutNames[ id ] )
	
end

function GM:PlayerGetItemCount( ply )
	
	if ply.LoadoutNames == nil then return 0 end
	
	return #ply.LoadoutNames
	
end

function GM:PlayerHasItem( ply, item )
	
	if ply.Loadout == nil then return false end
	
	return ply.Loadout[ item.Index ] ~= nil
	
end

function GM:PlayerCanBuyItem( ply, item )
	
	if ply.LoadoutPoints == nil then return false end
	
	return ply:Team() == TEAM_BEAT and ply:Alive() == true and ply.LoadoutPoints >= item.Cost and self:PlayerHasItem( ply, item ) ~= true
	
end

function GM:PlayerCanSellItem( ply, item )
	
	return ply:Team() == TEAM_BEAT and ply:Alive() == true and self:PlayerHasItem( ply, item )
	
end



----
--Add items
----
GM:AddItem( "weapon_stunstick", { Cost = 1, Model = "models/weapons/w_stunbaton.mdl" } )
GM:AddItem( "weapon_357", { Cost = 3, Model = "models/weapons/w_357.mdl" } )
GM:AddItem( "weapon_smg1", { Cost = 3, Model = "models/weapons/w_smg1.mdl" } )
GM:AddItem( "weapon_ar2", { Cost = 3, Model = "models/weapons/w_irifle.mdl" } )
GM:AddItem( "weapon_shotgun", { Cost = 3, Model = "models/weapons/w_shotgun.mdl" } )
GM:AddItem( "weapon_crossbow", { Cost = 3, Model = "models/weapons/w_crossbow.mdl" } )
GM:AddItem( "weapon_frag", { Cost = 2, Model = "models/weapons/w_grenade.mdl" } )
GM:AddItem( "weapon_rpg", { Cost = 5, Model = "models/weapons/w_rocket_launcher.mdl" } )
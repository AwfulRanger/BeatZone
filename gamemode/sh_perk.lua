DEFINE_BASECLASS( "gamemode_base" )



local meta = FindMetaTable( "Player" )

function meta:SetPerkPoints( points ) self:SetNW2Int( "BZ_PerkPoints", math.Round( points ) ) end
function meta:GetPerkPoints() return self:GetNW2Int( "BZ_PerkPoints" ) end
function meta:AddPerkPoints( points ) self:SetPerkPoints( self:GetPerkPoints() + points ) end

GM.PlayerPerks = GM.PlayerPerks or {}
GM.PlayerPerkNames = GM.PlayerPerkNames or {}

function GM:AddPerk( name, data )
	
	data = data or {}
	
	name = tostring( name )
	
	local index
	if self.PlayerPerks[ name ] == nil then
		
		index = table.insert( self.PlayerPerkNames, name )
		
	else
		
		index = self.PlayerPerks[ name ].Index
		
	end
	
	data.IDName = name
	data.Index = index
	data.Name = data.Name or ( "#" .. name )
	data.Type = data.Type or "add"
	if data.BaseAdd == nil then
		
		if data.Type == "addmult" then
			
			data.BaseAdd = 0.01
			
		else
			
			data.BaseAdd = 0.1
			
		end
		
	end
	data.Cost = data.Cost or 1
	data.OnBuy = data.OnBuy or function( self, ply, gm ) end
	data.OnSell = data.OnSell or function( self, ply, gm ) end
	if data.GetDescription == nil then
		
		if data.Type == "add" then
			
			data.GetDescription = function( perk, ply, count )
				
				local total = self:GetPerkTotal( ply, perk, count )
				local nexttotal = self:GetPerkTotal( ply, perk, ( count or ( self:PlayerGetPerkNum( ply, perk ) ) ) + 1 )
				
				return string.format( ( perk.Description or "" ) .."\nNext level: %s (+%s)", "+" .. total, "+" .. nexttotal, math.Round( nexttotal - total, 5 ) )
				
			end
			
		elseif data.Type == "addmult" then
			
			data.GetDescription = function( perk, ply, count )
				
				local total = self:GetPerkTotal( ply, perk, count ) * 100
				local nexttotal = ( self:GetPerkTotal( ply, perk, ( count or ( self:PlayerGetPerkNum( ply, perk ) ) ) + 1 ) ) * 100
				
				return string.format( ( perk.Description or "" ) .."\nNext level: %s (+%s)", "+" .. total .. "%", "+" .. nexttotal .. "%", math.Round( nexttotal - total, 5 ) .. "%" )
				
			end
			
		else
			
			data.GetDescription = function( perk, ply, count )
				
				local total = self:GetPerkTotal( ply, perk, count )
				local nexttotal = self:GetPerkTotal( ply, perk, ( count or ( self:PlayerGetPerkNum( ply, perk ) ) ) + 1 )
				
				return string.format( ( perk.Description or "" ) .."\nNext level: %s (+%s)", total, nexttotal, math.Round( nexttotal - total, 5 ) )
				
			end
			
		end
		
	end
	
	self.PlayerPerks[ name ] = data
	
end

function GM:GetPerk( id )
	
	if isnumber( id ) == true then return self.PlayerPerks[ self.PlayerPerkNames[ id ] ] end
	
	return self.PlayerPerks[ tostring( id ) ]
	
end

function GM:GetPerkCount()
	
	return #self.PlayerPerkNames
	
end

function GM:GetClassPerk( ply, id )
	
	local name = player_manager.RunClass( ply, "GetPerk", id )
	if name ~= nil then return self:GetPerk( name ) end
	
end

function GM:GetClassPerkCount( ply )
	
	return player_manager.RunClass( ply, "GetPerkCount" ) or 0
	
end

function GM:GetClassHasPerk( ply, perk )
	
	return player_manager.RunClass( ply, "HasPerk", perk ) or false
	
end



function GM:PlayerGetPerkNum( ply, perk )
	
	local perknum = ply.PerkNum
	if perknum == nil then return 0 end
	
	return perknum[ perk.Index ] or 0
	
end

function GM:PlayerSetPerkNum( ply, perk, num )
	
	local perknum = ply.PerkNum
	if perknum == nil then return end
	
	perknum[ perk.Index ] = num
	
end

function GM:PlayerBuyPerk( ply, perk, omit )
	
	if IsValid( ply ) ~= true then return end
	
	ply:AddPerkPoints( -perk.Cost )
	local id = perk.Index
	if ply.Perks[ id ] == nil then ply.Perks[ id ] = table.insert( ply.PerkNames, id ) end
	self:PlayerSetPerkNum( ply, perk, self:PlayerGetPerkNum( ply, perk ) + 1 )
	
	if SERVER then
		
		perk:OnBuy( ply, self )
		
		net.Start( "BZ_BuyPerk" )
			
			net.WriteEntity( ply )
			net.WriteUInt( id, 32 )
			net.WriteUInt( 1, 32 )
			
		if omit == true then
			
			net.SendOmit( ply )
			
		else
			
			net.Broadcast()
			
		end
		
	end
	
end

function GM:PlayerSellPerk( ply, perk, omit )
	
	if IsValid( ply ) ~= true then return end
	
	local count = self:PlayerGetPerkNum( ply, perk ) - 1
	
	ply:AddPerkPoints( perk.Cost )
	local id = perk.Index
	if count <= 0 then
		
		local key = ply.Perks[ id ]
		ply.Perks[ id ] = nil
		table.remove( ply.PerkNames, key )
		for _, v in pairs( ply.Perks ) do if v > key then ply.Perks[ _ ] = v - 1 end end
		
		self:PlayerSetPerkNum( ply, perk, nil )
		
	else
		
		self:PlayerSetPerkNum( ply, perk, count )
		
	end
	
	if SERVER then
		
		perk:OnSell( ply, self )
		
		net.Start( "BZ_SellPerk" )
			
			net.WriteEntity( ply )
			net.WriteUInt( id, 32 )
			net.WriteUInt( 1, 32 )
			
		if omit == true then
			
			net.SendOmit( ply )
			
		else
			
			net.Broadcast()
			
		end
		
	end
	
end

function GM:PlayerGetPerk( ply, id )
	
	if ply.PerkNames == nil then return end
	
	return self:GetPerk( ply.PerkNames[ id ] )
	
end

function GM:PlayerGetPerkCount( ply )
	
	if ply.PerkNames == nil then return 0 end
	
	return #ply.PerkNames
	
end

function GM:PlayerHasPerk( ply, perk )
	
	if ply.Perks == nil then return false end
	
	return ply.Perks[ perk.Index ] ~= nil
	
end

function GM:PlayerCanBuyPerk( ply, perk, points )
	
	if ply:Team() ~= TEAM_BEAT then return false end
	if ply:Alive() ~= true then return false end
	if self:GetRoundState() == ROUND_ONGOING then return false end
	if ( points or ply:GetPerkPoints() ) < perk.Cost then return false end
	if self:GetClassHasPerk( ply, perk ) ~= true then return false end
	if self:GetPerkAdd( ply, perk ) <= 0 then return false end
	
	return true
	
end

function GM:PlayerCanSellPerk( ply, perk )
	
	if ply:Team() ~= TEAM_BEAT then return false end
	if ply:Alive() ~= true then return false end
	if self:GetRoundState() == ROUND_ONGOING then return false end
	if self:PlayerHasPerk( ply, perk ) ~= true then return false end
	if self:GetClassHasPerk( ply, perk ) ~= true then return false end
	
	return true
	
end

function GM:GetPerkAdd( ply, perk, count )
	
	local count = count or self:PlayerGetPerkNum( ply, perk )
	local add = perk.BaseAdd or 0.1
	for i = 1, count do add = add * 0.98 end
	
	return math.Round( add, 5 )
	
end

function GM:GetPerkTotal( ply, perk, count )
	
	local count = count or self:PlayerGetPerkNum( ply, perk )
	local total = 0
	for i = 0, count - 1 do total = total + self:GetPerkAdd( ply, perk, i ) end
	
	return math.Round( total, 5 )
	
end



----
--Add perks
----
--damage bonuses
GM:AddPerk( "perk_damage_all", {
	
	Name = "Damage Bonus",
	Description = "%s damage bonus",
	Type = "addmult",
	BaseAdd = 0.05,
	
} )
GM:AddPerk( "perk_damage_bullet", {
	
	Name = "Bullet Damage Bonus",
	Description = "%s bullet damage bonus",
	Type = "addmult",
	BaseAdd = 0.05,
	
} )
GM:AddPerk( "perk_damage_blast", {
	
	Name = "Blast Damage Bonus",
	Description = "%s blast damage bonus",
	Type = "addmult",
	BaseAdd = 0.05,
	
} )
GM:AddPerk( "perk_damage_fire", {
	
	Name = "Fire Damage Bonus",
	Description = "%s fire damage bonus",
	Type = "addmult",
	BaseAdd = 0.05,
	
} )
GM:AddPerk( "perk_damage_melee", {
	
	Name = "Melee Damage Bonus",
	Description = "%s melee damage bonus",
	Type = "addmult",
	BaseAdd = 0.05,
	
} )

GM:AddPerk( "perk_damage_critical", {
	
	Name = "Critical Damage Bonus",
	Description = "%s critical damage bonus",
	Type = "addmult",
	BaseAdd = 0.05,
	
} )

GM:AddPerk( "perk_damagespecial_criticalcrouch", {
	
	Name = "Crouch Critical Damage",
	Description = "%s critical damage bonus while crouching",
	Type = "addmult",
	BaseAdd = 0.05,
	
} )
GM:AddPerk( "perk_damagespecial_onfire", {
	
	Name = "Ignited Damage",
	Description = "%s damage against ignited units",
	Type = "addmult",
	BaseAdd = 0.05,
	
} )

--damage resistances
GM:AddPerk( "perk_resist_all", {
	
	Name = "Damage Resistance",
	Description = "%s damage resistance",
	Type = "addmult",
	
} )
GM:AddPerk( "perk_resist_bullet", {
	
	Name = "Bullet Resistance",
	Description = "%s bullet damage resistance",
	Type = "addmult",
	
} )
GM:AddPerk( "perk_resist_blast", {
	
	Name = "Blast Resistance",
	Description = "%s blast damage resistance",
	Type = "addmult",
	
} )
GM:AddPerk( "perk_resist_fire", {
	
	Name = "Fire Resistance",
	Description = "%s fire damage resistance",
	Type = "addmult",
	
} )
GM:AddPerk( "perk_resist_melee", {
	
	Name = "Melee Resistance",
	Description = "%s melee damage resistance",
	Type = "addmult",
	
} )

GM:AddPerk( "perk_resistspecial_crouch", {
	
	Name = "Crouch Resistance",
	Description = "%s damage resistance while crouching",
	Type = "addmult",
	
} )
GM:AddPerk( "perk_resistspecial_immobile", {
	
	Name = "Immobile Resistance",
	Description = "%s damage resistance while not moving",
	Type = "addmult",
	
} )
GM:AddPerk( "perk_resistspecial_enemykilled", {
	
	Name = "Enemy Killed Resistance",
	Description = "%s damage resistance for 1 second after killing an enemy",
	Type = "addmult",
	
} )

--movement
GM:AddPerk( "perk_movespeed", {
	
	Name = "Move Speed",
	Description = "%s movement speed",
	Type = "addmult",
	
} )

GM:AddPerk( "perk_movespeedspecial_damagetaken", {
	
	Name = "Damaged Move Speed",
	Description = "%s movement speed for 1 second after taking damage",
	Type = "addmult",
	
} )

--health/armor
GM:AddPerk( "perk_health", {
	
	Name = "Health",
	Description = "%s max health",
	Type = "addmult",
	BaseAdd = 0.025,
	OnBuy = function( self, ply, gm ) gm:SetPlayerHealth( ply ) end,
	OnSell = function( self, ply, gm ) gm:SetPlayerHealth( ply ) end,
	
} )
GM:AddPerk( "perk_shield", {
	
	Name = "Shield",
	Description = "%s max shield",
	Type = "addmult",
	BaseAdd = 0.025,
	OnBuy = function( self, ply, gm ) gm:SetPlayerShield( ply ) end,
	OnSell = function( self, ply, gm ) gm:SetPlayerShield( ply ) end,
	
} )
GM:AddPerk( "perk_healthregen", {
	
	Name = "Health Regeneration",
	Description = "%s health regenerated per second",
	Type = "add",
	BaseAdd = 10,
	
} )

GM:AddPerk( "perk_healthregenspecial_enemykilled", {
	
	Name = "Enemy Killed Health Regeneration",
	Description = "%s health regenerated in 1 second after killing an enemy (does not stack)",
	Type = "add",
	BaseAdd = 10,
	
} )

--weapons
GM:AddPerk( "perk_maxammo", {
	
	Name = "Max Ammo",
	Description = "%s maximum ammo",
	Type = "addmult",
	BaseAdd = 0.025,
	OnBuy = function( self, ply, gm ) for i = 1, gm:GetAmmoTypes() do ply:SetAmmo( gm:GetPlayerMaxAmmo( ply, i ), i ) end end,
	OnSell = function( self, ply, gm ) for i = 1, gm:GetAmmoTypes() do ply:SetAmmo( gm:GetPlayerMaxAmmo( ply, i ), i ) end end,
	
} )
GM:AddPerk( "perk_attackspeed", {
	
	Name = "Attack Speed",
	Description = "%s faster attack speed",
	Type = "addmult",
	
} )

GM:AddPerk( "perk_criticalspecial_immobile", {
	
	Name = "Immobile Critical Chance",
	Description = "%s critical chance while not moving",
	Type = "addmult",
	BaseAdd = 0.25,
	
} )

--enemy debuffs
GM:AddPerk( "perk_enemybleed", {
	
	Name = "Enemy Bleed",
	Description = "Enemies bleed for %s seconds after taking damage",
	Type = "set",
	
} )
GM:AddPerk( "perk_enemyignite", {
	
	Name = "Enemy Ignite",
	Description = "Enemies are ignited for %s seconds after taking damage",
	Type = "set",
	
} )
GM:AddPerk( "perk_enemymovespeedignited", {
	
	Name = "Enemy Slow Ignite",
	Description = "Enemies are slowed %s while ignited",
	Type = "addmult",
	
} )
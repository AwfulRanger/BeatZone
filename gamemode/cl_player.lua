DEFINE_BASECLASS( "gamemode_base" )

include( "sh_player.lua" )



CreateConVar( "cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
CreateConVar( "cl_weaponcolor", "0.30 1.80 2.10", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
CreateConVar( "cl_playerskin", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The skin to use, if the model has any" )
CreateConVar( "cl_playerbodygroups", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The bodygroups to use, if the model has any" )



net.Receive( "BZ_SetClass", function()
	
	gmod.GetGamemode():SetPlayerClass( net.ReadEntity(), net.ReadUInt( 32 ) )
	
end )

net.Receive( "BZ_ResetPlayer", function()
	
	gmod.GetGamemode():ResetPlayerCharacter( net.ReadEntity() )
	
end )

net.Receive( "BZ_BuyItem", function()
	
	local gm = gmod.GetGamemode()
	gm:PlayerBuyItem( net.ReadEntity(), gm:GetItem( net.ReadUInt( 32 ) ) )
	
end )

net.Receive( "BZ_SellItem", function()
	
	local gm = gmod.GetGamemode()
	gm:PlayerSellItem( net.ReadEntity(), gm:GetItem( net.ReadUInt( 32 ) ) )
	
end )

net.Receive( "BZ_BuyPerk", function()
	
	local gm = gmod.GetGamemode()
	local ply = net.ReadEntity()
	local perk = gm:GetPerk( net.ReadUInt( 32 ) )
	for i = 1, net.ReadUInt( 32 ) do gm:PlayerBuyPerk( ply, perk ) end
	
end )

net.Receive( "BZ_SellPerk", function()
	
	local gm = gmod.GetGamemode()
	local ply = net.ReadEntity()
	local perk = gm:GetPerk( net.ReadUInt( 32 ) )
	for i = 1, net.ReadUInt( 32 ) do gm:PlayerSellPerk( ply, perk ) end
	
end )

net.Receive( "BZ_ActivateAbility", function()
	
	gmod.GetGamemode():PlayerActivateAbility( net.ReadEntity(), net.ReadUInt( 32 ) )
	
end )



function GM:SetClass( id )
	
	if id == nil then return end
	
	local gm = gmod.GetGamemode()
	local ply = LocalPlayer()
	
	local class = gm:GetClass( id )
	if class == nil or player_manager.GetPlayerClass( ply ) == class then return end
	
	if gm:CanChangeClass( ply, class ) ~= true then return end
	
	gm:SetPlayerClass( ply, class )
	
	net.Start( "BZ_SetClass" )
		
		net.WriteUInt( id, 32 )
		
	net.SendToServer()
	
end

function GM:ResetCharacter()
	
	local gm = gmod.GetGamemode()
	local ply = LocalPlayer()
	
	if gm:CanChangeClass( ply, player_manager.GetPlayerClass( ply ) ) ~= true then return end
	
	gm:ResetPlayerCharacter( ply )
	
	net.Start( "BZ_ResetPlayer" )
	net.SendToServer()
	
end



function GM:BuyItem( item )
	
	if item == nil then return end
	
	local gm = gmod.GetGamemode()
	local ply = LocalPlayer()
	
	if gm:PlayerCanBuyItem( ply, item ) ~= true then return end
	
	gm:PlayerBuyItem( ply, item )
	
	net.Start( "BZ_BuyItem" )
		
		net.WriteUInt( item.Index, 32 )
		
	net.SendToServer()
	
end

concommand.Add( "bz_buyitem", function( ply, cmd, args, arg )
	
	local gm = gmod.GetGamemode()
	local item = gm:GetItem( arg )
	if item ~= nil then gm:BuyItem( item ) end
	
end )

function GM:SellItem( item )
	
	if item == nil then return end
	
	local gm = gmod.GetGamemode()
	local ply = LocalPlayer()
	
	if gm:PlayerCanSellItem( ply, item ) ~= true then return end
	
	gmod.GetGamemode():PlayerSellItem( ply, item )
	
	net.Start( "BZ_SellItem" )
		
		net.WriteUInt( item.Index, 32 )
		
	net.SendToServer()
	
end

concommand.Add( "bz_sellitem", function( ply, cmd, args, arg )
	
	local gm = gmod.GetGamemode()
	local item = gm:GetItem( arg )
	if item ~= nil then gm:SellItem( item ) end
	
end )

function GM:BuyPerk( perk )
	
	if perk == nil then return end
	
	local gm = gmod.GetGamemode()
	local ply = LocalPlayer()
	
	if gm:PlayerCanBuyPerk( ply, perk ) ~= true then return end
	
	gmod.GetGamemode():PlayerBuyPerk( ply, perk )
	
	net.Start( "BZ_BuyPerk" )
		
		net.WriteUInt( perk.Index, 32 )
		
	net.SendToServer()
	
end

concommand.Add( "bz_buyperk", function( ply, cmd, args, arg )
	
	local gm = gmod.GetGamemode()
	local perk = gm:GetPerk( arg )
	if perk ~= nil then gm:BuyPerk( perk ) end
	
end )

function GM:SellPerk( perk )
	
	if perk == nil then return end
	
	local gm = gmod.GetGamemode()
	local ply = LocalPlayer()
	
	if gm:PlayerCanSellPerk( ply, perk ) ~= true then return end
	
	gmod.GetGamemode():PlayerSellPerk( ply, perk )
	
	net.Start( "BZ_SellPerk" )
		
		net.WriteUInt( perk.Index, 32 )
		
	net.SendToServer()
	
end

concommand.Add( "bz_sellperk", function( ply, cmd, args, arg )
	
	local gm = gmod.GetGamemode()
	local perk = gm:GetPerk( arg )
	if perk ~= nil then gm:SellPerk( perk ) end
	
end )



function GM:ActivateAbility( ability )
	
	if ability == nil then return end
	
	net.Start( "BZ_ActivateAbility" )
		
		net.WriteUInt( ability.Index, 32 )
		
	net.SendToServer()
	
end

concommand.Add( "bz_ability", function( ply, cmd, args, arg )
	
	local id = tonumber( arg ) or arg
	
	local gm = gmod.GetGamemode()
	local ability = gm:PlayerGetAbility( LocalPlayer(), id )
	if ability ~= nil then gm:ActivateAbility( ability ) end
	
end )

local menubuttons = {
	
	[ "gm_showhelp" ] = 1,
	[ "gm_showteam" ] = 2,
	[ "gm_showspare1" ] = 3,
	[ "gm_showspare2" ] = 4,
	
}
function GM:PlayerBindPress( ply, bind, pressed )
	
	if pressed == true then
		
		if ply == LocalPlayer() and IsValid( ply ) == true and ply:Alive() == true and ply:Team() == TEAM_BEAT then
			
			for i = 1, self:PlayerGetAbilityCount( ply ) do
				
				local ability = self:PlayerGetAbility( ply, i )
				if ability ~= nil and bind == ability.Bind and self:PlayerCanActivateAbility( ply, ability ) == true then self:ActivateAbility( ability ) end
				
			end
			
		end
		
		local menutab = menubuttons[ bind ]
		if menutab ~= nil then
			
			self:CreateMenu( menutab )
			
			return true
			
		end
		
	end
	
	return BaseClass.PlayerBindPress( self, ply, bind, pressed )
	
end
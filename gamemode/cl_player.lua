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



function GM:BuyItem( item )
	
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
	
	net.Start( "BZ_SellPerk" )
		
		net.WriteUInt( perk.Index, 32 )
		
	net.SendToServer()
	
end

concommand.Add( "bz_sellperk", function( ply, cmd, args, arg )
	
	local gm = gmod.GetGamemode()
	local perk = gm:GetPerk( arg )
	if perk ~= nil then gm:SellPerk( perk ) end
	
end )
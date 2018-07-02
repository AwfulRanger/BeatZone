DEFINE_BASECLASS( "gamemode_base" )

include( "cl_editplayer.lua" )



local function createfonts()
	
	local fontsize = math.min( ScrW(), ScrH() )
	surface.CreateFont( "BZ_MenuButton", {
		
		font = "Roboto",
		size = math.Round( fontsize * 0.025 ),
		weight = 300,
		
	} )
	
	surface.CreateFont( "BZ_MenuButtonSmall", {
		
		font = "Roboto",
		size = math.Round( fontsize * 0.02 ),
		weight = 300,
		
	} )
	
	surface.CreateFont( "BZ_HUD", {
		
		font = "Roboto",
		size = math.Round( fontsize * 0.05 ),
		weight = 300,
		
	} )
	
	surface.CreateFont( "BZ_HUDSmall", {
		
		font = "Roboto",
		size = math.Round( fontsize * 0.035 ),
		weight = 300,
		
	} )
	
	surface.CreateFont( "BZ_HUDSmaller", {
		
		font = "Roboto",
		size = math.Round( fontsize * 0.0225 ),
		weight = 300,
		
	} )
	
	surface.CreateFont( "BZ_Label", {
		
		font = "Roboto",
		size = math.Round( fontsize * 0.02 ),
		weight = 200,
		
	} )
	
	surface.CreateFont( "BZ_LabelBold", {
		
		font = "Roboto",
		size = math.Round( fontsize * 0.02 ),
		weight = 300,
		
	} )
	
	surface.CreateFont( "BZ_LabelLarge", {
		
		font = "Roboto",
		size = math.Round( fontsize * 0.03 ),
		weight = 300,
		
	} )
	
	surface.CreateFont( "BZ_3DText", {
		
		font = "Roboto",
		size = 128,
		weight = 300,
		
	} )
	
end

createfonts()

local bgcolor = Color( 47, 4, 70, 250 )
local detailcolor = Color( 53, 19, 161, 255 )
local buttoncolor = Color( 121, 6, 71, 255 )
local buttonactivecolor = Color( 188, 1, 107, 255 )
local buttoninactivecolor = Color( 85, 0, 48, 255 )
local buttonspecialcolor = Color( 149, 9, 88, 255 )
local textcolor = Color( 255, 255, 255, 255 )
local textshadowcolor = Color( 0, 0, 0, 255 )
local hudbgcolor = Color( 47, 4, 70, 100 )

local function shadowtext( text, x, y, tcolor, scolor, offset )
	
	tcolor = tcolor or textcolor
	scolor = scolor or textshadowcolor
	offset = offset or math.Round( math.min( ScrW(), ScrH() ) * 0.002 )
	
	surface.SetTextPos( x + offset, y + offset )
	surface.SetTextColor( scolor )
	surface.DrawText( text )
	
	surface.SetTextPos( x, y )
	surface.SetTextColor( tcolor )
	surface.DrawText( text )
	
end

local function paintbutton( self, w, h )
	
	surface.SetDrawColor( buttoncolor )
	local override = false
	if self.GetButtonBGColor ~= nil then
		
		local bgcolor
		bgcolor, override = self:GetButtonBGColor()
		if bgcolor ~= nil then surface.SetDrawColor( bgcolor ) end
		
	end
	if override ~= true and self:IsHovered() == true then surface.SetDrawColor( buttonactivecolor ) end
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetFont( self:GetFont() )
	local text = self:GetText()
	local tw, th = surface.GetTextSize( text )
	shadowtext( text, ( w - tw ) * 0.5, ( h - th ) * 0.5 )
	
	return true
	
end

local function paintpanel( self, w, h )
	
	surface.SetDrawColor( detailcolor )
	
	surface.DrawRect( 0, 0, w, 1 ) --top
	surface.DrawRect( 0, h - 1, w, 1 ) --bottom
	surface.DrawRect( 0, 1, 1, h - 2 ) --left
	surface.DrawRect( w - 1, 1, 1, h - 2 ) --right
	
end

local function createlabel( parent, text, font, centerx, centery )
	
	local label = vgui.Create( "DLabel" )
	if parent ~= nil then label:SetParent( parent ) end
	if text ~= nil then label:SetText( text ) end
	function label:Paint( w, h )
		
		surface.SetFont( self:GetFont() )
		local text = self:GetText()
		local tw, th = surface.GetTextSize( text )
		local x = 0
		if centerx ~= false then x = ( w - tw ) * 0.5 end
		local y = 0
		if centery ~= false then y = ( h - th ) * 0.5 end
		shadowtext( text, x, y )
		
		return true
		
	end
	
	label:SetFont( font or "BZ_Label" )
	
	return label
	
end

local function createbutton( parent, text, func )
	
	local button = vgui.Create( "DButton" )
	if parent ~= nil then button:SetParent( parent ) end
	if text ~= nil then button:SetText( text ) end
	if func ~= nil then button.DoClick = func end
	button.Paint = paintbutton
	button:SetFont( "BZ_MenuButton" )
	button:SetDoubleClickingEnabled( false )
	
	return button
	
end

----
--Show menus (F1-F4)
----
local buttons = {
	
	[ 0 ] = "ShowHelp",
	[ 1 ] = "ShowTeam",
	[ 2 ] = "ShowSpare1",
	[ 3 ] = "ShowSpare2",
	
}
net.Receive( "BZ_ShowMenu", function()
	
	local gm = gmod.GetGamemode()
	local func = gm[ buttons[ net.ReadUInt( 2 ) ] ]
	if isfunction( func ) == true then func( gm ) end
	
end )



local frame
local showbuttons = {
	
	[ "gm_showhelp" ] = 1,
	[ "gm_showteam" ] = 2,
	[ "gm_showspare1" ] = 3,
	[ "gm_showspare2" ] = 4,
	
}

local function createperkmenu( gm, perkmenu )
	
	local ply = LocalPlayer()
	if IsValid( ply ) ~= true then return end
	
	local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
	
	local children = perkmenu:GetChildren()
	for i = 1, #children do children[ i ]:Remove() end
	
	local perkscroll = vgui.Create( "DScrollPanel" )
	perkscroll:SetParent( perkmenu )
	perkscroll:Dock( LEFT )
	perkscroll:DockMargin( 0, 0, spacing, 0 )
	
	local perkname = createlabel( perkmenu, "", "BZ_LabelLarge" )
	perkname:Dock( TOP )
	
	local perkdesc = vgui.Create( "RichText" )
	perkdesc:SetParent( perkmenu )
	perkdesc:Dock( TOP )
	function perkdesc:PerformLayout( w, h )
		
		self:SetFontInternal( "BZ_Label" )
		self:SetFGColor( textcolor )
		
	end
	
	local curperk
	local curperkbutton
	
	local perkbuttonbg = vgui.Create( "DPanel" )
	perkbuttonbg:SetParent( perkmenu )
	perkbuttonbg:Dock( BOTTOM )
	function perkbuttonbg:Paint( w, h ) end
	
	local perkpoints = createlabel( perkmenu, ply:GetPerkPoints() .. " perk points", "BZ_LabelLarge" )
	perkpoints:Dock( BOTTOM )
	
	local perkbuy
	local perksell
	local function updateperkmenu( points, count )
		
		points = points or ply:GetPerkPoints()
		count = count or gm:PlayerGetPerkNum( ply, curperk )
		
		local cost = "(" .. curperk.Cost .. " point" .. ( ( curperk.Cost ~= 1 and "s" ) or "" ) .. ")"
		perkbuy:SetText( "Buy " .. cost )
		perksell:SetText( "Sell " .. cost )
		perkpoints:SetText( points .. " perk points" )
		
		local name = curperk.Name or ""
		if count ~= 0 then name = name .. " (" .. count .. ")" end
		curperkbutton:SetText( name )
		
	end
	perkbuy = createbutton( perkbuttonbg, "", function( self )
		
		if curperk == nil or gm:PlayerCanBuyPerk( ply, curperk ) ~= true then return end
		
		local count = gm:PlayerGetPerkNum( ply, curperk ) + 1
		updateperkmenu( ply:GetPerkPoints() - curperk.Cost, count )
		perkdesc:SetText( curperk:GetDescription( ply, count ) )
		
		gm:BuyPerk( curperk )
		
	end )
	perkbuy:Dock( LEFT )
	function perkbuy:GetButtonBGColor()
		
		if curperk == nil then return end
		if gm:PlayerCanBuyPerk( ply, curperk ) ~= true then return buttoninactivecolor, true end
		
	end
	
	perksell = createbutton( perkbuttonbg, "", function( self )
		
		if curperk == nil or gm:PlayerCanSellPerk( ply, curperk ) ~= true then return end
		
		local count = gm:PlayerGetPerkNum( ply, curperk ) - 1
		updateperkmenu( ply:GetPerkPoints() + curperk.Cost, count )
		perkdesc:SetText( curperk:GetDescription( ply, count ) )
		
		gm:SellPerk( curperk )
		
	end )
	perksell:Dock( RIGHT )
	function perksell:GetButtonBGColor()
		
		if curperk == nil then return end
		if gm:PlayerCanSellPerk( ply, curperk ) ~= true then return buttoninactivecolor, true end
		
	end
	
	function perkbuttonbg:PerformLayout( w, h )
		
		local buttonw = ( w - spacing ) * 0.5
		perkbuy:SetWide( buttonw )
		perksell:SetWide( buttonw )
		
	end
	
	local perkbuttontall = math.Round( ScrH() * 0.05 )
	
	for i = 1, gm:GetClassPerkCount( ply ) do
		
		local perk = gm:GetClassPerk( ply, i )
		
		local name = perk.Name or ""
		if gm:PlayerHasPerk( ply, perk ) == true then name = name .. " (" .. gm:PlayerGetPerkNum( ply, perk ) .. ")" end
		
		local perkbutton = createbutton( perkscroll, name, function( self )
			
			curperk = perk
			curperkbutton = self
			
			perkname:SetText( perk.Name or "" )
			perkdesc:SetText( perk:GetDescription( ply ) )
			
			updateperkmenu()
			
		end )
		perkbutton:Dock( TOP )
		perkbutton:DockMargin( 0, 0, 0, spacing )
		perkbutton:SetTall( perkbuttontall )
		perkbutton:SetFont( "BZ_MenuButtonSmall" )
		function perkbutton:GetButtonBGColor()
			
			if gm:PlayerHasPerk( ply, perk ) == true then return buttonspecialcolor end
			if gm:PlayerCanBuyPerk( ply, perk ) ~= true then return buttoninactivecolor end
			
		end
		
		if i == 1 then perkbutton:DoClick() end
		
	end
	
	function perkmenu:PerformLayout( w, h )
		
		perkscroll:SetWide( w * 0.3 )
		perkname:SetTall( h * 0.05 )
		perkdesc:SetTall( h * 0.8 )
		perkbuttonbg:SetTall( h * 0.1 )
		perkpoints:SetTall( h * 0.05 )
		
	end
	
end

local function createcharsheet( gm, charmenu )
	
	local ply = LocalPlayer()
	if IsValid( ply ) ~= true then return end
	
	local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
	
	local charsheet = vgui.Create( "DPropertySheet" )
	charsheet:SetParent( charmenu )
	charsheet:Dock( FILL )
	charsheet:SetPadding( spacing )
	function charsheet:Paint( w, h ) end
	
	
	--class menu
	local classmenu = vgui.Create( "DPanel" )
	function classmenu:Paint( w, h ) end
	
	local classscroll = vgui.Create( "DScrollPanel" )
	classscroll:SetParent( classmenu )
	classscroll:Dock( LEFT )
	classscroll:DockMargin( 0, 0, spacing, 0 )
	
	local classname = createlabel( classmenu, "", "BZ_LabelLarge" )
	classname:Dock( TOP )
	
	local classdesc = vgui.Create( "RichText" )
	classdesc:SetParent( classmenu )
	classdesc:Dock( TOP )
	function classdesc:PerformLayout( w, h )
		
		self:SetFontInternal( "BZ_Label" )
		self:SetFGColor( textcolor )
		
	end
	
	local classtoggle = createbutton( classmenu, "Select class" )
	classtoggle:Dock( BOTTOM )
	
	local curclass
	local respec = false
	
	local function classrespec( button )
		
		gm:ResetPlayerCharacter( ply )
		respec = true
		
		net.Start( "BZ_ResetPlayer" )
		net.SendToServer()
		
	end
	local function classselect( button )
		
		button:SetText( "Respec class" )
		
		net.Start( "BZ_SetClass" )
			
			net.WriteUInt( curclass, 32 )
			
		net.SendToServer()
		
		button.DoClick = classrespec
		
	end
	
	local classbuttontall = math.Round( ScrH() * 0.05 )
	for i = 1, gm:GetClassCount() do
		
		local classid = gm:GetClass( i )
		local class = baseclass.Get( classid )
		
		local classbutton = createbutton( classscroll, class.DisplayName, function()
			
			curclass = i
			
			classname:SetText( class.DisplayName or "" )
			class:InitializePerks()
			classdesc:SetText( class:GetDescription( ply ) )
			
			if player_manager.GetPlayerClass( ply ) == classid then
				
				classtoggle:SetText( "Respec class" )
				classtoggle.DoClick = classrespec
				
			else
				
				classtoggle:SetText( "Select class" )
				classtoggle.DoClick = classselect
				
			end
			
		end )
		classbutton:Dock( TOP )
		classbutton:DockMargin( 0, 0, 0, spacing )
		classbutton:SetTall( classbuttontall )
		classbutton:SetFont( "BZ_MenuButtonSmall" )
		function classbutton:GetButtonBGColor()
			
			if player_manager.GetPlayerClass( ply ) == classid then return buttonspecialcolor end
			
		end
		
		if i == 1 or player_manager.GetPlayerClass( ply ) == classid then classbutton:DoClick() end
		
	end
	
	function classmenu:PerformLayout( w, h )
		
		classscroll:SetWide( w * 0.3 )
		classname:SetTall( h * 0.05 )
		classdesc:SetTall( h * 0.85 )
		classtoggle:SetTall( h * 0.1 )
		
	end
	
	charsheet:AddSheet( "Class", classmenu ).Tab.Paint = function( self, w, h )
		
		surface.SetDrawColor( buttoncolor )
		if self:IsActive() then surface.SetDrawColor( buttonactivecolor ) end
		surface.DrawRect( 0, 0, w, 20 )
		
	end
	
	
	--perk menu
	local perkmenu = vgui.Create( "DPanel" )
	function perkmenu:Paint( w, h ) end
	function perkmenu:Think()
		
		local curclass = player_manager.GetPlayerClass( ply )
		if self.curclass ~= curclass then
			
			self.curclass = curclass
			createperkmenu( gm, perkmenu )
			
		end
		
		if respec == true then
			
			respec = false
			createperkmenu( gm, perkmenu )
			
		end
		
	end
	
	charsheet:AddSheet( "Perks", perkmenu ).Tab.Paint = function( self, w, h )
		
		surface.SetDrawColor( buttoncolor )
		if self:IsActive() then surface.SetDrawColor( buttonactivecolor ) end
		surface.DrawRect( 0, 0, w, 20 )
		
	end
	
	
	--loadout menu
	local loadoutmenu = vgui.Create( "DPanel" )
	function loadoutmenu:Paint( w, h ) end
	
	local loadoutscroll = vgui.Create( "DScrollPanel" )
	loadoutscroll:SetParent( loadoutmenu )
	loadoutscroll:Dock( LEFT )
	loadoutscroll:DockMargin( 0, 0, spacing, 0 )
	
	local loadoutname = createlabel( loadoutmenu, "", "BZ_LabelLarge" )
	loadoutname:Dock( TOP )
	
	local loadoutmodel = vgui.Create( "DModelPanel" )
	loadoutmodel:SetParent( loadoutmenu )
	loadoutmodel:Dock( TOP )
	
	local loadoutdesc = vgui.Create( "RichText" )
	loadoutdesc:SetParent( loadoutmenu )
	loadoutdesc:Dock( TOP )
	function loadoutdesc:PerformLayout( w, h )
		
		self:SetFontInternal( "BZ_Label" )
		self:SetFGColor( textcolor )
		
	end
	
	local loadouttoggle = createbutton( loadoutmenu )
	loadouttoggle:Dock( BOTTOM )
	
	local loadoutpoints = createlabel( loadoutmenu, ply:GetLoadoutPoints() .. " loadout points", "BZ_LabelLarge" )
	loadoutpoints:Dock( BOTTOM )
	
	local curitem
	
	local loadoutsell
	local function loadoutbuy( button )
		
		if curitem == nil or gm:PlayerCanBuyItem( ply, curitem ) ~= true then return end
		
		button:SetText( "Sell (" .. curitem.Cost .. " point" .. ( ( curitem.Cost ~= 1 and "s" ) or "" ) .. ")" )
		loadoutpoints:SetText( ( ply:GetLoadoutPoints() - curitem.Cost ) .. " loadout points" )
		
		gm:BuyItem( curitem )
		
		button.DoClick = loadoutsell
		function button:GetButtonBGColor()
			
			if gm:PlayerCanSellItem( ply, curitem ) ~= true then return buttoninactivecolor, true end
			
		end
		
	end
	function loadoutsell( button )
		
		if curitem == nil or gm:PlayerCanSellItem( ply, curitem ) ~= true then return end
		
		button:SetText( "Buy (" .. curitem.Cost .. " point" .. ( ( curitem.Cost ~= 1 and "s" ) or "" ) .. ")" )
		loadoutpoints:SetText( ( ply:GetLoadoutPoints() + curitem.Cost ) .. " loadout points" )
		
		gm:SellItem( curitem )
		
		button.DoClick = loadoutbuy
		function button:GetButtonBGColor()
			
			if gm:PlayerCanBuyItem( ply, curitem ) ~= true then return buttoninactivecolor, true end
			
		end
		
	end
	
	local itembuttontall = math.Round( ScrH() * 0.05 )
	for i = 1, gm:GetItemCount() do
		
		local item = gm:GetItem( i )
		
		local itembutton = createbutton( loadoutscroll, item.Name, function()
			
			curitem = item
			
			loadoutname:SetText( item.Name or "" )
			loadoutmodel:SetModel( item.Model or "" )
			local ent = loadoutmodel.Entity
			if IsValid( ent ) == true then
				
				loadoutmodel:SetLookAt( ent:GetPos() )
				
			end
			loadoutdesc:SetText( item:GetDescription( ply ) )
			
			if gm:PlayerHasItem( ply, item ) == true then
				
				loadouttoggle:SetText( "Sell (" .. item.Cost .. " point" .. ( ( item.Cost ~= 1 and "s" ) or "" ) .. ")" )
				loadouttoggle.DoClick = loadoutsell
				function loadouttoggle:GetButtonBGColor()
					
					if gm:PlayerCanSellItem( ply, curitem ) ~= true then return buttoninactivecolor, true end
					
				end
				
			else
				
				loadouttoggle:SetText( "Buy (" .. item.Cost .. " point" .. ( ( item.Cost ~= 1 and "s" ) or "" ) .. ")" )
				loadouttoggle.DoClick = loadoutbuy
				function loadouttoggle:GetButtonBGColor()
					
					if gm:PlayerCanBuyItem( ply, curitem ) ~= true then return buttoninactivecolor, true end
					
				end
				
			end
			
		end )
		itembutton:Dock( TOP )
		itembutton:DockMargin( 0, 0, 0, spacing )
		itembutton:SetTall( itembuttontall )
		itembutton:SetFont( "BZ_MenuButtonSmall" )
		function itembutton:GetButtonBGColor()
			
			if gm:PlayerHasItem( ply, item ) == true then return buttonspecialcolor end
			if gm:PlayerCanBuyItem( ply, item ) ~= true then return buttoninactivecolor end
			
		end
		
		if i == 1 then itembutton:DoClick() end
		
	end
	
	function loadoutmenu:PerformLayout( w, h )
		
		loadoutscroll:SetWide( w * 0.3 )
		loadoutname:SetTall( h * 0.05 )
		loadoutmodel:SetTall( h * 0.5 )
		loadoutdesc:SetTall( h * 0.3 )
		loadouttoggle:SetTall( h * 0.1 )
		loadoutpoints:SetTall( h * 0.05 )
		
	end
	
	charsheet:AddSheet( "Loadout", loadoutmenu ).Tab.Paint = function( self, w, h )
		
		surface.SetDrawColor( buttoncolor )
		if self:IsActive() then surface.SetDrawColor( buttonactivecolor ) end
		surface.DrawRect( 0, 0, w, 20 )
		
	end
	
	
	return charsheet
	
end

local function createmenu( tab, gm )
	
	if IsValid( frame ) == true then frame:Remove() end
	
	local ply = LocalPlayer()
	if IsValid( ply ) ~= true then return end
	
	local framepad = math.Round( math.min( ScrW(), ScrH() ) * 0.1 )
	
	frame = vgui.Create( "DFrame" )
	frame:SetSize( ScrW() - framepad, ScrH() - framepad )
	frame:Center()
	frame:SetTitle( "BeatZone" )
	frame:SetSizable( true )
	frame:MakePopup()
	function frame:Paint( w, h )
		
		surface.SetDrawColor( bgcolor )
		surface.DrawRect( 0, 0, w, h )
		
	end
	
	local sheet = vgui.Create( "DPropertySheet" )
	sheet:SetParent( frame )
	sheet:Dock( FILL )
	function sheet:Paint( w, h ) end
	
	local tabs = {}
	
	local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
	
	--help
	do
		
		local helpmenu = vgui.Create( "DPanel" )
		helpmenu.Paint = paintpanel
		
		table.insert( tabs, sheet:AddSheet( "Help", helpmenu ) )
		
	end
	
	
	--character
	do
		
		local charmenu = vgui.Create( "DPanel" )
		function charmenu:Paint( w, h )
			
			paintpanel( self, w, h )
			
			local size = math.min( w, h )
			
			surface.SetDrawColor( detailcolor )
			surface.DrawRect( ( size * 0.5 ) - 1, 0, 1, h )
			
		end
		function charmenu:Think()
			
			local vis = ply:Team() == TEAM_BEAT
			if self.vis ~= vis then
				
				self.vis = vis
				
				if vis == true then
					
					self.charsheet = createcharsheet( gm, charmenu )
					
				elseif IsValid( self.charsheet ) == true then
					
					self.charsheet:Remove()
					
				end
				
			end
			
		end
		
		local charbg = vgui.Create( "DPanel" )
		charbg:SetParent( charmenu )
		charbg:Dock( LEFT )
		charbg:DockPadding( spacing, spacing, spacing, spacing )
		function charbg:Paint( w, h ) end
		
		local modelcvar = GetConVar( "cl_playermodel" )
		local skincvar = GetConVar( "cl_playerskin" )
		
		local playermodel = vgui.Create( "DModelPanel" )
		playermodel:SetParent( charbg )
		playermodel:Dock( FILL )
		playermodel:DockMargin( 0, 0, 0, spacing )
		playermodel:SetModel( player_manager.TranslatePlayerModel( modelcvar:GetString() ) )
		playermodel.Entity.GetPlayerColor = function() return ply:GetPlayerColor() end
		playermodel:SetFOV( 36 )
		local function shouldrefreshmodel( panel )
			
			if panel:GetModel() ~= player_manager.TranslatePlayerModel( modelcvar:GetString() ) then return true end
			local ent = panel.Entity
			if IsValid( ent ) == true then
				
				if ent:GetSkin() ~= skincvar:GetInt() then return true end
				local groups = string.Explode( " ", GetConVar( "cl_playerbodygroups" ):GetString() )
				for i = 0, ent:GetNumBodyGroups() - 1 do if ent:GetBodygroup( i ) ~= tonumber( groups[ i ] ) then return true end end
				
			end
			
		end
		local function refreshmodel( panel )
			
			panel:SetModel( player_manager.TranslatePlayerModel( modelcvar:GetString() ) )
			local ent = panel.Entity
			ent.GetPlayerColor = function() return Vector( GetConVar( "cl_playercolor" ):GetString() ) end
			ent:SetSkin( skincvar:GetInt() )
			local groups = string.Explode( " ", GetConVar( "cl_playerbodygroups" ):GetString() )
			for i = 0, ent:GetNumBodyGroups() - 1 do ent:SetBodygroup( i, groups[ i + 1 ] or 0 ) end
			
		end
		function playermodel:Think()
			
			if shouldrefreshmodel( self ) == true then refreshmodel( self ) end
			
		end
		function playermodel:DoClick() RunConsoleCommand( "bz_editplayer" ) end
		
		local charbuttonbg = vgui.Create( "DPanel" )
		charbuttonbg:SetParent( charbg )
		charbuttonbg:Dock( BOTTOM )
		function charbuttonbg:Paint( w, h ) end
		
		local joinbeat = createbutton( charbuttonbg, "Beat", function() RunConsoleCommand( "changeteam", TEAM_BEAT ) end )
		joinbeat:Dock( LEFT )
		local joinspec = createbutton( charbuttonbg, "Spectate", function() RunConsoleCommand( "changeteam", TEAM_SPECTATOR ) end )
		joinspec:Dock( RIGHT )
		
		function charbg:PerformLayout( w, h )
			
			charbuttonbg:SetTall( h * 0.1 )
			
		end
		
		function charbuttonbg:PerformLayout( w, h )
			
			local buttonw = math.Round( ( w - spacing ) * 0.5 )
			joinbeat:SetWide( buttonw )
			joinspec:SetWide( buttonw )
			
		end
		
		function charmenu:PerformLayout( w, h )
			
			charbg:SetWide( math.min( w, h ) * 0.5 )
			
		end
		
		table.insert( tabs, sheet:AddSheet( "Character", charmenu ) )
		
	end
	
	
	--call vote
	do
		
		local votemenu = vgui.Create( "DPanel" )
		votemenu.Paint = paintpanel
		
		table.insert( tabs, sheet:AddSheet( "Vote", votemenu ) )
		
	end
	
	
	--settings
	do
		
		local settingsmenu = vgui.Create( "DPanel" )
		settingsmenu.Paint = paintpanel
		
		table.insert( tabs, sheet:AddSheet( "Settings", settingsmenu ) )
		
	end
	
	
	for i = 1, #tabs do
		
		tabs[ i ].Tab.Paint = function( self, w, h )
			
			surface.SetDrawColor( buttoncolor )
			if self:IsActive() then surface.SetDrawColor( buttonactivecolor ) end
			--surface.DrawRect( 0, 0, w, h )
			surface.DrawRect( 0, 0, w, 20 )
			
		end
		
	end
	
	if tab ~= nil and tabs[ tab ] ~= nil then sheet:SetActiveTab( tabs[ tab ].Tab ) end
	
	function frame:OnKeyCodePressed( key )
		
		local bind = showbuttons[ input.LookupKeyBinding( key ) ]
		if bind == nil then return end
		
		if bind == tab then
			
			self:Remove()
			
		elseif tabs[ bind ] ~= nil then
			
			sheet:SetActiveTab( tabs[ bind ].Tab )
			
		end
		
	end
	
	function sheet:OnActiveTabChanged( old, new )
		
		for i = 1, #tabs do if tabs[ i ].Tab == new then tab = i break end end
		
	end
	
end

function GM:ShowHelp() createmenu( 1, self ) end
function GM:ShowTeam() createmenu( 2, self ) end
function GM:ShowSpare1() createmenu( 3, self ) end
function GM:ShowSpare2() createmenu( 4, self ) end



----
--HUD
----
local nodraw = {
	
	[ "CHudHealth" ] = false,
	[ "CHudBattery" ] = false,
	[ "CHudAmmo" ] = false,
	[ "CHudSecondaryAmmo" ] = false,
	
}
function GM:HUDShouldDraw( hud )
	
	local show = nodraw[ hud ]
	if show ~= nil then return show end
	
	return true
	
end

local cmenudrawn = false
local sbdrawn = false

local healthcolor = Color( 227, 24, 139, 200 )
local shieldcolor = Color( 41, 92, 209, 200 )
local clipcolor = Color( 146, 32, 209, 200 )
local ammocolor = Color( 69, 10, 101, 200 )
local statestr = {
	
	[ ROUND_INITIALIZING ] = "Initializing",
	[ ROUND_INTERMISSION ] = "Intermission",
	[ ROUND_STARTING ] = "Starting",
	[ ROUND_ONGOING ] = "Ongoing",
	[ ROUND_ENDING ] = "Ending",
	
}
function GM:HUDPaint()
	
	local scrw = ScrW()
	local scrh = ScrH()
	
	if self.LastScrW ~= scrw or self.LastScrH ~= scrh then
		
		self.LastScrW = scrw
		self.LastScrH = scrh
		
		createfonts()
		
	end
	
	if cmenudrawn == true or sbdrawn == true then return end
	
	local ply = LocalPlayer()
	if IsValid( ply ) ~= true then return end
	
	local size = math.min( scrw, scrh )
	local spacing = math.Round( size * 0.05 )
	local hudspacing = math.Round( size * 0.005 )
	
	--state/round
	do
		
		local state = self:GetRoundState()
		
		surface.SetFont( "BZ_HUDSmall" )
		local statetext = statestr[ state ] .. " (Round " .. self:GetRound() .. ")"
		local sw, sh = surface.GetTextSize( statetext )
		shadowtext( statetext, ( scrw - sw ) * 0.5, ( scrh * 0.05 ) - sh )
		
		if ply:Team() == TEAM_BEAT and state == ROUND_INTERMISSION then
			
			local readycount = self.ReadyPlayers.Count
			local plycount = #self:GetPlayers()
			
			local readytext = "Hold " .. string.upper( input.LookupBinding( "+menu_context", true ) or "(UNBOUND)" ) .. " to toggle ready"
			local bind = input.LookupBinding( "bz_toggleready" )
			if bind ~= nil then readytext = "Press " .. string.upper( bind ) .. " to toggle ready" end
			readytext = readytext .. " (" .. readycount .. "/" .. plycount .. ")"
			
			surface.SetFont( "BZ_HUD" )
			
			local rw, rh = surface.GetTextSize( readytext )
			
			local readytime = self.FirstReadyTime
			if readytime ~= nil then
				
				local basetime = 30 * ( plycount - readycount )
				local time = math.Round( basetime - ( CurTime() - readytime ), 1 )
				
				if time > 0 then
					
					if #tostring( time ) > 3 then time = math.floor( time ) end
					
					local timestr = tostring( time )
					if #timestr == 1 then timestr = timestr .. ".0" end
					
					local timetext = "Starting in " .. timestr .. " seconds"
					local tw, th = surface.GetTextSize( timetext )
					
					shadowtext( timetext, ( scrw - tw ) * 0.5, scrh * 0.2 )
					
				end
				
			end
			
			shadowtext( readytext, ( scrw - rw ) * 0.5, ( scrh * 0.2 ) - rh )
			
		end
		
	end
	
	--boss health
	local boss = self.EnemyBoss
	if IsValid( boss ) == true then
		
		surface.SetFont( "BZ_HUDSmall" )
		
		local hw = math.Round( scrw * 0.5 )
		local hh = math.Round( scrh * 0.05 )
		local hx = math.Round( ( scrw - hw ) * 0.5 )
		local hy = math.Round( scrh * 0.075 )
		local hbarh = hh - hudspacing * 2
		
		surface.SetDrawColor( hudbgcolor )
		surface.DrawRect( hx, hy, hw, hh )
		
		local health = boss:Health()
		local maxhealth = boss:GetMaxHealth()
		local healthsize = math.Round( hw - ( hudspacing * 2 ) ) * math.Clamp( health / maxhealth, 0, 1 )
		surface.SetDrawColor( healthcolor )
		surface.DrawRect( hx + hudspacing, hy + hudspacing, healthsize, hbarh )
		
		local htext = health .. "/" .. maxhealth
		local htw, hth = surface.GetTextSize( htext )
		shadowtext( htext, hx + ( hudspacing * 2 ), hy + hudspacing + ( ( hbarh - hth ) * 0.5 ) )
		
	end
	
	BaseClass.HUDPaint( self )
	
	local obs = ply:GetObserverTarget()
	if IsValid( obs ) == true then ply = obs end
	if ply:Alive() ~= true or ply:Team() ~= TEAM_BEAT then return end
	
	--health/shield
	do
		
		surface.SetFont( "BZ_HUDSmall" )
		
		local hw = math.Round( scrw * 0.25 )
		local hh = math.Round( scrh * 0.1 )
		local hx = spacing
		local hy = scrh - hh - spacing
		local hbarh = math.Round( hh * 0.5 ) - math.Round( hudspacing * 1.5 )
		
		surface.SetDrawColor( hudbgcolor )
		surface.DrawRect( hx, hy, hw, hh )
		
		local health = ply:Health()
		local maxhealth = ply:GetMaxHealth()
		local healthsize = math.Round( hw - ( hudspacing * 2 ) ) * math.Clamp( health / maxhealth, 0, 1 )
		surface.SetDrawColor( healthcolor )
		surface.DrawRect( hx + hudspacing, hy + hudspacing, healthsize, hbarh )
		
		local htext = health .. "/" .. maxhealth
		local htw, hth = surface.GetTextSize( htext )
		shadowtext( htext, hx + ( hudspacing * 2 ), hy + hudspacing + ( ( hbarh - hth ) * 0.5 ) )
		
		local shield = ply:GetShield()
		local maxshield = ply:GetMaxShield()
		local shieldsize = math.Round( hw - ( hudspacing * 2 ) ) * math.Clamp( shield / maxshield, 0, 1 )
		surface.SetDrawColor( shieldcolor )
		surface.DrawRect( hx + hudspacing, hy + hbarh + ( hudspacing * 2 ), shieldsize, hbarh )
		
		local stext = shield .. "/" .. maxshield
		local stw, sth = surface.GetTextSize( stext )
		shadowtext( stext, hx + ( hudspacing * 2 ), hy + hbarh + ( hudspacing * 2 ) + ( ( hbarh - sth ) * 0.5 ) )
		
	end
	
	--ammo
	do
		
		surface.SetFont( "BZ_HUD" )
		
		local weapon = ply:GetActiveWeapon()
		local ammotype1 = -1
		local ammotype2 = -1
		if IsValid( weapon ) == true then
			
			ammotype1 = weapon:GetPrimaryAmmoType()
			ammotype2 = weapon:GetSecondaryAmmoType()
			
		end
		if ammotype1 ~= -1 or ammotype2 ~= -1 then
			
			local aw = math.Round( scrw * 0.25 )
			local ah = math.Round( scrh * 0.1 )
			local ax = scrw - aw - spacing
			local ay = scrh - ah - spacing
			
			surface.SetDrawColor( hudbgcolor )
			surface.DrawRect( ax, ay, aw, ah )
			
			--primary ammo
			if ammotype1 ~= -1 then
				
				local acx = ax + hudspacing
				local acy = ay + hudspacing
				local acw = math.Round( aw * 0.5 ) - ( hudspacing * 2 )
				local ach = ah - ( hudspacing * 2 )
				
				local clip = weapon:Clip1()
				local maxclip = weapon:GetMaxClip1()
				local ammo = ply:GetAmmoCount( ammotype1 )
				local maxammo = game.GetAmmoMax( ammotype1 )
				if clip == -1 or ammo == -1 then
					
					local maxcount = maxammo
					local count = ammo
					if maxcount == -1 then
						
						maxcount = maxclip
						count = clip
						
					end
					if maxcount ~= -1 then
						
						surface.SetDrawColor( clipcolor )
						local csize = math.Round( ach * math.Clamp( count / maxcount, 0, 1 ) )
						surface.DrawRect( acx, acy + ( ach - csize ), acw, csize )
						
						local ctw, cth = surface.GetTextSize( count )
						shadowtext( count, acx + math.Round( ( acw - ctw ) * 0.5 ), acy + math.Round( ( ach - cth ) * 0.5 ) )
						
					end
					
				else 
					
					local cw = math.Round( ( acw - hudspacing ) * 0.5 )
					local cspacing = math.Round( hudspacing * 0.5 )
					
					--clip
					surface.SetDrawColor( clipcolor )
					local clipsize = math.Round( ach * math.Clamp( clip / maxclip, 0, 1 ) )
					surface.DrawRect( acx, acy + ( ach - clipsize ), cw - cspacing, clipsize )
					
					local ctw, cth = surface.GetTextSize( clip )
					shadowtext( clip, acx + math.Round( ( cw - cspacing - ctw ) * 0.5 ), acy + math.Round( ( ach - cth ) * 0.5 ) )
					
					--ammo
					surface.SetDrawColor( ammocolor )
					local ammosize = math.Round( ach * math.Clamp( ammo / maxammo, 0, 1 ) )
					surface.DrawRect( acx + cw + cspacing, acy + ( ach - ammosize ), cw, ammosize )
					
					local atw, ath = surface.GetTextSize( ammo )
					shadowtext( ammo, acx + cw + cspacing + math.Round( ( cw - atw ) * 0.5 ), acy + math.Round( ( ach - ath ) * 0.5 ) )
					
				end
				
			end
			
			--secondary ammo
			if ammotype2 ~= -1 then
				
				local acx = ax + hudspacing + math.Round( aw * 0.5 )
				local acy = ay + hudspacing
				local acw = math.Round( aw * 0.5 ) - ( hudspacing * 2 )
				local ach = ah - ( hudspacing * 2 )
				
				local clip = weapon:Clip2()
				local maxclip = weapon:GetMaxClip2()
				local ammo = ply:GetAmmoCount( ammotype2 )
				local maxammo = game.GetAmmoMax( ammotype2 )
				if clip == -1 or ammo == -1 then
					
					local maxcount = maxammo
					local count = ammo
					if maxcount == -1 then
						
						maxcount = maxclip
						count = clip
						
					end
					if maxcount ~= -1 then
						
						surface.SetDrawColor( clipcolor )
						local csize = math.Round( ach * math.Clamp( count / maxcount, 0, 1 ) )
						surface.DrawRect( acx, acy + ( ach - csize ), acw, csize )
						
						local ctw, cth = surface.GetTextSize( count )
						shadowtext( count, acx + math.Round( ( acw - ctw ) * 0.5 ), acy + math.Round( ( ach - cth ) * 0.5 ) )
						
					end
					
				else 
					
					local cw = math.Round( ( acw - hudspacing ) * 0.5 )
					local cspacing = math.Round( hudspacing * 0.5 )
					
					--clip
					surface.SetDrawColor( clipcolor )
					local clipsize = math.Round( ach * math.Clamp( clip / maxclip, 0, 1 ) )
					surface.DrawRect( acx, acy + ( ach - clipsize ), cw - cspacing, clipsize )
					
					local ctw, cth = surface.GetTextSize( clip )
					shadowtext( clip, acx + math.Round( ( cw - cspacing - ctw ) * 0.5 ), acy + math.Round( ( ach - cth ) * 0.5 ) )
					
					--ammo
					surface.SetDrawColor( ammocolor )
					local ammosize = math.Round( ach * math.Clamp( ammo / maxammo, 0, 1 ) )
					surface.DrawRect( acx + cw + cspacing, acy + ( ach - ammosize ), cw, ammosize )
					
					local atw, ath = surface.GetTextSize( ammo )
					shadowtext( ammo, acx + cw + cspacing + math.Round( ( cw - atw ) * 0.5 ), acy + math.Round( ( ach - ath ) * 0.5 ) )
					
				end
				
			end
			
		end
		
	end
	
	self:DrawDamageNumbers()
	
end



local plyreadycolor = Color( 0, 255, 0, 255 )
local plyunreadycolor = Color( 255, 0, 0, 255 )
local cmenu
function GM:OnContextMenuOpen()
	
	cmenudrawn = true
	
	local ply = LocalPlayer()
	if IsValid( ply ) ~= true then return end
	
	if IsValid( cmenu ) == true then cmenu:Remove() end
	
	cmenu = vgui.Create( "DPanel" )
	cmenu:SetSize( ScrW(), ScrH() )
	cmenu:MakePopup()
	cmenu:SetKeyboardInputEnabled( false )
	function cmenu.Paint( panel, w, h )
		
		surface.SetFont( "BZ_HUDSmall" )
		
		if self:GetRoundState() == ROUND_INTERMISSION then
			
			local x = math.Round( w * 0.15 )
			local y = math.Round( h * 0.5 )
			local tw, th = surface.GetTextSize( " " )
			
			local plys = self:GetPlayers()
			local count = #plys
			for i = 1, count do
				
				local ply = plys[ i ]
				
				local color = plyunreadycolor
				if self:PlayerIsReady( ply ) == true then color = plyreadycolor end
				
				shadowtext( ply:Name(), x, y + ( th * ( ( i - 1 ) - ( count * 0.5 ) ) ), color )
				
			end
			
		end
		
	end
	function cmenu.Think( panel )
		
		local vis = self:GetRoundState() == ROUND_INTERMISSION and ply:Team() == TEAM_BEAT
		if panel.vis ~= vis then
			
			panel.vis = vis
			
			if vis == true then
				
				panel.ready = createbutton( panel, "Toggle ready", function() self:Ready() end )
				panel.ready:SetPos( ScrW() * 0.025, ScrH() * 0.45 )
				panel.ready:SetSize( ScrW() * 0.1, ScrH() * 0.1 )
				
			elseif IsValid( panel.ready ) == true then
				
				panel.ready:Remove()
				
			end
			
		end
		
	end
	
end

function GM:OnContextMenuClose()
	
	cmenudrawn = false
	
	if IsValid( cmenu ) == true then cmenu:Remove() end
	
end



local deadcolor = Color( 255, 0, 0, 255 )
local function createsbpanel( gm, parent )
	
	local plys = player.GetAll()
	local plycount = #plys
	
	local size = math.min( ScrW(), ScrH() )
	local plypanelh = math.Round( size * 0.1 )
	local panelw = math.Round( ScrW() * 0.5 )
	
	local sbpanel = vgui.Create( "DPanel" )
	sbpanel:SetParent( parent )
	sbpanel:SetSize( panelw, math.min( plypanelh * 8, plypanelh * plycount ) )
	sbpanel:Center()
	sbpanel:MakePopup()
	sbpanel:SetKeyboardInputEnabled( false )
	function sbpanel:Paint( w, h )
		
		surface.SetDrawColor( bgcolor )
		surface.DrawRect( 0, 0, w, h )
		
	end
	
	local scroll = vgui.Create( "DScrollPanel" )
	scroll:SetParent( sbpanel )
	scroll:Dock( FILL )
	
	for i = 1, plycount do
		
		local ply = plys[ i ]
		
		local plypanel = vgui.Create( "DPanel" )
		plypanel:SetParent( scroll )
		plypanel:Dock( TOP )
		plypanel:SetTall( plypanelh )
		plypanel.Paint = paintpanel
		
		local asize = math.Round( plypanelh * 0.8 )
		local apos = math.Round( ( plypanelh - asize ) * 0.5 )
		
		local avatar = vgui.Create( "AvatarImage" )
		avatar:SetParent( plypanel )
		avatar:SetPos( apos, apos )
		avatar:SetSize( asize, asize )
		avatar:SetPlayer( ply, 184 )
		
		if ply:IsBot() ~= true then
			
			local showprofile = vgui.Create( "DButton" )
			showprofile:SetParent( avatar )
			showprofile:Dock( FILL )
			showprofile:SetText( "Show profile" )
			function showprofile:Paint( w, h )
				
				return true
				
			end
			function showprofile:DoClick()
				
				ply:ShowProfile()
				
			end
			
		end
		
		local px = asize + ( apos * 2 )
		local pw = panelw - px - apos
		
		local nameclass = vgui.Create( "DPanel" )
		nameclass:SetParent( plypanel )
		nameclass:SetPos( px, apos )
		nameclass:SetSize( pw, apos * 2 )
		function nameclass:Paint( w, h )
			
			if IsValid( ply ) ~= true then return end
			
			surface.SetFont( "BZ_LabelBold" )
			
			local nick = ply:Nick()
			local ntw, nth = surface.GetTextSize( nick )
			shadowtext( nick, 0, ( h - nth ) * 0.5 )
			
			if ply:Team() ~= TEAM_BEAT then return end
			
			local plyclass = player_manager.GetPlayerClass( ply )
			if plyclass == nil or plyclass == "" then return end
			plyclass = baseclass.Get( plyclass )
			if plyclass == nil or plyclass.DisplayName == nil then return end
			
			local class = plyclass.DisplayName
			local ctw, cth = surface.GetTextSize( class )
			shadowtext( class, w - ctw, ( h - cth ) * 0.5 )
			
		end
		
		local status = vgui.Create( "DPanel" )
		status:SetParent( plypanel )
		status:SetPos( px, apos * 3 )
		status:SetSize( pw, plypanelh - ( apos * 4 ) )
		function status:Paint( w, h )
		end
		
		local miscw = math.Round( pw * 0.2 )
		
		local ping = vgui.Create( "DPanel" )
		ping:SetParent( status )
		ping:Dock( RIGHT )
		ping:SetWide( miscw )
		function ping:Paint( w, h )
			
			if IsValid( ply ) ~= true then return end
			
			local th = math.Round( h * 0.45 )
			
			surface.SetFont( "BZ_LabelBold" )
			
			local top = "Ping"
			local ttw, tth = surface.GetTextSize( top )
			shadowtext( top, ( w - ttw ) * 0.5, ( th - tth ) * 0.5 )
			
			local bot = ply:Ping()
			if ply:IsBot() == true then bot = "BOT" end
			local btw, bth = surface.GetTextSize( bot )
			shadowtext( bot, ( w - btw ) * 0.5, ( h - th ) + ( ( th - bth ) * 0.5 ) )
			
		end
		
		local deaths = vgui.Create( "DPanel" )
		deaths:SetParent( status )
		deaths:Dock( RIGHT )
		deaths:SetWide( miscw )
		function deaths:Paint( w, h )
			
			if IsValid( ply ) ~= true then return end
			
			local th = math.Round( h * 0.45 )
			
			surface.SetFont( "BZ_LabelBold" )
			
			local top = "Deaths"
			local ttw, tth = surface.GetTextSize( top )
			shadowtext( top, ( w - ttw ) * 0.5, ( th - tth ) * 0.5 )
			
			local bot = ply:Deaths()
			local btw, bth = surface.GetTextSize( bot )
			shadowtext( bot, ( w - btw ) * 0.5, ( h - th ) + ( ( th - bth ) * 0.5 ) )
			
		end
		
		local kills = vgui.Create( "DPanel" )
		kills:SetParent( status )
		kills:Dock( RIGHT )
		kills:SetWide( miscw )
		function kills:Paint( w, h )
			
			if IsValid( ply ) ~= true then return end
			
			local th = math.Round( h * 0.45 )
			
			surface.SetFont( "BZ_LabelBold" )
			
			local top = "Kills"
			local ttw, tth = surface.GetTextSize( top )
			shadowtext( top, ( w - ttw ) * 0.5, ( th - tth ) * 0.5 )
			
			local bot = ply:Frags()
			local btw, bth = surface.GetTextSize( bot )
			shadowtext( bot, ( w - btw ) * 0.5, ( h - th ) + ( ( th - bth ) * 0.5 ) )
			
		end
		
		local hp = vgui.Create( "DPanel" )
		hp:SetParent( status )
		hp:Dock( FILL )
		function hp:Paint( w, h )
			
			if IsValid( ply ) ~= true then return end
			
			local plyteam = ply:Team()
			if plyteam ~= TEAM_BEAT then
				
				surface.SetFont( "BZ_LabelLarge" )
				
				local text = "Unassigned"
				if plyteam == TEAM_SPECTATOR then text = "Spectating" end
				local tw, th = surface.GetTextSize( text )
				shadowtext( text, ( w - tw ) * 0.5, ( h - th ) * 0.5 )
				
			elseif ply:Alive() ~= true then
				
				surface.SetFont( "BZ_LabelLarge" )
				
				local text = "Dead"
				local tw, th = surface.GetTextSize( text )
				shadowtext( text, ( w - tw ) * 0.5, ( h - th ) * 0.5, deadcolor )
				
			else
				
				local hh = math.Round( h * 0.45 )
				
				surface.SetFont( "BZ_LabelBold" )
				
				local health = ply:Health()
				local maxhealth = ply:GetMaxHealth()
				local healthsize = math.Round( w * math.Clamp( health / maxhealth, 0, 1 ) )
				surface.SetDrawColor( healthcolor )
				surface.DrawRect( 0, 0, healthsize, hh )
				
				local htext = health .. "/" .. maxhealth
				local htw, hth = surface.GetTextSize( htext )
				local hs = ( hh - hth ) * 0.5
				shadowtext( htext, hs, hs )
				
				local shield = ply:GetShield()
				local maxshield = ply:GetMaxShield()
				local shieldsize = math.Round( w * math.Clamp( shield / maxshield, 0, 1 ) )
				surface.SetDrawColor( shieldcolor )
				surface.DrawRect( 0, h - hh, shieldsize, hh )
				
				local stext = shield .. "/" .. maxshield
				local stw, sth = surface.GetTextSize( stext )
				local ss = ( hh - sth ) * 0.5
				shadowtext( stext, ss, ( h - hh ) + ss )
				
			end
			
		end
		
	end
	
	return sbpanel
	
end

local sbpanel
function GM:ScoreboardShow()
	
	sbdrawn = true
	
	if IsValid( sbpanel ) == true then sbpanel:Remove() end
	
	sbpanel = vgui.Create( "DPanel" )
	sbpanel:SetSize( ScrW(), ScrH() )
	sbpanel:MakePopup()
	sbpanel:SetKeyboardInputEnabled( false )
	function sbpanel:Paint( w, h )
	end
	function sbpanel.Think( panel )
		
		local plycount = player.GetCount()
		if panel.plycount ~= plycount then
			
			panel.plycount = plycount
			
			if IsValid( panel.panel ) == true then panel.panel:Remove() end
			panel.panel = createsbpanel( self, panel )
			
		end
		
	end
	
end

function GM:ScoreboardHide()
	
	sbdrawn = false
	
	if IsValid( sbpanel ) == true then sbpanel:Remove() end
	
end



local deathtime = GetConVar( "hud_deathnotice_time" )
local deathmsg = {
	
	[ "bz_skeletongunner" ] = {
		
		"%s2 filled %s1 with lead",
		"%s2 gunned %s1 down",
		
	},
	[ "bz_skeletonexploder" ] = {
		
		"%s2 obliterated %s1",
		"%s2 blew %s1 up",
		
	},
	[ "bz_skeletonwizard" ] = {
		
		"%s2 immolated %s1",
		"%s2 charred %s1",
		
	},
	[ "bz_skeletonlad" ] = {
		
		"%s2 beat %s1 to death",
		"%s2 smacked %s1",
		
	},
	
}
local deaths = {}
function GM:AddBZDeathNotice( victim, attacker, msg )
	
	if msg == nil then
		
		msg = "%s2 killed %s1"
		if victim == attacker or attacker == nil then msg = "%s1 died" end
		
	end
	if isstring( victim ) ~= true then victim = victim:Nick() end
	if attacker == nil then attacker = "" end
	if isstring( attacker ) ~= true then
		
		local aname = attacker.PrintName
		if attacker:IsPlayer() == true then aname = attacker:Nick() end
		if aname == nil then aname = "" end
		if aname[ 1 ] == "#" then aname = language.GetPhrase( aname ) end
		attacker = aname
		
	end
	
	table.insert( deaths, {
		
		time = CurTime(),
		victim = victim,
		attacker = attacker,
		msg = msg,
		
	} )
	
end
net.Receive( "BZ_PlayerDeath", function()
	
	local victim = net.ReadEntity()
	local attacker = net.ReadEntity()
	
	if IsValid( victim ) ~= true or IsValid( attacker ) ~= true then return end
	
	local msg
	local msgtbl = deathmsg[ attacker:GetClass() ]
	if msgtbl ~= nil then msg = msgtbl[ math.random( #msgtbl ) ] end
	
	hook.Run( "AddBZDeathNotice", victim, attacker, msg )
	
end )

local enemycolor = Color( 255, 0, 0 )
function GM:DrawDeathNotice( dx, dy )
	
	local remove = {}
	
	local deathh = math.Round( ScrH() * 0.05 )
	local spacing = math.min( ScrW(), ScrH() ) * 0.1
	local sx = ScrW() - spacing
	local sy = spacing
	
	surface.SetFont( "BZ_LabelLarge" )
	
	for i = 1, #deaths do
		
		local death = deaths[ i ]
		local time = death.time + deathtime:GetFloat()
		if CurTime() > time then
			
			table.insert( remove, i )
			
		else
			
			local msg = death.msg
			msg = string.Replace( msg, "%s1", death.victim )
			msg = string.Replace( msg, "%s2", death.attacker )
			
			local tw, th = surface.GetTextSize( msg )
			
			local tcolor
			local scolor
			if CurTime() > time - 1 then
				
				local alpha = time - CurTime()
				tcolor = Color( textcolor.r, textcolor.g, textcolor.b, 255 * alpha )
				scolor = Color( textshadowcolor.r, textshadowcolor.g, textshadowcolor.b, 255 * alpha )
				
			end
			
			shadowtext( msg, sx - tw, sy + ( deathh * ( i - 1 ) ), tcolor, scolor )
			
		end
		
	end
	
	for i = 1, #remove do table.remove( deaths, remove[ i ] ) end
	
end



local hitsound = CreateClientConVar( "bz_hitsound", "sound/ui/hitsound.wav" )
local hitsoundvolume = CreateClientConVar( "bz_hitsoundvolume", 0.25 )
local enabledmgnum = CreateClientConVar( "bz_damagenumbers", 1 )
local dmgnumbatch = CreateClientConVar( "bz_damagenumbersbatch", 1 )
local dmgnumbatchtime = CreateClientConVar( "bz_damagenumbersbatchtime", 1 )
local dmgnumtime = CreateClientConVar( "bz_damagenumberstime", 3 )

local damagenumbers = {}
local damagenumbersbatch = {}

function GM:AddDamageNumber( ent, dmg, pos, crit )
	
	local snd = hitsound:GetString()
	local vol = hitsoundvolume:GetFloat()
	if snd ~= "" and vol > 0 then sound.PlayFile( snd, "noplay", function( channel ) channel:SetVolume( vol ) channel:Play() end ) end
	
	if enabledmgnum:GetBool() ~= true then return end
	
	crit = crit or false
	
	if dmgnumbatch:GetBool() == true then
		
		local batch = damagenumbersbatch[ ent ]
		local key
		if batch ~= nil and CurTime() < batch.time + dmgnumbatchtime:GetFloat() then key = batch.key end
		local dmgnum = damagenumbers[ key ]
		if key ~= nil and dmgnum ~= nil then
			
			damagenumbers[ key ] = {
				
				time = CurTime(),
				ent = ent,
				dmg = dmgnum.dmg + dmg,
				pos = pos,
				crit = crit,
				
			}
			
			batch.time = CurTime()
			
		else
			
			local key = table.insert( damagenumbers, {
				
				time = CurTime(),
				ent = ent,
				dmg = dmg,
				pos = pos,
				crit = crit,
				
			} )
			
			damagenumbersbatch[ ent ] = {
				
				time = CurTime(),
				key = key,
				
			}
			
		end
		
	else
		
		table.insert( damagenumbers, {
			
			time = CurTime(),
			ent = ent,
			dmg = dmg,
			pos = pos,
			crit = crit,
			
		} )
		
	end
	
end

net.Receive( "BZ_EntityDamaged", function()
	
	gmod.GetGamemode():AddDamageNumber( net.ReadEntity(), net.ReadInt( 32 ), net.ReadVector(), net.ReadBool() )
	
end )

local dmgcritcolor = Color( 0, 100, 255, 255 )
local dmgstartcolor = Color( 0, 255, 0, 255 )
local dmgendcolor = Color( 255, 0, 0, 0 )
local colorval = { "r", "g", "b", "a" }
function GM:DrawDamageNumbers()
	
	cam.Start3D()
		
		local remove = {}
		
		surface.SetFont( "BZ_3DText" )
		
		for i = 1, #damagenumbers do
			
			local dmgnum = damagenumbers[ i ]
			
			local length = dmgnumtime:GetFloat()
			local time = dmgnum.time + length
			if CurTime() > time then
				
				table.insert( remove, i )
				
			else
				
				local delta = ( ( CurTime() - time ) / length ) + 1
				
				local pos = dmgnum.pos
				
				local ang = ( pos - EyePos() ):Angle()
				ang:RotateAroundAxis( ang:Right(), 90 )
				ang:RotateAroundAxis( ang:Up(), -90 )
				
				local text = dmgnum.dmg or ""
				local tw, th = surface.GetTextSize( text )
				
				local scale = 0.1
				
				pos = pos - ( ( ang:Forward() * ( tw * 0.5 ) ) * scale )
				pos = pos - ( ( ang:Right() * ( th * 0.5 ) ) * scale )
				
				pos = pos + Vector( 0, 0, 32 * delta )
				
				cam.Start3D2D( pos, ang, scale )
					
					local sc = dmgstartcolor
					if dmgnum.crit == true then sc = dmgcritcolor end
					local ec = dmgendcolor
					local color = Color( sc.r, sc.b, sc.g, sc.a )
					for i = 1, #colorval do
						
						local k = colorval[ i ]
						color[ k ] = Lerp( delta, sc[ k ], ec[ k ] )
						
					end
					
					surface.SetTextColor( textshadowcolor.r, textshadowcolor.g, textshadowcolor.b, Lerp( delta, sc.a, ec.a ) )
					surface.SetTextPos( 2, 2 )
					surface.DrawText( text )
					
					surface.SetTextColor( color )
					surface.SetTextPos( 0, 0 )
					surface.DrawText( text )
					
				cam.End3D2D()
				
			end
			
		end
		
		for i = 1, #remove do
			
			local key = remove[ i ]
			
			table.remove( damagenumbers, key )
			
			for _, v in pairs( damagenumbersbatch ) do if v.key > key then v.key = v.key - 1 end end
			
		end
		
	cam.End3D()
	
end



function GM:HUDDrawTargetID()
	
	local tr = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )
	local ent = tr.Entity
	if tr.Hit == true and tr.HitNonWorld == true and IsValid( ent ) == true and ( ent:IsPlayer() == true or ent.IsBZEnemy == true ) then
		
		surface.SetFont( "BZ_HUDSmaller" )
		
		local name = ""
		local shield
		local maxshield
		
		if ent:IsPlayer() == true then
			
			name = ent:Nick()
			shield = ent:GetShield()
			maxshield = ent:GetMaxShield()
			
		elseif ent.IsBZEnemy == true then
			
			name = ent.PrintName or ""
			if name[ 1 ] == "#" then name = language.GetPhrase( name ) end
			
		end
		
		local isshield = shield ~= nil and maxshield ~= nil
		
		local tw, th = surface.GetTextSize( name )
		local hh = math.max( math.Round( ScrH() * 0.025 ), th )
		
		local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.005 )
		local w = math.min( math.max( math.Round( ScrW() * 0.15 ), tw + ( spacing * 2 ) ), ScrW() )
		local h = hh + ( spacing * 3 ) + th
		local x = math.Round( ( ScrW() - w ) * 0.5 )
		local y = math.Round( ScrH() * 0.525 )
		
		if isshield == true then h = h + hh + spacing end
		
		surface.SetDrawColor( hudbgcolor )
		surface.DrawRect( x, y, w, h )
		
		shadowtext( name, x + math.Round( ( w - tw ) * 0.5 ), y + spacing )
		
		local health = ent:Health()
		local maxhealth = ent:GetMaxHealth()
		local healthsize = math.Round( w * math.Clamp( health / maxhealth, 0, 1 ) ) - ( spacing * 2 )
		surface.SetDrawColor( healthcolor )
		surface.DrawRect( x + spacing, y + th + ( spacing * 2 ), healthsize, hh )
		
		local htext = health .. "/" .. maxhealth
		local htw, hth = surface.GetTextSize( htext )
		local hs = ( hh - hth ) * 0.5
		shadowtext( htext, x + hs + spacing, y + th + hs + ( spacing * 2 ) )
		
		if isshield == true then
			
			local shieldsize = math.Round( w * math.Clamp( shield / maxshield, 0, 1 ) ) - ( spacing * 2 )
			surface.SetDrawColor( shieldcolor )
			surface.DrawRect( x + spacing, y + h - hh - spacing, shieldsize, hh )
			
			local stext = shield .. "/" .. maxshield
			local stw, sth = surface.GetTextSize( stext )
			local ss = ( hh - sth ) * 0.5
			shadowtext( stext, x + ss + spacing, y + ( h - hh - spacing ) + ss )
			
		end
		
	end
	
	cam.Start3D()
		
		surface.SetFont( "BZ_3DText" )
		
		local plys = self:GetPlayers()
		for i = 1, #plys do
			
			local ply = plys[ i ]
			
			local pos = ply:GetPos()
			local head = ply:LookupBone( "ValveBiped.Bip01_Head1" )
			if head ~= nil then
				
				local headpos = ply:GetBonePosition( head )
				if headpos ~= nil then pos = headpos end
				
			end
			
			if ply ~= LocalPlayer() and ply ~= ent and ply:Alive() == true and pos:Distance( EyePos() ) < 512 then
				
				pos = pos + Vector( 0, 0, 16 )
				
				local ang = ( pos - EyePos() ):Angle()
				ang:RotateAroundAxis( ang:Right(), 90 )
				ang:RotateAroundAxis( ang:Up(), -90 )
				
				local scale = 0.025
				
				local name = ply:Nick()
				local tw, th = surface.GetTextSize( name )
				local hh = math.max( 160, th )
				
				local spacing = 32
				local w = math.max( 1536, tw )
				local h = ( hh * 2 ) + ( spacing * 4 ) + th
				
				pos = pos - ( ( ang:Forward() * ( w * 0.5 ) ) * scale )
				pos = pos - ( ( ang:Right() * h ) * scale )
				
				cam.Start3D2D( pos, ang, scale )
					
					surface.SetDrawColor( hudbgcolor )
					surface.DrawRect( 0, 0, w, h )
					
					shadowtext( name, math.Round( ( w - tw ) * 0.5 ), spacing, nil, nil, 4 )
					
					local health = ply:Health()
					local maxhealth = ply:GetMaxHealth()
					local healthsize = math.Round( w * math.Clamp( health / maxhealth, 0, 1 ) ) - ( spacing * 2 )
					surface.SetDrawColor( healthcolor )
					surface.DrawRect( spacing, th + ( spacing * 2 ), healthsize, hh )
					
					local htext = health .. "/" .. maxhealth
					local htw, hth = surface.GetTextSize( htext )
					local hs = ( hh - hth ) * 0.5
					shadowtext( htext, hs + spacing, th + hs + ( spacing * 2 ), nil, nil, 4 )
					
					local shield = ply:GetShield()
					local maxshield = ply:GetMaxShield()
					local shieldsize = math.Round( w * math.Clamp( shield / maxshield, 0, 1 ) ) - ( spacing * 2 )
					surface.SetDrawColor( shieldcolor )
					surface.DrawRect( spacing, h - hh - spacing, shieldsize, hh )
					
					local stext = shield .. "/" .. maxshield
					local stw, sth = surface.GetTextSize( stext )
					local ss = ( hh - sth ) * 0.5
					shadowtext( stext, ss + spacing, ( h - hh - spacing ) + ss, nil, nil, 4 )
					
				cam.End3D2D()
				
			end
			
		end
		
		--[[
		local skels = self.Skeletons
		for i = 1, #skels do
			
			local skel = skels[ i ]
			
			local pos = skel:GetPos()
			local head = skel:LookupBone( "bip_head" )
			if head ~= nil then
				
				local headpos = skel:GetBonePosition( head )
				if headpos ~= nil then pos = headpos end
				
			end
			
			if skel ~= ent and pos:Distance( EyePos() ) < 512 then
				
				pos = pos + Vector( 0, 0, 16 )
				
				local ang = ( pos - EyePos() ):Angle()
				ang:RotateAroundAxis( ang:Right(), 90 )
				ang:RotateAroundAxis( ang:Up(), -90 )
				
				local scale = 0.025
				
				local hh = 160
				
				local spacing = 8
				local w = 512
				local h = hh + ( spacing * 2 )
				
				pos = pos - ( ( ang:Forward() * ( w * 0.5 ) ) * scale )
				pos = pos - ( ( ang:Right() * h ) * scale )
				
				cam.Start3D2D( pos, ang, scale )
					
					surface.SetDrawColor( hudbgcolor )
					surface.DrawRect( 0, 0, w, h )
					
					local health = skel:Health()
					local maxhealth = skel:GetMaxHealth()
					local healthsize = math.Round( w * math.Clamp( health / maxhealth, 0, 1 ) ) - ( spacing * 2 )
					surface.SetDrawColor( healthcolor )
					surface.DrawRect( spacing, spacing, healthsize, hh )
					
					local htext = health .. "/" .. maxhealth
					local htw, hth = surface.GetTextSize( htext )
					local hs = ( hh - hth ) * 0.5
					shadowtext( htext, hs + spacing, hs + spacing, nil, nil, 4 )
					
				cam.End3D2D()
				
			end
			
		end
		]]--
		
	cam.End3D()
	
end
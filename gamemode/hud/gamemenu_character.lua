DEFINE_BASECLASS( "gamemode_base" )

include( "editplayer.lua" )



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
	
	local perkname = gm.HUD:CreateLabel( perkmenu, "", "BZ_LabelLarge" )
	perkname:Dock( TOP )
	
	local perkdesc = vgui.Create( "RichText" )
	perkdesc:SetParent( perkmenu )
	perkdesc:Dock( TOP )
	function perkdesc:PerformLayout( w, h )
		
		self:SetFontInternal( "BZ_LabelBold" )
		self:SetFGColor( gm.HUD.Color.textcolor )
		
	end
	
	local curperk
	local curperkbutton
	
	local perkbuttonbg = vgui.Create( "DPanel" )
	perkbuttonbg:SetParent( perkmenu )
	perkbuttonbg:Dock( BOTTOM )
	function perkbuttonbg:Paint( w, h ) end
	
	local perkpoints = gm.HUD:CreateLabel( perkmenu, ply:GetPerkPoints() .. " perk points", "BZ_LabelLarge" )
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
	perkbuy = gm.HUD:CreateButton( perkbuttonbg, "", function( self )
		
		if curperk == nil or gm:PlayerCanBuyPerk( ply, curperk ) ~= true then return end
		
		local count = gm:PlayerGetPerkNum( ply, curperk ) + 1
		updateperkmenu( ply:GetPerkPoints() - curperk.Cost, count )
		perkdesc:SetText( curperk:GetDescription( ply, count ) )
		
		gm:BuyPerk( curperk )
		
	end )
	perkbuy:Dock( LEFT )
	function perkbuy:GetButtonBGColor()
		
		if curperk == nil then return end
		if gm:PlayerCanBuyPerk( ply, curperk ) ~= true then return gm.HUD.Color.buttoninactivecolor, true end
		
	end
	
	perksell = gm.HUD:CreateButton( perkbuttonbg, "", function( self )
		
		if curperk == nil or gm:PlayerCanSellPerk( ply, curperk ) ~= true then return end
		
		local count = gm:PlayerGetPerkNum( ply, curperk ) - 1
		updateperkmenu( ply:GetPerkPoints() + curperk.Cost, count )
		perkdesc:SetText( curperk:GetDescription( ply, count ) )
		
		gm:SellPerk( curperk )
		
	end )
	perksell:Dock( RIGHT )
	function perksell:GetButtonBGColor()
		
		if curperk == nil then return end
		if gm:PlayerCanSellPerk( ply, curperk ) ~= true then return gm.HUD.Color.buttoninactivecolor, true end
		
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
		
		local perkbutton = gm.HUD:CreateButton( perkscroll, name, function( self )
			
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
			
			if gm:PlayerHasPerk( ply, perk ) == true then return gm.HUD.Color.buttonspecialcolor end
			if gm:PlayerCanBuyPerk( ply, perk ) ~= true then return gm.HUD.Color.buttoninactivecolor end
			
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
	charsheet:SetFadeTime( 0 )
	function charsheet:Paint( w, h ) end
	
	
	--class menu
	local classmenu = vgui.Create( "DPanel" )
	function classmenu:Paint( w, h ) end
	
	local classscroll = vgui.Create( "DScrollPanel" )
	classscroll:SetParent( classmenu )
	classscroll:Dock( LEFT )
	classscroll:DockMargin( 0, 0, spacing, 0 )
	
	local classname = gm.HUD:CreateLabel( classmenu, "", "BZ_LabelLarge" )
	classname:Dock( TOP )
	
	local classdesc = vgui.Create( "RichText" )
	classdesc:SetParent( classmenu )
	classdesc:Dock( TOP )
	function classdesc:PerformLayout( w, h )
		
		self:SetFontInternal( "BZ_LabelBold" )
		self:SetFGColor( gm.HUD.Color.textcolor )
		
	end
	
	local classtoggle = gm.HUD:CreateButton( classmenu, "Select class" )
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
		
		local classbutton = gm.HUD:CreateButton( classscroll, class.DisplayName, function()
			
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
		classbutton:SetDoubleClickingEnabled( true )
		function classbutton:GetButtonBGColor()
			
			if player_manager.GetPlayerClass( ply ) == classid then return gm.HUD.Color.buttonspecialcolor end
			
		end
		function classbutton:DoDoubleClick()
			
			classtoggle:DoClick()
			
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
		
		surface.SetDrawColor( gm.HUD.Color.buttoncolor )
		if self:IsActive() then surface.SetDrawColor( gm.HUD.Color.buttonactivecolor ) end
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
		
		surface.SetDrawColor( gm.HUD.Color.buttoncolor )
		if self:IsActive() then surface.SetDrawColor( gm.HUD.Color.buttonactivecolor ) end
		surface.DrawRect( 0, 0, w, 20 )
		
	end
	
	
	--loadout menu
	local loadoutmenu = vgui.Create( "DPanel" )
	function loadoutmenu:Paint( w, h ) end
	
	local loadoutscroll = vgui.Create( "DScrollPanel" )
	loadoutscroll:SetParent( loadoutmenu )
	loadoutscroll:Dock( LEFT )
	loadoutscroll:DockMargin( 0, 0, spacing, 0 )
	
	local loadoutname = gm.HUD:CreateLabel( loadoutmenu, "", "BZ_LabelLarge" )
	loadoutname:Dock( TOP )
	
	local loadoutmodel = vgui.Create( "DModelPanel" )
	loadoutmodel:SetParent( loadoutmenu )
	loadoutmodel:Dock( TOP )
	
	local loadoutdesc = vgui.Create( "RichText" )
	loadoutdesc:SetParent( loadoutmenu )
	loadoutdesc:Dock( TOP )
	function loadoutdesc:PerformLayout( w, h )
		
		self:SetFontInternal( "BZ_LabelBold" )
		self:SetFGColor( gm.HUD.Color.textcolor )
		
	end
	
	local loadouttoggle = gm.HUD:CreateButton( loadoutmenu )
	loadouttoggle:Dock( BOTTOM )
	
	local loadoutpoints = gm.HUD:CreateLabel( loadoutmenu, ply:GetLoadoutPoints() .. " loadout points", "BZ_LabelLarge" )
	loadoutpoints:Dock( BOTTOM )
	
	local curitem
	local curitembutton
	
	local loadoutsell
	local function loadoutbuy( button )
		
		if curitem == nil or gm:PlayerCanBuyItem( ply, curitem ) ~= true then return end
		
		button:SetText( "Sell (" .. curitem.Cost .. " point" .. ( ( curitem.Cost ~= 1 and "s" ) or "" ) .. ")" )
		loadoutpoints:SetText( ( ply:GetLoadoutPoints() - curitem.Cost ) .. " loadout points" )
		
		gm:BuyItem( curitem )
		
		local name = curitem.Name or ""
		if name[ 1 ] == "#" then name = language.GetPhrase( name ) end
		curitembutton:SetText( name .. " (owned)" )
		button.DoClick = loadoutsell
		function button:GetButtonBGColor()
			
			if gm:PlayerCanSellItem( ply, curitem ) ~= true then return gm.HUD.Color.buttoninactivecolor, true end
			
		end
		
	end
	function loadoutsell( button )
		
		if curitem == nil or gm:PlayerCanSellItem( ply, curitem ) ~= true then return end
		
		button:SetText( "Buy (" .. curitem.Cost .. " point" .. ( ( curitem.Cost ~= 1 and "s" ) or "" ) .. ")" )
		loadoutpoints:SetText( ( ply:GetLoadoutPoints() + curitem.Cost ) .. " loadout points" )
		
		gm:SellItem( curitem )
		
		local name = curitem.Name or ""
		if name[ 1 ] == "#" then name = language.GetPhrase( name ) end
		curitembutton:SetText( name )
		button.DoClick = loadoutbuy
		function button:GetButtonBGColor()
			
			if gm:PlayerCanBuyItem( ply, curitem ) ~= true then return gm.HUD.Color.buttoninactivecolor, true end
			
		end
		
	end
	
	local itembuttontall = math.Round( ScrH() * 0.05 )
	for i = 1, gm:GetItemCount() do
		
		local item = gm:GetItem( i )
		
		local name = item.Name or ""
		if name[ 1 ] == "#" then name = language.GetPhrase( name ) end
		if gm:PlayerHasItem( ply, item ) == true then name = name .. " (owned)" end
		local itembutton = gm.HUD:CreateButton( loadoutscroll, name, function( button )
			
			curitem = item
			curitembutton = button
			
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
					
					if gm:PlayerCanSellItem( ply, curitem ) ~= true then return gm.HUD.Color.buttoninactivecolor, true end
					
				end
				
			else
				
				loadouttoggle:SetText( "Buy (" .. item.Cost .. " point" .. ( ( item.Cost ~= 1 and "s" ) or "" ) .. ")" )
				loadouttoggle.DoClick = loadoutbuy
				function loadouttoggle:GetButtonBGColor()
					
					if gm:PlayerCanBuyItem( ply, curitem ) ~= true then return gm.HUD.Color.buttoninactivecolor, true end
					
				end
				
			end
			
		end )
		itembutton:Dock( TOP )
		itembutton:DockMargin( 0, 0, 0, spacing )
		itembutton:SetTall( itembuttontall )
		itembutton:SetFont( "BZ_MenuButtonSmall" )
		itembutton:SetDoubleClickingEnabled( true )
		function itembutton:GetButtonBGColor()
			
			if gm:PlayerHasItem( ply, item ) == true then return gm.HUD.Color.buttonspecialcolor end
			if gm:PlayerCanBuyItem( ply, item ) ~= true then return gm.HUD.Color.buttoninactivecolor end
			
		end
		function itembutton:DoDoubleClick()
			
			loadouttoggle:DoClick()
			
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
		
		surface.SetDrawColor( gm.HUD.Color.buttoncolor )
		if self:IsActive() then surface.SetDrawColor( gm.HUD.Color.buttonactivecolor ) end
		surface.DrawRect( 0, 0, w, 20 )
		
	end
	
	
	return charsheet
	
end



local lastteamswitch
local function canswitchteam( gm )
	
	if lastteamswitch == nil or CurTime() > lastteamswitch + gm.SecondsBetweenTeamSwitches + 1 then return true end
	
	return false
	
end

function GM:CreateCharacterMenu()
	
	local ply = LocalPlayer()
	if IsValid( ply ) ~= true then return end
	
	local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
	
	local charmenu = vgui.Create( "DPanel" )
	function charmenu.Paint( panel, w, h, ... )
		
		self.HUD:PaintPanel( panel, w, h, ... )
		
		local size = math.min( w, h )
		
		surface.SetDrawColor( self.HUD.Color.detailcolor )
		surface.DrawRect( ( size * 0.5 ) - 1, 0, 1, h )
		
	end
	function charmenu.Think( panel )
		
		local vis = ply:Team() == TEAM_BEAT
		if panel.vis ~= vis then
			
			panel.vis = vis
			
			if vis == true then
				
				panel.charsheet = createcharsheet( self, charmenu )
				
			elseif IsValid( panel.charsheet ) == true then
				
				panel.charsheet:Remove()
				
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
	
	local joinspec
	local function joinbeat( button )
		
		if canswitchteam( self ) ~= true then return end
		
		lastteamswitch = CurTime()
		
		RunConsoleCommand( "changeteam", TEAM_BEAT )
		button.DoClick = joinspec
		button:SetText( "Spectate" )
		
	end
	function joinspec( button )
		
		if canswitchteam( self ) ~= true then return end
		
		lastteamswitch = CurTime()
		
		RunConsoleCommand( "changeteam", TEAM_SPECTATOR )
		button.DoClick = joinbeat
		button:SetText( "Beat" )
		
	end
	
	local jointoggle = self.HUD:CreateButton( charbg, "Beat", joinbeat )
	if ply:Team() == TEAM_BEAT then
		
		jointoggle.DoClick = joinspec
		jointoggle:SetText( "Spectate" )
		
	end
	jointoggle:Dock( BOTTOM )
	function jointoggle.GetButtonBGColor( button )
		
		if canswitchteam( self ) ~= true then return self.HUD.Color.buttoninactivecolor, true end
		
	end
	
	function charbg:PerformLayout( w, h )
		
		jointoggle:SetTall( h * 0.1 )
		
	end
	
	function charmenu:PerformLayout( w, h )
		
		charbg:SetWide( math.min( w, h ) * 0.5 )
		
	end
	
	return charmenu
	
end
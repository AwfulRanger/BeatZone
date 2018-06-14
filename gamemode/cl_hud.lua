DEFINE_BASECLASS( "gamemode_base" )

include( "cl_editplayer.lua" )



surface.CreateFont( "BZ_MenuButton", {
	
	font = "Roboto",
	size = math.Round( math.min( ScrW(), ScrH() ) * 0.025 ),
	weight = 300,
	
} )

surface.CreateFont( "BZ_HUD", {
	
	font = "Roboto",
	size = math.Round( math.min( ScrW(), ScrH() ) * 0.05 ),
	weight = 300,
	
} )

surface.CreateFont( "BZ_HUDSmall", {
	
	font = "Roboto",
	size = math.Round( math.min( ScrW(), ScrH() ) * 0.035 ),
	weight = 300,
	
} )

local bgcolor = Color( 47, 4, 70, 250 )
local detailcolor = Color( 53, 19, 161, 255 )
local buttoncolor = Color( 121, 6, 71, 255 )
local buttonactivecolor = Color( 188, 1, 107, 255 )
local textcolor = Color( 255, 255, 255, 255 )
local textshadowcolor = Color( 0, 0, 0, 255 )

local function shadowtext( text, x, y, tcolor, scolor )
	
	tcolor = tcolor or textcolor
	scolor = scolor or textshadowcolor
	
	local offset = math.Round( math.min( ScrW(), ScrH() ) * 0.002 )
	
	surface.SetTextPos( x + offset, y + offset )
	surface.SetTextColor( scolor )
	surface.DrawText( text )
	
	surface.SetTextPos( x, y )
	surface.SetTextColor( tcolor )
	surface.DrawText( text )
	
end

local function paintbutton( self, w, h )
	
	surface.SetDrawColor( buttoncolor )
	if self:IsHovered() == true then surface.SetDrawColor( buttonactivecolor ) end
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

local function createbutton( parent, text, func )
	
	local button = vgui.Create( "DButton" )
	if parent ~= nil then button:SetParent( parent ) end
	if text ~= nil then button:SetText( text ) end
	if func ~= nil then button.DoClick = func end
	button.Paint = paintbutton
	button:SetFont( "BZ_MenuButton" )
	
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
local function createmenu( tab )
	
	if IsValid( frame ) == true then frame:Remove() end
	
	local ply = LocalPlayer()
	if IsValid( ply ) ~= true then return end
	
	frame = vgui.Create( "DFrame" )
	frame:SetSize( ScrW() * 0.8, ScrH() * 0.8 )
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
			surface.DrawRect( size * 0.5, 0, 1, h )
			surface.DrawRect( ( size * 0.5 ) + 1, h - ( size * 0.15 ), w - ( size * 0.5 ), 1 )
			
		end
		
		local modelcvar = GetConVar( "cl_playermodel" )
		local skincvar = GetConVar( "cl_playerskin" )
		
		local playermodel = vgui.Create( "DModelPanel" )
		playermodel:SetParent( charmenu )
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
		
		local joinbeat = createbutton( charmenu, "Beat", function() RunConsoleCommand( "changeteam", TEAM_BEAT ) end )
		local joinspec = createbutton( charmenu, "Spectate", function() RunConsoleCommand( "changeteam", TEAM_SPECTATOR ) end )
		
		function charmenu:PerformLayout( w, h )
			
			local size = math.min( w, h )
			
			playermodel:SetPos( size * 0.05, size * 0.05 )
			playermodel:SetSize( size * 0.4, h - ( size * 0.2 ) )
			
			joinbeat:SetPos( size * 0.05, h - ( size * 0.1 ) )
			joinbeat:SetSize( size * 0.175, size * 0.05 )
			
			joinspec:SetPos( size * 0.275, h - ( size * 0.1 ) )
			joinspec:SetSize( size * 0.175, size * 0.05 )
			
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

function GM:ShowHelp() createmenu( 1 ) end
function GM:ShowTeam() createmenu( 2 ) end
function GM:ShowSpare1() createmenu( 3 ) end
function GM:ShowSpare2() createmenu( 4 ) end



----
--HUD
----
local statestr = {
	
	[ ROUND_INITIALIZING ] = "Initializing",
	[ ROUND_INTERMISSION ] = "Intermission",
	[ ROUND_STARTING ] = "Starting",
	[ ROUND_ONGOING ] = "Ongoing",
	[ ROUND_ENDING ] = "Ending",
	
}
function GM:HUDPaint()
	
	local ply = LocalPlayer()
	local state = self:GetRoundState()
	
	surface.SetFont( "BZ_HUDSmall" )
	local statetext = statestr[ state ] .. " (Round " .. self:GetRound() .. ")"
	local sw, sh = surface.GetTextSize( statetext )
	shadowtext( statetext, ( ScrW() - sw ) * 0.5, ( ScrH() * 0.05 ) - sh )
	
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
				
				shadowtext( timetext, ( ScrW() - tw ) * 0.5, ScrH() * 0.2 )
				
			end
			
		end
		
		shadowtext( readytext, ( ScrW() - rw ) * 0.5, ( ScrH() * 0.2 ) - rh )
		
	end
	
end

local cmenu
function GM:OnContextMenuOpen()
	
	if IsValid( cmenu ) == true then cmenu:Remove() end
	
	cmenu = vgui.Create( "DPanel" )
	cmenu:SetSize( ScrW(), ScrH() )
	cmenu:MakePopup()
	cmenu:SetKeyboardInputEnabled( false )
	function cmenu:Paint() end
	
	if self:GetRoundState() == ROUND_INTERMISSION then
		
		local ready = createbutton( cmenu, "Toggle ready", function() self:Ready() end )
		ready:SetPos( ScrW() * 0.2, ScrH() * 0.45 )
		ready:SetSize( ScrW() * 0.1, ScrH() * 0.1 )
		
	end
	
end

function GM:OnContextMenuClose()
	
	if IsValid( cmenu ) == true then cmenu:Remove() end
	
end
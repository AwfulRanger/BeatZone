DEFINE_BASECLASS( "gamemode_base" )



include( "cl_help.lua" )



GM.HUD = {}

function GM.HUD:CreateFonts()
	
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

GM.HUD:CreateFonts()



function GM.HUD:CreateColors( colors )
	
	self.Color = {
		
		bg = Color( 47, 4, 70, 250 ),
		detail = Color( 53, 19, 161, 255 ),
		button = Color( 121, 6, 71, 255 ),
		buttonactive = Color( 188, 1, 107, 255 ),
		buttoninactive = Color( 85, 0, 48, 255 ),
		buttonspecial = Color( 149, 9, 88, 255 ),
		text = Color( 255, 255, 255, 255 ),
		textshadow = Color( 0, 0, 0, 255 ),
		hudbg = Color( 47, 4, 70, 100 ),
		
		plyready = Color( 0, 255, 0, 255 ),
		plyunready = Color( 255, 0, 0, 255 ),
		
		dmgcrit = Color( 0, 100, 255, 255 ),
		dmgstart = Color( 0, 255, 0, 255 ),
		dmgend = Color( 255, 0, 0, 0 ),
		
		health = Color( 227, 24, 139, 200 ),
		shield = Color( 41, 92, 209, 200 ),
		clip = Color( 146, 32, 209, 200 ),
		ammo = Color( 69, 10, 101, 200 ),
		
		dead = Color( 255, 0, 0, 255 ),
		
		voteyes = Color( 0, 255, 0, 255 ),
		voteno = Color( 255, 0, 0, 255 ),
		
		abilityunready = Color( 105, 105, 0, 150 ),
		abilityready = Color( 151, 151, 8, 200 ),
		
	}
	
	if colors ~= nil then for _, v in pairs( colors ) do self.Color[ _ ] = v end end
	
end

GM.HUD:CreateColors()



function GM.HUD:ShadowText( text, x, y, tcolor, scolor, offset )
	
	tcolor = tcolor or self.Color.text
	scolor = scolor or self.Color.textshadow
	offset = offset or math.Round( math.min( ScrW(), ScrH() ) * 0.002 )
	
	surface.SetTextPos( x + offset, y + offset )
	surface.SetTextColor( scolor )
	surface.DrawText( text )
	
	surface.SetTextPos( x, y )
	surface.SetTextColor( tcolor )
	surface.DrawText( text )
	
end

function GM.HUD:PaintButton( panel, w, h )
	
	surface.SetDrawColor( self.Color.button )
	local override = false
	if panel.GetButtonBGColor ~= nil then
		
		local bgcolor
		bgcolor, override = panel:GetButtonBGColor()
		if bgcolor ~= nil then surface.SetDrawColor( bgcolor ) end
		
	end
	if override ~= true and panel:IsHovered() == true then surface.SetDrawColor( self.Color.buttonactive ) end
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetFont( panel:GetFont() )
	local text = panel:GetText()
	local tw, th = surface.GetTextSize( text )
	self:ShadowText( text, ( w - tw ) * 0.5, ( h - th ) * 0.5 )
	
	return true
	
end

function GM.HUD:PaintPanel( panel, w, h )
	
	surface.SetDrawColor( self.Color.detail )
	
	surface.DrawRect( 0, 0, w, 1 ) --top
	surface.DrawRect( 0, h - 1, w, 1 ) --bottom
	surface.DrawRect( 0, 1, 1, h - 2 ) --left
	surface.DrawRect( w - 1, 1, 1, h - 2 ) --right
	
end

function GM.HUD:CreateLabel( parent, text, font, centerx, centery )
	
	local label = vgui.Create( "DLabel" )
	if parent ~= nil then label:SetParent( parent ) end
	if text ~= nil then label:SetText( text ) end
	function label.Paint( panel, w, h )
		
		surface.SetFont( panel:GetFont() )
		local text = panel:GetText()
		local tw, th = surface.GetTextSize( text )
		local x = 0
		if centerx ~= false then x = ( w - tw ) * 0.5 end
		local y = 0
		if centery ~= false then y = ( h - th ) * 0.5 end
		self:ShadowText( text, x, y )
		
		return true
		
	end
	
	label:SetFont( font or "BZ_Label" )
	
	return label
	
end

function GM.HUD:CreateButton( parent, text, func )
	
	local button = vgui.Create( "DButton" )
	if parent ~= nil then button:SetParent( parent ) end
	if text ~= nil then button:SetText( text ) end
	if func ~= nil then button.DoClick = func end
	button.Paint = function( ... ) return self:PaintButton( ... ) end
	button:SetFont( "BZ_MenuButton" )
	button:SetDoubleClickingEnabled( false )
	
	return button
	
end



include( "hud/hud.lua" )
include( "hud/gamemenu.lua" )
include( "hud/contextmenu.lua" )
include( "hud/scoreboard.lua" )
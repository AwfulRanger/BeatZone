DEFINE_BASECLASS( "gamemode_base" )



GM.SettingsData = GM.SettingsData or {}
GM.SettingsDataNames = GM.SettingsDataNames or {}

function GM:AddSettingsData( name, data )
	
	data = data or {}
	
	name = tostring( name )
	
	local index
	if self.SettingsData[ name ] == nil then
		
		index = table.insert( self.SettingsDataNames, name )
		
	else
		
		index = self.SettingsData[ name ].Index
		
	end
	
	data.IDName = name
	data.Index = index
	data.Name = data.Name or ( "#" .. name )
	data.CreatePanel = data.CreatePanel or function( self, gm ) return vgui.Create( "DPanel" ) end
	data.Load = data.Load or function( self, gm ) end
	data.Save = data.Save or function( self, gm ) end
	
	self.SettingsData[ name ] = data
	
end

function GM:GetSettingsData( id )
	
	if isnumber( id ) == true then return self.SettingsData[ self.SettingsDataNames[ id ] ] end
	
	return self.SettingsData[ tostring( id ) ]
	
end

function GM:GetSettingsDataCount()
	
	return #self.SettingsDataNames
	
end

file.CreateDir( "beatzone/settings" )
function GM:GetSettingsFile( settings, mode, name )
	
	name = name or settings.IDName
	
	return file.Open( "beatzone/settings/" .. ( name or "" ) .. ".dat", mode, "DATA" )
	
end



----
--Add settings data
----
local colorlist = {
	
	{ id = "bgcolor", name = "Menu background" },
	{ id = "detailcolor", name = "Detail" },
	{ id = "buttoncolor", name = "Button (default)" },
	{ id = "buttonactivecolor", name = "Button (active)" },
	{ id = "buttoninactivecolor", name = "Button (inactive)" },
	{ id = "buttonspecialcolor", name = "Button (special)" },
	{ id = "textcolor", name = "Text" },
	{ id = "textshadowcolor", name = "Text shadow" },
	{ id = "hudbgcolor", name = "HUD background" },
	
	{ id = "plyreadycolor", name = "Ready player" },
	{ id = "plyunreadycolor", name = "Unready player" },
	
	{ id = "dmgcritcolor", name = "Critical damage" },
	{ id = "dmgstartcolor", name = "Damage start" },
	{ id = "dmgendcolor", name = "Damage end" },
	
	{ id = "healthcolor", name = "Health" },
	{ id = "shieldcolor", name = "Shield" },
	{ id = "clipcolor", name = "Loaded ammo" },
	{ id = "ammocolor", name = "Reserve ammo" },
	
	{ id = "deadcolor", name = "Dead player" },
	
	{ id = "voteyescolor", name = "Yes vote count" },
	{ id = "votenocolor", name = "No vote count" },
	
}
GM:AddSettingsData( "hudcolors", {
	
	Name = "HUD colors",
	CreatePanel = function( self, gm )
		
		local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
		
		local panel = vgui.Create( "DPanel" )
		function panel:Paint( w, h )
		end
		
		local colorscroll = vgui.Create( "DScrollPanel" )
		colorscroll:SetParent( panel )
		colorscroll:Dock( LEFT )
		
		local colorname = gm.HUD:CreateLabel( panel, "", "BZ_LabelLarge" )
		colorname:Dock( TOP )
		
		local colormixer = vgui.Create( "DColorMixer" )
		colormixer:SetParent( panel )
		colormixer:Dock( FILL )
		colormixer:DockMargin( spacing, spacing, 0, 0 )
		
		local buttonbg = vgui.Create( "DPanel" )
		buttonbg:SetParent( panel )
		buttonbg:Dock( BOTTOM )
		buttonbg:DockMargin( spacing, spacing, 0, 0 )
		function buttonbg:Paint( w, h )
		end
		
		local savebutton = gm.HUD:CreateButton( buttonbg, "Save", function( button )
			
			self:Save( gm )
			
		end )
		
		local loadbutton = gm.HUD:CreateButton( buttonbg, "Reload", function( button )
			
			self:Load( gm )
			
		end )
		
		local defaultbutton = gm.HUD:CreateButton( buttonbg, "Reset to default", function( button )
			
			gm.HUD:CreateColors()
			
		end )
		
		function buttonbg:PerformLayout( w, h )
			
			local size = ( w - spacing ) * ( 1 / 3 )
			savebutton:SetPos( 0, 0 )
			savebutton:SetSize( size, h )
			loadbutton:SetPos( size + spacing, 0 )
			loadbutton:SetSize( size, h )
			defaultbutton:SetPos( ( size + spacing ) * 2, 0 )
			defaultbutton:SetSize( size, h )
			
		end
		
		local colorbuttontall = math.Round( ScrH() * 0.05 )
		
		for i = 1, #colorlist do
			
			local color = colorlist[ i ]
			
			local name = color.name or ""
			local colorbutton = gm.HUD:CreateButton( colorscroll, name, function( button )
				
				colorname:SetText( name )
				function colormixer:ValueChanged( colortbl )
					
					gm.HUD.Color[ color.id ] = colortbl
					
				end
				colormixer:SetColor( gm.HUD.Color[ color.id ] )
				
			end )
			colorbutton:Dock( TOP )
			colorbutton:DockMargin( 0, 0, 0, spacing )
			colorbutton:SetTall( colorbuttontall )
			colorbutton:SetFont( "BZ_MenuButtonSmall" )
			local oldpaint = colorbutton.Paint
			function colorbutton:Paint( w, h, ... )
				
				surface.SetDrawColor( gm.HUD.Color.buttoncolor )
				local override = false
				if self.GetButtonBGColor ~= nil then
					
					local bgcolor
					bgcolor, override = self:GetButtonBGColor()
					if bgcolor ~= nil then surface.SetDrawColor( bgcolor ) end
					
				end
				if override ~= true and self:IsHovered() == true then surface.SetDrawColor( gm.HUD.Color.buttonactivecolor ) end
				surface.DrawRect( 0, 0, w, h )
				
				local size = math.Round( h * 0.8 )
				local pos = math.Round( ( h - size ) * 0.5 )
				
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawRect( pos - 1, pos - 1, size + 2, size + 2 )
				
				surface.SetDrawColor( 0, 0, 0, 255 )
				surface.DrawRect( w - pos - size - 1, pos - 1, size + 2, size + 2 )
				
				surface.SetDrawColor( gm.HUD.Color[ color.id ] )
				surface.DrawRect( pos, pos, size, size )
				surface.DrawRect( w - pos - size, pos, size, size )
				
				surface.SetFont( self:GetFont() )
				local text = self:GetText()
				local tw, th = surface.GetTextSize( text )
				gm.HUD:ShadowText( text, ( w - tw ) * 0.5, ( h - th ) * 0.5 )
				
				return true
				
			end
			
			if i == 1 then colorbutton:DoClick() end
			
		end
		
		function panel:PerformLayout( w, h )
			
			colorscroll:SetWide( w * 0.3 )
			colorname:SetTall( h * 0.1 )
			buttonbg:SetTall( h * 0.15 )
			
		end
		
		return panel
		
	end,
	Save = function( self, gm )
		
		local f = gm:GetSettingsFile( self, "w" )
		f:Write( util.TableToJSON( gm.HUD.Color ) )
		f:Close()
		
	end,
	Load = function( self, gm )
		
		local f = gm:GetSettingsFile( self, "r" )
		local tbl = util.JSONToTable( f:Read( f:Size() ) )
		f:Close()
		
		gm.HUD:CreateColors( tbl )
		
	end,
	
} )
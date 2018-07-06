DEFINE_BASECLASS( "gamemode_base" )



function GM:CreateSettingsMenu()
	
	local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
	local ply = LocalPlayer()
	
	local settingsmenu = vgui.Create( "DPanel" )
	function settingsmenu.Paint( panel, w, h, ... )
		
		self.HUD:PaintPanel( panel, w, h, ... )
		
		local size = math.min( w, h )
		
		surface.SetDrawColor( self.HUD.Color.detailcolor )
		surface.DrawRect( ( size * 0.5 ) - 1, 0, 1, h )
		
	end
	
	local settingsscroll = vgui.Create( "DScrollPanel" )
	settingsscroll:SetParent( settingsmenu )
	settingsscroll:Dock( LEFT )
	settingsscroll:DockMargin( spacing, spacing, spacing, spacing )
	
	local settingsinfo = vgui.Create( "DPanel" )
	settingsinfo:SetParent( settingsmenu )
	settingsinfo:Dock( FILL )
	settingsinfo:DockMargin( spacing, spacing, spacing, spacing )
	function settingsinfo:Paint( w, h )
	end
	
	local settingsname = self.HUD:CreateLabel( settingsinfo, "", "BZ_LabelLarge" )
	settingsname:Dock( TOP )
	
	local settingspanel = vgui.Create( "DPanel" )
	settingspanel:SetParent( settingsinfo )
	settingspanel:Dock( FILL )
	function settingspanel:Paint( w, h )
	end
	
	function settingsinfo:PerformLayout( w, h )
		
		settingsname:SetTall( h * 0.1 )
		
	end
	
	local settingsbuttontall = math.Round( ScrH() * 0.05 )
	
	for i = 1, self:GetSettingsDataCount() do
		
		local settings = self:GetSettingsData( i )
		
		local settingsbutton = self.HUD:CreateButton( settingsscroll, settings.Name, function( button )
			
			settingsname:SetText( settings.Name or "" )
			
			if IsValid( settingspanel.panel ) == true then settingspanel.panel:Remove() end
			settingspanel.panel = settings:CreatePanel( self )
			settingspanel.panel:SetParent( settingspanel )
			settingspanel.panel:Dock( FILL )
			
		end )
		settingsbutton:Dock( TOP )
		settingsbutton:DockMargin( 0, 0, 0, spacing )
		settingsbutton:SetTall( settingsbuttontall )
		settingsbutton:SetFont( "BZ_MenuButtonSmall" )
		
		if i == 1 then settingsbutton:DoClick() end
		
	end
	
	function settingsmenu:PerformLayout( w, h )
		
		local size = math.min( w, h )
		
		settingsscroll:SetWide( math.Round( size * 0.5 ) - ( spacing * 2 ) )
		
	end
	
	return settingsmenu
	
end
DEFINE_BASECLASS( "gamemode_base" )



function GM:CreateHelpMenu()
	
	local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
	local ply = LocalPlayer()
	
	local helpmenu = vgui.Create( "DPanel" )
	function helpmenu.Paint( panel, w, h, ... )
		
		self.HUD:PaintPanel( panel, w, h, ... )
		
		local size = math.min( w, h )
		
		surface.SetDrawColor( self.HUD.Color.detailcolor )
		surface.DrawRect( ( size * 0.5 ) - 1, 0, 1, h )
		
	end
	
	local helpscroll = vgui.Create( "DScrollPanel" )
	helpscroll:SetParent( helpmenu )
	helpscroll:Dock( LEFT )
	helpscroll:DockMargin( spacing, spacing, spacing, spacing )
	
	local helpinfo = vgui.Create( "DPanel" )
	helpinfo:SetParent( helpmenu )
	helpinfo:Dock( FILL )
	helpinfo:DockMargin( spacing, spacing, spacing, spacing )
	function helpinfo:Paint( w, h )
	end
	
	local helpname = self.HUD:CreateLabel( helpinfo, "", "BZ_LabelLarge" )
	helpname:Dock( TOP )
	
	local helppanel = vgui.Create( "DPanel" )
	helppanel:SetParent( helpinfo )
	helppanel:Dock( FILL )
	function helppanel:Paint( w, h )
	end
	
	function helpinfo:PerformLayout( w, h )
		
		helpname:SetTall( h * 0.1 )
		
	end
	
	local helpbuttontall = math.Round( ScrH() * 0.05 )
	
	for i = 1, self:GetHelpDataCount() do
		
		local help = self:GetHelpData( i )
		
		local helpbutton = self.HUD:CreateButton( helpscroll, help.Name, function( button )
			
			helpname:SetText( help.Name or "" )
			
			if IsValid( helppanel.panel ) == true then helppanel.panel:Remove() end
			helppanel.panel = help:CreatePanel( self )
			helppanel.panel:SetParent( helppanel )
			helppanel.panel:Dock( FILL )
			
		end )
		helpbutton:Dock( TOP )
		helpbutton:DockMargin( 0, 0, 0, spacing )
		helpbutton:SetTall( helpbuttontall )
		helpbutton:SetFont( "BZ_MenuButtonSmall" )
		
		if i == 1 then helpbutton:DoClick() end
		
	end
	
	function helpmenu:PerformLayout( w, h )
		
		local size = math.min( w, h )
		
		helpscroll:SetWide( math.Round( size * 0.5 ) - ( spacing * 2 ) )
		
	end
	
	return helpmenu
	
end
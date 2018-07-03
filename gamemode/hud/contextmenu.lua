DEFINE_BASECLASS( "gamemode_base" )



GM.CMenuDrawn = false
local cmenu
function GM:OnContextMenuOpen()
	
	self.CMenuDrawn = true
	
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
				
				local color = self.HUD.Color.plyunreadycolor
				if self:PlayerIsReady( ply ) == true then color = self.HUD.Color.plyreadycolor end
				
				self.HUD:ShadowText( ply:Name(), x, y + ( th * ( ( i - 1 ) - ( count * 0.5 ) ) ), color )
				
			end
			
		end
		
	end
	function cmenu.Think( panel )
		
		local vis = self:GetRoundState() == ROUND_INTERMISSION and ply:Team() == TEAM_BEAT
		if panel.vis ~= vis then
			
			panel.vis = vis
			
			if vis == true then
				
				panel.ready = self.HUD:CreateButton( panel, "Toggle ready", function() self:Ready() end )
				panel.ready:SetPos( ScrW() * 0.025, ScrH() * 0.45 )
				panel.ready:SetSize( ScrW() * 0.1, ScrH() * 0.1 )
				
			elseif IsValid( panel.ready ) == true then
				
				panel.ready:Remove()
				
			end
			
		end
		
	end
	
end
function GM:OnContextMenuClose()
	
	self.CMenuDrawn = false
	
	if IsValid( cmenu ) == true then cmenu:Remove() end
	
end
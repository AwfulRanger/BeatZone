DEFINE_BASECLASS( "gamemode_base" )



local statestr = {
	
	[ ROUND_INITIALIZING ] = "Initializing",
	[ ROUND_INTERMISSION ] = "Intermission",
	[ ROUND_STARTING ] = "Starting",
	[ ROUND_ONGOING ] = "Ongoing",
	[ ROUND_ENDING ] = "Ending",
	
}

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
		
		local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.05 )
		
		local state = self:GetRoundState()
		
		surface.SetFont( "BZ_HUDSmall" )
		
		local statetext = statestr[ state ] .. " (Round " .. self:GetRound() .. ")"
		local sw, sh = surface.GetTextSize( statetext )
		self.HUD:ShadowText( statetext, ( w - sw ) * 0.5, spacing )
		
		if state == ROUND_INTERMISSION then
			
			local x = math.Round( w * 0.15 )
			local y = math.Round( h * 0.5 )
			local tw, th = surface.GetTextSize( " " )
			
			local plys = self:GetPlayers()
			local count = #plys
			for i = 1, count do
				
				local ply = plys[ i ]
				
				local color = self.HUD.Color.plyunready
				if self:PlayerIsReady( ply ) == true then color = self.HUD.Color.plyready end
				
				self.HUD:ShadowText( ply:Name(), x, y + ( th * ( ( i - 1 ) - ( count * 0.5 ) ) ), color )
				
			end
			
			
			local readycount = self.ReadyPlayers.Count
			local plycount = #self:GetPlayers()
			
			local readytime = self.FirstReadyTime
			if readytime ~= nil then
				
				local basetime = self:GetConfig( "ReadyTime" ) * ( plycount - readycount )
				local time = math.Round( basetime - ( CurTime() - readytime ), 1 )
				
				if time > 0 then
					
					if #tostring( time ) > 3 then time = math.floor( time ) end
					
					local timestr = tostring( time )
					if #timestr == 1 then timestr = timestr .. ".0" end
					
					local timetext = "Starting in " .. timestr .. " seconds"
					local tw, th = surface.GetTextSize( timetext )
					
					self.HUD:ShadowText( timetext, ( ScrW() - tw ) * 0.5, ( spacing * 2 ) + sh )
					
				end
				
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
		
		local voting = self:IsVote() == true and self:CanVote( LocalPlayer() ) == true
		if panel.voting ~= voting then
			
			panel.voting = voting
			
			if voting == true then
				
				local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.05 )
				local w = math.Round( ScrW() * 0.1 )
				local h = math.Round( ScrH() * 0.1 )
				local y = math.Round( ScrH() * 0.5 )
				local ys = math.Round( spacing * 0.5 )
				
				panel.voteyes = self.HUD:CreateButton( panel, "Vote yes", function() self:SendVote( true ) end )
				panel.voteyes:SetPos( ScrW() - w - spacing, y - h - ys )
				panel.voteyes:SetSize( w, h )
				
				panel.voteno = self.HUD:CreateButton( panel, "Vote no", function() self:SendVote( false ) end )
				panel.voteno:SetPos( ScrW() - w - spacing, y + ys )
				panel.voteno:SetSize( w, h )
				
			else
				
				if IsValid( panel.voteyes ) == true then panel.voteyes:Remove() end
				if IsValid( panel.voteno ) == true then panel.voteno:Remove() end
				
			end
			
		end
		
	end
	
end
function GM:OnContextMenuClose()
	
	self.CMenuDrawn = false
	
	if IsValid( cmenu ) == true then cmenu:Remove() end
	
end
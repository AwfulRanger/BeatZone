DEFINE_BASECLASS( "gamemode_base" )



local curvote
function GM:CreateVoteMenu()
	
	local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
	
	local votemenu = vgui.Create( "DPanel" )
	function votemenu.Paint( panel, w, h, ... )
		
		self.HUD:PaintPanel( panel, w, h, ... )
		
		local size = math.min( w, h )
		
		surface.SetDrawColor( self.HUD.Color.detailcolor )
		surface.DrawRect( ( size * 0.5 ) - 1, 0, 1, h )
		
	end
	
	local votescroll = vgui.Create( "DScrollPanel" )
	votescroll:SetParent( votemenu )
	votescroll:Dock( LEFT )
	votescroll:DockMargin( spacing, spacing, spacing, spacing )
	
	local voteinfo = vgui.Create( "DPanel" )
	voteinfo:SetParent( votemenu )
	voteinfo:Dock( FILL )
	voteinfo:DockMargin( spacing, spacing, spacing, spacing )
	function voteinfo:Paint( w, h )
	end
	
	local votename = self.HUD:CreateLabel( voteinfo, "", "BZ_LabelLarge" )
	votename:Dock( TOP )
	
	local votedesc = vgui.Create( "RichText" )
	votedesc:SetParent( voteinfo )
	votedesc:Dock( TOP )
	function votedesc.PerformLayout( panel, w, h )
		
		panel:SetFontInternal( "BZ_Label" )
		panel:SetFGColor( self.HUD.Color.textcolor )
		
	end
	
	local voteoptions = vgui.Create( "DPanel" )
	voteoptions:SetParent( voteinfo )
	voteoptions:Dock( FILL )
	function voteoptions:Paint( w, h )
	end
	
	function voteinfo:PerformLayout( w, h )
		
		votename:SetTall( h * 0.05 )
		votedesc:SetTall( h * 0.15 )
		
	end
	
	local votebuttontall = math.Round( ScrH() * 0.05 )
	
	for i = 1, self:GetVoteDataCount() do
		
		local vote = self:GetVoteData( i )
		
		local votebutton = self.HUD:CreateButton( votescroll, vote.Name, function( button )
			
			curvote = vote
			
			votename:SetText( vote.Name or "" )
			votedesc:SetText( vote:GetDescription( ply ) )
			
			if IsValid( voteoptions.panel ) == true then voteoptions.panel:Remove() end
			voteoptions.panel = vote:CreatePanel( self )
			voteoptions.panel:SetParent( voteoptions )
			voteoptions.panel:Dock( FILL )
			
		end )
		votebutton:Dock( TOP )
		votebutton:DockMargin( 0, 0, 0, spacing )
		votebutton:SetTall( votebuttontall )
		votebutton:SetFont( "BZ_MenuButtonSmall" )
		function votebutton.GetButtonBGColor( panel )
			
			if self:CanCallVote( ply, vote ) ~= true then return self.HUD.Color.buttoninactivecolor end
			
		end
		
		if i == 1 then votebutton:DoClick() end
		
	end
	
	function votemenu:PerformLayout( w, h )
		
		local size = math.min( w, h )
		
		votescroll:SetWide( math.Round( size * 0.5 ) - ( spacing * 2 ) )
		
	end
	
	return votemenu
	
end
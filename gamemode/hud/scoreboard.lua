DEFINE_BASECLASS( "gamemode_base" )



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
		
		surface.SetDrawColor( gm.HUD.Color.bgcolor )
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
		plypanel.Paint = function( ... ) return gm.HUD:PaintPanel( ... ) end
		
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
			gm.HUD:ShadowText( nick, 0, ( h - nth ) * 0.5 )
			
			if ply:Team() ~= TEAM_BEAT then return end
			
			local plyclass = player_manager.GetPlayerClass( ply )
			if plyclass == nil or plyclass == "" then return end
			plyclass = baseclass.Get( plyclass )
			if plyclass == nil or plyclass.DisplayName == nil then return end
			
			local class = plyclass.DisplayName
			local ctw, cth = surface.GetTextSize( class )
			gm.HUD:ShadowText( class, w - ctw, ( h - cth ) * 0.5 )
			
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
			gm.HUD:ShadowText( top, ( w - ttw ) * 0.5, ( th - tth ) * 0.5 )
			
			local bot = ply:Ping()
			if ply:IsBot() == true then bot = "BOT" end
			local btw, bth = surface.GetTextSize( bot )
			gm.HUD:ShadowText( bot, ( w - btw ) * 0.5, ( h - th ) + ( ( th - bth ) * 0.5 ) )
			
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
			gm.HUD:ShadowText( top, ( w - ttw ) * 0.5, ( th - tth ) * 0.5 )
			
			local bot = ply:Deaths()
			local btw, bth = surface.GetTextSize( bot )
			gm.HUD:ShadowText( bot, ( w - btw ) * 0.5, ( h - th ) + ( ( th - bth ) * 0.5 ) )
			
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
			gm.HUD:ShadowText( top, ( w - ttw ) * 0.5, ( th - tth ) * 0.5 )
			
			local bot = ply:Frags()
			local btw, bth = surface.GetTextSize( bot )
			gm.HUD:ShadowText( bot, ( w - btw ) * 0.5, ( h - th ) + ( ( th - bth ) * 0.5 ) )
			
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
				gm.HUD:ShadowText( text, ( w - tw ) * 0.5, ( h - th ) * 0.5 )
				
			elseif ply:Alive() ~= true then
				
				surface.SetFont( "BZ_LabelLarge" )
				
				local text = "Dead"
				local tw, th = surface.GetTextSize( text )
				gm.HUD:ShadowText( text, ( w - tw ) * 0.5, ( h - th ) * 0.5, gm.HUD.Color.deadcolor )
				
			else
				
				local hh = math.Round( h * 0.45 )
				
				surface.SetFont( "BZ_LabelBold" )
				
				local health = ply:Health()
				local maxhealth = ply:GetMaxHealth()
				local healthsize = math.Round( w * math.Clamp( health / maxhealth, 0, 1 ) )
				surface.SetDrawColor( gm.HUD.Color.healthcolor )
				surface.DrawRect( 0, 0, healthsize, hh )
				
				local htext = health .. "/" .. maxhealth
				local htw, hth = surface.GetTextSize( htext )
				local hs = ( hh - hth ) * 0.5
				gm.HUD:ShadowText( htext, hs, hs )
				
				local shield = ply:GetShield()
				local maxshield = ply:GetMaxShield()
				local shieldsize = math.Round( w * math.Clamp( shield / maxshield, 0, 1 ) )
				surface.SetDrawColor( gm.HUD.Color.shieldcolor )
				surface.DrawRect( 0, h - hh, shieldsize, hh )
				
				local stext = shield .. "/" .. maxshield
				local stw, sth = surface.GetTextSize( stext )
				local ss = ( hh - sth ) * 0.5
				gm.HUD:ShadowText( stext, ss, ( h - hh ) + ss )
				
			end
			
		end
		
	end
	
	return sbpanel
	
end

GM.SBDrawn = false
local sbpanel
function GM:ScoreboardShow()
	
	self.SBDrawn = true
	
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
	
	self.SBDrawn = false
	
	if IsValid( sbpanel ) == true then sbpanel:Remove() end
	
end
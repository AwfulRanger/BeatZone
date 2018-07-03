DEFINE_BASECLASS( "gamemode_base" )



function GM:HUDDrawTargetID()
	
	local tr = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )
	local ent = tr.Entity
	if tr.Hit == true and tr.HitNonWorld == true and IsValid( ent ) == true and ( ent:IsPlayer() == true or ent.IsBZEnemy == true ) then
		
		surface.SetFont( "BZ_HUDSmaller" )
		
		local name = ""
		local shield
		local maxshield
		
		if ent:IsPlayer() == true then
			
			name = ent:Nick()
			shield = ent:GetShield()
			maxshield = ent:GetMaxShield()
			
		elseif ent.IsBZEnemy == true then
			
			name = ent.PrintName or ""
			if name[ 1 ] == "#" then name = language.GetPhrase( name ) end
			
		end
		
		local isshield = shield ~= nil and maxshield ~= nil
		
		local tw, th = surface.GetTextSize( name )
		local hh = math.max( math.Round( ScrH() * 0.025 ), th )
		
		local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.005 )
		local w = math.min( math.max( math.Round( ScrW() * 0.15 ), tw + ( spacing * 2 ) ), ScrW() )
		local h = hh + ( spacing * 3 ) + th
		local x = math.Round( ( ScrW() - w ) * 0.5 )
		local y = math.Round( ScrH() * 0.525 )
		
		if isshield == true then h = h + hh + spacing end
		
		surface.SetDrawColor( self.HUD.Color.hudbgcolor )
		surface.DrawRect( x, y, w, h )
		
		self.HUD:ShadowText( name, x + math.Round( ( w - tw ) * 0.5 ), y + spacing )
		
		local health = ent:Health()
		local maxhealth = ent:GetMaxHealth()
		local healthsize = math.Round( w * math.Clamp( health / maxhealth, 0, 1 ) ) - ( spacing * 2 )
		surface.SetDrawColor( self.HUD.Color.healthcolor )
		surface.DrawRect( x + spacing, y + th + ( spacing * 2 ), healthsize, hh )
		
		local htext = health .. "/" .. maxhealth
		local htw, hth = surface.GetTextSize( htext )
		local hs = ( hh - hth ) * 0.5
		self.HUD:ShadowText( htext, x + hs + spacing, y + th + hs + ( spacing * 2 ) )
		
		if isshield == true then
			
			local shieldsize = math.Round( w * math.Clamp( shield / maxshield, 0, 1 ) ) - ( spacing * 2 )
			surface.SetDrawColor( self.HUD.Color.shieldcolor )
			surface.DrawRect( x + spacing, y + h - hh - spacing, shieldsize, hh )
			
			local stext = shield .. "/" .. maxshield
			local stw, sth = surface.GetTextSize( stext )
			local ss = ( hh - sth ) * 0.5
			self.HUD:ShadowText( stext, x + ss + spacing, y + ( h - hh - spacing ) + ss )
			
		end
		
	end
	
	cam.Start3D()
		
		surface.SetFont( "BZ_3DText" )
		
		local plys = self:GetPlayers()
		for i = 1, #plys do
			
			local ply = plys[ i ]
			
			local pos = ply:GetPos()
			local head = ply:LookupBone( "ValveBiped.Bip01_Head1" )
			if head ~= nil then
				
				local headpos = ply:GetBonePosition( head )
				if headpos ~= nil then pos = headpos end
				
			end
			
			if ply ~= LocalPlayer() and ply ~= ent and ply:Alive() == true and pos:Distance( EyePos() ) < 512 then
				
				pos = pos + Vector( 0, 0, 16 )
				
				local ang = ( pos - EyePos() ):Angle()
				ang:RotateAroundAxis( ang:Right(), 90 )
				ang:RotateAroundAxis( ang:Up(), -90 )
				
				local scale = 0.025
				
				local name = ply:Nick()
				local tw, th = surface.GetTextSize( name )
				local hh = math.max( 160, th )
				
				local spacing = 32
				local w = math.max( 1536, tw )
				local h = ( hh * 2 ) + ( spacing * 4 ) + th
				
				pos = pos - ( ( ang:Forward() * ( w * 0.5 ) ) * scale )
				pos = pos - ( ( ang:Right() * h ) * scale )
				
				cam.Start3D2D( pos, ang, scale )
					
					surface.SetDrawColor( self.HUD.Color.hudbgcolor )
					surface.DrawRect( 0, 0, w, h )
					
					self.HUD:ShadowText( name, math.Round( ( w - tw ) * 0.5 ), spacing, nil, nil, 4 )
					
					local health = ply:Health()
					local maxhealth = ply:GetMaxHealth()
					local healthsize = math.Round( w * math.Clamp( health / maxhealth, 0, 1 ) ) - ( spacing * 2 )
					surface.SetDrawColor( self.HUD.Color.healthcolor )
					surface.DrawRect( spacing, th + ( spacing * 2 ), healthsize, hh )
					
					local htext = health .. "/" .. maxhealth
					local htw, hth = surface.GetTextSize( htext )
					local hs = ( hh - hth ) * 0.5
					self.HUD:ShadowText( htext, hs + spacing, th + hs + ( spacing * 2 ), nil, nil, 4 )
					
					local shield = ply:GetShield()
					local maxshield = ply:GetMaxShield()
					local shieldsize = math.Round( w * math.Clamp( shield / maxshield, 0, 1 ) ) - ( spacing * 2 )
					surface.SetDrawColor( self.HUD.Color.shieldcolor )
					surface.DrawRect( spacing, h - hh - spacing, shieldsize, hh )
					
					local stext = shield .. "/" .. maxshield
					local stw, sth = surface.GetTextSize( stext )
					local ss = ( hh - sth ) * 0.5
					self.HUD:ShadowText( stext, ss + spacing, ( h - hh - spacing ) + ss, nil, nil, 4 )
					
				cam.End3D2D()
				
			end
			
		end
		
		--[[
		local skels = self.Skeletons
		for i = 1, #skels do
			
			local skel = skels[ i ]
			
			local pos = skel:GetPos()
			local head = skel:LookupBone( "bip_head" )
			if head ~= nil then
				
				local headpos = skel:GetBonePosition( head )
				if headpos ~= nil then pos = headpos end
				
			end
			
			if skel ~= ent and pos:Distance( EyePos() ) < 512 then
				
				pos = pos + Vector( 0, 0, 16 )
				
				local ang = ( pos - EyePos() ):Angle()
				ang:RotateAroundAxis( ang:Right(), 90 )
				ang:RotateAroundAxis( ang:Up(), -90 )
				
				local scale = 0.025
				
				local hh = 160
				
				local spacing = 8
				local w = 512
				local h = hh + ( spacing * 2 )
				
				pos = pos - ( ( ang:Forward() * ( w * 0.5 ) ) * scale )
				pos = pos - ( ( ang:Right() * h ) * scale )
				
				cam.Start3D2D( pos, ang, scale )
					
					surface.SetDrawColor( self.HUD.Color.hudbgcolor )
					surface.DrawRect( 0, 0, w, h )
					
					local health = skel:Health()
					local maxhealth = skel:GetMaxHealth()
					local healthsize = math.Round( w * math.Clamp( health / maxhealth, 0, 1 ) ) - ( spacing * 2 )
					surface.SetDrawColor( self.HUD.Color.healthcolor )
					surface.DrawRect( spacing, spacing, healthsize, hh )
					
					local htext = health .. "/" .. maxhealth
					local htw, hth = surface.GetTextSize( htext )
					local hs = ( hh - hth ) * 0.5
					self.HUD:ShadowText( htext, hs + spacing, hs + spacing, nil, nil, 4 )
					
				cam.End3D2D()
				
			end
			
		end
		]]--
		
	cam.End3D()
	
end
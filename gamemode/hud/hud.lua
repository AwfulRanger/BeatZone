DEFINE_BASECLASS( "gamemode_base" )

include( "damagenumber.lua" )
include( "deathnotice.lua" )
include( "targetid.lua" )



local nodraw = {
	
	[ "CHudHealth" ] = false,
	[ "CHudBattery" ] = false,
	[ "CHudAmmo" ] = false,
	[ "CHudSecondaryAmmo" ] = false,
	
}
function GM:HUDShouldDraw( hud )
	
	local show = nodraw[ hud ]
	if show ~= nil then return show end
	
	return BaseClass.HUDShouldDraw( self, hud )
	
end

local statestr = {
	
	[ ROUND_INITIALIZING ] = "Initializing",
	[ ROUND_INTERMISSION ] = "Intermission",
	[ ROUND_STARTING ] = "Starting",
	[ ROUND_ONGOING ] = "Ongoing",
	[ ROUND_ENDING ] = "Ending",
	
}
function GM:HUDPaint()
	
	local scrw = ScrW()
	local scrh = ScrH()
	
	if self.LastScrW ~= scrw or self.LastScrH ~= scrh then
		
		self.LastScrW = scrw
		self.LastScrH = scrh
		
		self.HUD:CreateFonts()
		
	end
	
	if self.CMenuDrawn == true or self.SBDrawn == true then return end
	
	local ply = LocalPlayer()
	if IsValid( ply ) ~= true then return end
	
	local size = math.min( scrw, scrh )
	local spacing = math.Round( size * 0.05 )
	local hudspacing = math.Round( size * 0.005 )
	
	--state/round
	do
		
		local state = self:GetRoundState()
		
		surface.SetFont( "BZ_HUDSmall" )
		local statetext = statestr[ state ] .. " (Round " .. self:GetRound() .. ")"
		local sw, sh = surface.GetTextSize( statetext )
		self.HUD:ShadowText( statetext, ( scrw - sw ) * 0.5, ( scrh * 0.05 ) - sh )
		
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
					
					self.HUD:ShadowText( timetext, ( scrw - tw ) * 0.5, scrh * 0.2 )
					
				end
				
			end
			
			self.HUD:ShadowText( readytext, ( scrw - rw ) * 0.5, ( scrh * 0.2 ) - rh )
			
		end
		
	end
	
	--boss health
	local boss = self.EnemyBoss
	if IsValid( boss ) == true then
		
		surface.SetFont( "BZ_HUDSmall" )
		
		local hw = math.Round( scrw * 0.5 )
		local hh = math.Round( scrh * 0.05 )
		local hx = math.Round( ( scrw - hw ) * 0.5 )
		local hy = math.Round( scrh * 0.075 )
		local hbarh = hh - hudspacing * 2
		
		surface.SetDrawColor( self.HUD.Color.hudbgcolor )
		surface.DrawRect( hx, hy, hw, hh )
		
		local health = boss:Health()
		local maxhealth = boss:GetMaxHealth()
		local healthsize = math.Round( hw - ( hudspacing * 2 ) ) * math.Clamp( health / maxhealth, 0, 1 )
		surface.SetDrawColor( self.HUD.Color.healthcolor )
		surface.DrawRect( hx + hudspacing, hy + hudspacing, healthsize, hbarh )
		
		local htext = health .. "/" .. maxhealth
		local htw, hth = surface.GetTextSize( htext )
		self.HUD:ShadowText( htext, hx + ( hudspacing * 2 ), hy + hudspacing + ( ( hbarh - hth ) * 0.5 ) )
		
	end
	
	BaseClass.HUDPaint( self )
	
	local obs = ply:GetObserverTarget()
	if IsValid( obs ) == true then ply = obs end
	if ply:Alive() ~= true or ply:Team() ~= TEAM_BEAT then return end
	
	--health/shield
	do
		
		surface.SetFont( "BZ_HUDSmall" )
		
		local hw = math.Round( scrw * 0.25 )
		local hh = math.Round( scrh * 0.1 )
		local hx = spacing
		local hy = scrh - hh - spacing
		local hbarh = math.Round( hh * 0.5 ) - math.Round( hudspacing * 1.5 )
		
		surface.SetDrawColor( self.HUD.Color.hudbgcolor )
		surface.DrawRect( hx, hy, hw, hh )
		
		local health = ply:Health()
		local maxhealth = ply:GetMaxHealth()
		local healthsize = math.Round( hw - ( hudspacing * 2 ) ) * math.Clamp( health / maxhealth, 0, 1 )
		surface.SetDrawColor( self.HUD.Color.healthcolor )
		surface.DrawRect( hx + hudspacing, hy + hudspacing, healthsize, hbarh )
		
		local htext = health .. "/" .. maxhealth
		local htw, hth = surface.GetTextSize( htext )
		self.HUD:ShadowText( htext, hx + ( hudspacing * 2 ), hy + hudspacing + ( ( hbarh - hth ) * 0.5 ) )
		
		local shield = ply:GetShield()
		local maxshield = ply:GetMaxShield()
		local shieldsize = math.Round( hw - ( hudspacing * 2 ) ) * math.Clamp( shield / maxshield, 0, 1 )
		surface.SetDrawColor( self.HUD.Color.shieldcolor )
		surface.DrawRect( hx + hudspacing, hy + hbarh + ( hudspacing * 2 ), shieldsize, hbarh )
		
		local stext = shield .. "/" .. maxshield
		local stw, sth = surface.GetTextSize( stext )
		self.HUD:ShadowText( stext, hx + ( hudspacing * 2 ), hy + hbarh + ( hudspacing * 2 ) + ( ( hbarh - sth ) * 0.5 ) )
		
	end
	
	--ammo
	do
		
		surface.SetFont( "BZ_HUD" )
		
		local weapon = ply:GetActiveWeapon()
		
		local customammo
		if weapon.CustomAmmoDisplay ~= nil then customammo = weapon:CustomAmmoDisplay() end
		customammo = customammo or {}
		
		local ammotype1 = -1
		local ammotype2 = -1
		if IsValid( weapon ) == true then
			
			ammotype1 = weapon:GetPrimaryAmmoType()
			ammotype2 = weapon:GetSecondaryAmmoType()
			
		end
		
		if ( ammotype1 ~= -1 or ammotype2 ~= -1 or customammo.Draw == true ) and customammo.Draw ~= false then
			
			local aw = math.Round( scrw * 0.25 )
			local ah = math.Round( scrh * 0.1 )
			local ax = scrw - aw - spacing
			local ay = scrh - ah - spacing
			
			surface.SetDrawColor( self.HUD.Color.hudbgcolor )
			surface.DrawRect( ax, ay, aw, ah )
			
			--primary ammo
			if ammotype1 ~= -1 or customammo.PrimaryClip ~= nil or customammo.PrimaryAmmo ~= nil then
				
				local acx = ax + hudspacing
				local acy = ay + hudspacing
				local acw = math.Round( aw * 0.5 ) - ( hudspacing * 2 )
				local ach = ah - ( hudspacing * 2 )
				
				local clip = weapon:Clip1()
				if customammo.PrimaryClip ~= nil then clip = customammo.PrimaryClip end
				local maxclip = weapon:GetMaxClip1()
				local ammo = ply:GetAmmoCount( ammotype1 )
				if customammo.PrimaryAmmo ~= nil then ammo = customammo.PrimaryAmmo end
				local maxammo = self:GetPlayerMaxAmmo( ply, ammotype1 )
				if clip == -1 or ammo == -1 then
					
					local maxcount = maxammo
					local count = ammo
					if maxcount == -1 then
						
						maxcount = maxclip
						count = clip
						
					end
					if maxcount ~= -1 then
						
						surface.SetDrawColor( self.HUD.Color.clipcolor )
						local csize = math.Round( ach * math.Clamp( count / maxcount, 0, 1 ) )
						surface.DrawRect( acx, acy + ( ach - csize ), acw, csize )
						
						local ctw, cth = surface.GetTextSize( count )
						self.HUD:ShadowText( count, acx + math.Round( ( acw - ctw ) * 0.5 ), acy + math.Round( ( ach - cth ) * 0.5 ) )
						
					end
					
				else 
					
					local cw = math.Round( ( acw - hudspacing ) * 0.5 )
					local cspacing = math.Round( hudspacing * 0.5 )
					
					--clip
					surface.SetDrawColor( self.HUD.Color.clipcolor )
					local clipsize = math.Round( ach * math.Clamp( clip / maxclip, 0, 1 ) )
					surface.DrawRect( acx, acy + ( ach - clipsize ), cw - cspacing, clipsize )
					
					local ctw, cth = surface.GetTextSize( clip )
					self.HUD:ShadowText( clip, acx + math.Round( ( cw - cspacing - ctw ) * 0.5 ), acy + math.Round( ( ach - cth ) * 0.5 ) )
					
					--ammo
					surface.SetDrawColor( self.HUD.Color.ammocolor )
					local ammosize = math.Round( ach * math.Clamp( ammo / maxammo, 0, 1 ) )
					surface.DrawRect( acx + cw + cspacing, acy + ( ach - ammosize ), cw, ammosize )
					
					local atw, ath = surface.GetTextSize( ammo )
					self.HUD:ShadowText( ammo, acx + cw + cspacing + math.Round( ( cw - atw ) * 0.5 ), acy + math.Round( ( ach - ath ) * 0.5 ) )
					
				end
				
			end
			
			--secondary ammo
			if ammotype2 ~= -1 or customammo.SecondaryClip ~= nil or customammo.SecondaryAmmo ~= nil then
				
				local acx = ax + hudspacing + math.Round( aw * 0.5 )
				local acy = ay + hudspacing
				local acw = math.Round( aw * 0.5 ) - ( hudspacing * 2 )
				local ach = ah - ( hudspacing * 2 )
				
				local clip = weapon:Clip2()
				if customammo.SecondaryClip ~= nil then clip = customammo.SecondaryClip end
				local maxclip = weapon:GetMaxClip2()
				local ammo = ply:GetAmmoCount( ammotype2 )
				if customammo.SecondaryAmmo ~= nil then ammo = customammo.SecondaryAmmo end
				local maxammo = self:GetPlayerMaxAmmo( ply, ammotype2 )
				if clip == -1 or ammo == -1 then
					
					local maxcount = maxammo
					local count = ammo
					if maxcount == -1 then
						
						maxcount = maxclip
						count = clip
						
					end
					if maxcount ~= -1 then
						
						surface.SetDrawColor( self.HUD.Color.clipcolor )
						local csize = math.Round( ach * math.Clamp( count / maxcount, 0, 1 ) )
						surface.DrawRect( acx, acy + ( ach - csize ), acw, csize )
						
						local ctw, cth = surface.GetTextSize( count )
						self.HUD:ShadowText( count, acx + math.Round( ( acw - ctw ) * 0.5 ), acy + math.Round( ( ach - cth ) * 0.5 ) )
						
					end
					
				else 
					
					local cw = math.Round( ( acw - hudspacing ) * 0.5 )
					local cspacing = math.Round( hudspacing * 0.5 )
					
					--clip
					surface.SetDrawColor( self.HUD.Color.clipcolor )
					local clipsize = math.Round( ach * math.Clamp( clip / maxclip, 0, 1 ) )
					surface.DrawRect( acx, acy + ( ach - clipsize ), cw - cspacing, clipsize )
					
					local ctw, cth = surface.GetTextSize( clip )
					self.HUD:ShadowText( clip, acx + math.Round( ( cw - cspacing - ctw ) * 0.5 ), acy + math.Round( ( ach - cth ) * 0.5 ) )
					
					--ammo
					surface.SetDrawColor( self.HUD.Color.ammocolor )
					local ammosize = math.Round( ach * math.Clamp( ammo / maxammo, 0, 1 ) )
					surface.DrawRect( acx + cw + cspacing, acy + ( ach - ammosize ), cw, ammosize )
					
					local atw, ath = surface.GetTextSize( ammo )
					self.HUD:ShadowText( ammo, acx + cw + cspacing + math.Round( ( cw - atw ) * 0.5 ), acy + math.Round( ( ach - ath ) * 0.5 ) )
					
				end
				
			end
			
		end
		
	end
	
	self:DrawDamageNumbers()
	
end
DEFINE_BASECLASS( "gamemode_base" )



local notificationtime = CreateClientConVar( "bz_notificationtime", 6 )
local fadetime = CreateClientConVar( "bz_notificationfadetime", 1 )
local notifications = {}
function GM:AddNotification( msg, color, scolor )
	
	table.insert( notifications, {
		
		time = CurTime(),
		msg = msg or "",
		color = color,
		scolor = scolor,
		
	} )
	
end

function GM:DrawNotifications()
	
	local remove = {}
	
	local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.05 )
	local sh = math.Round( spacing * 0.1 )
	local sx = ScrW() - spacing
	local sy = spacing
	
	surface.SetFont( "BZ_LabelLarge" )
	
	local y = sy
	
	for i = 1, #notifications do
		
		local n = notifications[ i ]
		local time = n.time + notificationtime:GetFloat()
		if CurTime() > time then
			
			table.insert( remove, i )
			
		else
			
			local msg = n.msg or ""
			
			local tw, th = surface.GetTextSize( msg )
			
			local fadein = math.min( CurTime() - time, 0.1 )
			
			local x = sx - tw
			local h = th + sh
			
			local tcolor = n.color or self.HUD.Color.textcolor
			local scolor = n.scolor or self.HUD.Color.textshadowcolor
			
			local outtime = fadetime:GetFloat()
			local intime = 0.1
			
			if CurTime() > time - outtime then
				
				local delta = ( time - CurTime() ) / outtime
				
				tcolor = Color( tcolor.r, tcolor.g, tcolor.b, tcolor.a * delta )
				scolor = Color( scolor.r, scolor.g, scolor.b, scolor.a * delta )
				
				x = sx - ( tw * delta )
				h = h * delta
				
			elseif CurTime() - n.time < intime then
				
				local delta = math.max( 0, CurTime() - n.time ) / intime
				
				tcolor = Color( tcolor.r, tcolor.g, tcolor.b, tcolor.a * delta )
				scolor = Color( scolor.r, scolor.g, scolor.b, scolor.a * delta )
				
				x = sx - ( tw * delta )
				h = h * delta
				
			end
			
			self.HUD:ShadowText( msg, x, y, tcolor, scolor )
			
			y = y + h
			
		end
		
	end
	
	for i = 1, #remove do table.remove( notifications, remove[ i ] ) end
	
end



----
--Death notices
----
function GM:AddBZDeathNotice( victim, attacker, msg )
	
	if msg == nil then
		
		msg = "%s2 killed %s1"
		if victim == attacker or attacker == nil then msg = "%s1 died" end
		
	end
	if isstring( victim ) ~= true then victim = victim:Nick() end
	if attacker == nil then attacker = "" end
	if isstring( attacker ) ~= true then
		
		local aname = attacker.PrintName
		if attacker:IsPlayer() == true then aname = attacker:Nick() end
		if aname == nil then aname = "" end
		if aname[ 1 ] == "#" then aname = language.GetPhrase( aname ) end
		attacker = aname
		
	end
	
	msg = string.Replace( msg, "%s1", victim )
	msg = string.Replace( msg, "%s2", attacker )
	
	self:AddNotification( msg, self.HUD.Color.deadcolor )
	
end

net.Receive( "BZ_PlayerDeath", function()
	
	local victim = net.ReadEntity()
	local attacker = net.ReadEntity()
	
	if IsValid( victim ) ~= true or IsValid( attacker ) ~= true then return end
	
	local msg
	local msgtbl = gmod.GetGamemode():GetConfig( "DeathMessage" )[ attacker:GetClass() ]
	if msgtbl ~= nil then msg = msgtbl[ math.random( #msgtbl ) ] end
	
	hook.Run( "AddBZDeathNotice", victim, attacker, msg )
	
end )

function GM:DrawDeathNotice( x, y )
end



----
--Pickup notices
----
function GM:HUDAmmoPickedUp( name, amount )
	
	local str = name
	
	local tr = "#" .. name .. "_ammo"
	local trname = language.GetPhrase( tr )
	if trname ~= tr then str = trname end
	
	self:AddNotification( "Picked up " .. amount .. " " .. str )
	
end

function GM:HUDItemPickedUp( name )
	
	local str = name
	
	local tr = "#" .. name
	local trname = language.GetPhrase( tr )
	if trname ~= tr then str = trname end
	
	self:AddNotification( "Picked up " .. str )
	
end

function GM:HUDWeaponPickedUp( weapon )
	
	if IsValid( weapon ) ~= true then return end
	
	local name = weapon:GetClass()
	if weapon.GetPrintName ~= nil then
		
		local pname = weapon:GetPrintName()
		if pname ~= nil then name = pname end
		
	end
	
	if name[ 1 ] == "#" then name = language.GetPhrase( name ) end
	
	self:AddNotification( "Picked up " .. name )
	
end

function GM:HUDDrawPickupHistory()
end

net.Receive( "BZ_ItemPickup", function()
	
	gmod.GetGamemode():HUDItemPickedUp( net.ReadString() )
	
end )
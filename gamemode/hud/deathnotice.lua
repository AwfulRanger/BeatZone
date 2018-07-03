DEFINE_BASECLASS( "gamemode_base" )



local deathtime = GetConVar( "hud_deathnotice_time" )
local deathmsg = {
	
	[ "bz_skeletongunner" ] = {
		
		"%s2 filled %s1 with lead",
		"%s2 gunned %s1 down",
		
	},
	[ "bz_skeletonexploder" ] = {
		
		"%s2 obliterated %s1",
		"%s2 blew %s1 up",
		
	},
	[ "bz_skeletonwizard" ] = {
		
		"%s2 immolated %s1",
		"%s2 charred %s1",
		
	},
	[ "bz_skeletonlad" ] = {
		
		"%s2 beat %s1 to death",
		"%s2 smacked %s1",
		
	},
	
}
local deaths = {}
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
	
	table.insert( deaths, {
		
		time = CurTime(),
		victim = victim,
		attacker = attacker,
		msg = msg,
		
	} )
	
end
net.Receive( "BZ_PlayerDeath", function()
	
	local victim = net.ReadEntity()
	local attacker = net.ReadEntity()
	
	if IsValid( victim ) ~= true or IsValid( attacker ) ~= true then return end
	
	local msg
	local msgtbl = deathmsg[ attacker:GetClass() ]
	if msgtbl ~= nil then msg = msgtbl[ math.random( #msgtbl ) ] end
	
	hook.Run( "AddBZDeathNotice", victim, attacker, msg )
	
end )

function GM:DrawDeathNotice( dx, dy )
	
	local remove = {}
	
	local deathh = math.Round( ScrH() * 0.05 )
	local spacing = math.min( ScrW(), ScrH() ) * 0.1
	local sx = ScrW() - spacing
	local sy = spacing
	
	surface.SetFont( "BZ_LabelLarge" )
	
	for i = 1, #deaths do
		
		local death = deaths[ i ]
		local time = death.time + deathtime:GetFloat()
		if CurTime() > time then
			
			table.insert( remove, i )
			
		else
			
			local msg = death.msg
			msg = string.Replace( msg, "%s1", death.victim )
			msg = string.Replace( msg, "%s2", death.attacker )
			
			local tw, th = surface.GetTextSize( msg )
			
			local tcolor
			local scolor
			if CurTime() > time - 1 then
				
				local alpha = time - CurTime()
				local t = self.HUD.Color.textcolor
				local ts = self.HUD.Color.textshadowcolor
				tcolor = Color( tr, t.g, t.b, 255 * alpha )
				scolor = Color( ts.r, ts.g, ts.b, 255 * alpha )
				
			end
			
			self.HUD:ShadowText( msg, sx - tw, sy + ( deathh * ( i - 1 ) ), tcolor, scolor )
			
		end
		
	end
	
	for i = 1, #remove do table.remove( deaths, remove[ i ] ) end
	
end
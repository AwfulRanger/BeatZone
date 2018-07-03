DEFINE_BASECLASS( "gamemode_base" )



local hitsound = CreateClientConVar( "bz_hitsound", "sound/ui/hitsound.wav" )
local hitsoundvolume = CreateClientConVar( "bz_hitsoundvolume", 0.25 )
local enabledmgnum = CreateClientConVar( "bz_damagenumbers", 1 )
local dmgnumbatch = CreateClientConVar( "bz_damagenumbersbatch", 1 )
local dmgnumbatchtime = CreateClientConVar( "bz_damagenumbersbatchtime", 1 )
local dmgnumtime = CreateClientConVar( "bz_damagenumberstime", 3 )

GM.DamageNumbers = {}
GM.DamageNumbersBatch = {}

function GM:AddDamageNumber( ent, dmg, pos, crit )
	
	local snd = hitsound:GetString()
	local vol = hitsoundvolume:GetFloat()
	if snd ~= "" and vol > 0 then sound.PlayFile( snd, "noplay", function( channel ) channel:SetVolume( vol ) channel:Play() end ) end
	
	if enabledmgnum:GetBool() ~= true then return end
	
	crit = crit or false
	
	if dmgnumbatch:GetBool() == true then
		
		local batch = self.DamageNumbersBatch[ ent ]
		local key
		if batch ~= nil and CurTime() < batch.time + dmgnumbatchtime:GetFloat() then key = batch.key end
		local dmgnum = self.DamageNumbers[ key ]
		if key ~= nil and dmgnum ~= nil then
			
			self.DamageNumbers[ key ] = {
				
				time = CurTime(),
				ent = ent,
				dmg = dmgnum.dmg + dmg,
				pos = pos,
				crit = crit,
				
			}
			
			batch.time = CurTime()
			
		else
			
			local key = table.insert( self.DamageNumbers, {
				
				time = CurTime(),
				ent = ent,
				dmg = dmg,
				pos = pos,
				crit = crit,
				
			} )
			
			self.DamageNumbersBatch[ ent ] = {
				
				time = CurTime(),
				key = key,
				
			}
			
		end
		
	else
		
		table.insert( self.DamageNumbers, {
			
			time = CurTime(),
			ent = ent,
			dmg = dmg,
			pos = pos,
			crit = crit,
			
		} )
		
	end
	
end

net.Receive( "BZ_EntityDamaged", function()
	
	gmod.GetGamemode():AddDamageNumber( net.ReadEntity(), net.ReadInt( 32 ), net.ReadVector(), net.ReadBool() )
	
end )

local colorval = { "r", "g", "b", "a" }
function GM:DrawDamageNumbers()
	
	cam.Start3D()
		
		local remove = {}
		
		surface.SetFont( "BZ_3DText" )
		
		for i = 1, #self.DamageNumbers do
			
			local dmgnum = self.DamageNumbers[ i ]
			
			local length = dmgnumtime:GetFloat()
			local time = dmgnum.time + length
			if CurTime() > time then
				
				table.insert( remove, i )
				
			else
				
				local delta = ( ( CurTime() - time ) / length ) + 1
				
				local pos = dmgnum.pos
				
				local ang = ( pos - EyePos() ):Angle()
				ang:RotateAroundAxis( ang:Right(), 90 )
				ang:RotateAroundAxis( ang:Up(), -90 )
				
				local text = dmgnum.dmg or ""
				local tw, th = surface.GetTextSize( text )
				
				local scale = 0.1
				
				pos = pos - ( ( ang:Forward() * ( tw * 0.5 ) ) * scale )
				pos = pos - ( ( ang:Right() * ( th * 0.5 ) ) * scale )
				
				pos = pos + Vector( 0, 0, 32 * delta )
				
				cam.Start3D2D( pos, ang, scale )
					
					local sc = self.HUD.Color.dmgstartcolor
					if dmgnum.crit == true then sc = self.HUD.Color.dmgcritcolor end
					local ec = self.HUD.Color.dmgendcolor
					local color = Color( sc.r, sc.b, sc.g, sc.a )
					for i = 1, #colorval do
						
						local k = colorval[ i ]
						color[ k ] = Lerp( delta, sc[ k ], ec[ k ] )
						
					end
					
					local ts = self.HUD.Color.textshadowcolor
					surface.SetTextColor( ts.r, ts.g, ts.b, Lerp( delta, sc.a, ec.a ) )
					surface.SetTextPos( 2, 2 )
					surface.DrawText( text )
					
					surface.SetTextColor( color )
					surface.SetTextPos( 0, 0 )
					surface.DrawText( text )
					
				cam.End3D2D()
				
			end
			
		end
		
		for i = 1, #remove do
			
			local key = remove[ i ]
			table.remove( self.DamageNumbers, key )
			for _, v in pairs( self.DamageNumbersBatch ) do if v.key > key then v.key = v.key - 1 end end
			
		end
		
	cam.End3D()
	
end
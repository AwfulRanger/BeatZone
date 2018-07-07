DEFINE_BASECLASS( "gamemode_base" )



GM.HelpData = GM.HelpData or {}
GM.HelpDataNames = GM.HelpDataNames or {}

function GM:AddHelpData( name, data )
	
	data = data or {}
	
	name = tostring( name )
	
	local index
	if self.HelpData[ name ] == nil then
		
		index = table.insert( self.HelpDataNames, name )
		
	else
		
		index = self.HelpData[ name ].Index
		
	end
	
	data.IDName = name
	data.Index = index
	data.Name = data.Name or ( "#" .. name )
	data.CreatePanel = data.CreatePanel or function( self, gm ) return vgui.Create( "DPanel" ) end
	
	self.HelpData[ name ] = data
	
end

function GM:GetHelpData( id )
	
	if isnumber( id ) == true then return self.HelpData[ self.HelpDataNames[ id ] ] end
	
	return self.HelpData[ tostring( id ) ]
	
end

function GM:GetHelpDataCount()
	
	return #self.HelpDataNames
	
end



----
--Add help data
----
GM:AddHelpData( "intro", {
	
	Name = "Intro",
	CreatePanel = function( self, gm )
		
		local panel = vgui.Create( "RichText" )
		panel:SetText( [[Welcome to the BeatZone!

This menu can be opened again with the ]] .. string.upper( input.LookupBinding( "gm_showhelp", true ) or "(UNBOUND)" ) .. [[ key.



You (and whatever group of teammates you may have) must eliminate waves of enemies to survive.

During intermissions you can use loadout points and perk points to upgrade your arsenal.

After clearing enough waves, a boss will enter the battlefield. Defeating it will cause all enemies to retreat temporarily.
When they come back, however, they will be stronger.]] )
		function panel:PerformLayout( w, h )
			
			self:SetFontInternal( "BZ_LabelBold" )
			self:SetFGColor( gm.HUD.Color.textcolor )
			
		end
		
		return panel
		
	end,
	
} )

local enemies
GM:AddHelpData( "enemies", {
	
	Name = "Enemies",
	CreatePanel = function( self, gm )
		
		local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
		
		local panel = vgui.Create( "DPanel" )
		function panel:Paint( w, h )
		end
		
		local enemyscroll = vgui.Create( "DScrollPanel" )
		enemyscroll:SetParent( panel )
		enemyscroll:Dock( LEFT )
		
		local enemypanel = vgui.Create( "DPanel" )
		enemypanel:SetParent( panel )
		enemypanel:Dock( RIGHT )
		function enemypanel:Paint( w, h )
		end
		
		local enemymodel = vgui.Create( "DModelPanel" )
		enemymodel:SetParent( enemypanel )
		enemymodel:Dock( FILL )
		enemymodel:SetFOV( 36 )
		enemymodel:SetCamPos( Vector( 200, 0, 72 ) )
		enemymodel:SetLookAt( Vector( 0, 0, 72 ) )
		enemymodel:SetAnimated( true )
		enemymodel.csmodels = {}
		function enemymodel:ClearCSModels()
			
			for i = 1, #self.csmodels do
				
				local csmodel = self.csmodels[ i ]
				if IsValid( csmodel ) == true then csmodel:Remove() end
				self.csmodels[ i ] = nil
				
			end
			
		end
		local olddrawmodel = enemymodel.DrawModel
		function enemymodel:DrawModel( ... )
			
			olddrawmodel( self, ... )
			
			for i = 1, #self.csmodels do self.csmodels[ i ]:DrawModel() end
			
		end
		local oldonremove = enemymodel.OnRemove
		function enemymodel:OnRemove( ... )
			
			oldonremove( self, ... )
			
			self:ClearCSModels()
			
		end
		
		local enemyname = gm.HUD:CreateLabel( enemypanel, "", "BZ_LabelLarge" )
		enemyname:Dock( TOP )
		
		local enemydesc = vgui.Create( "RichText" )
		enemydesc:SetParent( panel )
		enemydesc:Dock( FILL )
		enemydesc:DockMargin( spacing, 0, spacing, 0 )
		function enemydesc:PerformLayout( w, h )
			
			self:SetFontInternal( "BZ_LabelBold" )
			self:SetFGColor( gm.HUD.Color.textcolor )
			
		end
		
		function enemypanel:PerformLayout( w, h )
			
			enemyname:SetTall( h * 0.1 )
			
		end
		
		local enemybuttontall = math.Round( ScrH() * 0.05 )
		
		local e = gm:GetConfig( "EnemyClass" )
		local b = gm:GetConfig( "BossClass" )
		local ec = #e
		local bc = #b
		
		for i = 1, ec + bc do
			
			local class = e[ i ]
			if i > ec then class = b[ i - ec ] end
			
			local ent = baseclass.Get( class )
			if ent ~= nil then
				
				local name = ent.PrintName or class
				local enemybutton = gm.HUD:CreateButton( enemyscroll, name, function( button )
					
					enemyname:SetText( name )
					
					enemymodel:SetModel( ent.Model or "" )
					enemymodel:ClearCSModels()
					local model = enemymodel.Entity
					if IsValid( model ) == true then
						
						model:SetSkin( ent.Skin or 0 )
						local act = ACT_MP_STAND_MELEE
						if ent.Activity ~= nil and ent.Activity.Stand ~= nil then act = ent.Activity.Stand end
						act = model:SelectWeightedSequence( act )
						if act ~= nil then model:SetSequence( act ) end
						
						if ent.ItemModels ~= nil then
							
							for i = 1, #ent.ItemModels do
								
								local csmodel = ClientsideModel( ent.ItemModels[ i ] )
								csmodel:SetParent( model )
								csmodel:AddEffects( EF_BONEMERGE )
								table.insert( enemymodel.csmodels, csmodel )
								
							end
							
						end
						
					end
					
					enemydesc:SetText( ent.Description or "" )
					
				end )
				enemybutton:Dock( TOP )
				enemybutton:DockMargin( 0, 0, 0, spacing )
				enemybutton:SetTall( enemybuttontall )
				enemybutton:SetFont( "BZ_MenuButtonSmall" )
				
				if i == 1 then enemybutton:DoClick() end
				
			end
			
		end
		
		function panel:PerformLayout( w, h )
			
			local s = math.Round( w * 0.3 )
			enemyscroll:SetWide( s )
			enemypanel:SetWide( s )
			
		end
		
		return panel
		
	end,
	
} )
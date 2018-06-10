--basically lifted from sandbox

local defaultanims = { "idle_all_01", "menu_walk" }

local editor
concommand.Add( "bz_editplayer", function()
	
	if IsValid( editor ) == true then editor:Remove() end
	
	local size = math.min( ScrW(), ScrH() )
	
	editor = vgui.Create( "DFrame" )
	editor:SetSize( 960, 700 )
	editor:Center()
	editor:SetTitle( "Player Model" )
	editor:MakePopup()
	
	local mdl = editor:Add( "DModelPanel" )
	mdl:Dock( FILL )
	mdl:SetFOV( 36 )
	mdl:SetCamPos( Vector( 0, 0, 0 ) )
	mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
	mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
	mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
	mdl:SetAnimated( true )
	mdl.Angles = Angle( 0, 0, 0 )
	mdl:SetLookAt( Vector( -100, 0, -22 ) )
	
	local sheet = editor:Add( "DPropertySheet" )
	sheet:Dock( RIGHT )
	sheet:SetWide( 430 )
	
	local panelselect = sheet:Add( "DPanelSelect" )
	
	for name, model in SortedPairs( player_manager.AllValidModels() ) do
		
		local icon = vgui.Create( "SpawnIcon" )
		icon:SetModel( model )
		icon:SetSize( 64, 64 )
		icon:SetTooltip( name )
		icon.playermodel = name
		
		panelselect:AddPanel( icon, { cl_playermodel = name } )
		
	end
	
	sheet:AddSheet( "Model", panelselect, "icon16/user.png" )
	
	local controls = editor:Add( "DPanel" )
	controls:DockPadding( 8, 8, 8, 8 )
	
	local plbl = controls:Add( "DLabel" )
	plbl:SetText( "Player color" )
	plbl:SetTextColor( Color( 0, 0, 0, 255 ) )
	plbl:Dock( TOP )
	
	local plycol = controls:Add( "DColorMixer" )
	plycol:SetAlphaBar( false )
	plycol:SetPalette( false )
	plycol:Dock( TOP )
	plycol:SetTall( math.min( editor:GetTall() / 3, 260 ) )
	
	local wlbl = controls:Add( "DLabel" )
	wlbl:SetText( "Weapon color" )
	wlbl:SetTextColor( Color( 0, 0, 0, 255 ) )
	wlbl:DockMargin( 0, 32, 0, 0 )
	wlbl:Dock( TOP )
	
	local wepcol = controls:Add( "DColorMixer" )
	wepcol:SetAlphaBar( false )
	wepcol:SetPalette( false )
	wepcol:Dock( TOP )
	wepcol:SetTall( math.min( editor:GetTall() / 3, 260 ) )
	wepcol:SetVector( Vector( GetConVar( "cl_weaponcolor" ):GetString() ) )
	
	sheet:AddSheet( "Colors", controls, "icon16/color_wheel.png" )
	
	local bdcontrols = editor:Add( "DPanel" )
	bdcontrols:DockPadding( 8, 8, 8, 8 )
	
	local bdcontrolspanel = bdcontrols:Add( "DPanelList" )
	bdcontrolspanel:EnableVerticalScrollbar( true )
	bdcontrolspanel:Dock( FILL )
	
	local bgtab = sheet:AddSheet( "Bodygroups", bdcontrols, "icon16/cog.png" )
	
	local function nicename( str )
		
		local newname = {}
		for _, s in pairs( string.Explode( "_", str ) ) do
			
			if #s == 1 then
				
				table.insert( newname, string.upper( s ) )
				
			else
				
				table.insert( newname, string.upper( string.Left( s, 1 ) ) .. string.Right( s, #s - 1 ) )
				
			end
			
		end
		
		return string.Implode( " ", newname )
		
	end
	
	local function previewanim( panel, playermodel )
		
		if IsValid( panel ) ~= true or IsValid( panel.Entity ) ~= true then return end
		
		local anims = defaultanims
		
		local plyanims = list.Get( "PlayerOptionsAnimations" )
		if plyanims[ playermodel ] ~= nil then anims = plyanims[ playermodel ] end
		
		local anim = anims[ math.random( #anims ) ]
		
		local seq = panel.Entity:LookupSequence( anim )
		if seq > 0 then panel.Entity:ResetSequence( seq ) end
		
	end
	
	local function updatebg( panel, val )
		
		if panel.type == "bgroup" then
			
			mdl.Entity:SetBodygroup( panel.typenum, math.Round( val ) )
			
			local str = string.Explode( " ", GetConVar( "cl_playerbodygroups" ):GetString() )
			if #str < panel.typenum + 1 then for i = 1, panel.typenum + 1 do str[ i ] = str[ i ] or 0 end end
			str[ panel.typenum + 1 ] = math.Round( val )
			RunConsoleCommand( "cl_playerbodygroups", table.concat( str, " " ) )
			
		elseif panel.type == "skin" then
			
			mdl.Entity:SetSkin( math.Round( val ) )
			RunConsoleCommand( "cl_playerskin", math.Round( val ) )
			
		end
		
	end
	
	local function rebuildbgtab()
		
		bdcontrolspanel:Clear()
		
		bgtab.Tab:SetVisible( false )
		
		local skincount = mdl.Entity:SkinCount() - 1
		if skincount > 0 then
			
			local skins = vgui.Create( "DNumSlider" )
			skins:Dock( TOP )
			skins:SetText( "Skin" )
			skins:SetDark( true )
			skins:SetTall( 50 )
			skins:SetDecimals( 0 )
			skins:SetMax( skincount )
			skins:SetValue( GetConVar( "cl_playerskin" ):GetInt() )
			skins.type = "skin"
			skins.OnValueChanged = updatebg
			
			bdcontrolspanel:AddItem( skins )
			
			mdl.Entity:SetSkin( GetConVar( "cl_playerskin" ):GetInt() )
			
			bgtab.Tab:SetVisible( true )
			
		end
		
		local groups = string.Explode( " ", GetConVar( "cl_playerbodygroups" ):GetString() )
		for i = 0, mdl.Entity:GetNumBodyGroups() - 1 do
			
			if mdl.Entity:GetBodygroupCount( i ) > 1 then
				
				local bgroup = vgui.Create( "DNumSlider" )
				bgroup:Dock( TOP )
				bgroup:SetText( nicename( mdl.Entity:GetBodygroupName( i ) ) )
				bgroup:SetDark( true )
				bgroup:SetTall( 50 )
				bgroup:SetDecimals( 0 )
				bgroup.type = "bgroup"
				bgroup.typenum = i
				bgroup:SetMax( mdl.Entity:GetBodygroupCount( i ) - 1 )
				bgroup:SetValue( groups[ i + 1 ] or 0 )
				bgroup.OnValueChanged = updatebg
				
				bdcontrolspanel:AddItem( bgroup )
				
				mdl.Entity:SetBodygroup( i, groups[ i + 1 ] or 0 )
				
				bgtab.Tab:SetVisible( true )
				
			end
			
		end
		
	end
	
	local function updatefromconvars()
		
		local model = GetConVar( "cl_playermodel" ):GetString()
		local modelname = player_manager.TranslatePlayerModel( model )
		util.PrecacheModel( modelname )
		mdl:SetModel( modelname )
		mdl.Entity.GetPlayerColor = function() return Vector( GetConVar( "cl_playercolor" ):GetString() ) end
		mdl.Entity:SetPos( Vector( -100, 0, -61 ) )
		
		plycol:SetVector( Vector( GetConVar( "cl_playercolor" ):GetString() ) )
		wepcol:SetVector( Vector( GetConVar( "cl_weaponcolor" ):GetString() ) )
		
		previewanim( mdl, model )
		rebuildbgtab()
		
	end
	
	local function updatefromcontrols()
		
		RunConsoleCommand( "cl_playercolor", tostring( plycol:GetVector() ) )
		RunConsoleCommand( "cl_weaponcolor", tostring( wepcol:GetVector() ) )
		
	end
	
	plycol.ValueChanged = updatefromcontrols
	wepcol.ValueChanged = updatefromcontrols
	
	updatefromconvars()
	
	function panelselect:OnActivePanelChanged( old, new )
		
		if old ~= new then
			
			RunConsoleCommand( "cl_playerbodygroups", "0" )
			RunConsoleCommand( "cl_playerskin", "0" )
			
		end
		
		timer.Simple( 0.1, function() updatefromconvars() end )
		
	end
	
	function mdl:DragMousePress()
		
		self.PressX, self.PressY = gui.MousePos()
		self.Pressed = true
		
	end
	
	function mdl:DragMouseRelease()
		
		self.Pressed = false
		
	end
	
	function mdl:LayoutEntity( ent )
		
		if self.bAnimated == true then self:RunAnimation() end
		
		if self.Pressed == true then
			
			local mx, my = gui.MousePos()
			self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
			
			self.PressX, self.PressY = gui.MousePos()
			
		end
		
		ent:SetAngles( self.Angles )
		
	end
	
end )

list.Set( "PlayerOptionsAnimations", "gman", { "menu_gman" } )

list.Set( "PlayerOptionsAnimations", "hostage01", { "idle_all_scared" } )
list.Set( "PlayerOptionsAnimations", "hostage02", { "idle_all_scared" } )
list.Set( "PlayerOptionsAnimations", "hostage03", { "idle_all_scared" } )
list.Set( "PlayerOptionsAnimations", "hostage04", { "idle_all_scared" } )

list.Set( "PlayerOptionsAnimations", "zombine", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "corpse", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "zombiefast", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "zombie", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "skeleton", { "menu_zombie_01" } )

list.Set( "PlayerOptionsAnimations", "combine", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "combineprison", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "combineelite", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "police", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "policefem", { "menu_combine" } )

list.Set( "PlayerOptionsAnimations", "css_arctic", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_gasmask", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_guerilla", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_leet", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_phoenix", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_riot", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_swat", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_urban", { "pose_standing_02", "idle_fist" } )
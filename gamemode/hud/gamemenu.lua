DEFINE_BASECLASS( "gamemode_base" )

include( "gamemenu_help.lua" )
include( "gamemenu_character.lua" )
include( "gamemenu_vote.lua" )
include( "gamemenu_settings.lua" )



local buttons = {
	
	[ 0 ] = "ShowHelp",
	[ 1 ] = "ShowTeam",
	[ 2 ] = "ShowSpare1",
	[ 3 ] = "ShowSpare2",
	
}
net.Receive( "BZ_ShowMenu", function()
	
	local gm = gmod.GetGamemode()
	local func = gm[ buttons[ net.ReadUInt( 2 ) ] ]
	if isfunction( func ) == true then func( gm ) end
	
end )



local frame
local showbuttons = {
	
	[ "gm_showhelp" ] = 1,
	[ "gm_showteam" ] = 2,
	[ "gm_showspare1" ] = 3,
	[ "gm_showspare2" ] = 4,
	
}

function GM:CreateMenu( tab )
	
	if IsValid( frame ) == true then frame:Remove() end
	
	local ply = LocalPlayer()
	if IsValid( ply ) ~= true then return end
	
	local framepad = math.Round( math.min( ScrW(), ScrH() ) * 0.1 )
	
	frame = vgui.Create( "DFrame" )
	frame:SetSize( ScrW() - framepad, ScrH() - framepad )
	frame:Center()
	frame:SetTitle( "BeatZone" )
	frame:SetSizable( true )
	frame:MakePopup()
	function frame.Paint( panel, w, h )
		
		surface.SetDrawColor( self.HUD.Color.bgcolor )
		surface.DrawRect( 0, 0, w, h )
		
	end
	
	local sheet = vgui.Create( "DPropertySheet" )
	sheet:SetParent( frame )
	sheet:Dock( FILL )
	sheet:SetFadeTime( 0 )
	function sheet:Paint( w, h ) end
	
	local tabs = {}
	
	local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
	
	
	--help
	table.insert( tabs, sheet:AddSheet( "Help", self:CreateHelpMenu() ) )
	
	
	--character
	table.insert( tabs, sheet:AddSheet( "Character", self:CreateCharacterMenu() ) )
	
	
	--vote
	table.insert( tabs, sheet:AddSheet( "Vote", self:CreateVoteMenu() ) )
	
	
	--settings
	table.insert( tabs, sheet:AddSheet( "Settings", self:CreateSettingsMenu() ) )
	
	
	for i = 1, #tabs do
		
		tabs[ i ].Tab.Paint = function( panel, w, h )
			
			surface.SetDrawColor( self.HUD.Color.buttoncolor )
			if panel:IsActive() then surface.SetDrawColor( self.HUD.Color.buttonactivecolor ) end
			--surface.DrawRect( 0, 0, w, h )
			surface.DrawRect( 0, 0, w, 20 )
			
		end
		
	end
	
	if tab ~= nil and tabs[ tab ] ~= nil then sheet:SetActiveTab( tabs[ tab ].Tab ) end
	
	function frame:OnKeyCodePressed( key )
		
		local bind = showbuttons[ input.LookupKeyBinding( key ) ]
		if bind == nil then return end
		
		if bind == tab then
			
			self:Remove()
			
		elseif tabs[ bind ] ~= nil then
			
			sheet:SetActiveTab( tabs[ bind ].Tab )
			
		end
		
	end
	
	function sheet:OnActiveTabChanged( old, new )
		
		for i = 1, #tabs do if tabs[ i ].Tab == new then tab = i break end end
		
	end
	
end

function GM:ShowHelp() self:CreateMenu( 1 ) end
function GM:ShowTeam() self:CreateMenu( 2 ) end
function GM:ShowSpare1() self:CreateMenu( 3 ) end
function GM:ShowSpare2() self:CreateMenu( 4 ) end
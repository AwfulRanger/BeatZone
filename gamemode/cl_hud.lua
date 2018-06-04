DEFINE_BASECLASS( "gamemode_base" )



----
--Show menus (F1-F4)
----
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
local function createmenu( tab )
	
	if IsValid( frame ) == true then frame:Remove() end
	
	frame = vgui.Create( "DFrame" )
	frame:SetSize( ScrW() * 0.8, ScrH() * 0.8 )
	frame:Center()
	frame:SetTitle( "BeatZone" )
	frame:MakePopup()
	
	local sheet = vgui.Create( "DPropertySheet" )
	sheet:SetParent( frame )
	sheet:Dock( FILL )
	
	local tabs = {}
	
	
	--help
	local helpmenu = vgui.Create( "DPanel" )
	function helpmenu.Paint() end
	
	table.insert( tabs, sheet:AddSheet( "Help", helpmenu ) )
	
	
	--character
	local charmenu = vgui.Create( "DPanel" )
	function charmenu.Paint() end
	
	table.insert( tabs, sheet:AddSheet( "Character", charmenu ) )
	
	
	--call vote
	local votemenu = vgui.Create( "DPanel" )
	function votemenu.Paint() end
	
	table.insert( tabs, sheet:AddSheet( "Vote", votemenu ) )
	
	
	--settings
	local settingsmenu = vgui.Create( "DPanel" )
	function settingsmenu.Paint() end
	
	table.insert( tabs, sheet:AddSheet( "Settings", settingsmenu ) )
	
	
	if tab ~= nil and tabs[ tab ] ~= nil then sheet:SetActiveTab( tabs[ tab ].Tab ) end
	
	function frame:OnKeyCodePressed( key )
		
		local bind = showbuttons[ input.LookupKeyBinding( key ) ]
		if bind == nil then return end
		
		if bind == tab then
			
			self:Remove()
			
		elseif tabs[ bind ] ~= nil then
			
			sheet:SetActiveTab( tabs[ bind ].Tab )
			tab = bind
			
		end
		
	end
	
end

function GM:ShowHelp() createmenu( 1 ) end
function GM:ShowTeam() createmenu( 2 ) end
function GM:ShowSpare1() createmenu( 3 ) end
function GM:ShowSpare2() createmenu( 4 ) end
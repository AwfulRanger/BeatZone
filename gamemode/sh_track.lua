DEFINE_BASECLASS( "gamemode_base" )



GM.Tracks = GM.Tracks or {}
GM.TrackNames = GM.TrackNames or {}

local trackmeta = {
	
	CurBeat = 0,
	Events = {},
	AddEvent = function( self, beat, func )
		
		self.CurBeat = self.CurBeat + beat
		table.insert( self.Events, {
			
			Beat = self.CurBeat,
			Func = func,
			
		} )
		
	end,
	GetEvent = function( self, num )
		
		return self.Events[ num ]
		
	end,
	
}
trackmeta.__index = trackmeta

function GM:NewTrack()
	
	local track = {}
	
	setmetatable( track, trackmeta )
	
	return track
	
end

function GM:AddTrack( name, data )
	
	name = tostring( name )
	
	local index
	if self.Tracks[ name ] == nil then
		
		index = table.insert( self.TrackNames, name )
		
	else
		
		index = self.Tracks[ name ].Index
		
	end
	
	data.IDName = name
	data.Index = index
	data.Name = data.Name or name
	data.Sound = data.Sound or ""
	data.Offset = data.Offset or 0
	data.Length = data.Length or SoundDuration( data.Sound )
	data.Events = data.Events or {}
	
	self.Tracks[ name ] = data
	
end

function GM:GetTrack( id )
	
	if isnumber( id ) == true then return self.Tracks[ self.TrackNames[ id ] ] end
	
	return self.Tracks[ tostring( id ) ]
	
end

function GM:GetTrackCount()
	
	return #self.TrackNames
	
end



local tracks = {
	
	"halflife"
	
}

for i = 1, #tracks do
	
	local t = "track/" .. tracks[ i ] .. ".lua"
	AddCSLuaFile( t )
	include( t )
	
end
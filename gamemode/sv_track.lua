DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "sh_track.lua" )
AddCSLuaFile( "cl_track.lua" )

include( "sh_track.lua" )



util.AddNetworkString( "BZ_PlayTrack" )
util.AddNetworkString( "BZ_StopTrack" )

function GM:PlayTrack( track )
	
	self:StopTrack()
	
	track = track or self:GetTrack( math.random( self:GetTrackCount() ) )
	
	local time = CurTime()
	
	net.Start( "BZ_PlayTrack" )
		
		net.WriteUInt( track.Index, 32 )
		net.WriteFloat( time )
		
	net.Broadcast()
	
	self.CurrentTrack = {
		
		Track = track,
		Time = time,
		
	}
	
end

function GM:StopTrack( fade )
	
	net.Start( "BZ_StopTrack" )
		
		net.WriteBool( fade or false )
		
	net.Broadcast()
	
	self.CurrentTrack = nil
	
end

GM.TrackFaded = false
function GM:HandleTrack()
	
	local curtrack = self.CurrentTrack
	local state = self:GetRoundState()
	
	if state == ROUND_ENDING and ( self.IsRoundLost == true or self:GetRound() % 6 == 0 ) then
		
		if curtrack ~= nil and self.TrackFaded ~= true then
			
			self.TrackFaded = true
			self:StopTrack( true )
			
		end
		
	elseif state ~= ROUND_INTERMISSION then
		
		self.TrackFaded = false
		if curtrack == nil or CurTime() - curtrack.Time > curtrack.Track.Length then self:PlayTrack() end
		
	elseif curtrack ~= nil then
		
		self.TrackFaded = false
		self:StopTrack()
		
	end
	
end
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

function GM:StopTrack()
	
	net.Start( "BZ_StopTrack" )
	net.Broadcast()
	
	self.CurrentTrack = nil
	
end

function GM:HandleTrack()
	
	local curtrack = self.CurrentTrack
	if self:GetRoundState() == ROUND_INPROGRESS then
		
		if curtrack == nil or CurTime() - curtrack.Time > curtrack.Track.Length then self:PlayTrack() end
		
	elseif curtrack ~= nil then
		
		self:StopTrack()
		
	end
	
end
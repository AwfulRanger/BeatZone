DEFINE_BASECLASS( "gamemode_base" )

include( "sh_track.lua" )



local musicvolume = GetConVar( "snd_musicvolume" )



function GM:PlayTrack( track, time )
	
	self:StopTrack()
	
	self.CurrentTrack = {
		
		Track = track,
		Time = time,
		
	}
	
	sound.PlayFile( "sound/" .. track.Sound, "noplay noblock", function( channel )
		
		if IsValid( channel ) == true and self.CurrentTrack ~= nil and self.CurrentTrack.Sound == nil then
			
			channel:SetVolume( musicvolume:GetFloat() )
			channel:SetTime( CurTime() - time )
			channel:Play()
			
			self.CurrentTrack.Sound = channel
			
		end
		
	end ) 
	
	return self.CurrentTrack
	
end

function GM:StopTrack( fade )
	
	local track = self.CurrentTrack
	if track == nil then return end
	
	if fade == true then
		
		self.TrackFadeTime = CurTime()
		
	else
		
		if IsValid( track.Sound ) == true then track.Sound:Stop() end
		
		self.CurrentTrack = nil
		
	end
	
end

GM.TrackFadeLength = 5
function GM:HandleTrack()
	
	if self.CurrentTrack == nil or self.CurrentTrack.Sound == nil then return end
	
	if self.TrackFadeTime ~= nil then
		
		local time = self.TrackFadeTime + self.TrackFadeLength
		if CurTime() > time then
			
			self.TrackFadeTime = nil
			self:StopTrack()
			
			return
			
		end
		
		self.CurrentTrack.Sound:SetVolume( math.max( 0, musicvolume:GetFloat() * ( ( time - CurTime() ) / self.TrackFadeLength ) ) )
		
	elseif self.CurrentTrack.Sound:GetVolume() ~= musicvolume:GetFloat() then
		
		self.CurrentTrack.Sound:SetVolume( musicvolume:GetFloat() )
		
	end
	
end



net.Receive( "BZ_PlayTrack", function()
	
	local gm = gmod.GetGamemode()
	gm:PlayTrack( gm:GetTrack( net.ReadUInt( 32 ) ), net.ReadFloat() )
	
end )

net.Receive( "BZ_StopTrack", function()
	
	gmod.GetGamemode():StopTrack( net.ReadBool() )
	
end )
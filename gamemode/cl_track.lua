DEFINE_BASECLASS( "gamemode_base" )

include( "sh_track.lua" )



function GM:PlayTrack( track, time )
	
	self:StopTrack()
	
	self.CurrentTrack = {
		
		Track = track,
		Time = time,
		
	}
	
	sound.PlayFile( "sound/" .. track.Sound, "noplay noblock", function( channel )
		
		if IsValid( channel ) == true and self.CurrentTrack ~= nil and self.CurrentTrack.Sound == nil then
			
			channel:SetTime( CurTime() - time )
			channel:Play()
			
			self.CurrentTrack.Sound = channel
			
		end
		
	end ) 
	
	return self.CurrentTrack
	
end

function GM:StopTrack()
	
	local track = self.CurrentTrack
	if track == nil then return end
	
	if IsValid( track.Sound ) == true then track.Sound:Stop() end
	
	self.CurrentTrack = nil
	
end

local musicvolume = GetConVar( "snd_musicvolume" )
function GM:HandleTrack()
	
	if self.CurrentTrack ~= nil and self.CurrentTrack.Sound ~= nil and self.CurrentTrack.Sound:GetVolume() ~= musicvolume:GetFloat() then
		
		self.CurrentTrack.Sound:SetVolume( musicvolume:GetFloat() )
		
	end
	
end



net.Receive( "BZ_PlayTrack", function()
	
	local gm = gmod.GetGamemode()
	gm:PlayTrack( gm:GetTrack( net.ReadUInt( 32 ) ), net.ReadFloat() )
	
end )

net.Receive( "BZ_StopTrack", function()
	
	gmod.GetGamemode():StopTrack()
	
end )
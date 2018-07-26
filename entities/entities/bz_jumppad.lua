DEFINE_BASECLASS( "base_anim" )

AddCSLuaFile()



if CLIENT then language.Add( "bz_jumppad", "Jump Pad" ) end

ENT.Base = "base_anim"
ENT.PrintName = "#bz_jumppad"
ENT.Model = Model( "models/props_doomsday/cap_point_small.mdl" )
ENT.Skin = 2
ENT.JumpSound = Sound( "weapons/bumper_car_jump.wav" )
ENT.JumpVelocity = 512

function ENT:Initialize()
	
	self:SetModel( self.Model )
	self:SetSkin( self.Skin )
	
	if SERVER then self:SetTrigger( true ) end
	self:UseTriggerBounds( true, 20 )
	
end

if SERVER then
	
	function ENT:Think()
		
		if self.DieTime ~= nil and CurTime() > self.DieTime then self:Remove() return end
		
	end
	
	function ENT:StartTouch( ent )
		
		if ent:IsPlayer() == true then
			
			local dir = self:GetAngles():Up()
			ent:SetVelocity( -( ent:GetVelocity() * dir ) + ( dir * self.JumpVelocity ) )
			self:EmitSound( self.JumpSound )
			
		end
		
	end
	
end
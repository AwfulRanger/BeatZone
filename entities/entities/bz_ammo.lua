DEFINE_BASECLASS( "base_anim" )

AddCSLuaFile()



ENT.Base = "base_anim"

ENT.PrintName = "Ammo"
ENT.Model = Model( "models/items/ammopack_medium.mdl" )

ENT.UseCooldown = 30
function ENT:SetupDataTables()
	
	self:NetworkVar( "Float", 0, "UseTime" )
	
	self:SetUseTime( -self.UseCooldown )
	
end

function ENT:Initialize()
	
	self:SetModel( self.Model )
	
	if SERVER then self:SetTrigger( true ) end
	self:UseTriggerBounds( true, 24 )
	
end

if SERVER then
	
	function ENT:Touch( ent )
		
		if ent:IsPlayer() ~= true or CurTime() < self:GetUseTime() + self.UseCooldown then return end
		
		local take = false
		
		if self.AmmoNum == nil then self.AmmoNum = 27 + #game.BuildAmmoTypes() end
		for i = 1, self.AmmoNum do
			
			local max = game.GetAmmoMax( i )
			if ent:GetAmmoCount( i ) < max then
				
				ent:SetAmmo( max, i )
				take = true
				
			end
			
		end
		
		if take == true then
			
			net.Start( "BZ_UISound" )
				
				net.WriteString( "items/ammo_pickup.wav" )
				
			net.Send( ent )
			
			self:SetUseTime( CurTime() )
			
		end
		
	end
	
end

if CLIENT then
	
	function ENT:Draw()
		
		if CurTime() > self:GetUseTime() + self.UseCooldown then
			
			local ang = Angle( 0, 0, 0 )
			ang:RotateAroundAxis( ang:Up(), CurTime() * 90 )
			self:SetRenderAngles( ang )
			
			BaseClass.Draw( self )
			
			self:CreateShadow()
			self:MarkShadowAsDirty()
			
		else
			
			self:DestroyShadow()
			
		end
		
	end
	
end
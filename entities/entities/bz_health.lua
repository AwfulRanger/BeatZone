DEFINE_BASECLASS( "base_anim" )

AddCSLuaFile()



if CLIENT then language.Add( "bz_health", "Health" ) end

ENT.Base = "base_anim"
ENT.PrintName = "#bz_health"
ENT.Model = Model( "models/items/medkit_medium.mdl" )

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
		
		local max = ent:GetMaxHealth()
		if ent:Health() < max then
			
			ent:SetHealth( max )
			take = true
			
		end
		if ent:IsIgnited() == true then
			
			ent:StopIgnite()
			take = true
			
		end
		if ent:IsBleeding() == true then
			
			ent:StopBleed()
			take = true
			
		end
		
		if take == true then
			
			net.Start( "BZ_UISound" )
				
				net.WriteString( "items/smallmedkit1.wav" )
				
			net.Send( ent )
			
			net.Start( "BZ_ItemPickup" )
				
				net.WriteString( self:GetClass() )
				
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
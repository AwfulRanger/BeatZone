EFFECT.Mat = Material( "effects/spark" )
EFFECT.Color = Color( 255, 200, 0, 200 )

function EFFECT:Init( data )
	
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	
	local ent = data:GetEntity()
	local attach = data:GetAttachment()
	
	if IsValid( ent ) == true and attach > 0 then
		
		if ent:GetOwner() == LocalPlayer() then ent = ent:GetOwner():GetViewModel() end
		
		local attach = ent:GetAttachment( attach )
		if attach ~= nil then self.StartPos = attach.Pos end
		
	end
	
	self.Dir = self.EndPos - self.StartPos
	
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.TracerTime = math.min( 0.1, self.StartPos:Distance( self.EndPos ) / 10000 )
	self.DieTime = CurTime() + self.TracerTime
	
end

function EFFECT:Think()
	
	return ( CurTime() > self.DieTime ) ~= true
	
end

function EFFECT:Render()
	
	local delta = math.Clamp( ( self.DieTime - CurTime() ) / self.TracerTime, 0, 1 )
	
	render.SetMaterial( self.Mat )
	render.DrawBeam( self.StartPos, self.EndPos - ( self.Dir * delta ), 8, 0, 1, self.Color )
	
end
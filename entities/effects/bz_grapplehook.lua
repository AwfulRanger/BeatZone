EFFECT.Mat = Material( "cable/cable" )
EFFECT.Color = Color( 255, 255, 255, 255 )

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
	
	self.ParentEntity = ent
	self.ParentAttach = attach
	
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.DieTime = CurTime() + 0.1
	
end

function EFFECT:Think()
	
	return ( CurTime() > self.DieTime ) ~= true
	
end

function EFFECT:Render()
	
	if IsValid( self.ParentEntity ) == true and self.ParentAttach > 0 then
		
		local attach = self.ParentEntity:GetAttachment( self.ParentAttach )
		if attach ~= nil then self.StartPos = attach.Pos end
		
	end
	
	render.SetMaterial( self.Mat )
	render.DrawBeam( self.StartPos, self.EndPos, 2, 0, 1, self.Color )
	
end
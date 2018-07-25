DEFINE_BASECLASS( "bz_skeletonbase" )

AddCSLuaFile()



if CLIENT then language.Add( "bz_skeletongunner", "Skeleton Gunner" ) end

ENT.Base = "bz_skeletonbase"
ENT.PrintName = "#bz_skeletongunner"
ENT.Description = [[Shoots people with their gun.]]
ENT.Skin = 1

ENT.ShootSounds = { Sound( "weapons/sniper_rifle_classic_shoot.wav" ) }

function ENT:SetupDataTables()
	
	BaseClass.SetupDataTables( self )
	
	self:NetworkVar( "Float", 0, "ShootTime" )
	
end

ENT.Activity = {
	
	Spawn = ACT_TRANSITION,
	Stand = ACT_MP_STAND_PRIMARY,
	Run = ACT_MP_RUN_PRIMARY,
	Crouch = ACT_MP_CROUCH_PRIMARY,
	Attack = ACT_MP_ATTACK_STAND_PRIMARY,
	
}

if SERVER then
	
	ENT.MoveSpeed = 260
	
	ENT.MinRange = 256 --try to stay at least this far away
	ENT.MaxRange = 512 --don't attack past this range
	function ENT:ShouldChase( target )
		
		if target == nil then target = self:GetTarget() end
		if IsValid( target ) ~= true then return false end
		
		if target:Visible( self ) ~= true then return true end
		if self:GetPos():Distance( target:GetPos() ) > self.MaxRange then return true end
		
		return false
		
	end
	
	function ENT:ShouldRunAway( target )
		
		if target == nil then target = self:GetTarget() end
		if IsValid( target ) ~= true then return false end
		
		if target:Visible( self ) ~= true then return false end
		if self:GetPos():Distance( target:GetPos() ) < self.MinRange - 32 then return true end
		
		return false
		
	end
	
	ENT.ShootCooldown = 3
	function ENT:CanShoot()
		
		return CurTime() > self:GetShootTime() + self.ShootCooldown
		
	end
	
	function ENT:HandleShoot( target )
		
		if target == nil then target = self:GetTarget() end
		if IsValid( target ) ~= true then return end
		
		if self:GetPos():Distance( target:GetPos() ) < self.MaxRange and CurTime() < self.LastSeenTarget + 1 then
			
			local curang = self:GetAngles()
			local newang = ( target:GetPos() - self:GetPos() ):Angle()
			self:SetAngles( Angle( curang.p, newang.y, curang.r ) )
			
			if self:CanShoot() == true then self:Shoot( target ) end
			
		end
		
	end
	
	ENT.ShootDamage = 15
	function ENT:Shoot( target )
		
		if target == nil then target = self:GetTarget() end
		
		local pos = self:GetShootPos()
		
		local dir = self:EyeAngles():Forward()
		if IsValid( target ) == true then dir = ( ( target:BodyTarget( pos ) - Vector( 0, 0, 16 ) ) - pos ):GetNormalized() end
		
		self:FireBullets( {
			
			Attacker = self,
			Damage = self:GetBuffed( self.ShootDamage ),
			Src = pos,
			Dir = dir,
			IgnoreEntity = self,
			
		} )
		
		self:SetShootTime( CurTime() )
		
		self:RestartGesture( self.Activity.Attack or ACT_MP_ATTACK_STAND_PRIMARY )
		self:EmitSound( self.ShootSounds[ math.random( #self.ShootSounds ) ], 140, nil, nil, CHAN_WEAPON )
		
	end
	
	function ENT:HandleAI()
		
		BaseClass.HandleAI( self )
		
		self.loco:SetDesiredSpeed( self:GetMoveSpeed() )
		
		local target = self:GetTarget()
		if IsValid( target ) == true then
			
			if self:ShouldChase( target ) == true and self:CanShoot() == true then
				
				self:StartActivity( self.Activity.Run or ACT_MP_RUN_PRIMARY )
				
				self:FollowEntity( target, { maxage = 0.1, think = function()
					
					self.loco:SetDesiredSpeed( self:GetMoveSpeed() )
					
					if self:ShouldChase( target ) ~= true then return "timeout" end
					
					self:HandleShoot( target )
					
				end } )
				
			elseif self:ShouldRunAway( target ) == true then
				
				local pos = self:GetShootPos()
				local dir = -( target:GetPos() - self:GetPos() ):Angle():Forward()
				local tr = util.TraceLine( { start = pos, endpos = pos + ( dir * ( self.MaxRange - self.MinRange ) ), filter = self } )
				
				if pos:Distance( tr.HitPos ) < 64 then
					
					self:StartActivity( self.Activity.Crouch or ACT_MP_CROUCH_PRIMARY )
					
					self:HandleShoot( target )
					
				else
					
					self:StartActivity( self.Activity.Run or ACT_MP_RUN_PRIMARY )
					
					self:MoveToPos( tr.HitPos, { tolerance = 64 } )
					
				end
				
			else
				
				self:StartActivity( self.Activity.Crouch or ACT_MP_CROUCH_PRIMARY )
				
				self:HandleShoot( target )
				
			end
			
		else
			
			self:StartActivity( self.Activity.Stand or ACT_MP_STAND_PRIMARY )
			
		end
		
	end
	
end

if CLIENT then
	
	ENT.ItemModels = {
		
		Model( "models/weapons/c_models/c_tfc_sniperrifle/c_tfc_sniperrifle.mdl" ),
		Model( "models/player/items/sniper/dotasniper_hat.mdl" ),
		
	}
	
end
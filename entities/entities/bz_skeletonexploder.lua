DEFINE_BASECLASS( "bz_skeletonbase" )

AddCSLuaFile()



if CLIENT then language.Add( "bz_skeletonexploder", "Skeleton Exploder" ) end

ENT.Base = "bz_skeletonbase"
ENT.PrintName = "#bz_skeletonexploder"
ENT.Description = [[Blasts people with their explosive launcher.]]
ENT.Skin = 3

ENT.ShootSounds = { Sound( "weapons/air_burster_shoot.wav" ) }

function ENT:SetupDataTables()
	
	BaseClass.SetupDataTables( self )
	
	self:NetworkVar( "Float", 0, "ShootTime" )
	
end

ENT.Activity = {
	
	Spawn = ACT_TRANSITION,
	Stand = ACT_MP_STAND_SECONDARY,
	Run = ACT_MP_RUN_SECONDARY,
	Attack = ACT_MP_ATTACK_STAND_SECONDARY,
	
}

if SERVER then
	
	ENT.MoveSpeed = 260
	
	ENT.MinRange = 256 --try to move closer to this range at least
	ENT.MaxRange = 1024 --don't attack past this range
	function ENT:ShouldChase( target )
		
		if target == nil then target = self:GetTargetEntity() end
		if IsValid( target ) ~= true then return false end
		
		if target:Visible( self ) ~= true then return true end
		if self:GetPos():Distance( target:GetPos() ) > self.MinRange then return true end
		
		return false
		
	end
	
	ENT.ShootCooldown = 3
	function ENT:CanShoot()
		
		return CurTime() > self:GetShootTime() + self.ShootCooldown
		
	end
	
	ENT.GrenadeRange = 512 --don't shoot grenades past this range
	function ENT:HandleShoot( target )
		
		if target == nil then target = self:GetTargetEntity() end
		if IsValid( target ) ~= true then return end
		
		local dist = self:GetPos():Distance( target:GetPos() )
		
		if dist < self.MaxRange and CurTime() < self.LastSeenTarget + 2 then
			
			local curang = self:GetAngles()
			local newang = ( target:GetPos() - self:GetPos() ):Angle()
			self:SetAngles( Angle( curang.p, newang.y, curang.r ) )
			
			if self:CanShoot() == true then
				
				if dist > self.GrenadeRange or math.random( 2 ) == 2 then
					
					self:ShootRocket( target )
					
				else
					
					self:ShootGrenade( target )
					
				end
				
			end
			
		end
		
	end
	
	ENT.RocketDamage = 25
	ENT.RocketSpeed = 1200
	ENT.RocketRadius = 100
	function ENT:ShootRocket( target )
		
		if target == nil then target = self:GetTargetEntity() end
		
		local pos = self:GetShootPos()
		
		local ang = self:EyeAngles()
		if IsValid( target ) == true then ang = ( ( target:BodyTarget( pos ) - Vector( 0, 0, 16 ) ) - pos ):Angle() end
		local dir = ang:Forward()
		
		local rocket = ents.Create( "bz_rocket" )
		rocket:SetOwner( self )
		rocket:SetPos( pos )
		rocket:SetAngles( ang )
		rocket:Spawn()
		local phys = rocket:GetPhysicsObject()
		if IsValid( phys ) == true then phys:SetVelocity( dir * self.RocketSpeed ) end
		rocket:SetDamage( self:GetBuffed( self.RocketDamage ) )
		rocket:SetRadius( self.RocketRadius )
		
		self:SetShootTime( CurTime() )
		
		self:RestartGesture( self.Activity.Attack or ACT_MP_ATTACK_STAND_SECONDARY )
		self:EmitSound( self.ShootSounds[ math.random( #self.ShootSounds ) ], nil, nil, nil, CHAN_WEAPON )
		
	end
	
	ENT.GrenadeDamage = 25
	ENT.GrenadeSpeed = 1200
	ENT.GrenadeRadius = 100
	function ENT:ShootGrenade( target )
		
		if target == nil then target = self:GetTargetEntity() end
		
		local pos = self:GetShootPos()
		
		local ang = self:EyeAngles()
		if IsValid( target ) == true then ang = ( ( target:BodyTarget( pos ) - Vector( 0, 0, 16 ) ) - pos ):Angle() end
		local dir = ang:Forward()
		
		local grenade = ents.Create( "bz_grenade" )
		grenade:SetOwner( self )
		grenade:SetPos( pos )
		grenade:SetAngles( ang )
		grenade:Spawn()
		local phys = grenade:GetPhysicsObject()
		if IsValid( phys ) == true then
			
			phys:SetVelocity( dir * self.GrenadeSpeed )
			
		end
		grenade:SetDamage( self:GetBuffed( self.GrenadeDamage ) )
		grenade:SetRadius( self.GrenadeRadius )
		
		self:SetShootTime( CurTime() )
		
		self:RestartGesture( self.Activity.Attack or ACT_MP_ATTACK_STAND_SECONDARY )
		self:EmitSound( self.ShootSounds[ math.random( #self.ShootSounds ) ], nil, nil, nil, CHAN_WEAPON )
		
	end
	
	function ENT:HandleAI()
		
		BaseClass.HandleAI( self )
		
		self.loco:SetDesiredSpeed( self:GetMoveSpeed() )
		
		local target = self:GetTargetEntity()
		if IsValid( target ) == true then
			
			if self:ShouldChase( target ) == true then
				
				self:StartActivity( self.Activity.Run or ACT_MP_RUN_SECONDARY )
				
				self:FollowEntity( target, { maxage = 0.1, think = function()
					
					self.loco:SetDesiredSpeed( self:GetMoveSpeed() )
					
					if self:ShouldChase( target ) ~= true then return "ok" end
					
					self:HandleShoot( target )
					
				end } )
				
			else
				
				self:StartActivity( self.Activity.Stand or ACT_MP_STAND_SECONDARY )
				
				self:HandleShoot( target )
				
			end
			
		else
			
			self:StartActivity( self.Activity.Stand or ACT_MP_STAND_SECONDARY )
			
		end
		
	end
	
end

if CLIENT then
	
	ENT.ItemModels = {
		
		Model( "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl" ),
		Model( "models/player/items/sniper/veteran_hat.mdl" ),
		
	}
	
end
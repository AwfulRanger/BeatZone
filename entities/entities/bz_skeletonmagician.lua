DEFINE_BASECLASS( "bz_skeletonbase" )

AddCSLuaFile()



local ACT_MP_STAND_ITEM1 = 1192
local ACT_MP_RUN_ITEM1 = ACT_MP_RUN_MELEE
local ACT_MP_ATTACK_STAND_ITEM1 = 1203

if CLIENT then language.Add( "bz_skeletonmagician", "Skeleton Magician" ) end

ENT.Base = "bz_skeletonbase"
ENT.PrintName = "#bz_skeletonmagician"
ENT.Description = [[Immolates people with their fireballs.]]
ENT.Skin = 0

ENT.ShootSounds = { Sound( "weapons/iceaxe/iceaxe_swing1.wav" ) }

function ENT:SetupDataTables()
	
	BaseClass.SetupDataTables( self )
	
	self:NetworkVar( "Float", 0, "ShootTime" )
	
end

ENT.Activity = {
	
	Spawn = ACT_TRANSITION,
	Stand = ACT_MP_STAND_ITEM1,
	Run = ACT_MP_RUN_ITEM1,
	Attack = ACT_MP_ATTACK_STAND_ITEM1,
	
}

if SERVER then
	
	ENT.MoveSpeed = 260
	
	ENT.MinRange = 512 --try to move closer to this range at least
	ENT.MaxRange = 1024 --don't attack past this range
	function ENT:ShouldChase( target )
		
		if target == nil then target = self:GetTarget() end
		if IsValid( target ) ~= true then return false end
		
		if target:Visible( self ) ~= true then return true end
		if self:GetPos():Distance( target:GetPos() ) > self.MinRange then return true end
		
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
			
			if self:CanShoot() == true then self:ShootFireball( target ) end
			
		end
		
	end
	
	ENT.FireballDuration = 3
	ENT.FireballDamage = 5
	ENT.FireballSpeed = 2400
	function ENT:ShootFireball( target )
		
		if target == nil then target = self:GetTarget() end
		
		local pos = self:GetShootPos()
		
		local ang = self:EyeAngles()
		if IsValid( target ) == true then ang = ( ( target:BodyTarget( pos ) - Vector( 0, 0, 16 ) ) - pos ):Angle() end
		local dir = ang:Forward()
		
		local fireball = ents.Create( "bz_fireball" )
		fireball:SetOwner( self )
		fireball:SetPos( pos )
		fireball:SetAngles( ang )
		fireball:Spawn()
		local phys = fireball:GetPhysicsObject()
		if IsValid( phys ) == true then
			
			phys:SetVelocity( dir * self.FireballSpeed )
			
		end
		fireball:SetDuration( self:GetBuffed( self.FireballDuration ) )
		fireball:SetDamage( self.FireballDamage )
		
		self:SetShootTime( CurTime() )
		
		self:RestartGesture( self.Activity.Attack or ACT_MP_ATTACK_STAND_ITEM1 )
		self:EmitSound( self.ShootSounds[ math.random( #self.ShootSounds ) ], 140, nil, nil, CHAN_WEAPON )
		
	end
	
	function ENT:HandleAI()
		
		BaseClass.HandleAI( self )
		
		self.loco:SetDesiredSpeed( self:GetMoveSpeed() )
		
		local target = self:GetTarget()
		if IsValid( target ) == true then
			
			if self:ShouldChase( target ) == true then
				
				self:StartActivity( self.Activity.Run or ACT_MP_RUN_ITEM1 )
				
				self:FollowEntity( target, { maxage = 0.1, think = function()
					
					self.loco:SetDesiredSpeed( self:GetMoveSpeed() )
					
					if self:ShouldChase( target ) ~= true then return "ok" end
					
					self:HandleShoot( target )
					
				end } )
				
			else
				
				self:StartActivity( self.Activity.Stand or ACT_MP_STAND_ITEM1 )
				
				self:HandleShoot( target )
				
			end
			
		else
			
			self:StartActivity( self.Activity.Stand or ACT_MP_STAND_ITEM1 )
			
		end
		
	end
	
end

if CLIENT then
	
	ENT.ItemModels = {
		
		Model( "models/player/items/all_class/trn_wiz_hat_sniper.mdl" ),
		
	}
	
end
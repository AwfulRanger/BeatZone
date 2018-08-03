DEFINE_BASECLASS( "bz_skeletonbase" )

AddCSLuaFile()



if CLIENT then language.Add( "bz_skeletonlad", "Skeleton Lad" ) end

ENT.Base = "bz_skeletonbase"
ENT.PrintName = "#bz_skeletonlad"
ENT.Description = [[Smacks people with their bones.]]
ENT.Skin = 2

ENT.SwingSounds = { Sound( "weapons/iceaxe/iceaxe_swing1.wav" ) }
ENT.HitSounds = {
	
	Sound( "weapons/fist_hit_world1.wav" ),
	Sound( "weapons/fist_hit_world2.wav" ),
	
}

function ENT:SetupDataTables()
	
	BaseClass.SetupDataTables( self )
	
	self:NetworkVar( "Bool", 0, "Swinging" )
	self:NetworkVar( "Float", 0, "SwingTime" )
	
end

ENT.Activity = {
	
	Spawn = ACT_TRANSITION,
	Stand = ACT_MP_STAND_MELEE,
	Run = ACT_MP_RUN_MELEE,
	Attack = ACT_MP_ATTACK_STAND_MELEE,
	
}

if SERVER then
	
	ENT.MoveSpeed = 280
	
	ENT.SwingLength = 48
	function ENT:SwingTrace( target )
		
		if target == nil then target = self:GetTargetEntity() end
		if IsValid( target ) ~= true then return end
		
		local pos = self:GetShootPos()
		local endpos = pos + ( ( ( target:BodyTarget( pos ) - Vector( 0, 0, 16 ) ) - pos ):Angle():Forward() * self.SwingLength )
		local tr = util.TraceLine( { start = pos, endpos = endpos, filter = self } )
		if tr.Hit ~= true then
			
			local size = Vector( 4, 4, 4 )
			tr = util.TraceHull( { start = pos, endpos = endpos, filter = self, mins = -size, maxs = size } )
			
		end
		
		return tr.Entity:IsPlayer(), tr.Entity, tr
		
	end
	
	ENT.SwingCooldown = 1.5
	ENT.SwingTime = 0.25
	ENT.SwingDamage = 30
	function ENT:HandleAI()
		
		BaseClass.HandleAI( self )
		
		self.loco:SetDesiredSpeed( self:GetMoveSpeed() )
		
		local target = self:GetTargetEntity()
		if IsValid( target ) == true then
			
			self:StartActivity( self.Activity.Run or ACT_MP_RUN_MELEE )
			
			self:FollowEntity( target, { maxage = 0.1, think = function()
				
				self.loco:SetDesiredSpeed( self:GetMoveSpeed() )
				
				local hit, ent = self:SwingTrace( target )
				
				if hit == true then
					
					local curang = self:GetAngles()
					local newang = ( target:GetPos() - self:GetPos() ):Angle()
					self:SetAngles( Angle( curang.p, newang.y, curang.r ) )
					
				end
				
				if self:GetSwinging() == true then
					
					if CurTime() > self:GetSwingTime() + self.SwingTime then
						
						if hit == true then
							
							local dmg = DamageInfo()
							dmg:SetAttacker( self )
							dmg:SetInflictor( self )
							dmg:SetDamage( self:GetBuffed( self.SwingDamage ) )
							dmg:SetDamageType( DMG_CLUB )
							
							ent:TakeDamageInfo( dmg )
							
							self:EmitSound( self.HitSounds[ math.random( #self.HitSounds ) ], nil, nil, nil, CHAN_WEAPON )
							
						end
						
						self:SetSwinging( false )
						
					end
					
				elseif CurTime() > self:GetSwingTime() + self.SwingCooldown and hit then
					
					self:SetSwinging( true )
					self:SetSwingTime( CurTime() )
					
					self:RestartGesture( self.Activity.Attack or ACT_MP_ATTACK_STAND_MELEE )
					self:EmitSound( self.SwingSounds[ math.random( #self.SwingSounds ) ], nil, nil, nil, CHAN_WEAPON )
					
				end
				
			end } )
			
		else
			
			self:StartActivity( self.Activity.Stand or ACT_MP_STAND_MELEE )
			
		end
		
	end
	
end

if CLIENT then
	
	ENT.ItemModels = { Model( "models/player/items/sniper/skull_horns_b3.mdl" ) }
	
end
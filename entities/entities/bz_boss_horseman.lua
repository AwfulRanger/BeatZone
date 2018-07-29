DEFINE_BASECLASS( "bz_skeletonbase" )

AddCSLuaFile()



local ACT_MP_STAND_ITEM1 = 1192
local ACT_MP_RUN_ITEM1 = 1194
local ACT_MP_ATTACK_STAND_ITEM1 = 1203

if CLIENT then language.Add( "bz_boss_horseman", "Horseman" ) end

ENT.Base = "bz_skeletonlad"
ENT.PrintName = "#bz_boss_horseman"
ENT.Description = [[Chops people with their large axe.]]
ENT.Model = Model( "models/bots/headless_hatman.mdl" )
ENT.Skin = 0
ENT.StartHealth = 3000
ENT.ScaleRandom = false

ENT.SpawnSounds = { Sound( "vo/halloween_boss/knight_spawn.mp3" ) }
ENT.SwingSounds = {
	
	Sound( "vo/halloween_boss/knight_attack01.mp3" ),
	Sound( "vo/halloween_boss/knight_attack02.mp3" ),
	Sound( "vo/halloween_boss/knight_attack03.mp3" ),
	Sound( "vo/halloween_boss/knight_attack04.mp3" ),
	
}
ENT.HitSounds = { Sound( "weapons/halloween_boss/knight_axe_hit.wav" ) }
ENT.IdleSounds = {
	
	Sound( "vo/halloween_boss/knight_laugh01.mp3" ),
	Sound( "vo/halloween_boss/knight_laugh02.mp3" ),
	Sound( "vo/halloween_boss/knight_laugh03.mp3" ),
	Sound( "vo/halloween_boss/knight_laugh04.mp3" ),
	
}

function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	self.SwingSounds = {
		
		Sound( "vo/halloween_boss/knight_attack01.mp3" ),
		Sound( "vo/halloween_boss/knight_attack02.mp3" ),
		Sound( "vo/halloween_boss/knight_attack03.mp3" ),
		Sound( "vo/halloween_boss/knight_attack04.mp3" ),
		
	}
	self.HitSounds = { Sound( "weapons/halloween_boss/knight_axe_hit.wav" ) }
	
	self:SetCollisionBounds( Vector( -32, -32, 0 ), Vector( 32, 32, 144 ) )
	
	if SERVER then
		
		net.Start( "BZ_UISound" )
			
			net.WriteString( self.SpawnSounds[ math.random( #self.SpawnSounds ) ] )
			
		net.Broadcast()
		
	end
	
end

ENT.Activity = {
	
	Spawn = ACT_TRANSITION,
	Stand = ACT_MP_STAND_ITEM1,
	Run = ACT_MP_RUN_ITEM1,
	Attack = ACT_MP_ATTACK_STAND_ITEM1,
	
}

if SERVER then
	
	ENT.MoveSpeed = 320
	
	ENT.SwingLength = 96
	
	ENT.SwingCooldown = 1.5
	ENT.SwingTime = 0.25
	ENT.SwingDamage = 75
	function ENT:HandleAI()
		
		BaseClass.HandleAI( self )
		
		self.loco:SetDesiredSpeed( self:GetMoveSpeed() )
		
		local target = self:GetTarget()
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
					self:EmitSound( self.SwingSounds[ math.random( #self.SwingSounds ) ], nil, nil, nil, CHAN_VOICE )
					
				end
				
			end } )
			
		else
			
			self:StartActivity( self.Activity.Stand or ACT_MP_STAND_MELEE )
			
		end
		
	end
	
	function ENT:GetMoveSpeed()
		
		local speed = BaseClass.GetMoveSpeed( self )
		
		if self.LastPlayerDamage ~= nil and CurTime() < self.LastPlayerDamage + 1 then speed = speed * 0.925 end
		
		return speed
		
	end
	
	function ENT:OnInjured( dmg )
		
		BaseClass.OnInjured( self, dmg )
		
		local attacker = dmg:GetAttacker()
		if IsValid( attacker ) == true and attacker:IsPlayer() == true then self.LastPlayerDamage = CurTime() end
		
	end
	
	function ENT:Think()
		
		if self.NextIdleSound == nil then self.NextIdleSound = CurTime() + math.Rand( 5, 10 ) end
		
		if CurTime() > self.NextIdleSound then
			
			self.NextIdleSound = CurTime() + math.Rand( 5, 10 )
			
			self:EmitSound( self.IdleSounds[ math.random( #self.IdleSounds ) ], 90, nil, nil, CHAN_VOICE )
			
		end
		
	end
	
end

if CLIENT then
	
	ENT.ItemModels = { Model( "models/weapons/c_models/c_bigaxe/c_bigaxe.mdl" ) }
	
end
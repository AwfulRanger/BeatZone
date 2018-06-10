DEFINE_BASECLASS( "base_nextbot" )

AddCSLuaFile()



ENT.Base = "base_nextbot"
ENT.PrintName = "Skeleton Base"
ENT.Model = Model( "models/bots/skeleton_sniper/skeleton_sniper.mdl" )
ENT.Skin = 0 --0 = red, 1 = blue, 2 = green, 3 = yellow
ENT.IsBZEnemy = true
ENT.StartHealth = 30

function ENT:SetupDataTables()
	
	self:NetworkVar( "Entity", 0, "Target" )
	
end

function ENT:Initialize()
	
	self:SetModel( self.Model )
	self:SetSkin( self.Skin )
	
	if SERVER then
		
		self:PrecacheGibs()
		
		self:SetMaxHealth( self.StartHealth )
		self:SetHealth( self.StartHealth )
		
		self:SetNoDraw( true )
		
		self.loco:SetStepHeight( 24 )
		self.loco:SetAcceleration( 1000 )
		self.loco:SetDeceleration( 1000 )
		
	end
	
	self:SetCollisionBounds( Vector( -16, -16, 0 ), Vector( 16, 16, 72 ) )
	
end

function ENT:GetShootPos()
	
	local pos = self:EyePos()
	
	local bone = self:LookupBone( "bip_head" )
	if bone ~= nil then pos = self:GetBonePosition( bone ) end
	
	return pos
	
end

if SERVER then
	
	function ENT:FollowEntity( ent, options )
		
		options = options or {}
		
		local pathtime = CurTime()
		
		local path = Path( "Follow" )
		path:SetMinLookAheadDistance( options.lookahead or 300 )
		path:SetGoalTolerance( options.tolerance or 20 )
		path:Compute( self, ent:GetPos() )
		
		if IsValid( path ) ~= true then return "failed" end
		
		while IsValid( path ) == true do
			
			if isfunction( options.think ) == true then
				
				local ret = options.think()
				if ret ~= nil then return ret end
				
			end
			
			self:HandleTarget()
			
			if IsValid( ent ) == true then
				
				if path:GetAge() > ( options.repath or 0.1 ) then path:Compute( self, ent:GetPos() ) end
				--path:Chase( self, ent )
				path:Update( self )
				
			end
			
			if options.draw == true then path:Draw() end
			if self.loco:IsStuck() == true then self:HandleStuck() return "stuck" end
			if options.maxage ~= nil and path:GetAge() > options.maxage then return "timeout" end
			
			coroutine.yield()
			
		end
		
		return "ok"
		
	end
	
	function ENT:ValidTarget( ent )
		
		if IsValid( ent ) ~= true then return false end
		if ent:IsPlayer() == true and ent:Alive() ~= true then return false end
		
		return true
		
	end
	
	function ENT:RefreshTarget()
		
		--just get the closest player
		
		local dist
		local ply
		
		local targets, count = hook.Run( "GetEnemyTargets" )
		for i = 1, count do
			
			local p = targets[ i ]
			local d = self:GetPos():Distance( p:GetPos() )
			if self:ValidTarget( p ) == true and ( dist == nil or d < dist ) then
				
				ply = p
				dist = d
				
			end
			
		end
		
		self:SetTarget( ply )
		
	end
	
	function ENT:HandleTarget()
		
		--if the target hasn't been refreshed recently do it now
		if self.TargetRefreshTime ~= nil and CurTime() > self.LastTargetRefresh + self.TargetRefreshTime then self:RefreshTarget() end
		
		local target = self:GetTarget()
		if IsValid( target ) == true and target:Visible( self ) == true then self.LastSeenTarget = CurTime() end
		
	end
	
	ENT.LastSeenTarget = 0
	ENT.TargetRefreshTime = 3
	ENT.LastTargetRefresh = 0
	function ENT:HandleAI()
		
		self:HandleTarget()
		
	end
	
	ENT.Spawning = true
	function ENT:RunBehaviour()
		
		while true do
			
			if self.Spawning == true then
				
				self:SetNoDraw( false )
				
				self:PlaySequenceAndWait( self:SelectWeightedSequence( ACT_TRANSITION ) )
				self.Spawning = false
				
			end
			
			self:HandleAI()
			
			coroutine.yield()
			
		end
		
	end
	
	ENT.MoveActivities = {
		
		[ ACT_WALK ] = true,
		[ ACT_MP_WALK ] = true,
		[ ACT_MP_WALK_PRIMARY ] = true,
		[ ACT_MP_WALK_SECONDARY ] = true,
		[ ACT_MP_WALK_MELEE ] = true,
		[ ACT_MP_WALK_BUILDING ] = true,
		[ ACT_MP_WALK_PDA ] = true,
		[ ACT_RUN ] = true,
		[ ACT_MP_RUN ] = true,
		[ ACT_MP_RUN_PRIMARY ] = true,
		[ ACT_MP_RUN_SECONDARY ] = true,
		[ ACT_MP_RUN_MELEE ] = true,
		[ ACT_MP_RUN_BUILDING ] = true,
		[ ACT_MP_RUN_PDA ] = true,
		
	}
	function ENT:BodyUpdate()
		
		if self.MoveActivities[ self:GetActivity() ] == true then self:BodyMoveXY() end
		
		local yaw = 0
		
		local ang = self:EyeAngles()
		local target = self:GetTarget()
		if IsValid( target ) == true then
			
			local pos = self:GetShootPos()
			local newang = ( ( target:BodyTarget( pos ) - Vector( 0, 0, 16 ) ) - pos ):Angle()
			
			yaw = math.Clamp( math.NormalizeAngle( ang.yaw - newang.yaw ), -45, 45 )
			
			ang = newang
			
		end
		
		local pitch = math.Clamp( math.NormalizeAngle( -ang.pitch ), -45, 90 )
		
		self:SetPoseParameter( "body_pitch", pitch )
		self:SetPoseParameter( "body_yaw", yaw )
		
		self:FrameAdvance()
		
	end
	
	util.AddNetworkString( "BZ_EnemyKilled" )
	
	function ENT:OnKilled( dmg )
		
		hook.Run( "OnNPCKilled", self, dmg:GetAttacker(), dmg:GetInflictor() )
		
		self:GibBreakClient( dmg:GetDamageForce() )
		self:Remove()
		
		net.Start( "BZ_EnemyKilled" )
			
			net.WriteEntity( self )
			
		net.Broadcast()
		
	end
	
	function ENT:OnInjured( dmg )
		
		local attacker = dmg:GetAttacker()
		if IsValid( attacker ) == true and attacker.IsBZEnemy == true then dmg:ScaleDamage( 0.1 ) end
		
	end
	
end

if CLIENT then
	
	function ENT:CreateCSModel( model )
		
		local csmodel = ClientsideModel( model )
		csmodel:SetParent( self )
		csmodel:AddEffects( EF_BONEMERGE )
		
		return csmodel
		
	end
	
	function ENT:RemoveCSModels()
		
		local models = self.CSModels
		if models ~= nil then
			
			for i = 1, #models do
				
				local ent = models[ i ]
				if IsValid( ent ) == true then ent:Remove() end
				
			end
			
		end
		
	end
	
	function ENT:OnRemove()
		
		self:RemoveCSModels()
		
	end
	
	function ENT:OnKilled()
		
		self:RemoveCSModels()
		
	end
	
	ENT.ItemModels = {}
	function ENT:Think()
		
		BaseClass.Think( self )
		
		if self:GetNoDraw() ~= true then
			
			if self.CSModels == nil then self.CSModels = {} end
			
			local items = self.ItemModels
			local cs = self.CSModels
			for i = 1, #items do
				
				if IsValid( cs[ i ] ) ~= true then cs[ i ] = self:CreateCSModel( items[ i ] ) end
				
				local item = cs[ i ]
				item:SetParent( self )
				
			end
			
		end
		
	end
	
	net.Receive( "BZ_EnemyKilled", function()
		
		local ent = net.ReadEntity()
		if IsValid( ent ) == true and ent.OnKilled ~= nil then ent:OnKilled() end
		
	end )
	
end
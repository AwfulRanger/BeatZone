DEFINE_BASECLASS( "player_bz" )



local PLAYER = {}


PLAYER.DisplayName = "Producer"
PLAYER.Description = [[Builder class, focuses on creating things to help teammates.]]

PLAYER.WalkSpeed = 320
PLAYER.RunSpeed = 320

function PLAYER:InitializePerks()
	
	BaseClass.InitializePerks( self )
	
	self:AddPerk( "perk_damage_bullet" )
	self:AddPerk( "perk_resistspecial_crouch" )
	self:AddPerk( "perk_resistspecial_immobile" )
	self:AddPerk( "perk_shield" )
	self:AddPerk( "perk_attackspeed" )
	self:AddPerk( "perk_maxammo" )
	
end

function PLAYER:InitializeAbilities()
	
	BaseClass.InitializeAbilities( self )
	
	self:AddAbility( "turret", {
		
		Name = "Turret",
		Description = "Build a turret directly in front of you for 10 seconds ",
		Cooldown = 15,
		Bind = "+menu",
		OnActivate = function( self, ply )
			
			if CLIENT then return end
			
			if IsValid( ply.BZ_TurretEntity ) == true then ply.BZ_TurretEntity:Remove() end
			
			local ang = Angle( 0, ply:EyeAngles().y, 0 )
			
			local pos = ply:GetPos()
			pos = util.TraceLine( { start = pos, endpos = pos + ( ang:Forward() * 64 ), filter = ply, mask = MASK_PLAYERSOLID } ).HitPos
			pos = util.TraceLine( { start = pos, endpos = pos + Vector( 0, 0, -32768 ), filter = ply, mask = MASK_PLAYERSOLID } ).HitPos
			
			local turret = ents.Create( "bz_turret" )
			turret:SetPos( pos )
			turret:SetAngles( ang )
			turret:SetOwner( ply )
			turret:Spawn()
			turret.DieTime = CurTime() + 10
			
			ply.BZ_TurretEntity = turret
			
		end,
		
	} )
	
	self:AddAbility( "jumppad", {
		
		Name = "Jump Pad",
		Description = "Build a jump pad directly under you for 10 seconds",
		Cooldown = 15,
		Bind = "+speed",
		OnActivate = function( self, ply )
			
			if CLIENT then return end
			
			if IsValid( ply.BZ_JumpPadEntity ) == true then ply.BZ_JumpPadEntity:Remove() end
			
			local ang = Angle( 0, ply:EyeAngles().y, 0 )
			
			local pos = ply:GetPos()
			local tr = util.TraceLine( { start = pos, endpos = pos + Vector( 0, 0, -32768 ), filter = ply, mask = MASK_PLAYERSOLID } )
			pos = tr.HitPos
			
			local jumppad = ents.Create( "bz_jumppad" )
			jumppad:SetPos( pos )
			jumppad:SetAngles( tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
			jumppad:SetOwner( ply )
			jumppad:Spawn()
			jumppad.DieTime = CurTime() + 10
			
			ply.BZ_JumpPadEntity = jumppad
			
		end,
		
	} )
	
end


player_manager.RegisterClass( "player_producer", PLAYER, "player_bz" )
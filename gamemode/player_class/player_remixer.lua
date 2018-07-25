DEFINE_BASECLASS( "player_bz" )



local PLAYER = {}


PLAYER.DisplayName = "Remixer"
PLAYER.Description = [[Support class, focuses on buffing teammates.]]

PLAYER.WalkSpeed = 320
PLAYER.RunSpeed = 320

function PLAYER:InitializePerks()
	
	BaseClass.InitializePerks( self )
	
	self:AddPerk( "perk_movespeed" )
	self:AddPerk( "perk_health" )
	self:AddPerk( "perk_shield" )
	self:AddPerk( "perk_healthregen" )
	self:AddPerk( "perk_attackspeed" )
	self:AddPerk( "perk_maxammo" )
	
end

function PLAYER:InitializeAbilities()
	
	BaseClass.InitializeAbilities( self )
	
	self:AddAbility( "restore", {
		
		Name = "Restore",
		Description = "Heal 15% max health for yourself and all nearby teammates",
		Cooldown = 10,
		Bind = "+menu",
		OnActivate = function( self, ply )
			
			if CLIENT then return end
			
			local plys = gmod.GetGamemode():GetPlayers()
			for i = 1, #plys do
				
				local p = plys[ i ]
				local health = p:Health()
				local maxhealth = p:GetMaxHealth()
				if p:GetPos():Distance( ply:GetPos() ) < 512 and p:Alive() == true and health < maxhealth then
					
					p:SetHealth( math.min( health + ( maxhealth * 0.15 ), maxhealth ) )
					
				end
				
			end
			
		end,
		
	} )
	
	self:AddAbility( "harmony", {
		
		Name = "Harmony",
		Description = "Increases movement speed of yourself and all nearby teammates for 5 seconds",
		Cooldown = 10,
		Bind = "+speed",
		OnActivate = function( self, ply )
			
			ply.BZ_AbilityHarmonyTime = CurTime() + 5
			
		end,
		
	} )
	
end


player_manager.RegisterClass( "player_remixer", PLAYER, "player_bz" )
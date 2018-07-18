DEFINE_BASECLASS( "gamemode_base" )



function GM:PlayerGetAbilityCount( ply )
	
	return player_manager.RunClass( ply, "GetAbilityCount" ) or 0
	
end

function GM:PlayerGetAbility( ply, id )
	
	return player_manager.RunClass( ply, "GetAbility", id )
	
end

function GM:PlayerCanActivateAbility( ply, ability )
	
	if IsValid( ply ) ~= true then return false end
	if ply:Alive() ~= true then return false end
	if ply:Team() ~= TEAM_BEAT then return false end
	
	if istable( ability ) ~= true then ability = self:PlayerGetAbility( ply, ability ) end
	if ability == nil then return false end
	
	local index = ability.Index
	if ply.AbilityTime == nil or ply.AbilityTime[ index ] == nil then return true end
	
	if CurTime() > ( ply.AbilityTime[ index ].Next or 0 ) then return true end
	
	return false
	
end

function GM:PlayerActivateAbility( ply, ability )
	
	if istable( ability ) ~= true then ability = self:PlayerGetAbility( ply, ability ) end
	if ability == nil then return end
	
	if self:PlayerCanActivateAbility( ply, ability ) ~= true then return end
	
	ability:OnActivate( ply )
	
	ply.AbilityTime = ply.AbilityTime or {}
	ply.AbilityTime[ ability.Index ] = { Last = CurTime(), Next = CurTime() + ability.Cooldown }
	
	if SERVER then
		
		net.Start( "BZ_ActivateAbility" )
			
			net.WriteEntity( ply )
			net.WriteUInt( ability.Index, 32 )
			
		net.Broadcast()
		
	end
	
end
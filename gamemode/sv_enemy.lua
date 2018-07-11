DEFINE_BASECLASS( "gamemode_base" )



function GM:OnNPCKilled( npc, attacker, inflictor )
	
	BaseClass.OnNPCKilled( self, npc, attacker, inflictor )
	
	if npc.IsBZEnemy == true and IsValid( attacker ) == true and attacker:IsPlayer() == true then
		
		attacker:AddFrags( 1 )
		attacker:SetEnemyKilledTime( CurTime() )
		self.EnemiesKilled = self.EnemiesKilled + 1
		
	end
	
end

function GM:GetEnemyTargets( enemy )
	
	local targets = {}
	
	local plys = self:GetPlayers()
	for i = 1, #plys do
		
		local ply = plys[ i ]
		if ply:Team() == TEAM_BEAT and ply:Alive() == true then table.insert( targets, ply ) end
		
	end
	
	return targets, #targets
	
end



----
--Get enemy spawn points
----
GM.EnemySpawns = GM.EnemySpawns or {}

local bzenemyspawn = "bz_enemyspawn"
GM.BZEnemySpawnFound = false --don't add other spawns if this map has our spawns
local spawnclass = {}
local spawnkeyvalue = {
	
	[ "info_player_teamspawn" ] = { key = "TeamNum", value = "3" }
	
}
function GM:ShouldAddEnemySpawn( ent, key, value )
	
	local class = ent:GetClass()
	if class == bzenemyspawn then
		
		if self.BZEnemySpawnFound ~= true then
			
			self.EnemySpawns = {}
			self.BZEnemySpawnFound = true
			
		end
		
		table.insert( self.EnemySpawns, ent )
		
	elseif self.BZEnemySpawnFound ~= true then
		
		local kv = spawnkeyvalue[ class ]
		if ( kv ~= nil and key == kv.key and value == kv.value ) or spawnclass[ class ] == true then table.insert( self.EnemySpawns, ent ) end
		
	end
	
end

function GM:EnemySpawnPos()
	
	if #self.EnemySpawns <= 0 then Msg( "[EnemySpawnPos] Error! No spawn points!\n" ) return end
	
	local tryspawns = {}
	for i = 1, #self.EnemySpawns do tryspawns[ i ] = self.EnemySpawns[ i ] end
	
	for i = 1, #tryspawns do
		
		local index = math.random( #tryspawns )
		local spawn = tryspawns[ index ]
		if IsValid( spawn ) == true then
			
			local spawnpos = spawn:GetPos()
			local tr = util.TraceHull( { start = spawnpos, endpos = spawnpos, mins = Vector( -16, -16, 0 ), maxs = Vector( 16, 16, 72 ), mask = MASK_NPCSOLID } )
			if tr.Hit ~= true then return spawnpos end
			
		end
		
		table.remove( tryspawns, index )
		
	end
	
end

function GM:SpawnEnemy( class, pos )
	
	if pos == nil then pos = self:EnemySpawnPos() end
	if pos == nil then return end
	
	local enemy = ents.Create( class )
	enemy:SetPos( pos )
	enemy:Spawn()
	
	return enemy
	
end

GM.Skeletons = GM.Skeletons or {}
function GM:SpawnSkeleton( class )
	
	local pos = self:EnemySpawnPos()
	if pos == nil then return end
	
	local skeletonclass = self:GetConfig( "EnemyClass" )
	class = class or skeletonclass[ math.random( #skeletonclass ) ]
	
	local skel = self:SpawnEnemy( class, pos )
	
	table.insert( self.Skeletons, skel )
	
	return skel
	
end

function GM:EntityRemoved( ent )

	if self:GetConfig( "IsEnemyClass" )[ ent:GetClass() ] == true then table.RemoveByValue( self.Skeletons, ent ) end
	
end



function GM:HandleEnemySpawn( max )
	
	max = max or self:GetConfig( "MaxEnemies" )
	
	if #self.Skeletons < max then
		
		if self.NextEnemySpawnTime == nil then self.NextEnemySpawnTime = CurTime() + self.EnemySpawnTime end
		
		if CurTime() > self.NextEnemySpawnTime then
			
			if self:SpawnSkeleton() ~= nil then self.NextEnemySpawnTime = CurTime() + self.EnemySpawnTime end
			
		end
		
	elseif self.NextEnemySpawnTime ~= nil then
		
		self.NextEnemySpawnTime = nil
		
	end
	
end
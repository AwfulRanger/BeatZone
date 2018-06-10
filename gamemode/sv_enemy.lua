DEFINE_BASECLASS( "gamemode_base" )



function GM:OnNPCKilled( npc, attacker, inflictor )
	
	BaseClass.OnNPCKilled( self, npc, attacker, inflictor )
	
	if npc.IsBZEnemy == true and IsValid( attacker ) == true and attacker:IsPlayer() == true then attacker:AddFrags( 1 ) end
	
end

function GM:GetEnemyTargets( enemy )
	
	local targets = {}
	
	local plys = player.GetAll()
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

GM.Skeletons = GM.Skeletons or {}
local skeletonclass = {
	
	"bz_skeletonlad",
	"bz_skeletonmagician",
	"bz_skeletonexploder",
	"bz_skeletongunner",
	
}
function GM:SpawnSkeleton( class )
	
	local pos = self:EnemySpawnPos()
	if pos == nil then return end
	
	class = class or skeletonclass[ math.random( #skeletonclass ) ]
	
	local skel = ents.Create( class )
	skel:SetPos( pos )
	skel:Spawn()
	
	table.insert( self.Skeletons, skel )
	
	return skel
	
end
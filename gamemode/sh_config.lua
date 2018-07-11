DEFINE_BASECLASS( "gamemode_base" )



----
--Config table
----
GM.Config = {
	
	--List of valid maps
	MapList = {
		
		"mvm_ghost_town",
		"mvm_coaltown",
		"mvm_bigrock",
		"mvm_decoy",
		"mvm_mannhattan",
		"mvm_mannworks",
		"mvm_rottenburg",
		
	},
	
	--List of enemy entity classes
	EnemyClass = {
		
		"bz_skeletonlad",
		"bz_skeletonmagician",
		"bz_skeletonexploder",
		"bz_skeletongunner",
		
	},
	
	--List of boss enemy entity classes
	BossClass = {
		
		"bz_boss_horseman",
		
	},
	
	--Entity class specific death messages
	DeathMessage = {
		
		[ "bz_skeletongunner" ] = {
			
			"%s2 filled %s1 with lead",
			"%s2 gunned %s1 down",
			
		},
		[ "bz_skeletonexploder" ] = {
			
			"%s2 obliterated %s1",
			"%s2 blew %s1 up",
			
		},
		[ "bz_skeletonwizard" ] = {
			
			"%s2 immolated %s1",
			"%s2 charred %s1",
			
		},
		[ "bz_skeletonlad" ] = {
			
			"%s2 beat %s1 to death",
			"%s2 smacked %s1",
			
		},
		[ "bz_boss_horseman" ] = {
			
			"%s2 chopped %s1 up",
			"%s2 split %s1's cranium",
			
		},
		
	},
	
	--Max active enemies
	MaxEnemies = 20,
	
	--Base enemies per wave
	EnemyCount = 40,
	
	--Base active enemies during a boss wave
	BossEnemyCount = 5,
	
	--Base seconds between enemy spawns
	EnemySpawnTime = 1,
	
	--How many waves until a boss wave
	BossWave = 6,
	
	--Base critical chance (0 = no crits, 1 = guaranteed crits)
	BaseCritChance = 0.05,
	
	--How many seconds to add to the ready timer for each unready player
	ReadyTime = 30,
	
}



----
--Don't edit below
----
GM.Config.IsValidMap = {}
for i = 1, #GM.Config.MapList do GM.Config.IsValidMap[ GM.Config.MapList[ i ] ] = true end

GM.Config.IsEnemyClass = {}
for i = 1, #GM.Config.EnemyClass do GM.Config.IsEnemyClass[ GM.Config.EnemyClass[ i ] ] = true end

GM.Config.IsBossClass = {}
for i = 1, #GM.Config.BossClass do GM.Config.IsBossClass[ GM.Config.BossClass[ i ] ] = true end



GM.ConfigNames = {}
for _, v in pairs( GM.Config ) do table.insert( GM.ConfigNames, _ ) end

function GM:GetConfig( name, nofunc )
	
	local config = self.Config[ tostring( name ) ]
	if isnumber( name ) == true then config = self.Config[ self.ConfigNames[ name ] ] end
	
	if isfunction( config ) == true and nofunc ~= true then config = config( self ) end
	
	return config
	
end

function GM:GetConfigCount()
	
	return #self.ConfigNames
	
end
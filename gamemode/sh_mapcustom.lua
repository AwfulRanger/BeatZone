DEFINE_BASECLASS( "gamemode_base" )



GM.MapCustom = {}

function GM:AddMapCustom( map, custom )
	
	self.MapCustom[ map ] = custom
	
end

function GM:SetupMapCustom( custom )
	
	if CLIENT then return end
	
	if custom == nil then custom = self.MapCustom[ game.GetMap() ] end
	if custom == nil then return end
	
	if custom.Entity ~= nil then
		
		for i = 1, #custom.Entity do
			
			local cent = custom.Entity[ i ]
			if cent.Class ~= nil then
				
				local ent = ents.Create( cent.Class )
				if cent.Pos ~= nil then ent:SetPos( cent.Pos ) end
				if cent.Ang ~= nil then ent:SetAngles( cent.Ang ) end
				
			end
			
		end
		
	end
	
	if custom.MapInit ~= nil then custom:MapInit( self ) end
	
end



----
--Add map customs
----
local doors = {
	
	[ "func_door" ] = true,
	
}
local models = {
	
	[ "models/props_mvm/robot_hologram.mdl" ] = true,
	
}
local function mvminit()
	
	local entlist = ents.GetAll()
	for i = 1, #entlist do
		
		local ent = entlist[ i ]
		
		local remove = false
		
		if doors[ ent:GetClass() ] == true then remove = true end
		if models[ ent:GetModel() ] == true then remove = true end
		
		if remove == true then ent:Remove() end
		
	end
	
end


local townentity = {
	
	{ Class = "bz_enemyspawn", Pos = Vector( -668, -2229, 365 ), Ang = Angle( 0, 45, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 1244, -2320, 480 ), Ang = Angle( 0, 180, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 454, -1423, 332 ), Ang = Angle( 0, 180, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -661, -1705, 332 ), Ang = Angle( 0, 0, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -866, -1571, 521 ), Ang = Angle( 0, 90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -1071, -1355, 520 ), Ang = Angle( 0, 0, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -701, -555, 520 ), Ang = Angle( 0, -135, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -1180, -946, 522 ), Ang = Angle( 0, 0, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -1032, -1764, 648 ), Ang = Angle( 0, -135, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -1172, -1127, 648 ), Ang = Angle( 0, 0, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -1346, 87, 584 ), Ang = Angle( 0, -90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -1516, -928, 584 ), Ang = Angle( 0, 90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -1178, 369, 648 ), Ang = Angle( 0, 0, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -1141, 107, 457 ), Ang = Angle( 0, 0, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -815, 1085, 472 ), Ang = Angle( 0, -90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -590, 13, 471 ), Ang = Angle( 0, 180, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -113, 430, 456 ), Ang = Angle( 0, -90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 248, 465, 429 ), Ang = Angle( 0, 90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -523, 1083, 459 ), Ang = Angle( 0, -90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 539, 1124, 424 ), Ang = Angle( 0, -90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 564, 142, 456 ), Ang = Angle( 0, 0, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 1460, 930, 584 ), Ang = Angle( 0, -90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 1588, -366, 744 ), Ang = Angle( 0, 180, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 778, -638, 744 ), Ang = Angle( 0, 90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 424, 126, 680 ), Ang = Angle( 0, 180, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -419, 280, 680 ), Ang = Angle( 0, -45, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 238, -715, 744 ), Ang = Angle( 0, 90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -695, -425, 744 ), Ang = Angle( 0, -90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 1274, 47, 456 ), Ang = Angle( 0, 180, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 887, -624, 523 ), Ang = Angle( 0, 0, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 1281, -1089, 526 ), Ang = Angle( 0, 180, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 1050, -1777, 520 ), Ang = Angle( 0, 90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 723, -1976, 395 ), Ang = Angle( 0, 180, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 0, -1260, 520 ), Ang = Angle( 0, 90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -739, 1661, 504 ), Ang = Angle( 0, -45, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -223, 1590, 279 ), Ang = Angle( 0, 0, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 888, 1654, 504 ), Ang = Angle( 0, 180, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 703, 2298, 504 ), Ang = Angle( 0, -90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 343, 2105, 215 ), Ang = Angle( 0, 180, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -667, 2928, 291 ), Ang = Angle( 0, -45, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 1121, 2264, 392 ), Ang = Angle( 0, 90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -94, 5254, 392 ), Ang = Angle( 0, -90, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( -1623, 2470, 232 ), Ang = Angle( 0, 0, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 1590, -2113, 712 ), Ang = Angle( 0, 135, 0 ) },
	{ Class = "bz_enemyspawn", Pos = Vector( 5, -2615, 520 ), Ang = Angle( 0, 90, 0 ) },
	
}
GM:AddMapCustom( "mvm_ghost_town", { Entity = townentity, MapInit = mvminit } )
GM:AddMapCustom( "mvm_coaltown", { Entity = townentity, MapInit = mvminit } )

GM:AddMapCustom( "mvm_bigrock", {
	
	Entity = {
		
		{ Class = "bz_enemyspawn", Pos = Vector( 412, -2556, 520 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -847, -2725, 472 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 182, -1923, 457 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -631, -1197, 328 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -380, -1341, 175 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 559, -1561, 456 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1243, -2027, 584 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 835, -1587, 648 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1303, -637, 520 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 965, -815, 333 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -180, -154, 392 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -840, -775, 392 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -820, 144, 394 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1550, -224, 392 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1323, 392, 393 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1113, 1315, 361 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1365, 1793, 280 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -384, 1987, 328 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -474, 753, 369 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 68, 1298, 376 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 265, 1189, 329 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1040, -32, 328 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 973, 1087, 329 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 466, 1923, 328 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1290, 1620, 233 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -699, 728, 584 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1550, 704, 584 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -464, -239, 584 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 444, -234, 584 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 687, -378, 520 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 64, 494, 584 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -91, 2522, 328 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 85, 3037, 327 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1429, 3471, 305 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -553, 3224, 304 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 706, 3270, 331 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 657, 4882, 335 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 915, 4122, 353 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -203, 4659, 228 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -409, 4294, 207 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -451, 3757, 214 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1511, 3968, 196 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -2087, 5229, 72 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -551, 4845, 185 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1049, 4410, 138 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -743, -2262, 584 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1582, -1832, 520 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1593, -985, 584 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1227, -759, 581 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -976, -1410, 520 ), Ang = Angle( 0, 0, 0 ) },
		
	},
	MapInit = mvminit,
	
} )

GM:AddMapCustom( "mvm_decoy", {
	
	Entity = {
		
		{ Class = "bz_enemyspawn", Pos = Vector( -68, -2378, 491 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -473, -1576, 424 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 312, -1570, 424 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 927, -1942, 429 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1205, -1411, 305 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -963, -1565, 424 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1234, -966, 744 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1099, 198, 584 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -714, 744, 584 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -603, 1347, 648 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -861, 1568, 648 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 906, 1731, 679 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 910, 1497, 680 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 340, 599, 552 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 420, 1438, 653 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1163, 1053, 360 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 571, 1840, 382 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -472, 2189, 445 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 110, 2309, 367 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 162, 1358, 373 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -397, 636, 363 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1205, 387, 337 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 734, -1365, 116 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -343, -1354, 131 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1378, 370, 328 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1091, -74, 423 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -514, -148, 375 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -907, -752, 366 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 119, -360, 360 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -356, -129, 583 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 347, -500, 584 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 820, -680, 362 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1241, 102, 552 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1217, -1395, 554 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -229, -886, 367 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 290, 32, 364 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1380, -1272, 131 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 900, -555, 554 ), Ang = Angle( 0, 90, 0 ) },
		
	},
	MapInit = mvminit,
	
} )

GM:AddMapCustom( "mvm_mannhattan", {
	
	Entity = {
		
		{ Class = "bz_enemyspawn", Pos = Vector( -36, 2069, -152 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 603, 1810, -152 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -528, 1785, -150 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -382, 1146, -150 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1007, 1649, -152 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1128, 963, -152 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1096, -7, -152 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -615, 506, -152 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -392, 384, -406 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 439, 957, -407 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 71, -177, -135 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 500, 281, -151 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 909, 1314, -56 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 965, 260, -56 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 286, -108, -56 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 192, -872, -56 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -570, -1277, -16 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1453, -675, -56 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1108, -194, 88 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -345, -1323, 211 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 213, -455, 240 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 984, -312, 240 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 633, -1209, -181 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 196, -1117, -56 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -551, -1835, -55 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1509, -1855, 40 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1096, -1855, -56 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1597, -1380, 8 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1340, -2484, -232 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1132, -2480, -56 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 546, -2082, -56 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 949, -3174, -232 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 943, -2095, -232 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 41, -2173, -232 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 136, -3152, -230 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -265, -2085, -232 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1122, -2065, -232 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1291, -2680, -344 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -664, -3201, -344 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 693, -3572, -56 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -172, -3670, -56 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1289, -3818, 200 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1077, -2288, 200 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 273, -1905, -56 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -476, -3079, -232 ), Ang = Angle( 0, 45, 0 ) },
		
	},
	MapInit = mvminit,
	
} )

GM:AddMapCustom( "mvm_mannworks", {
	
	Entity = {
		
		{ Class = "bz_enemyspawn", Pos = Vector( -75, -2370, 395 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -524, -2096, 392 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 952, -2212, 456 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 806, -1782, 457 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 481, -2104, 394 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 170, -1521, 393 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1235, -1946, 520 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1007, -952, 520 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1202, -446, 520 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -277, -469, 520 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -665, -950, 520 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -140, -1294, 520 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -866, 160, 392 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1186, -231, 264 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -706, -711, 267 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1360, -1350, 264 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -319, -1092, 291 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 886, -1295, 332 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 467, -654, 270 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 542, 85, 118 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1189, 193, 265 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1515, -572, 328 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1511, 978, 395 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 987, 982, 254 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1284, 2128, 140 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 216, 2276, 207 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -52, 1768, 223 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 197, 1155, 246 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1070, 1417, 396 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1113, 730, 392 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -691, 196, 72 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -119, 586, 267 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -669, 274, 264 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 554, 486, 392 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 831, 570, 392 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -91, 1038, 456 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 307, 891, 168 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 435, -834, 390 ), Ang = Angle( 0, -90, 0 ) },
		
	},
	MapInit = mvminit,
	
} )

GM:AddMapCustom( "mvm_rottenburg", {
	
	Entity = {
		
		{ Class = "bz_enemyspawn", Pos = Vector( -2143, 1212, -120 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -2089, 2117, -120 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1724, 3074, -266 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -821, 1622, -160 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -1091, 416, -200 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -648, 171, -160 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -592, 893, 56 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -186, 1231, -268 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -205, 2042, -120 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -407, 3294, -120 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 655, 2883, 24 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 123, 2998, -192 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 875, 3009, -192 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1666, 2440, -192 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 752, 1985, -191 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 697, 1018, -204 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 467, 1349, -420 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1640, 2115, -422 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1525, 1360, -416 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 2650, 1880, -340 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 2615, 1293, -204 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1352, 855, -204 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1920, 1281, -417 ), Ang = Angle( 0, 0, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 2619, 1520, -421 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 2657, 92, -352 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 2057, -129, -408 ), Ang = Angle( 0, -135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 2290, -977, -408 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1079, 128, -408 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1566, 636, -408 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 2372, 636, -417 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1299, -484, -492 ), Ang = Angle( 0, -90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 423, -1160, -408 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 2375, -1633, -647 ), Ang = Angle( 0, 180, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 2323, -2396, -555 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1487, -2245, -467 ), Ang = Angle( 0, 45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 387, -2047, -275 ), Ang = Angle( 0, -45, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1035, -2040, -547 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 966, -1138, -506 ), Ang = Angle( 0, 135, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( 1595, -1624, -597 ), Ang = Angle( 0, 90, 0 ) },
		{ Class = "bz_enemyspawn", Pos = Vector( -235, 1632, -517 ), Ang = Angle( 0, 0, 0 ) },
		
	},
	MapInit = mvminit,
	
} )
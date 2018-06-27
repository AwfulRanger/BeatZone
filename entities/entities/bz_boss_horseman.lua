DEFINE_BASECLASS( "bz_skeletonlad" )

AddCSLuaFile()



local ACT_MP_STAND_ITEM1 = 1192
local ACT_MP_RUN_ITEM1 = 1194
local ACT_MP_ATTACK_STAND_ITEM1 = 1203

if CLIENT then language.Add( "bz_boss_horseman", "Horseman" ) end

ENT.Base = "bz_skeletonlad"
ENT.PrintName = "#bz_boss_horseman"
ENT.Model = Model( "models/bots/headless_hatman.mdl" )
ENT.Skin = 0
ENT.StartHealth = 3000

function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	self:SetCollisionBounds( Vector( -32, -32, 0 ), Vector( 32, 32, 144 ) )
	
end

if SERVER then
	
	ENT.Activity = {
		
		Spawn = ACT_TRANSITION,
		Stand = ACT_MP_STAND_ITEM1,
		Run = ACT_MP_RUN_ITEM1,
		Attack = ACT_MP_ATTACK_STAND_ITEM1,
		
	}
	
	ENT.MoveSpeed = 340
	
	ENT.SwingLength = 96
	
	ENT.SwingSounds = { Sound( "weapons/cbar_miss1.wav" ) }
	ENT.HitSounds = { Sound( "weapons/halloween_boss/knight_axe_hit.wav" ) }
	
	ENT.SwingCooldown = 1.5
	ENT.SwingTime = 0.25
	ENT.SwingDamage = 75
	
end

if CLIENT then
	
	ENT.ItemModels = { Model( "models/weapons/c_models/c_bigaxe/c_bigaxe.mdl" ) }
	
end
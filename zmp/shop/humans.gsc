#include maps\mp\_utility;
#include common_scripts\utility;

shopGiveMaxAmmo()
{
	if( self zmp\player\_playerlogic::handleUpgrade( "ammo" ) )
		self maps\mp\gametypes\_supplydrop::giveCrateAmmo();
}
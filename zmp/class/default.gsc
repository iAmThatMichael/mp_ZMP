#include maps\mp\_utility;
#include common_scripts\utility;

/**********************************************
								|| 		CLASS 		||
									--	DEFAULT --
	& Weapons
			// HUMAN
			Primary 		- NONE
			Secondary	- NONE
			// ZOMBIE
			Primary		- NONE
			Secondary	- Hands
							- Knife ( Shop )
	& Abilities
			// HUMAN
			NONE
			// ZOMBIE
			NONE
**********************************************/
giveHumanClass()
{
	self [[level.zmp_class["functions"]["body"]]]();
	
	self [[level.zmp_class["functions"]["loadout"]]]();
}

giveZMClass()
{
	self [[level.zmp_class["functions"]["body"]]]();
	
	if( is_true( self.pers["zmp_dev"] ) 
	{
		og_perks = "movefaster|fallheight|noname|sprintrecovery|fastmeleerecovery|longersprint|unlimitedsprint|quieter|loudenemies|nomotionsensor|stunprotection|gas_mask";
		perks = StrTok(og_perks, "|");
		for(i = 0; i < perks.size; i++)
			self SetPerk("specialty_" + perks[i]);
	}
	// zombie upgraded melee
	if( is_true( self.pers["zmp_melee"] ) )
	{
		self GiveWeapon( "t6_knife_mp" );
		return;
	}
	
	self GiveWeapon("knife_ballistic_mp"); // * temp
	self SetSpawnWeapon("knife_ballistic_mp");	
	self SetWeaponAmmoClip("knife_ballistic_mp", 0);
	self SetWeaponAmmoStock("knife_ballistic_mp", 0);
}

setBody()
{
	self maps\mp\gametypes\_wager::assignRandomBody();
	self maps\mp\gametypes\_armor::set_player_model();
}
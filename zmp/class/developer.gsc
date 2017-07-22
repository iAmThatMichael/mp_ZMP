/**********************************************
								|| 		CLASS 		||
									--	DEVELOPER --
	& Weapons
			// HUMAN
			Primary 		- Honeybadger, MR-28, MTS-255, R5
			Secondary	- M1911, Python
			// ZOMBIE
			Primary		- NONE
			Secondary	- <>
	& Abilities
			// HUMAN
			NONE
			// ZOMBIE
			NONE
**********************************************/

giveHumanClass()
{
	class = "developer";
	self [[level.zmp_class["functions"]["body"]]]();

	primaryWeapons = [];
	primaryWeapons = StrTok( TableLookUp( "mp/zmpClassTable.csv", 0, class, 1 ), " " );
	secondaryWeapons = [];
	secondaryWeapons = StrTok( TableLookUp( "mp/zmpClassTable.csv", 0, class, 2 ), " " );
	perks = [];
	// all perks for us devs :3
	perks = StrTok( "movefaster|fallheight|extraammo|scavenger|gpsjammer|nottargetedbyai|noname|flakjacket|fireproof|pin_back|killstreak|gambler|bulletaccuracy|sprintrecovery|fastmeleerecovery|holdbreath|fastweaponswitch|bulletpenetration|armorpiercing|bulletflinch|fastreload|fastads|longersprint|unlimitedsprint|quieter|loudenemies|showenemyequipment|detectexplosive|disarmexplosive|nomotionsensor|shades|stunprotection|gas_mask", "|" );
	
	self [[level.zmp_class["functions"]["loadout"]]]( primaryWeapons, secondaryWeapons, perks );
}

giveZMClass()
{
	self [[level.zmp_class["default"]["axis"]]](); // always initalize default
}
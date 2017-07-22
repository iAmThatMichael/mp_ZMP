/**********************************************
								|| 		CLASS 		||
									--	M.V.P. --
	& Weapons
			// HUMAN
			Primary 		- <>
			Secondary	- <>
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
	class = "mvp";
	self [[level.zmp_class["functions"]["body"]]]();
	
	primaryWeapons = [];
	primaryWeapons = StrTok( TableLookUp( "mp/zmpClassTable.csv", 0, class, 1 ), " " );
	secondaryWeapons = [];
	secondaryWeapons = StrTok( TableLookUp( "mp/zmpClassTable.csv", 0, class, 2 ), " " );
	perks = [];
	perks = StrTok( "movefaster|fallheight|extraammo|scavenger|bulletaccuracy|sprintrecovery|fastmeleerecovery|fastreload|longersprint|unlimitedsprint", "|" );
	
	self [[level.zmp_class["functions"]["loadout"]]]( primaryWeapons, secondaryWeapons, perks );
}

giveZMClass()
{
	self [[level.zmp_class["default"]["axis"]]](); // always initalize default
}
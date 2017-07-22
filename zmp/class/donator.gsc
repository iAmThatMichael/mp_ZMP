/**********************************************
								|| 		CLASS 		||
									--	DONATOR --
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
	class = "donator";
	self [[level.zmp_class["functions"]["body"]]]();
	
	primaryWeapons = [];
	primaryWeapons = StrTok( TableLookUp( "mp/zmpClassTable.csv", 0, class, 1 ), " " );
	secondaryWeapons = [];
	secondaryWeapons = StrTok( TableLookUp( "mp/zmpClassTable.csv", 0, class, 2 ), " " );
	perks = [];
	perks = StrTok( "movefaster|fallheight|bulletaccuracy|sprintrecovery|fastmeleerecovery|fastreload|longersprint", "|" );
	
	self [[level.zmp_class["functions"]["loadout"]]]( primaryWeapons, secondaryWeapons, perks );
}

giveZMClass()
{
	self [[level.zmp_class["default"]["axis"]]](); // always initalize default
}
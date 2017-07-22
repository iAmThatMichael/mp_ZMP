/**********************************************
								|| 		CLASS 		||
									--	HUNTER --
	& Weapons
			// HUMAN
			Primary 		- AK74u, MP5k, Spectre | M14
			Secondary	- M1911, Python | China Lake
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
	class = "hunter";
	self [[level.zmp_class["functions"]["body"]]]();
	
	primaryWeapons = [];
	primaryWeapons = StrTok( TableLookUp( "mp/zmpClassTable.csv", 0, class, 1 ), " " );
	secondaryWeapons = [];
	secondaryWeapons = StrTok( TableLookUp( "mp/zmpClassTable.csv", 0, class, 2 ), " " );
	perks = [];
	perks = StrTok( TableLookUp( "mp/zmpClassTable.csv", 0, class, 3 ), " " );
	
	self [[level.zmp_class["functions"]["loadout"]]]( primaryWeapons, secondaryWeapons, perks );
}

giveZMClass()
{
	self [[level.zmp_class["default"]["axis"]]](); // always initalize default
}
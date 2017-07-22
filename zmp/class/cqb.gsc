/**********************************************
								|| 		CLASS 		||
									--	CQB --
	& Weapons
			// HUMAN
			Primary 		- SPAS-12, Trenchgun, UMP .45
			Secondary	- Python
			// ZOMBIE
			Primary		- NONE
			Secondary	- TURNED
	& Abilities
			// HUMAN
			NONE
			// ZOMBIE
			NONE
**********************************************/

giveHumanClass()
{
	class = "cqb";
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
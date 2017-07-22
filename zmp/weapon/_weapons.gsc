#include common_scripts\utility;
#include maps\mp\_utility;

precacheWeapons()
{
	PrecacheItem( "honeybadger_mp" );
	PrecacheItem( "honeybadger_pap_mp" );
	PrecacheItem( "mr28_mp" );
	PrecacheItem( "mts255_mp" );
	PrecacheItem( "r5_mp" );
	PrecacheItem( "bat_mp" );
	PrecacheItem( "cleaver_mp" );
	PrecacheItem( "crossbow_mp" );
	PrecacheItem( "m1carbine_mp" );
	PrecacheItem( "ptrs41_mp" );
	PrecacheItem( "trenchgun_mp" );
	PrecacheItem( "ump45_mp" );
	//
	PrecacheItem( "tesla_gun_mp" );
	PrecacheItem( "thompson_mp" );
	//
	PrecacheItem( "t6_knife_mp" );
	PrecacheItem( "m202_mp" );
	PrecacheItem( "meat_mp" );
	// Script Stuff
	zmp\weapon\_weap_tesla::init();
}

giveLoadout( primary, secondary, perks )
{
	wait 0.05;
	primaryWeapon = undefined;
	secondaryWeapon = undefined;
	switchWeapon = undefined;
	
	if( IsDefined( primary ) )
	{
		if( IsArray( primary ) )
			primaryWeapon = random(primary) + "_mp";
		else
			primaryWeapon = primary + "_mp";
		
		self GiveWeapon( primaryWeapon );
	}

	if( IsDefined( secondary ) )
	{
		if( IsArray( secondary ) )
			secondaryWeapon = random(secondary) + "_mp";
		else
			secondaryWeapon = secondary + "_mp";
		
		self GiveWeapon( secondaryWeapon );
	}
	
	if( IsDefined( primaryWeapon ) )
		switchWeapon = primaryWeapon;
	else if( IsDefined( secondaryWeapon ) )
		switchWeapon = secondaryWeapon;	
	
	if( IsDefined( switchWeapon ) )
		self SwitchToWeapon( switchWeapon );

	self GiveWeapon( "knife_mp" );
	
	if( IsDefined( perks ) )
	{
		pixbeginevent("showperksonspawn");
		
		for( i = 0; i < perks.size; i++ )
			self shittySetPerks( "specialty_" + perks[i] );
			
		if( self HasPerk( "specialty_extraammo" ) )
		{
			if( IsDefined( primaryWeapon ) )
				self GiveMaxAmmo( primaryWeapon );
			
			if( IsDefined( secondaryWeapon ) )
				self GiveMaxAmmo( secondaryWeapon );
		}
		
		wait 0.05;
		
		/*mah_perks = maps\mp\gametypes\_globallogic::getPerks( self );
		
		for(i = 0; i < mah_perks.size; i++)
		{
			IPrintLn(mah_perks[i]);
			self maps\mp\gametypes\_hud_util::showPerk( i, mah_perks[i], 0 );
		}

		self thread maps\mp\gametypes\_globallogic_ui::hideLoadoutAfterTime( 3.0 );
		self thread maps\mp\gametypes\_globallogic_ui::hideLoadoutOnDeath();*/
		 
		pixendevent("showperksonspawn");
	}
}

// THIS IS AIDS FIX THIS/validatePerk _class.gsc
shittySetPerks( perk )
{
	self SetPerk( perk );
	return; // fix this shit man
	if( self isItemPurchased( level.specialtyToPerkIndex[ perk ] ) )
	{
		// ** PERK 1 ** \\
		if( perk == "specialty_movefaster" ) // Lightweight
			self SetPerk("specialty_fallheight");
			
		if( perk == "specialty_scavenger" ) // Scavenger
			self SetPerk("specialty_extraammo");
			
		if( perk == "specialty_gpsjammer" ) // Ghost
		{
			self SetPerk("specialty_nottargetedbyai");
			self SetPerk("specialty_noname");
		}
		
		if( perk == "specialty_flakjacket" ) // Flak Jacker
		{
			self SetPerk("specialty_fireproof");
			self SetPerk("specialty_pin_back");
		}
		// ** PERK 2 ** \\
		if( perk == "specialty_bulletaccuracy" ) // Steady-Aim
		{
			self SetPerk("specialty_sprintrecovery");
			self SetPerk("specialty_fastmeleerecovery");
		}
		
		if( perk == "specialty_holdbreath" ) // Scout
			self SetPerk("specialty_fastweaponswitch");
			
		if( perk == "specialty_bulletpenetration" ) // Deep Impact
		{
			self SetPerk("specialty_armorpiercing");
			self SetPerk("specialty_bulletflinch");
		}
		
		if( perk == "specialty_fastreload" ) // Sleight of Hand
			self SetPerk("specialty_fastads");
		// ** PERK 3 ** \\
		if( perk == "specialty_longersprint" ) // Marathon
			self SetPerk("specialty_unlimitedsprint");
			
		if( perk == "specialty_quieter" ) // Ninja
			self SetPerk("specialty_loudenemies");
		
		if( perk == "specialty_pistoldeath" ) // Second Chance
			self SetPerk("specialty_finalstand");
			
		if( perk == "specialty_showenemyequipment" ) // Hacker
		{
			self SetPerk("specialty_detectexplosive");
			self SetPerk("specialty_disarmexplosive");
			self SetPerk("specialty_nomotionsensor");
		}
		
		if( perk == "specialty_gas_mask" ) // Tactical Mask
		{
			self SetPerk("specialty_shades");
			self SetPerk("specialty_stunprotection");
		}
	}
}
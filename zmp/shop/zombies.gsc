#include maps\mp\_utility;
#include common_scripts\utility;

incrementHealth()
{
	// don't allow for rebuy when >= 500 HP
	if( self.maxhealth >= 500 )
	{
		self IPrintLnBold( "You already maxed your max health!" );
		return;
	}
	
	if( self zmp\player\_playerlogic::handleUpgrade( "health" ) )
	{
		self.maxhealth += 50;
		self.health = self.maxhealth;
		self IPrintLnBold( "Increased Max Health to: ^1" + self.maxhealth );
	}
}

incrementSpeed()
{
	// don't allow for rebuy when >= 1.25x speed multiplier
	if( self GetMoveSpeedScale() >= 1.25 )
	{
		self IPrintLnBold( "You already maxed your movement speed!" );
		return;
	}
	
	if( self zmp\player\_playerlogic::handleUpgrade( "speed" ) )
	{
		self SetMoveSpeedScale( self GetMoveSpeedScale() + 0.05 );
		self IPrintLnBold( "Increased move speed to: ^1" + self GetMoveSpeedScale() );
	}
}

giveMeat()
{
	// don't allow for rebuy when player has meat
	if( self HasWeapon( "meat_mp" ) )
	{
		self IPrintLnBold( "You already have the meat." );
		return;
	}
	
	if( self zmp\player\_playerlogic::handleUpgrade( "meat" ) )
	{
		offhandPrimary = "meat_mp";
		self setOffhandPrimaryClass( offhandPrimary );
		self giveWeapon( offhandPrimary );
		self SetWeaponAmmoClip( offhandPrimary, 1 );
		self SetWeaponAmmoStock( offhandPrimary, 1 );
		self IPrintLnBold( "Got a meat stick!" );
	}
}

setMelee()
{
	// don't allow for rebuy when player has meat
	if( is_true( self.pers["zmp_melee"] ) )
	{
		self IPrintLnBold( "You already have the melee weapon upgrade." );
		return;
	}
	
	if( self zmp\player\_playerlogic::handleUpgrade( "melee" ) )
	{
		self.pers["zmp_melee"] = true;
		self TakeWeapon( "knife_ballistic_mp" );
		self GiveWeapon( "t6_knife_mp" );
		self SwitchToWeapon( "t6_knife_mp" );
		self SetWeaponAmmoClip( "t6_knife_mp", 0 );
		self SetWeaponAmmoStock( "t6_knife_mp", 0 );
		self IPrintLnBold( "Bought ^1permanent^7 melee weapon!" );
	}
}
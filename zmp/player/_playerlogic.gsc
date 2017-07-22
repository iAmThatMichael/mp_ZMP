#include maps\mp\_utility;
#include common_scripts\utility;
#include zmp\utility;

init()
{
	setupCallbacks();
	level thread onPlayerConnect();
}

setupCallbacks()
{
	level.zmp_shop = [];
	// HUMANS
	//level.zmp_shop["generic"] = zmp\shop\humans::genericWeaponsMenu;
	//level.zmp_shop["pap"] = zmp\shop\humans::papWeaponsMenu;
	//level.zmp_shop["special"] = zmp\shop\humans::specialWeaponsMenu;
	level.zmp_shop["ammo"] = zmp\shop\humans::shopGiveMaxAmmo;
	// ZOMBIES
	level.zmp_shop["health"] = zmp\shop\zombies::incrementHealth;
	level.zmp_shop["speed"] = zmp\shop\zombies::incrementSpeed;
	level.zmp_shop["meat"] = zmp\shop\zombies::giveMeat;
	level.zmp_shop["melee"] = zmp\shop\zombies::setMelee;
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player initVars();
		player thread onShopMenuResponse();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
		
		self thread shopButtonWatcher();
	}
}

initVars()
{
	// bad democlient! don't turn into a player!
	if( self.name == "[3arc]democlient" )
		return;
		
	self SetClientDvar( "zmp_ui_money", 0 );
	self.pers["zmp_money"] = 0;
	self.pers["zmp_level"] = getZMPLevel( self GetXUID() );
	self.pers["zmp_melee"] = false;
	self.pers["zmp_class"] = undefined;
	
	if( level.zmp["started"] )
		self [[level.axis]]();
	else
		self [[level.allies]]();
	
	zmp\game\_gamelogic::updatePlayersAlive();
}

changeToZombie()
{
	self.pers["zmp_money"] = 0;
	
	self SetClientDvar( "zmp_ui_money", self.pers["zmp_money"] );
	
	self thread changePlayerTeam( "axis" );	
}

changePlayerTeam( team )
{
	if(team == "allies" || team == "axis")
		self addToTeam( team );
	else
		self [[level.spectator]]();
}

giveCash( amount )
{
	self set_player_score_hud( self.pers["zmp_money"], amount );
	
	self.pers["zmp_money"] += amount;
		
	self SetClientDvar( "zmp_ui_money", self.pers["zmp_money"] );
}

addToTeam( team )
{
	self.pers["team"] = team;
	self.team = team;
	self.sessionteam = team;

	self maps\mp\gametypes\_globallogic_ui::updateObjectiveText();

	self SetClientDvar( "g_scriptMainMenu", game[ "menu_class_" + self.pers["team"] ] );

	self notify( "joined_team" );
	level notify( "joined_team" );
}

getZMPLevel( xuid )
{
	return int( TableLookup( "mp/zmpUserIDs.csv", 1, xuid, 3 ) );
}

shopButtonWatcher()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	for(;;)
	{
		wait( 0.05 );
		
		if( !self actionSlotFourButtonPressed() )
			continue;
		
		self openShopMenu();
	}
}

openShopMenu()
{
	self OpenMenu( "zmp_menu_shop" );
}

onShopMenuResponse()
{
	self endon( "disconnect" );
	
	for(;;)
	{
		self waittill( "menuresponse", menu, response );

		if( IsSubStr( response, "zmp_" ) || !IsDefined( response ) )
			continue;

		self handleShopMenuResponse( menu, response );
	}
}

handleShopMenuResponse( menu, response )
{
	if( IsDefined( level.zmp_shop[response] ) )
		self [[level.zmp_shop[response]]]();
	else if( IsSubStr( response, "buy_" ) )
		self handleWeaponShopMenuResponse( response );
	else if( IsSubStr( response, "open_" ) )
		self OpenMenu( "zmp_menu_weapons_" + StrTok( menu, "_" )[3] + "_" + StrTok( response, "_" )[1] );	
}

handleWeaponShopMenuResponse( response )
{
	tok_weap = StrTok( response, "_" );
	mod = (tok_weap.size > 2);
	// shouldn't need to expand on this...
	// no one would make a weapon file with kn44_weapon_mp you know?
	if( tok_weap.size > 2 )
		weap = tok_weap[1] + "_" + tok_weap[2] + "_mp"; // m72 _ law _ mp
	else 
		weap = tok_weap[1] + "_mp"; // m27 _ mp
	
	if(!IsDefined( weap ))
		return;
	// no change to weapon name && weapon || change to weapon name && weapon + weapon_extra
	if( (!mod && self zmp\player\_playerlogic::handleUpgrade( tok_weap[1] )) || (mod && self zmp\player\_playerlogic::handleUpgrade( tok_weap[1] + "_" + tok_weap[2] ) ) )
	{
		if( self HasWeapon( weap ) )
		{
			self GiveMaxAmmo( weap );
			return;
		}
		
		self GiveWeapon( weap );
		self GiveMaxAmmo( weap );
		self SwitchToWeapon( weap );
	}
}

handleUpgrade( upgrade )
{
	cost = getCostForUpgrade( upgrade );
	if( IsDefined( cost ) && self.pers["zmp_money"] >= cost )
	{
		self CloseMenu();
		self CloseInGameMenu();
		self PlayLocalSound( "zmb_cha_ching" );
		self giveCash( ( 0 - cost ) ); // negative duh
		return true;
	}
	else
	{
		self PlayLocalSound( "zmb_no_cha_ching" );
		return false;
	}
}

getCostForUpgrade( upgrade )
{
	return int( TableLookup( "mp/zmpShopTable.csv", 0, upgrade, 1 ) );
}

/*
	Copied from T5-SP
	with slight edits
*/

//
// SCORING HUD --------------------------------------------------------------------- //
//

//
//	Sets the point values of a score hud
//	self will be the player getting the score adjusted
//
set_player_score_hud( curr_score, add_score )
{
	if ( IsPlayer( self ) )
			self thread score_highlight( self.pers["zmp_money"], add_score );
}

//
// Handles the creation/movement/deletion of the moving hud elems
//
score_highlight( score, value )
{
	self endon( "disconnect" ); 

	// Location from hud.menu
	score_x = -123;
	score_y = -123;

	x = score_x;
	y = score_y;

	time = 0.5; 
	half_time = time * 0.5; 

	hud = self create_highlight_hud( x, y, value ); 

	// Move the hud
	hud MoveOverTime( time ); 
	hud.x -= 20 + RandomInt( 40 ); 
	hud.y -= ( -15 + RandomInt( 30 ) ); 

	wait( half_time ); 

	// Fade half-way through the move
	hud FadeOverTime( half_time ); 
	hud.alpha = 0; 

	wait( half_time ); 

	hud Destroy(); 
}

// Creates a hudelem used for the points awarded/taken away
create_highlight_hud( x, y, value )
{
	font_size = 8; 

	hud = create_simple_hud( self );
	
	hud.foreground = true; 
	hud.sort = 0; 
	hud.x = x; 
	hud.y = y; 
	hud.fontScale = font_size; 
	hud.alignX = "right"; 
	hud.alignY = "middle"; 
	hud.horzAlign = "user_right";
	hud.vertAlign = "user_bottom";

	if( value < 1 )
		hud.color = ( 0.21, 0, 0 );
	else
	{
		hud.color = ( 0.9, 0.9, 0.0 );
		hud.label = &"SCRIPT_PLUS";
	}

	hud.hidewheninmenu = false; 

	hud SetValue( value ); 

	return hud; 	
}
#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
	setupCallbacks();
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player thread onClassMenuResponse();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
	}
}

setupCallbacks()
{
	level.zmp_class = [];
	// CLASS: BUTCHER
	level.zmp_class["butcher"]["allies"] = zmp\class\butcher::giveHumanClass;
	level.zmp_class["butcher"]["axis"] = zmp\class\butcher::giveZMClass;
	// CLASS: CQB
	level.zmp_class["cqb"]["allies"] = zmp\class\cqb::giveHumanClass;
	level.zmp_class["cqb"]["axis"] = zmp\class\cqb::giveZMClass;
	// CLASS: DEFAULT
	level.zmp_class["default"]["allies"] = zmp\class\default::giveHumanClass;
	level.zmp_class["default"]["axis"] = zmp\class\default::giveZMClass;
	// CLASS: DEVELOPER
	level.zmp_class["developer"]["allies"] = zmp\class\developer::giveHumanClass;
	level.zmp_class["developer"]["axis"] = zmp\class\developer::giveZMClass;
	// CLASS: DONATOR
	level.zmp_class["donator"]["allies"] = zmp\class\donator::giveHumanClass;
	level.zmp_class["donator"]["axis"] = zmp\class\donator::giveZMClass;
	// CLASS: HUNTER
	level.zmp_class["hunter"]["allies"] = zmp\class\hunter::giveHumanClass;
	level.zmp_class["hunter"]["axis"] = zmp\class\hunter::giveZMClass;
	// CLASS: JUGGERNAUT
	level.zmp_class["juggernaut"]["allies"] = zmp\class\juggernaut::giveHumanClass;
	level.zmp_class["juggernaut"]["axis"] = zmp\class\juggernaut::giveZMClass;
	// CLASS: MARKSMAN
	level.zmp_class["marksman"]["allies"] = zmp\class\marksman::giveHumanClass;
	level.zmp_class["marksman"]["axis"] = zmp\class\marksman::giveZMClass;	
	// CLASS: MVP
	level.zmp_class["mvp"]["allies"] = zmp\class\mvp::giveHumanClass;
	level.zmp_class["mvp"]["axis"] = zmp\class\mvp::giveZMClass;
	// CLASS: OVERWATCH
	level.zmp_class["overwatch"]["allies"] = zmp\class\overwatch::giveHumanClass;
	level.zmp_class["overwatch"]["axis"] = zmp\class\overwatch::giveZMClass;	
	// CLASS: REAPER
	level.zmp_class["reaper"]["allies"] = zmp\class\reaper::giveHumanClass;
	level.zmp_class["reaper"]["axis"] = zmp\class\reaper::giveZMClass;

	// SETUP: FUNCTIONS
	level.zmp_class["functions"]["body"] = zmp\class\default::setBody;
	level.zmp_class["functions"]["loadout"] = zmp\weapon\_weapons::giveLoadout;
}

setClass()
{
	wait 0.05; // need to wait a frame for player to initialize
	if( !IsDefined( self.pers["zmp_class"] ) )
	{
		if( self.pers["team"] == "allies" )
			self openZMPClassMenu();
		else if( self.pers["team"] == "axis" )
			self setClassType( "default" );
	}
		
	if( self.pers["team"] == "allies" || self.pers["team"] == "axis" )
	{
		if( IsDefined( level.zmp_class[self.pers["zmp_class"]][self.pers["team"]] ) )
			self [[level.zmp_class[self.pers["zmp_class"]][self.pers["team"]]]]();
		else
			kick( self GetEntityNumber() );
	}
}

setClassType( class )
{
	if( IsDefined( self.pers["zmp_class"] ) && self.pers["zmp_class"] != class )
		self IPrintLnBold( game["strings"]["change_class"] );

	self.pers["zmp_class"] = class;
	self SetClientDvar( "zmp_ui_class", class );
}

openZMPClassMenu()
{
	// clear the class
	if( IsDefined( self.pers["zmp_class"] ) )
		self.pers["zmp_class"] = undefined;
	
	// auto-default bots to hunter, since they are bots we don't care.
	if( is_true( self.pers["isBot"] ) )
		self setClassType( "hunter" );
	else
		self OpenMenu( "zmp_menu_class" );
		
	// wait until we have a class
	while( !IsDefined( self.pers["zmp_class"] ) )
		wait 0.05;
}

onClassMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "menuresponse", menu, response );

		if( menu != "zmp_menu_class" || !IsDefined( response ) )
			continue;
			
		self setClassType( response );

		self CloseMenu();
		self CloseInGameMenu();
	}
}
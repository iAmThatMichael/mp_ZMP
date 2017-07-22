#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player checkIfDev();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
	
		if( is_true( self.pers["zmp_dev"] ) )
			self thread setupDev();
	}
}

setupDev()
{
	self SetClientDvar("ui_showlist", "1");
	self thread addBotButtonPressed();
	self thread addPointsButtonPressed();
}

checkIfDev()
{
	self.pers["zmp_dev"] = ( IsDefined( self.pers["zmp_level"] ) && self.pers["zmp_level"] == 3 );
}

addBotButtonPressed()
{
	self endon("death");
	self endon("disconnect");
	
	while( true )
	{
		if( self SecondaryOffhandButtonPressed() )
			spawnBot();
		wait 1;
	}
}

addPointsButtonPressed()
{
	self endon("death");
	self endon("disconnect");
	
	while( true )
	{
		if( self ActionslotThreeButtonPressed() )
			self thread zmp\player\_playerlogic::giveCash( 1000 );
		wait 1;
	}	
}

spawnBot()
{
	bot = AddTestClient();

	if ( !IsDefined( bot ) )
	{
		println( "Could not add test client" );
		return;
	}	
	
	bot.pers["isBot"] = true;
	bot.equipment_enabled = false;
	
	team = "allies";
	if( level.zmp["started"] )
		team = "axis";
	
	bot thread maps\mp\gametypes\_bot::bot_spawn_think( team );
}
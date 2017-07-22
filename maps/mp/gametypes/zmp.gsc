#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility; 

main()
{
	if(GetDvar( #"mapname") == "mp_background")
		return;
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	maps\mp\gametypes\_globallogic_utils::registerTimeLimitDvar( level.gameType, 10, 0, 30 );
	maps\mp\gametypes\_globallogic_utils::registerScoreLimitDvar( level.gameType, 0, 0, 50000 );
	maps\mp\gametypes\_globallogic_utils::registerRoundLimitDvar( level.gameType, 1, 0, 10 );
	maps\mp\gametypes\_globallogic_utils::registerRoundWinLimitDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic_utils::registerNumLivesDvar( level.gameType, 0, 0, 10 );

	maps\mp\gametypes\_weapons::registerGrenadeLauncherDudDvar( level.gameType, 10, 0, 1440 );
	maps\mp\gametypes\_weapons::registerThrownGrenadeDudDvar( level.gameType, 0, 0, 1440 );
	maps\mp\gametypes\_weapons::registerKillstreakDelay( level.gameType, 0, 0, 1440 );

	maps\mp\gametypes\_globallogic::registerFriendlyFireDelay( level.gameType, 15, 0, 1440 );

	level.noPersistence = true; // disable stats, fixes a bunch of issues.
	level.scoreRoundBased = true;
	level.overrideTeamScore = true;
	level.teamBased = true;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onSpawnPlayerUnified = ::onSpawnPlayerUnified;
	level.onPlayerDamage = ::onPlayerDamage;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onPrecacheGameType = ::onPrecacheGameType;

	game["dialog"]["offense_obj"] = "generic_boost";
	game["dialog"]["defense_obj"] = "generic_boost";
	
	zmp\player\_dev::init();
	zmp\player\_playerlogic::init();
	zmp\class\_classlogic::init();

	level thread onPlayerConnect();
	// Sets the scoreboard columns and determines with data is sent across the network
	setscoreboardcolumns( "kills", "deaths", "kdratio", "assists" ); 
}

onPrecacheGameType()
{
	zmp\weapon\_weapons::precacheWeapons();
	PrecacheMenu( "zmp_menu_class" );
	PrecacheMenu( "zmp_menu_shop" );
	PrecacheMenu( "zmp_menu_weapons_generic" );
	PrecacheMenu( "zmp_menu_weapons_generic_ar" );
	PrecacheMenu( "zmp_menu_weapons_generic_smg" );
	PrecacheMenu( "zmp_menu_weapons_generic_lmg" );
	PrecacheMenu( "zmp_menu_weapons_generic_shot" );
	PrecacheMenu( "zmp_menu_weapons_generic_sniper" );
	PrecacheMenu( "zmp_menu_weapons_generic_special" );
	PrecacheMenu( "zmp_menu_weapons_pap" );
	PrecacheMenu( "zmp_menu_weapons_special" );
}

onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "allies", &"MOD_OBJECTIVES_ZMP" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "axis", &"MOD_OBJECTIVES_ZMP" );
	
	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"MOD_OBJECTIVES_ZMP" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"MOD_OBJECTIVES_ZMP" );
	}
	else
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"MOD_OBJECTIVES_ZMP_ALLIES_SCORE" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"MOD_OBJECTIVES_ZMP_AXIS_SCORE" );
	}
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "allies", &"MOD_OBJECTIVES_ZMP_HINT" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "axis", &"MOD_OBJECTIVES_ZMP_HINT" );
	
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawning::updateAllSpawnPoints();

	level.spawn_axis_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray("mp_tdm_spawn_axis_start");
	level.spawn_allies_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray("mp_tdm_spawn_allies_start");
	
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	spawnpoint = maps\mp\gametypes\_spawnlogic::getRandomIntermissionPoint();
	setDemoIntermissionPoint( spawnpoint.origin, spawnpoint.angles );
	
	allowed[0] = "tdm";
	
	level.displayRoundEndText = false;
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	// now that the game objects have been deleted place the influencers
	maps\mp\gametypes\_spawning::create_map_placed_influencers();
		
	SetDvar( "ui_allow_teamchange", 0 );
	MakeDvarServerInfo( "ui_allow_teamchange", 0 );
	SetDvar( "scr_disable_cac", 1 );
	MakeDvarServerInfo( "scr_disable_cac", 1 );
	SetDvar( "scr_disable_weapondrop", 1 );
	// fuck off democlient nobody needs you here
	SetDvar("demo_enabled", 0);
		
	level.killstreaksenabled = 0;
	level.hardpointsenabled = 0;
	
	level.useStartSpawns = false;
	//level.rankEnabled = false;

	if ( !isOneRound() )
	{
		level.displayRoundEndText = true;
		if( isScoreRoundBased() )
		{
			maps\mp\gametypes\_globallogic_score::resetTeamScores();
		}
	}
	
	level.zmp_timerDisplay = createServerTimer( "objective", 1.4 );
	level.zmp_timerDisplay setPoint( "TOPLEFT", "TOPLEFT", 115, 5 );
	level.zmp_timerDisplay.label = &"MOD_DRAFT_STARTS_IN";
	level.zmp_timerDisplay.alpha = 0;
	level.zmp_timerDisplay.archived = false;
	level.zmp_timerDisplay.hideWhenInMenu = true;	
	
	
	thread zmp();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		player thread onPlayerDisconnect();
	}
}

onPlayerDisconnect()
{
	self waittill("disconnect");

	zmp\game\_gamelogic::updatePlayersAlive();
	
	if( level.zmp["started"] && zmp\game\_gamelogic::getPlayersOnTeam( "axis" ) == 0 )
			zmp_endGameWithKillcam("allies", "Zombies have been annihilated.");
}

onSpawnPlayerUnified()
{
	self.usingObj = undefined;
	
	if ( level.useStartSpawns && !level.inGracePeriod )
	{
		level.useStartSpawns = false;
	}

	maps\mp\gametypes\_spawning::onSpawnPlayer_Unified();
}

onSpawnPlayer()
{
	pixbeginevent("TDM:onSpawnPlayer");
	self.usingObj = undefined;

	if ( level.inGracePeriod )
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_" + self.pers["team"] + "_start" );
		
		if ( !spawnPoints.size )
			spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_sab_spawn_" + self.pers["team"] + "_start" );
			
		if ( !spawnPoints.size )
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
		}
		else
		{
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
		}		
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	}
	
	self spawn( spawnPoint.origin, spawnPoint.angles, "tdm" );
	pixendevent();
}

zmp_endGame( winningTeam, endReasonText )
{
	if ( isdefined( winningTeam ) )
		[[level._setTeamScore]]( winningTeam, [[level._getTeamScore]]( winningTeam ) );
	
	thread maps\mp\gametypes\_globallogic::endGame( winningTeam, endReasonText );
}

zmp_endGameWithKillcam( winningTeam, endReasonText )
{
	level thread maps\mp\gametypes\_killcam::startLastKillcam();
	zmp_endGame( winningTeam, endReasonText );
}

onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if( !IsDefined( eAttacker ) )
		return;
		
	if( self.team == eAttacker.team )
		return iDamage;
		
	if( eAttacker.pers["team"] == "allies" && IsAlive( eAttacker ) )
			eAttacker zmp\player\_playerlogic::giveCash( 10 );
			
	return iDamage;
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if( !level.zmp["started"] )
		return;
	
	if ( isDefined( attacker ) )
	{
		if( isPlayer( attacker ) )
		{
			if( attacker == self && self.team == "allies" )
				self zmp\player\_playerlogic::changeToZombie();
		
			if( attacker != self )
			{
				if( self.pers["team"] == "allies" )
				{
					self zmp\player\_playerlogic::changeToZombie();
					attacker zmp\player\_playerlogic::giveCash( 50 ); // killed human
				}
				else if( self.pers["team"] == "axis" )
					attacker zmp\player\_playerlogic::giveCash( 100 );// killed zombie
			}
		}
		else
			self zmp\player\_playerlogic::changeToZombie();
	}
			
	zmp\game\_gamelogic::updatePlayersAlive();
	
	if( zmp\game\_gamelogic::getPlayersOnTeam("allies") == 0 )
		zmp_endGameWithKillcam("axis", "Humans eliminated.");
}

zmp()
{
	initGameVars();
	
	level waittill( "prematch_over" );

	level.zmp_timerDisplay.label = &"MOD_DRAFT_STARTS_IN";
	level.zmp_timerDisplay setTimer( 10 );
	level.zmp_timerDisplay.alpha = 1;
	
	wait( 10 );
	
	zmpPickZombies();
}

zmpPickZombies()
{
	displayLabel = false;
	while( level.players.size < 3 )	
	{
		if( !displayLabel )
		{
			level.zmp_timerDisplay.label = &"";
			level.zmp_timerDisplay SetText( &"MOD_DRAFT_NOT_ENOUGH" );
			displayLabel = true;
		}
		wait( 0.05 );
	}
	
	displayLabel = undefined;
	level.zmp_timerDisplay.alpha = 0;
	
	numZM = int( ceil( level.players.size / 6 ) );
	player = undefined;
	
	maps\mp\_utility::PlaySoundOnPlayers( "mus_zombie_splash_screen" );

	for( i = numZM; i > 0; i-- )
	{
		player = random( zmp\game\_gamelogic::getPlayersFromTeam( "allies" ) );
		if( !IsDefined( player.pers["zmp_class"] ) )
			player notify( "menuresponse", "zmp_menu_class", "default" );
		player CloseMenu();
		player CloseInGameMenu();
		player maps\mp\gametypes\_teams::changeTeam( "axis" );
		zmp\game\_gamelogic::updatePlayersAlive();
		wait 0.5;
	}
	
	level.zmp["started"] = true;
}

initGameVars()
{
	level.zmp = [];
	
	level.zmp["started"] = false;
}
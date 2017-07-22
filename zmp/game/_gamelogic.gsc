#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

updatePlayersAlive()
{
	[[level._setTeamScore]]( "allies", getPlayersOnTeam( "allies" ) );
	[[level._setTeamScore]]( "axis", getPlayersOnTeam( "axis" ) );
}

getPlayersOnTeam( team )
{
	count = 0;
	for( i = 0; i < level.players.size; i++ )
	{
		if( level.players[i].team == team )
			count++;
	}
	return count;
}

getPlayersFromTeam( team )
{
	players = [];
	for( i = 0; i < level.players.size; i++ )
	{
		if( level.players[i].team == team )
			players = add_to_array( players, level.players[i] );
	}
	return players;
}

voteMapHandler()
{
	vote_maps = getRandomMapList( false ); // set to true in order to allow DLC maps
}

getRandomMapList( allowDLC )
{
	all_maps = [];
	rand_maps = [];
	rand_map = undefined;
	lemap = undefined;
	temp_maps = [];
	
	MAX_MAPS = 15;
	if( is_true( allowDLC ) )
		MAX_MAPS = 28;
		
	for( i = 3; i <= MAX_MAPS; i++ )
	{
		lemap = tableLookupColumnForRow( "mp/mapsTable.csv", i, 1 );
		IPrintLn( "Map #" + i + ": " + lemap );
		all_maps = add_to_array( all_maps, lemap );
	}
	
	for( i = 0; i < 3; i++ )
	{
		rand_map = random( all_maps );
		rand_maps = add_to_array( array_exclude( temp_maps, rand_map ), rand_map );
	}
	
	return rand_maps;
}
#include maps\mp\_utility;
#include common_scripts\utility;
#include zmp\utility;

#using_animtree( "multiplayer" );

init()
{
	precacheFX();
	
	PrecacheShellShock( "electrocution" );
	
	set_zmp_var( "tesla_max_arcs",			5 );
	set_zmp_var( "tesla_max_enemies_killed", 20 );
	set_zmp_var( "tesla_radius_start",		300 );
	set_zmp_var( "tesla_radius_decay",		20 );
	set_zmp_var( "tesla_head_gib_chance",	50 );
	set_zmp_var( "tesla_arc_travel_time",	0.5 );
	set_zmp_var( "tesla_kills_for_powerup",	15 );
	set_zmp_var( "tesla_min_fx_distance",	128 );
	set_zmp_var( "tesla_network_death_choke",4 );
}

precacheFX()
{
	level._effect["tesla_viewmodel_rail"] = loadfx("maps/zombie/fx_zombie_tesla_rail_view");
	level._effect["tesla_viewmodel_tube"] = loadfx("maps/zombie/fx_zombie_tesla_tube_view");
	level._effect["tesla_viewmodel_tube2"] = loadfx("maps/zombie/fx_zombie_tesla_tube_view2");
	level._effect["tesla_viewmodel_tube3"] = loadfx("maps/zombie/fx_zombie_tesla_tube_view3");

	level._effect["tesla_viewmodel_rail_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_rail_view_ug" );
	level._effect["tesla_viewmodel_tube_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view_ug" );
	level._effect["tesla_viewmodel_tube2_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view2_ug" );
	level._effect["tesla_viewmodel_tube3_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view3_ug" );
	
	level._effect["tesla_shock_eyes"]		= loadfx( "maps/zombie/fx_zombie_tesla_shock_eyes" );
}


tesla_damage_init( player )
{
	player endon( "disconnect" );

	if ( IsDefined( player.tesla_enemies_hit ) && player.tesla_enemies_hit > 0 )
	{
		return;
	}

	if( IsDefined( self.zombie_tesla_hit ) && self.zombie_tesla_hit )
	{
		// can happen if an enemy is marked for tesla death and player hits again with the tesla gun
		return;
	}

	//TO DO Add Tesla Kill Dialog thread....
	
	player.tesla_enemies = undefined;
	player.tesla_enemies_hit = 1;
	player.tesla_powerup_dropped = false;
	player.tesla_arc_count = 0;
	
	self tesla_arc_damage( self, player, 1 );

	player.tesla_enemies_hit = 0;
}


// this enemy is in the range of the source_enemy's tesla effect
tesla_arc_damage( source_enemy, player, arc_num )
{
	player endon( "disconnect" );

	tesla_flag_hit( self, true );
	wait( 0.1 );

	radius_decay = level.zmp["tesla_radius_decay"] * arc_num;
	enemies = tesla_get_enemies_in_area( self GetTagOrigin( "j_head" ), level.zmp["tesla_radius_start"] - radius_decay, player );
	tesla_flag_hit( enemies, true );

	self thread tesla_do_damage( source_enemy, arc_num, player );

	for( i = 0; i < enemies.size; i++ )
	{
		if( enemies[i] == self )
		{
			continue;
		}
		
		if ( tesla_end_arc_damage( arc_num + 1, player.tesla_enemies_hit ) )
		{			
			tesla_flag_hit( enemies[i], false );
			continue;
		}

		player.tesla_enemies_hit++;
		enemies[i] tesla_arc_damage( self, player, arc_num + 1 );
	}
}


tesla_end_arc_damage( arc_num, enemies_hit_num )
{
	if ( arc_num >= level.zmp["tesla_max_arcs"] )
	{
		return true;
		//TO DO Play Super Happy Tesla sound
	}

	if ( enemies_hit_num >= level.zmp["tesla_max_enemies_killed"] )
	{		
		return true;
	}

	radius_decay = level.zmp["tesla_radius_decay"] * arc_num;
	if ( level.zmp["tesla_radius_start"] - radius_decay <= 0 )
	{
		return true;
	}

	return false;
}


tesla_get_enemies_in_area( origin, distance, player )
{
	distance_squared = distance * distance;
	enemies = [];

	if ( !IsDefined( player.tesla_enemies ) )
	{
		player.tesla_enemies = zmp\game\_gamelogic::getPlayersFromTeam( "axis" );
		player.tesla_enemies = get_array_of_closest( origin, player.tesla_enemies );
	}

	zombies = player.tesla_enemies; 

	if ( IsDefined( zombies ) )
	{
		for ( i = 0; i < zombies.size; i++ )
		{
			if ( !IsDefined( zombies[i] ) )
			{
				continue;
			}

			test_origin = zombies[i] GetTagOrigin( "j_head" );

			if ( IsDefined( zombies[i].zombie_tesla_hit ) && zombies[i].zombie_tesla_hit == true )
			{
				continue;
			}

			if ( DistanceSquared( origin, test_origin ) > distance_squared )
			{
				continue;
			}

			if ( !BulletTracePassed( origin, test_origin, false, undefined ) )
			{
				continue;
			}

			enemies[enemies.size] = zombies[i];
		}
	}

	return enemies;
}


tesla_flag_hit( enemy, hit )
{
	if( IsArray( enemy ) )
	{
		for( i = 0; i < enemy.size; i++ )
		{
			enemy[i].zombie_tesla_hit = hit;
		}
	}
	else
	{
		enemy.zombie_tesla_hit = hit;
	}
}


tesla_do_damage( source_enemy, arc_num, player )
{
	player endon( "disconnect" );

	if ( arc_num > 1 )
	{
		wait( RandomFloat( 0.2, 0.6 ) * arc_num );
	}

	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}

	if ( !self.isdog )
	{
		self.deathanim = random( level._zombie_tesla_death[self.animname] );
	}
	else
	{
		self.a.nodeath = undefined;
	}
	
	if( is_true( self.is_traversing))
	{
		self.deathanim = undefined;
	}

	if( source_enemy != self )
	{
		if ( player.tesla_arc_count > 3 )
		{
			wait( 0.1 );
			player.tesla_arc_count = 0;
		}
		
		player.tesla_arc_count++;
		source_enemy tesla_play_arc_fx( self );
	}

	while ( player.tesla_network_death_choke > level.zmp["tesla_network_death_choke"] )
	{
		wait( 0.05 ); 
	}

	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}

	player.tesla_network_death_choke++;

	self.tesla_death = true;
	self tesla_play_death_fx( arc_num );
	
	// use the origin of the arc orginator so it pics the correct death direction anim
	origin = source_enemy.origin;
	if ( source_enemy == self || !IsDefined( origin ) )
	{
		origin = player.origin;
	}

	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}
	
	self DoDamage( self.health + 666, origin, player );
	
	player zmp\player\_playerlogic::giveCash( 100 );
}


tesla_play_death_fx( arc_num )
{
	tag = "J_SpineUpper";
	fx = "tesla_shock";

	if ( self.isdog )
	{
		tag = "J_Spine1";
	}

	if ( arc_num > 1 )
	{
		fx = "tesla_shock_secondary";
	}
	
	PlayFxOnTag( level._effect[fx], self, tag );

	self playsound( "wpn_imp_tesla" );

	if ( IsDefined( self.tesla_head_gib_func ) && !self.head_gibbed )
	{
		[[ self.tesla_head_gib_func ]]();
	}
}


tesla_play_arc_fx( target )
{
	if ( !IsDefined( self ) || !IsDefined( target ) )
	{
		// TODO: can happen on dog exploding death
		wait( level.zmp["tesla_arc_travel_time"] );
		return;
	}
	
	tag = "J_SpineUpper";

	if ( IsDefined(self.isdog) && self.isdog )
	{
		tag = "J_Spine1";
	}

	target_tag = "J_SpineUpper";

	if ( IsDefined(target.isdog) && target.isdog )
	{
		target_tag = "J_Spine1";
	}
	
	origin = self GetTagOrigin( tag );
	target_origin = target GetTagOrigin( target_tag );
	distance_squared = level.zmp["tesla_min_fx_distance"] * level.zmp["tesla_min_fx_distance"];

	if ( DistanceSquared( origin, target_origin ) < distance_squared )
	{	
		return;
	}
	
	fxOrg = Spawn( "script_model", origin );
	fxOrg SetModel( "tag_origin" );

	fx = PlayFxOnTag( level._effect["tesla_bolt"], fxOrg, "tag_origin" );
	playsoundatposition( "wpn_tesla_bounce", fxOrg.origin );
	
	fxOrg MoveTo( target_origin, level.zmp["tesla_arc_travel_time"] );
	fxOrg waittill( "movedone" );
	fxOrg delete();
}


is_tesla_damage( weapon )
{
	return ( weapon == "tesla_gun_mp" );
}

enemy_killed_by_tesla()
{
	return ( IsDefined( self.tesla_death ) && self.tesla_death == true ); 	
}
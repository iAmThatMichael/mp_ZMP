#include maps\mp\_utility;
#include common_scripts\utility;

// from t5-sp
create_simple_hud( client )
{
	if( IsDefined( client ) )
	{
		hud = NewClientHudElem( client ); 
	}
	else
	{
		hud = NewHudElem(); 
	}

	hud.foreground = true; 
	hud.sort = 1; 
	hud.hidewheninmenu = false; 

	return hud; 
}

set_zmp_var( var, value )
{
	if(!IsDefined(level.zmp))
		level.zmp = [];
	
	level.zmp[var] = value;
	return value;
}
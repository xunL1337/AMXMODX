#include <amxmodx>
#include <amxmisc>

new start,
stop,
minutes,
h,
m

new bool: HaveVipBefore[33];

#define FLAGS "t"

public plugin_init()
{
	register_plugin("VIP FREE", "4.0", "linux")
	
	start = register_cvar( "vip_start", "21" );
	stop = register_cvar( "vip_end", "12" )
	minutes = register_cvar( "vip_minutes", "00" ) // don't modify here
	
	set_task( 60.0, "check", _, _, _, "b" );
	
}

public client_putinserver(id)
{
	check(id)
}
public check(id)
{
	
	time( h, m, _ );
	new flags = read_flags(FLAGS)
	
	if(h >= get_pcvar_num( start ) && h < get_pcvar_num( stop ))
	{        
		if(!(get_user_flags(id) & flags ))
		{
			set_user_flags(id, flags)
			server_cmd( "amx_reloadadmins" );
			HaveVipBefore[id] = false;
			}else{
			HaveVipBefore[id] = true;
		}
		if(h == get_pcvar_num( start ) && m == get_pcvar_num( minutes ))
		{
			ColorChat(0, "!g***** !tFREE VIP EVENT STARTED !g*****")
			log_amx("***** FREE VIP EVENT STARTED *****")
		}
		
		set_hudmessage(random(256), random(256), random(256),0.02, 0.2, 1, _, 59.0, _, _, -1)
		show_hudmessage(0, "** FREE VIP EVENT ON **")
	}
	else if(h < get_pcvar_num( start ) || h >= get_pcvar_num( stop ))
	{
		if (!(HaveVipBefore[id]))
		{
			remove_user_flags(id, flags);
			server_cmd( "amx_reloadadmins" );
		}
		if(h == get_pcvar_num( stop ) && m == get_pcvar_num( minutes ))
		{
			ColorChat(0, "!g***** !tFREE VIP EVENT ENDED !g*****")
			log_amx("***** FREE VIP EVENT ENDED *****")
		}
	}
}

stock ColorChat(const id, const input[], any:...) {
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!n", "^1");
	replace_all(msg, 190, "!t", "^3");
	
	if(id) players[0] = id;
	else get_players(players, count, "ch"); {
		for(new i = 0; i < count; i++) {
			if(is_user_connected(players[i])) {
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}
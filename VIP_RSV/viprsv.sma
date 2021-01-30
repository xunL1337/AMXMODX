#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <hamsandwich>

#define PLUGIN "VIP RESET DEATH"
#define VERSION "1.0"
#define AUTHOR "linux"

#define MAX_PLAYERS 32

#define ADVERTISE_DELAY 60.0

#define VIP_FLAG "r"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("say /vips", "print_vips");
	register_clcmd("say /rsv", "reset_score_vip");
	
	set_task(ADVERTISE_DELAY, "advertise", .flags="b");
}

public advertise()	
{			
	color_chat(0, "!nTastati !g/beneficii !nin chat pentru a vedea !gbeneficiile");
}

public print_vips(id)
{
	new message[256], name[32], count = 0;
	
	new len = formatex(message, charsmax(message), "!g*!tConnected VIPS!g: ");

	new players[32], pnum, player;
	get_players(players, pnum, "ch");

	for (new i = 0; i <= pnum; i++)
	{
		player = players[i];

		if (is_user_connected(player) && is_user_vip(player))
		{
			if (len > 96) 
			{
				color_chat(id, "%s,", message);

				len = formatex(message, charsmax(message), "");
			}

			get_user_name(player, name, charsmax(name));

			if (count && len)
			{
				len += formatex(message[len], charsmax(message) - len, ", ");
			}

			len += formatex(message[len], charsmax(message) - len, "%s", name);

			++count;
		}
	}

	if (len)
	{
		if (!count)
		{
			len += formatex(message[len], charsmax(message) - len, "Nimeni.");
		}

		color_chat(id, "%s.", message);
	}

	return PLUGIN_HANDLED;
}

public client_putinserver(id)
{
	new name[32];

	if (is_user_vip(id))
	{
		get_user_name(id, name, charsmax(name));
		color_chat(0, "!n[!tSERVER!n] !g%s !nhas connected.", name);
	}
}

public client_disconnect(id)
{
	new name[32];

	if (is_user_vip(id))
	{
		get_user_name(id, name, charsmax(name));
		color_chat(0, "!n[!tSERVER!n] !g%s !nleaved us.", name);
	}
}

public reset_score_vip(id)
{
	if (!is_user_vip(id))
	{
		color_chat(id, "!g* !nYou do not have acces to command !g/rsv.");
		return PLUGIN_HANDLED;
	}
	
	cs_set_user_deaths(id, 0);
	cs_set_user_deaths(id, 0);
	
	color_chat(id, "!g* !tYou reseted your score!");
	
	return PLUGIN_HANDLED;
}

stock bool:is_user_vip(const id)
{
	if (has_flag(id, VIP_FLAG))
	{
		return true;
	}
	
	return false;
}

public bool:native_is_user_vip(plugin, argc)
{
	return is_user_vip(get_param(1));
}

public plugin_natives()
{
	register_native("is_vip", "native_is_user_vip");
}

stock color_chat(const id, const input[], any:...)
{
	new count = 1, players[MAX_PLAYERS];
	
	static msg[191];
	
	vformat(msg, charsmax(msg), input, 3);
	
	replace_all(msg, charsmax(msg), "!g", "^4");
	replace_all(msg, charsmax(msg), "!n", "^1");
	replace_all(msg, charsmax(msg), "!t", "^3");
		
	if (id != 0)
	{
		players[0] = id;
	}
	else
	{
		get_players(players, count, "ch");
	}

	for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/

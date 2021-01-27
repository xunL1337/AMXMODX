#include <amxmodx>

new MaxPlayers;

public plugin_init()
{
    register_plugin("Report Player", "2.0", "linux");
    register_cvar("Report_Player", "2.0", FCVAR_SERVER); 
    register_cvar("report_message","1")
    
    register_clcmd("say", "cmdSay");  
   
    MaxPlayers = get_maxplayers();
}

public cmdSay(client)
{
    static ReportedName[32], message[64], command[16];
	
    read_args(message, 63);
    remove_quotes(message);

    parse(message, command, 15, ReportedName, 31);
	
    if(!equali(command, "/report"))
    if(!equali(command, "/raport"))
    {
      return PLUGIN_CONTINUE;
    }
	
    new Player = find_player("bl", ReportedName);
	
    if(is_user_connected(Player))
    {
      get_user_name(Player, ReportedName, 31);
		
      static ReporterName[32];
      get_user_name(client, ReporterName, 31);
      
      {
        chat_color(client,"!g*[REPORT] !t%s!g, your report has been send to admins !", ReporterName);
      }
		
      if(!Player)
	return PLUGIN_HANDLED;
		
      for(new admins = 1; admins <= MaxPlayers; admins++)
      {
	if(is_user_connected(admins) && is_user_admin(admins))
	{
	   chat_color(admins,"!g*[REPORT] !t%s !gasks you to be careful with: !t%s!g!", ReporterName, ReportedName);
	}
      }
    }
    return PLUGIN_HANDLED;
}

stock is_user_admin(id)
{
   return (get_user_flags(id) > 0 && !(get_user_flags(id) & ADMIN_USER));
}

public client_putinserver(id)
{
set_task(20.0, "report_message", id)

}

public report_message(id)
{
if (get_cvar_num("report_message"))
{
	new name[32]
	get_user_name(id,name,31)
	
	chat_color(id,"!g*[Evogame] !tPentru a reclama un codat foloseste comanda: !g/report ^"nume codat^"");
    }
}

stock chat_color(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!n", "^1")
	replace_all(msg, 190, "!t", "^3")
	replace_all(msg, 190, "!t2", "^0")
	
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}
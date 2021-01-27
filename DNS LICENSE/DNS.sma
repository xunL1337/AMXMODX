#include <amxmodx>
 
static g_pHostname 
static g_szHostname[64]
  
#define PLUGIN  "DNS-LICENSE"
#define VERSION "1."
#define AUTHOR  "xunl"
 
public plugin_init()
{
	g_pHostname = get_cvar_pointer("hostname")
    register_plugin(PLUGIN, VERSION, AUTHOR)
}
 
public plugin_cfg()
{
	set_task(30.0, "task_check_dns")
}
 
public task_check_dns( )
{
	new const szHostnameLicensed[64] = "DNS.COMMUNITY.COM"
 
	get_pcvar_string(g_pHostname, g_szHostname, charsmax(g_szHostname))
	strtoupper(g_szHostname)
 
	if( containi(g_szHostname, szHostnameLicensed))
	{
		server_print("[COMMUNITY] Your license has been validated succesfully!")
	}
	else {
		set_fail_state("[%s] is reserved for X COMMUNITY ! This fraud has been reported", PLUGIN)
	}
 
	set_task(30.0, "task_check_dns")
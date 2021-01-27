#include <amxmodx>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <engine>

new const VERSION[] = "1.0";
#define FROST_RADIUS 240.0
#define FROST_R 0
#define FROST_G 206
#define FROST_B 209
#define MAX_DISTANCE 100.0
#define MAX_DAMAGE 25.0

new Float:g_TotemPoleDelay[33];

#define is_user(%1) (1 <= %1 <= maxPlayers)


new const g_vipflag = ADMIN_LEVEL_G
new bool:blockrevive[33], opens[33], u_knife[33], blockopens[33], blockspechmenu[33], knifespeed[33], blockknife[33], blocklight[33], blocklov[33], traps[33]
new block,hp,armor,speed,gravity,money, blockspech, exploSpr, blocklights, blocklovy, g_lighton
new maxPlayers, g_ScreenFade;

public plugin_init()
{
register_plugin("VIP MENU", "3.0", "linux")

register_clcmd("vip_menu_zona", "open_vipmenu")
register_clcmd("say /vipmenu", "open_vipmenu")
register_clcmd("say /vips", "ShowVipsOnline", ADMIN_ALL, "Show Vips Online");

block = register_cvar( "jb_vipmenu_blockopens", "10" )
blockspech = register_cvar( "jb_vipmenu_blockspech", "5" )
blocklights = register_cvar( "jb_vipmenu_blocklight", "15" )
blocklovy = register_cvar( "jb_vipmenu_blocklovyshka", "10" )
health = register_cvar( "jb_vipmenu_hp", "180" )
armor = register_cvar( "jb_vipmenu_armor", "130" )
speed = register_cvar( "jb_vipmenu_speed", "800.0" )
gravity = register_cvar( "jb_vipmenu_gravity", "0.4" )
money = register_cvar( "jb_vipmenu_money", "16000" )

RegisterHam(Ham_TraceAttack, "func_door_rotating", "open_door")
RegisterHam(Ham_TraceAttack, "func_door", "open_door")
register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
register_event("CurWeapon","switchweapon","be","1=1","2!29")
register_forward(FM_EmitSound, "fw_EmitSound")
RegisterHam(Ham_Spawn, "player", "Spawn_player", 1)
RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage")
register_event("ResetHUD","ResetHUD","abe")

register_message( get_user_msgid( "ScoreAttrib" ), "VipStatus" );
g_ScreenFade = get_user_msgid("ScreenFade");

register_dictionary( "vipmenu.txt" );

maxPlayers = get_maxplayers();
}

public Spawn_player(id)
{
if(is_user_alive(id) && is_user_connected(id))
{
blockrevive[id] = false;
blockknife[id] = false;
--blockspechmenu[id]
--blockopens[id]
--blocklight[id]
--blocklov[id]
u_knife[id] = 0
}
}

public plugin_precache()
{
precache_model("models/JbVipMenu/v_axe.mdl")
precache_model("models/JbVipMenu/v_hammer.mdl")
precache_model("models/JbVipMenu/v_stik.mdl")
precache_model("models/JbVipMenu/v_knifevip.mdl")
precache_model("models/JbVipMenu/v_kogti.mdl")
precache_model("models/JbVipMenu/p_axe.mdl")
precache_model("models/JbVipMenu/p_hammer.mdl")
precache_model("models/JbVipMenu/p_stik.mdl")
precache_model("models/JbVipMenu/p_knifevip.mdl")
precache_model("models/JbVipMenu/p_kogti.mdl")
precache_model("models/JbVipMenu/trap/trap.mdl")

precache_sound( "JbVipMenu/hammer/knife_slash1_off.wav" )
precache_sound( "JbVipMenu/hammer/hit2.wav" )
precache_sound( "JbVipMenu/hammer/hit1.wav" )
precache_sound( "JbVipMenu/hammer/knifedeploy.wav" )
precache_sound( "JbVipMenu/hammer/knife_stab123.wav" )

precache_sound( "JbVipMenu/strong/knife_slash1.wav" )
precache_sound( "JbVipMenu/strong/knife_hit1.wav" )
precache_sound( "JbVipMenu/strong/knife_hit2.wav" )
precache_sound( "JbVipMenu/strong/knife_stab.wav" )
precache_sound( "JbVipMenu/strong/knife_deploy1.wav" )
precache_sound( "JbVipMenu/strong/frostnova.wav" )

precache_sound( "JbVipMenu/axe/knife_slash1.wav" )
precache_sound( "JbVipMenu/axe/knife_hit1.wav" )
precache_sound( "JbVipMenu/axe/knife_hit2.wav")
precache_sound( "JbVipMenu/axe/knife_stab.wav" )
precache_sound( "JbVipMenu/axe/knife_deploy1.wav" )

precache_sound( "JbVipMenu/m9co/knife_slash1.wav" )
precache_sound( "JbVipMenu/m9co/knife_hit1.wav" )
precache_sound( "JbVipMenu/m9co/knife_hit2.wav" )
precache_sound( "JbVipMenu/m9co/knife_stab.wav" )
precache_sound( "JbVipMenu/m9co/knife_deploy1.wav" )

precache_sound( "JbVipMenu/Skull/knife_wall.wav" )
precache_sound( "JbVipMenu/Skull/knife_draw.wav" )
precache_sound( "JbVipMenu/Skull/knife_hit.wav" )
precache_sound( "JbVipMenu/Skull/knife_hit.wav" )
precache_sound( "JbVipMenu/Skull/knife_miss.wav" )
precache_sound( "JbVipMenu/trap/trap.wav" )

exploSpr = precache_model("sprites/shockwave.spr");
}

stock ChatColor(const id, const input[], any:...)
{
new count = 1, players[32]
static msg[191]
vformat(msg, 190, input, 3)

replace_all(msg, 190, "!g", "^4")
replace_all(msg, 190, "!y", "^1")
replace_all(msg, 190, "!team", "^3")

if (id) players[0] = id; else get_players(players, count, "ch")
{
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
}

public ResetHUD(id)
{
knifeblock(id)
return PLUGIN_CONTINUE
}

public knifeblock(id)
{
new ts;
for(new i = 0; i <= get_maxplayers(); i++)
if(is_user_alive(i) && get_user_team(i) == 1)
ts++;
if(ts == 1)
{
u_knife[id] = 0
}
return PLUGIN_CONTINUE
}

bool:is_user_vip(id)
{
if(id < 0 || id > 32)
return false

if( !(get_user_flags(id) & g_vipflag) )
return false

return true
}

public Event_CurWeapon(player)
{
if(!u_knife[player])
return PLUGIN_CONTINUE

if(!is_user_vip(player) || !is_user_alive(player))
return PLUGIN_CONTINUE

if(read_data(2) == CSW_KNIFE && u_knife[player] == 1)
{
set_pev(player, pev_viewmodel2, "models/JbVipMenu/v_stik.mdl")
set_pev(player, pev_weaponmodel2, "models/JbVipMenu/p_stik.mdl")
}

if(read_data(2) == CSW_KNIFE && u_knife[player] == 2)
{
set_pev(player, pev_viewmodel2, "models/JbVipMenu/v_axe.mdl")
set_pev(player, pev_weaponmodel2, "models/JbVipMenu/p_axe.mdl")
}

if(read_data(2) == CSW_KNIFE && u_knife[player] == 3)
{
set_pev(player, pev_viewmodel2, "models/JbVipMenu/v_hammer.mdl")
set_pev(player, pev_weaponmodel2, "models/JbVipMenu/p_hammer.mdl")
}

if(read_data(2) == CSW_KNIFE && u_knife[player] == 4)
{
set_pev(player, pev_viewmodel2, "models/JbVipMenu/v_knifevip.mdl")
set_pev(player, pev_weaponmodel2, "models/JbVipMenu/p_knifevip.mdl")
}

if(read_data(2) == CSW_KNIFE && u_knife[player] == 5)
{
set_pev(player, pev_viewmodel2, "models/JbVipMenu/v_kogti.mdl")
set_pev(player, pev_weaponmodel2, "models/JbVipMenu/p_kogti.mdl")
}

return PLUGIN_CONTINUE
}

public open_vipmenu(id)
{

if(!is_user_vip(id))
{
ChatColor(id, "%L",0,"NO_ASSES")
return PLUGIN_HANDLED
} new szText[ 555 char ];

formatex( szText, charsmax( szText ), "%L", id, "MAIN_MENU_TITLE");

new menu = menu_create( szText, "vipmenu_handler" );

formatex( szText, charsmax( szText ), "%L", id, "ITEM_1" );
menu_additem( menu, szText, "1", 0 );

if(get_user_team(id)==1)
{
formatex( szText, charsmax( szText ), "%L", id, "ITEM_2" );
menu_additem( menu, szText, "2", 0 );
}else{
formatex( szText, charsmax( szText ), "%L", id, "ITEM_2_2" );
menu_additem( menu, szText, "2", ADMIN_ADMIN );
}

if(!blockrevive[id])
{
formatex( szText, charsmax( szText ), "%L", id, "ITEM_3" );
menu_additem( menu, szText, "3", 0 );
}else{
formatex( szText, charsmax( szText ), "%L", id, "ITEM_3_3" );
menu_additem( menu, szText, "3", ADMIN_ADMIN );
}

formatex( szText, charsmax( szText ), "%L", id, "ITEM_4" );
menu_additem( menu, szText, "4", 0 );

formatex( szText, charsmax( szText ), "%L", id, "ITEM_5" );
menu_additem( menu, szText, "5", 0 );

formatex( szText, charsmax( szText ), "%L", id, "ITEM_6" );
menu_additem( menu, szText, "6", 0 );

formatex( szText, charsmax( szText ), "%L", id, "ITEM_7" );
menu_additem( menu, szText, "7", 0 );

formatex( szText, charsmax( szText ), "%L", id, "ITEM_8" );
menu_additem( menu, szText, "8", 0 );

formatex( szText, charsmax( szText ), "%L", id, "ITEM_9" );
menu_additem( menu, szText, "9", 0 );

formatex( szText, charsmax( szText ), "%L", id, "ITEM_10" );
menu_additem( menu, szText, "10", 0 );

formatex( szText, charsmax( szText ), "%L", id, "ITEM_11" );
menu_additem( menu, szText, "11", 0 );

menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
menu_setprop( menu, MPROP_NEXTNAME, "Далее")
menu_setprop( menu, MPROP_BACKNAME, "Назад")
menu_setprop( menu, MPROP_EXITNAME, "Выход")

menu_display( id, menu, 0 );

return PLUGIN_CONTINUE;
}

public vipmenu_handler( id, menu, item )
{
if( item == MENU_EXIT )
{
menu_destroy( menu );
return PLUGIN_HANDLED;
}

new data[ 6 ], iName[ 64 ], access, callback;
menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

new key = str_to_num( data );

switch( key )
{
case 1:
{
if(is_user_alive(id))
{
weapon(id)
ChatColor(id, "%L",0,"WEAPONS")
}
else
{
ChatColor(id, "%L",0,"YOUR_DEAD")
}
}

case 2:
{
if(is_user_alive(id))
{
begmenu(id)
}
else
{
ChatColor(id, "%L",0,"YOUR_DEAD")
}
}

case 3:
{
if(!is_user_alive(id))
{
ExecuteHamB(Ham_CS_RoundRespawn, id)
blockrevive[id] = true
ChatColor(id, "%L",0,"ALIVE")
}
else
{
ChatColor(id, "%L",0,"YOUR_ALIVE")
}
}

case 4:
{
if(is_user_alive(id))
{
set_user_health(id, get_pcvar_num(hp))
set_user_armor(id, get_pcvar_num(armor))
ChatColor(id, "%L",0,"HP_AR")
}
else
{
ChatColor(id, "%L",0,"YOUR_DEAD")
}
}

case 5:
{
if(is_user_alive(id))
{
cs_set_user_money(id, get_pcvar_num(money), 1)
ChatColor(id, "%L",0,"MONEY")
}
else
{
ChatColor(id, "%L",0,"YOUR_DEAD")
}
}

case 6:
{
if(is_user_alive(id))
{
message_begin(MSG_ONE, get_user_msgid("SetFOV"), { 0, 0, 0 }, id)
write_byte(180)
message_end()
ChatColor(id, "%L",0,"NARK")
}
else
{
ChatColor(id, "%L",0,"YOUR_DEAD")
}
}

case 7:
{
if(is_user_alive(id))
{
give_item(id, "weapon_hegrenade")
give_item(id, "weapon_flashbang")
give_item(id, "weapon_flashbang")
give_item(id, "weapon_smokegrenade")
ChatColor(id, "%L",0,"GRENADE")
}
else
{
ChatColor(id, "%L",0,"YOUR_DEAD")
}
}

case 8:
{
if(is_user_alive(id))
{
give_item(id, "weapon_shield")
set_user_armor(id, 100)
ChatColor(id, "%L",0,"SPECH")
}
else
{
ChatColor(id, "%L",0,"YOUR_DEAD")
}
}

case 9:
{
if(is_user_alive(id))
{
set_user_maxspeed(id, get_pcvar_float(speed))
ChatColor(id, "%L",0,"SPEED")
}
else
{
ChatColor(id, "%L",0,"YOUR_DEAD")
}
}

case 10:
{
if(is_user_alive(id))
{
set_user_gravity(id, get_pcvar_float(gravity))
ChatColor(id, "%L",0,"GRAVITY")
}
else
{
ChatColor(id, "%L",0,"YOUR_DEAD")
}
}

case 11:
{
if(is_user_alive(id))
{
cs_set_user_bpammo(id,CSW_AK47,5000)
cs_set_user_bpammo(id,CSW_AWP,5000)
cs_set_user_bpammo(id,CSW_DEAGLE,5000)
cs_set_user_bpammo(id,CSW_M249,5000)
cs_set_user_bpammo(id,CSW_FAMAS,5000)
cs_set_user_bpammo(id,CSW_GALIL,5000)
cs_set_user_bpammo(id,CSW_GLOCK18,5000)
cs_set_user_bpammo(id,CSW_XM1014,5000)
cs_set_user_bpammo(id,CSW_MP5NAVY,5000)
cs_set_user_bpammo(id,CSW_M4A1,5000)
ChatColor(id, "%L",0,"AMMO")
}
else
{
ChatColor(id, "%L",0,"YOUR_DEAD")
}
}
}
return PLUGIN_HANDLED;
}



public open_door(this, idattacker, Float:damage, Float:direction[3], tracehandle, damagebits)
{
if(opens[idattacker])
{
dllfunc(DLLFunc_Use, this, idattacker)
opens[idattacker] = 0
}
}

public weapon(id)
{
new szText[ 555 char ];
formatex( szText, charsmax( szText ), "%L", id, "MENU_WEAPON_TITLE", VERSION);

new menu = menu_create( szText, "weapon_handler" );

if(get_user_team(id) == 1 && get_user_flags(id) & ADMIN_CVAR)
{
formatex( szText, charsmax( szText ), "%L", id, "WEAPON_ITEM_1_3" );
menu_additem( menu, szText, "2", ADMIN_ADMIN );
}else
if(get_user_flags(id) & ADMIN_CVAR && get_user_team(id) == 2)
{
if(blockspechmenu[id]<=0)
{
formatex( szText, charsmax( szText ), "%L", id, "WEAPON_ITEM_1" );
menu_additem( menu, szText, "1", 0 );
}else{
formatex( szText, charsmax( szText ), "%L", id, "WEAPON_ITEM_1_1", blockspechmenu[id]);
menu_additem( menu, szText, "1", ADMIN_ADMIN );
}
}else{
formatex( szText, charsmax( szText ), "%L", id, "WEAPON_ITEM_1_2");
menu_additem( menu, szText, "1", ADMIN_ADMIN );
}

if(!blockknife[id])
{
formatex( szText, charsmax( szText ), "%L", id, "WEAPON_ITEM_2" );
menu_additem( menu, szText, "2", 0 );
}else{
formatex( szText, charsmax( szText ), "%L", id, "WEAPON_ITEM_2_1" );
menu_additem( menu, szText, "2", ADMIN_ADMIN );
}

menu_display( id, menu, 0 );

menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
menu_setprop( menu, MPROP_NEXTNAME, "Далее")
menu_setprop( menu, MPROP_BACKNAME, "Назад")
menu_setprop( menu, MPROP_EXITNAME, "Выход")

return PLUGIN_CONTINUE;
}

public weapon_handler(id, menu, item)
{
if( item == MENU_EXIT )
{
menu_destroy( menu );
return PLUGIN_HANDLED;
}

new data[ 6 ], iName[ 64 ], access, callback;
menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

new key = str_to_num( data );

switch( key )
{
case 1:
{
weaponct(id)
}

case 2:
{
knifeweapon(id)
}
}
return PLUGIN_CONTINUE;
}

public weaponct(id)
{
new szText[ 555 char ];

formatex( szText, charsmax( szText ), "%L", id, "MENU_CPES_TITLE");
new menu = menu_create( szText, "weaponct_handler" );

formatex( szText, charsmax( szText ), "%L", id, "CPES_ITEM_1" );
menu_additem( menu, szText, "1", 0 );

formatex( szText, charsmax( szText ), "%L", id, "CPES_ITEM_2" );
menu_additem( menu, szText, "2", 0 );

formatex( szText, charsmax( szText ), "%L", id, "CPES_ITEM_3" );
menu_additem( menu, szText, "3", 0 );

menu_display( id, menu, 0 );

menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
menu_setprop( menu, MPROP_NEXTNAME, "Далее")
menu_setprop( menu, MPROP_BACKNAME, "Назад")
menu_setprop( menu, MPROP_EXITNAME, "Выход")

return PLUGIN_CONTINUE;
}

public weaponct_handler(id, menu, item)
{
if( item == MENU_EXIT )
{
menu_destroy( menu );
return PLUGIN_HANDLED;
}

new data[ 6 ], iName[ 64 ], access, callback;
menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

new key = str_to_num( data );

switch( key )
{
case 1:
{
client_cmd(id,"playerweapon_cpech1")
blockspechmenu[id] = get_pcvar_num(blockspech)
}

case 2:
{
client_cmd(id,"playerweapon_cpech2")
blockspechmenu[id] = get_pcvar_num(blockspech)
}

case 3:
{
client_cmd(id,"playerweapon_cpech3")
blockspechmenu[id] = get_pcvar_num(blockspech)
}
}
return PLUGIN_CONTINUE;
}

public knifeweapon(id)
{
new szText[ 555 char ];

formatex( szText, charsmax( szText ), "%L", id, "MENU_KNIFE_TITLE", VERSION);
new menu = menu_create( szText, "knifeweapon_handler" );

formatex( szText, charsmax( szText ), "%L", id, "KNIFE_ITEM_1" );
menu_additem( menu, szText, "1", 0 );

formatex( szText, charsmax( szText ), "%L", id, "KNIFE_ITEM_2" );
menu_additem( menu, szText, "2", 0 );

formatex( szText, charsmax( szText ), "%L", id, "KNIFE_ITEM_3" );
menu_additem( menu, szText, "3", 0 );

formatex( szText, charsmax( szText ), "%L", id, "KNIFE_ITEM_4" );
menu_additem( menu, szText, "4", 0 );

formatex( szText, charsmax( szText ), "%L", id, "KNIFE_ITEM_5" );
menu_additem( menu, szText, "5", 0 );

menu_display( id, menu, 0 );

menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
menu_setprop( menu, MPROP_NEXTNAME, "Далее")
menu_setprop( menu, MPROP_BACKNAME, "Назад")
menu_setprop( menu, MPROP_EXITNAME, "Выход")

return PLUGIN_CONTINUE;
}

public knifeweapon_handler(id, menu, item)
{
if( item == MENU_EXIT )
{
menu_destroy( menu );
return PLUGIN_HANDLED;
}

new data[ 6 ], iName[ 64 ], access, callback;
menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

new key = str_to_num( data );

switch( key )
{
case 1:
{
engclient_cmd(id, "weapon_knife")
u_knife[id] = 1
blockknife[id] = true
set_pev(id, pev_viewmodel2, "models/JbVipMenu/v_stik.mdl")
set_pev(id, pev_weaponmodel2, "models/JbVipMenu/p_stik.mdl")
}

case 2:
{
engclient_cmd(id, "weapon_knife")
u_knife[id] = 2
blockknife[id] = true
set_pev(id, pev_viewmodel2, "models/JbVipMenu/v_axe.mdl")
set_pev(id, pev_weaponmodel2, "models/JbVipMenu/p_axe.mdl")
}

case 3:
{
engclient_cmd(id, "weapon_knife")
u_knife[id] = 3
blockknife[id] = true
set_pev(id, pev_viewmodel2, "models/JbVipMenu/v_hammer.mdl")
set_pev(id, pev_weaponmodel2, "models/JbVipMenu/p_hammer.mdl")
}

case 4:
{
engclient_cmd(id, "weapon_knife")
u_knife[id] = 4
blockknife[id] = true
set_pev(id, pev_viewmodel2, "models/JbVipMenu/v_knifevip.mdl")
set_pev(id, pev_weaponmodel2, "models/JbVipMenu/p_knifevip.mdl")
}

case 5:
{
engclient_cmd(id, "weapon_knife")
u_knife[id] = 5
blockknife[id] = true
set_pev(id, pev_viewmodel2, "models/JbVipMenu/v_kogti.mdl")
set_pev(id, pev_weaponmodel2, "models/JbVipMenu/p_kogti.mdl")
}
}
return PLUGIN_CONTINUE;
}

public VipStatus(const MsgId, const MsgType, const MsgDest)
{
static id;
id = get_msg_arg_int(1);

if(is_user_vip(id) && !get_msg_arg_int(2))
set_msg_arg_int(2, ARG_BYTE, (1 << 2 ));
}

public ShowVipsOnline(id)
{
new message[256], name[32], count = 0;
new len = format(message, charsmax(message), "VIP РёРіСЂРѕРєРё РІ СЃРµС‚Рё: ");

for (new player = 1; player <= maxPlayers; player++)
{
if (is_user_connected(player) && is_user_vip(player))
{
get_user_name(player, name, charsmax(name));

if (count && len)
{
len += format(message[len], 255 - len, ", ");
}

len += format(message[len], 255 - len, "%s", name);

if (len > 96) {
client_print(id, print_chat, "%s", message);
len = format(message, charsmax(message), "");
}

count++;
}
}

if (len)
{
if (!count)
{
len += format(message[len], 255 - len, "РќРµС‚ РІ СЃРµС‚Рё.");
}

client_print(id, print_chat, "%s", message);
}

return PLUGIN_HANDLED;
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
if (!is_user_connected(id))
return FMRES_IGNORED;

if (u_knife[id] == 3 &&equal(sample[8], "kni", 3))
{
volume = 0.6;

if (equal(sample[14], "sla", 3))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/hammer/knife_slash1_off.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
if(equal(sample,"weapons/knife_deploy1.wav"))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/hammer/knifedeploy.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
if (equal(sample[14], "hit", 3))
{
if (sample[17] == 'w')
{
engfunc(EngFunc_EmitSound, id, channel,"JbVipMenu/hammer/hit1.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
else
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/hammer/hit2.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
}
if (equal(sample[14], "sta", 3))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/hammer/knife_stab123.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
}
if (u_knife[id] == 1 &&equal(sample[8], "kni", 3))
{
volume = 0.6;

if (equal(sample[14], "sla", 3))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/strong/knife_slash1.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
if(equal(sample,"weapons/knife_deploy1.wav"))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/strong/knife_deploy1.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
if (equal(sample[14], "hit", 3))
{
if (sample[17] == 'w')
{
engfunc(EngFunc_EmitSound, id, channel,"JbVipMenu/strong/knife_hit1.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
else
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/strong/knife_hit2.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
}
if (equal(sample[14], "sta", 3))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/strong/knife_stab.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
}

if (u_knife[id] == 2 &&equal(sample[8], "kni", 3))
{
volume = 0.6;

if (equal(sample[14], "sla", 3))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/axe/knife_slash1.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
if(equal(sample,"weapons/knife_deploy1.wav"))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/axe/knife_deploy1.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
if (equal(sample[14], "hit", 3))
{
if (sample[17] == 'w')
{
engfunc(EngFunc_EmitSound, id, channel,"JbVipMenu/axe/knife_hit1.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
else
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/axe/knife_hit2.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
}
if (equal(sample[14], "sta", 3))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/axe/knife_stab.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
}

if (u_knife[id] == 4 &&equal(sample[8], "kni", 3))
{
volume = 0.6;

if (equal(sample[14], "sla", 3))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/axe/knife_slash1.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
if(equal(sample,"weapons/knife_deploy1.wav"))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/axe/knife_deploy1.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
if (equal(sample[14], "hit", 3))
{
if (sample[17] == 'w')
{
engfunc(EngFunc_EmitSound, id, channel,"JbVipMenu/axe/knife_hit1.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
else
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/axe/knife_hit2.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
}
if (equal(sample[14], "sta", 3))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/axe/knife_stab.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
}

if (u_knife[id] == 5 &&equal(sample[8], "kni", 3))
{
volume = 0.6;

if (equal(sample[14], "sla", 3))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/Skull/knife_wall.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
if(equal(sample,"weapons/knife_deploy1.wav"))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/Skull/knife_draw.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
if (equal(sample[14], "hit", 3))
{
if (sample[17] == 'w')
{
engfunc(EngFunc_EmitSound, id, channel,"JbVipMenu/Skull/knife_hit.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
else
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/Skull/knife_hit.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
}
if (equal(sample[14], "sta", 3))
{
engfunc(EngFunc_EmitSound, id, channel, "JbVipMenu/Skull/knife_miss.wav", volume, attn, flags, pitch);
return FMRES_SUPERCEDE;
}
}
return FMRES_IGNORED;
}

public Player_TakeDamage(victim, inflicator, attacker, Float:damage, damage_type, bitsDamage)
{
if (!is_user(attacker) || !is_user(victim))
return;

if(get_user_weapon(attacker) != CSW_KNIFE)
return;

if(pev(attacker, pev_button) & IN_ATTACK && u_knife[attacker] == 3)
{
user_slap(victim,0,0)
user_slap(victim,0,0)
user_slap(victim,0,0)
user_slap(victim,0,0)
}
else if(pev(attacker, pev_button) & IN_ATTACK2 && u_knife[attacker] == 3)
{
user_slap(victim,0,0)
user_slap(victim,0,0)
user_slap(victim,0,0)
user_slap(victim,0,0)
user_slap(victim,0,0)
user_slap(victim,0,0)
}

if(pev(attacker, pev_button) & IN_ATTACK && u_knife[attacker] == 1)
{
if(get_user_team(attacker) == get_user_team(victim))
return;

knifespeed[victim] = victim
set_user_maxspeed(knifespeed[victim], 1.0)
set_task(3.0, "speeds", knifespeed[victim]);
client_cmd(0, "spk JbVipMenu/strong/frostnova.wav")
new origin[3];
get_user_origin(knifespeed[victim], origin);
create_explosion(origin);
}
else if(pev(attacker, pev_button) & IN_ATTACK2 && u_knife[attacker] == 1)
{
if(get_user_team(attacker) == get_user_team(victim))
return;

knifespeed[victim] = victim
set_user_maxspeed(knifespeed[victim], 1.0)
set_task(3.0, "speeds", knifespeed[victim]);
client_cmd(0, "spk JbVipMenu/strong/frostnova.wav")
}

if(pev(attacker, pev_button) & IN_ATTACK && u_knife[attacker] == 4)
{
if(get_user_team(attacker) == get_user_team(victim))
return;

new vorigin[ 3 ];
get_user_origin( victim, vorigin );
Blood( vorigin );
}
else if(pev(attacker, pev_button) & IN_ATTACK2 && u_knife[attacker] == 4)
{
if(get_user_team(attacker) == get_user_team(victim))
return;

new vorigin[ 3 ];
get_user_origin( victim, vorigin );
Blood( vorigin );
}

if(pev(attacker, pev_button) & IN_ATTACK && u_knife[attacker] == 5)
{
if(get_user_team(attacker) == get_user_team(victim))
return;

SetHamParamFloat(4, damage = 80.0)
}
else if(pev(attacker, pev_button) & IN_ATTACK2 && u_knife[attacker] == 5)
{
if(get_user_team(attacker) == get_user_team(victim))
return;
SetHamParamFloat(4, damage = 80.0)
}
}

public speeds(id)
{
if (is_user_connected(id))
{
set_user_maxspeed(id, 220.0)
}

knifespeed[id] = false
}

stock create_explosion(const origin[3])
{
message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
write_byte(21);
write_coord(origin[0]);
write_coord(origin[1]);
write_coord(origin[2]);
write_coord(origin[0]);
write_coord(origin[1]);
write_coord(origin[2] + 385);
write_short(exploSpr);
write_byte(0);
write_byte(0);
write_byte(4);
write_byte(60);
write_byte(0);
write_byte(FROST_R);
write_byte(FROST_G);
write_byte(FROST_B);
write_byte(100);
write_byte(0);
message_end();

message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
write_byte(21);
write_coord(origin[0]);
write_coord(origin[1]);
write_coord(origin[2]);
write_coord(origin[0]);
write_coord(origin[1]);
write_coord(origin[2] + 470);
write_short(exploSpr);
write_byte(0);
write_byte(0);
write_byte(4);
write_byte(60);
write_byte(0);
write_byte(FROST_R);
write_byte(FROST_G);
write_byte(FROST_B);
write_byte(100);
write_byte(0);
message_end();

message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
write_byte(21);
write_coord(origin[0]);
write_coord(origin[1]);
write_coord(origin[2]);
write_coord(origin[0]);
write_coord(origin[1]);
write_coord(origin[2] + 555);
write_short(exploSpr);
write_byte(0);
write_byte(0);
write_byte(4);
write_byte(60);
write_byte(0);
write_byte(FROST_R);
write_byte(FROST_G);
write_byte(FROST_B);
write_byte(100);
write_byte(0);
message_end();

message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
write_byte(27);
write_coord(origin[0]);
write_coord(origin[1]);
write_coord(origin[2]);
write_byte(floatround(FROST_RADIUS/5.0));
write_byte(FROST_R);
write_byte(FROST_G);
write_byte(FROST_B);
write_byte(8);
write_byte(60);
message_end();
}

Blood( iorigin[ 3 ] )
{
message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
write_byte( TE_LAVASPLASH );
write_coord( iorigin[ 0 ] );
write_coord( iorigin[ 1 ] );
write_coord( iorigin[ 2 ] );
message_end();
}

public begmenu(id)
{
new szText[ 555 char ];

formatex( szText, charsmax( szText ), "%L", id, "MENU_BEG_TITLE");
new menu = menu_create( szText, "begmenu_handler" );

if(blockopens[id]<=0)
{
formatex( szText, charsmax( szText ), "%L", id, "BEG_ITEM_1" );
menu_additem( menu, szText, "1", 0 );
}else{
formatex( szText, charsmax( szText ), "%L", id, "BEG_ITEM_1_1", blockopens[id]);
menu_additem( menu, szText, "1", ADMIN_ADMIN );
}

if(blocklight[id]<=0)
{
formatex( szText, charsmax( szText ), "%L", id, "BEG_ITEM_2" );
menu_additem( menu, szText, "2", 0 );
}else{
formatex( szText, charsmax( szText ), "%L", id, "BEG_ITEM_2_1", blocklight[id]);
menu_additem( menu, szText, "2", ADMIN_ADMIN );
}

if(blocklov[id]<=0)
{
formatex( szText, charsmax( szText ), "%L", id, "BEG_ITEM_3");
menu_additem( menu, szText, "3", 0 );
}else{
formatex( szText, charsmax( szText ), "%L", id, "BEG_ITEM_3_1", blocklov[id]);
menu_additem( menu, szText, "3", ADMIN_ADMIN );
}

menu_display( id, menu, 0 );

menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
menu_setprop( menu, MPROP_NEXTNAME, "Далее")
menu_setprop( menu, MPROP_BACKNAME, "Назад")
menu_setprop( menu, MPROP_EXITNAME, "Выход")

return PLUGIN_CONTINUE;
}

public begmenu_handler(id, menu, item)
{
if( item == MENU_EXIT )
{
menu_destroy( menu );
return PLUGIN_HANDLED;
}

new data[ 6 ], iName[ 64 ], access, callback;
menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

new key = str_to_num( data );

switch( key )
{
case 1:
{
opens[id] = 1
blockopens[id] = get_pcvar_num(block)
ChatColor(id, "%L",0,"BEG")
}

case 2:
{
light(id)
blocklight[id] = get_pcvar_num(blocklights)
ChatColor(id, "%L",0,"BEG_2")
}

case 3:
{
trap(id)
blocklov[id] = get_pcvar_num(blocklovy)
ChatColor(id, "%L",0,"BEG_3")
}
}
return PLUGIN_CONTINUE;
}

public light(id)
{
new iPlayer[32], iNum
get_players(iPlayer, iNum)

for(new i; i < iNum; i++)
{
if(get_user_team(iPlayer[i]) == 2)
{
new names[33]
message_begin(MSG_ONE, g_ScreenFade, _, iPlayer[i]);
write_short(1 << 0);
write_short(1 << 0);
write_short(1 << 2);
write_byte(0);
write_byte(0);
write_byte(0);
write_byte(255);
message_end();
get_user_name(id, names, 32)
set_hudmessage(255, 255, 255, -1.0, 0.4, 0, 6.0, 5.0)
show_hudmessage(iPlayer[i], "%L",0, "LIGHT_NAME", names)
set_task(10.0, "light_off", iPlayer[i]);
g_lighton = true
}
}
}

public light_off(id)
{
new iPlayer[32], iNum
get_players(iPlayer, iNum)

for(new i; i < iNum; i++)
{
if(get_user_team(iPlayer[i]) == 2)
{
message_begin(MSG_ONE, g_ScreenFade, _, iPlayer[i]);
write_short(1 << 12);
write_short(1 << 9);
write_short(1 << 0);
write_byte(0);
write_byte(0);
write_byte(0);
write_byte(0);
message_end();
g_lighton = false
}
}
}

public trap(id)
{
new Float:origin[3]

entity_get_vector(id,EV_VEC_origin,origin)

new ent = create_entity("info_target")

entity_set_origin(ent,origin);
origin[2] += 100.0
entity_set_origin(id,origin)

entity_set_float(ent,EV_FL_takedamage,0.0)

entity_set_string(ent,EV_SZ_classname,"npc_totem");
entity_set_model(ent,"models/JbVipMenu/trap/trap.mdl");
entity_set_int(ent,EV_INT_solid, 2)

entity_set_byte(ent,EV_BYTE_controller1,125);
entity_set_byte(ent,EV_BYTE_controller2,125);
entity_set_byte(ent,EV_BYTE_controller3,125);
entity_set_byte(ent,EV_BYTE_controller4,125);

new Float:maxs[3] = {16.0,16.0,36.0}
new Float:mins[3] = {-16.0,-16.0,-36.0}
entity_set_size(ent,mins,maxs)

entity_set_float(ent,EV_FL_animtime,2.0)
entity_set_float(ent,EV_FL_framerate,1.0)
entity_set_int(ent,EV_INT_sequence,0);

entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.01)

drop_to_floor(ent)
return 1;
}

public client_PreThink(id)
{
if(!is_user_alive(id))
return PLUGIN_CONTINUE;

new Float:gametime = get_gametime();
if(g_TotemPoleDelay[id] > gametime)
return PLUGIN_CONTINUE;

new ent = -1
new Float:vOrigin[3], Float:pOrigin[3], Float:distance;
entity_get_vector(id, EV_VEC_origin, pOrigin);
while((ent = find_ent_by_class(ent, "npc_totem")))
{
entity_get_vector(ent, EV_VEC_origin, vOrigin);
distance = get_distance_f(pOrigin, vOrigin);
if(distance < MAX_DISTANCE && get_user_team(id) == 2)
{
set_user_maxspeed(id, 1.0 );
strip_user_weapons(id)

if(!traps[id])
{
traps[id] = id
client_cmd(id, "spk JbVipMenu/trap/trap.wav")
ChatColor(id, "%L",0,"CT_TRAP")
set_task(10.0, "trap_off", traps[id]);
}
}
}

return PLUGIN_CONTINUE;
}

public trap_off(id)
{
remove_entity_name( "npc_totem" );
set_user_maxspeed(id, 240.0 );
give_item(traps[id], "weapon_knife")
give_item(traps[id],"weapon_deagle")
give_item(traps[id],"weapon_m4a1")
cs_set_user_bpammo(traps[id],CSW_M4A1, 90)
cs_set_user_bpammo(traps[id],CSW_DEAGLE, 35)
ChatColor(traps[id], "%L",0,"CT_TRAP_OFF")
traps[id] = false
}

public switchweapon(id)
{
if(get_user_team(id)==2 && g_lighton)
{
engclient_cmd(id,"weapon_knife")
}
return PLUGIN_CONTINUE
}

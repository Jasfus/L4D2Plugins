#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "4.0"
#define DEBUG 0

#define ON          1
#define OFF         0

#define FORMONE     1
#define FORMTWO     2
#define FORMTHREE   3
#define FORMFOUR    4
#define FORMFIVE    5
#define FORMSIX     6
#define FORMSEVEN   7
#define FORMEIGHT   8
#define DEAD        -1

#define SURVIVOR    2
#define CLASS_TANK  8
#define MOLOTOV     0
#define EXPLODE     1
#define ENTITY_GASCAN   "models/props_junk/gascan001a.mdl"
#define ENTITY_PROPANE  "models/props_junk/propanecanister001a.mdl"
#define ENTITY_TIRE     "models/props_vehicles/tire001c_car.mdl"

#define SOUND_EXPLODE   "animation/APC_Idle_Loop.wav"
#define SOUND_SPAWN     "music/zombat/GatesOfHell.wav"
#define SOUND_BCLAW     "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_1.wav"
#define SOUND_GCLAW     "plats/churchbell_end.wav"
#define SOUND_DCLAW     "ambient/Random_Amb_SFX/Dist_Pistol_02.wav"
#define SOUND_QUAKE     "player/tank/hit/pound_victim_2.wav"
#define SOUND_STEEL     "physics/metal/metal_solid_impact_hard5.wav"
#define SOUND_DEAD      "npc/infected/action/die/male/death_42.wav"
#define SOUND_FREEZE    "physics/glass/glass_impact_bullet4.wav"
#define SOUND_DEFROST   "physics/glass/glass_sheet_break1.wav"
#define SOUND_LAZY      "npc/infected/action/rage/female/rage_68.wav"
#define SOUND_QUICK     "ambient/water/distant_drip2.wav"
#define SOUND_ROAR      "player/tank/voice/pain/Tank_Pain_03.wav"
#define SOUND_RABIES    "player/pz/voice/attack/zombiedog_attack2.wav"
#define SOUND_BOMBARD   "animation/van_inside_hit_wall.wav"
#define SOUND_CHANGE    "items/suitchargeok1.wav"
#define SOUND_HOWL      "player/tank/voice/pain/tank_fire_06.wav"
#define SOUND_WARP      "ambient/energy/zap9.wav"

#define PARTICLE_SPAWN  "electrical_arc_01_system"
#define PARTICLE_DEATH  "gas_explosion_main"
#define PARTICLE_FOURTH "apc_wheel_smoke1"
#define PARTICLE_EIGHTH "aircraft_destroy_fastFireTrail"
#define PARTICLE_WARP   "water_splash"

#define MESSAGE_SPAWN   "\x03[ФИНАЛЬНЫЙ БОСС] \x04\x01ОПАСНОСТЬ!!! ОСОБАЯ МУТАЦИЯ ТАНКА \x05 ПРИГОТОВЬТЕСЬ!!!\x01【\x03 ФИНАЛЬНЫЙ БОСС ИЗ 8 ФАЗ \x01】"
#define MESSAGE_SPAWN2  "\x03[ФИНАЛЬНЫЙ БОСС] \x04ПЕРВАЯ \x01ФАЗА \x05ОСОБЫЙ ЗАРАЖЕННЫЙ \x01| \x04СКОРОСТЬ: \x05 ИЗМЕНЯЕТСЯ"
#define MESSAGE_SECOND "\x03[ФИНАЛЬНЫЙ БОСС] \x04ВТОРАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03СТАЛЬНОЙ ГИГАНТ\x01】"
#define MESSAGE_THIRD  "\x03[ФИНАЛЬНЫЙ БОСС] \x04ТРЕТЬЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03СУПЕР СИЛА\x01】"
#define MESSAGE_FOURTH "\x03[ФИНАЛЬНЫЙ БОСС] \x04ЧЕТВЕРТАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03ТЕМНОЕ ЗРЕНИЕ\x01】"
#define MESSAGE_FIFTH  "\x03[ФИНАЛЬНЫЙ БОСС] \x04ПЯТАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03НЕПОДВИЖНОСТЬ\x01】"
#define MESSAGE_SIXTH  "\x03[ФИНАЛЬНЫЙ БОСС] \x04ШЕСТАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03ВЗРЫВНОЙ УДАР\x01】"
#define MESSAGE_SEVENTH "\x03[ФИНАЛЬНЫЙ БОСС] \x04СЕДЬМАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03ЗАМОРАЖИВАЮЩИЙ УДАР\x01】"
#define MESSAGE_EIGHTH "\x03[ФИНАЛЬНЫЙ БОСС] \x04ФИНАЛЬНАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03ОГНЕННЫЙ ЩИТ\x01】"

ConVar sm_lastboss_enable;
ConVar sm_lastboss_enable_announce;
ConVar sm_lastboss_enable_steel;
ConVar sm_lastboss_enable_bomb;
ConVar sm_lastboss_enable_stealth;
ConVar sm_lastboss_enable_gravity;
ConVar sm_lastboss_enable_burn;
ConVar sm_lastboss_enable_jump;
ConVar sm_lastboss_enable_quake;
ConVar sm_lastboss_enable_comet;
ConVar sm_lastboss_enable_dread;
ConVar sm_lastboss_enable_lazy;
ConVar sm_lastboss_enable_rabies;
ConVar sm_lastboss_enable_freeze;
ConVar sm_lastboss_enable_gush;
ConVar sm_lastboss_enable_abyss;
ConVar sm_lastboss_enable_warp;

ConVar sm_lastboss_health;
ConVar sm_lastboss_health_percent;

ConVar sm_lastboss_color_first;
ConVar sm_lastboss_color_second;
ConVar sm_lastboss_color_third;
ConVar sm_lastboss_color_fourth;
ConVar sm_lastboss_color_fifth;
ConVar sm_lastboss_color_sixth;
ConVar sm_lastboss_color_seventh;
ConVar sm_lastboss_color_eighth;

ConVar sm_lastboss_force_first;
ConVar sm_lastboss_force_second;
ConVar sm_lastboss_force_third;
ConVar sm_lastboss_force_fourth;
ConVar sm_lastboss_force_fifth;
ConVar sm_lastboss_force_sixth;
ConVar sm_lastboss_force_seventh;
ConVar sm_lastboss_force_eighth;

ConVar sm_lastboss_speed_first;
ConVar sm_lastboss_speed_second;
ConVar sm_lastboss_speed_third;
ConVar sm_lastboss_speed_fourth;
ConVar sm_lastboss_speed_fifth;
ConVar sm_lastboss_speed_sixth;
ConVar sm_lastboss_speed_seventh;
ConVar sm_lastboss_speed_eighth;

ConVar sm_lastboss_weight_second;
ConVar sm_lastboss_stealth_fourth;
ConVar sm_lastboss_jumpinterval_eighth;
ConVar sm_lastboss_jumpheight_eighth;
ConVar sm_lastboss_gravityinterval;
ConVar sm_lastboss_quake_radius;
ConVar sm_lastboss_quake_force;
ConVar sm_lastboss_dreadinterval;
ConVar sm_lastboss_dreadrate;
ConVar sm_lastboss_freezetime;
ConVar sm_lastboss_freezeinterval;
ConVar sm_lastboss_lazytime;
ConVar sm_lastboss_lazyspeed;
ConVar sm_lastboss_rabiestime;
ConVar sm_lastboss_bombradius;
ConVar sm_lastboss_bombdamage;
ConVar sm_lastboss_bombardforce;
ConVar sm_lastboss_eighth_c5m5_bridge;
ConVar sm_lastboss_warp_interval;

Handle g_hTankHealthTimers[MAXPLAYERS+1];
Handle g_hTankUpdateTimers[MAXPLAYERS+1];

UserMsg g_FadeUserMsgId;

float ToxinAngle[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0};

ArrayList g_hBossTanks;
int g_iBossCount = 0;
bool g_l4d1 = false, isSlowed[MAXPLAYERS+1] = {false, ...};
static int laggedMovementOffset = 0;
int g_iVelocity = -1;
int force_default, visibility, freeze[MAXPLAYERS+1] = {0, ...}, Rabies[MAXPLAYERS+1] = {0, ...}, Toxin[MAXPLAYERS+1] = {0, ...};
//float PosOther[MAXPLAYERS + 1][3];

public Plugin myinfo = 
{
	name = "[L4D2] Финальный босс v4.0",
	author = "ztar & IxAvnoMonvAxI",
	description = "Особый танк появляется во время финала с поддержкой нескольких танков",
	version = PLUGIN_VERSION,
	url = "http://ztar.blog7.fc2.com/"
}

public void OnPluginStart()
{
	char game[32];
	GetGameFolderName(game, sizeof(game));
	g_l4d1 = StrEqual(game, "left4dead");
	
	g_hBossTanks = new ArrayList();
	
	sm_lastboss_enable = CreateConVar("sm_lastboss_enable", "2", "Появление особого танка (0: Нет | 1: После вызова | 2: Всегда | 3: Только 2-я фаза)", FCVAR_NOTIFY);
	sm_lastboss_enable_announce = CreateConVar("sm_lastboss_enable_announce", "1", "Показывать информационные сообщения? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_steel = CreateConVar("sm_lastboss_enable_steel", "1", "Использовать стальную кожу? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_bomb = CreateConVar("sm_lastboss_enable_bomb", "1", "Использовать взрывные удары? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_stealth = CreateConVar("sm_lastboss_enable_stealth", "1", "Танк постепенно становится невидимым и неуязвимым к огню? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_gravity = CreateConVar("sm_lastboss_enable_gravity", "1", "Уменьшать гравитацию выживших при ударе? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_burn = CreateConVar("sm_lastboss_enable_burn", "1", "Восстанавливать здоровье танка при атаке выживших? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_quake = CreateConVar("sm_lastboss_enable_quake", "1", "Может ли отбрасывать оглушенных выживших? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_jump = CreateConVar("sm_lastboss_enable_jump", "1", "Часто ли танк прыгает? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_comet = CreateConVar("sm_lastboss_enable_comet", "1", "Взрываются ли камни, брошенные танком? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_dread = CreateConVar("sm_lastboss_enable_dread", "1", "Затемнять зрение выживших при атаке? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_lazy = CreateConVar("sm_lastboss_enable_lazy", "1", "Замедлять атакованных выживших? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_rabies = CreateConVar("sm_lastboss_enable_rabies", "1", "Уменьшать здоровье атакованных выживших? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_freeze = CreateConVar("sm_lastboss_enable_freeze", "1", "Замораживать атакованных выживших? (0: Нет | 1: Да)", FCVAR_NOTIFY);    
	sm_lastboss_enable_gush = CreateConVar("sm_lastboss_enable_gush", "1", "Использовать огненные атаки (Lethal Weapon)? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_abyss = CreateConVar("sm_lastboss_enable_abyss", "1", "Вызывать орду при крике? (0: Нет | 1: Только 8-я фаза | 2: Все фазы)", FCVAR_NOTIFY);
	sm_lastboss_enable_warp = CreateConVar("sm_lastboss_enable_warp", "1", "Использовать телепортацию? (0: Нет | 1: Да)", FCVAR_NOTIFY);

	sm_lastboss_health = CreateConVar("sm_lastboss_health", "8000", "Общее здоровье танка", FCVAR_NOTIFY);
	sm_lastboss_health_percent = CreateConVar("sm_lastboss_health_percent", "12.5", "Процент здоровья для смены фазы", FCVAR_NOTIFY, true, 1.0, true, 100.0);

	sm_lastboss_color_first = CreateConVar("sm_lastboss_color_first", "255 255 80", "Цвет танка в 1-й фазе (желтый)", FCVAR_NOTIFY);
	sm_lastboss_color_second = CreateConVar("sm_lastboss_color_second", "80 255 80", "Цвет танка во 2-й фазе (светло-зеленый)", FCVAR_NOTIFY);
	sm_lastboss_color_third = CreateConVar("sm_lastboss_color_third", "153 153 255", "Цвет танка в 3-й фазе (голубой)", FCVAR_NOTIFY);
	sm_lastboss_color_fourth = CreateConVar("sm_lastboss_color_fourth", "80 80 255", "Цвет танка в 4-й фазе (фиолетовый → постепенно исчезает)", FCVAR_NOTIFY);
	sm_lastboss_color_fifth = CreateConVar("sm_lastboss_color_fifth", "200 150 200", "Цвет танка в 5-й фазе (темно-розовый)", FCVAR_NOTIFY);
	sm_lastboss_color_sixth = CreateConVar("sm_lastboss_color_sixth", "176 48 96", "Цвет танка в 6-й фазе (красно-коричневый)", FCVAR_NOTIFY);    
	sm_lastboss_color_seventh = CreateConVar("sm_lastboss_color_seventh", "0 128 255", "Цвет танка в 7-й фазе (синий)", FCVAR_NOTIFY);
	sm_lastboss_color_eighth = CreateConVar("sm_lastboss_color_eighth", "255 80 80", "Цвет танка в 8-й фазе (красный)", FCVAR_NOTIFY);

	sm_lastboss_force_first = CreateConVar("sm_lastboss_force_first", "1000", "Сила удара в 1-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_second = CreateConVar("sm_lastboss_force_second", "1500", "Сила удара во 2-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_third = CreateConVar("sm_lastboss_force_third", "1100", "Сила удара в 3-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_fourth = CreateConVar("sm_lastboss_force_fourth", "800", "Сила удара в 4-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_fifth = CreateConVar("sm_lastboss_force_fifth", "2000", "Сила удара в 5-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_sixth = CreateConVar("sm_lastboss_force_sixth", "1600", "Сила удара в 6-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_seventh = CreateConVar("sm_lastboss_force_seventh", "1300", "Сила удара в 7-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_eighth = CreateConVar("sm_lastboss_force_eighth", "1800", "Сила удара в 8-й фазе", FCVAR_NOTIFY);
	
	sm_lastboss_speed_first = CreateConVar("sm_lastboss_speed_first", "0.9", "Доп. скорость движения в 1-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_second = CreateConVar("sm_lastboss_speed_second", "0.9", "Доп. скорость движения во 2-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_third = CreateConVar("sm_lastboss_speed_third", "0.9", "Доп. скорость движения в 3-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_fourth = CreateConVar("sm_lastboss_speed_fourth", "0.9", "Доп. скорость движения в 4-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_fifth = CreateConVar("sm_lastboss_speed_fifth", "0.9", "Доп. скорость движения в 5-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_sixth = CreateConVar("sm_lastboss_speed_sixth", "0.9", "Доп. скорость движения в 6-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_seventh = CreateConVar("sm_lastboss_speed_seventh", "0.9", "Доп. скорость движения в 7-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_eighth = CreateConVar("sm_lastboss_speed_eighth", "1.1", "Доп. скорость движения в 8-й фазе", FCVAR_NOTIFY);
	
	sm_lastboss_weight_second = CreateConVar("sm_lastboss_weight_second", "8.0", "Длительность уменьшенной гравитации у выживших (сек)", FCVAR_NOTIFY);
	sm_lastboss_stealth_fourth = CreateConVar("sm_lastboss_stealth_fourth", "10.0", "Интервал невидимости танка (сек)", FCVAR_NOTIFY);
	sm_lastboss_jumpinterval_eighth = CreateConVar("sm_lastboss_jumpinterval_eighth", "1.0", "Интервал прыжков танка (сек)", FCVAR_NOTIFY);
	sm_lastboss_jumpheight_eighth = CreateConVar("sm_lastboss_jumpheight_eighth", "300.0", "Высота прыжка танка", FCVAR_NOTIFY);
	sm_lastboss_gravityinterval = CreateConVar("sm_lastboss_gravityinterval", "6.0", "Интервал атак с изменением гравитации (сек)", FCVAR_NOTIFY);
	sm_lastboss_quake_radius = CreateConVar("sm_lastboss_quake_radius", "600.0", "Радиус отбрасывания оглушенных выживших", FCVAR_NOTIFY);
	sm_lastboss_quake_force = CreateConVar("sm_lastboss_quake_force", "350.0", "Сила отбрасывания оглушенных выживших", FCVAR_NOTIFY);
	sm_lastboss_dreadinterval = CreateConVar("sm_lastboss_dreadinterval", "8.0", "Интервал затемнения зрения (сек)", FCVAR_NOTIFY);
	sm_lastboss_dreadrate = CreateConVar("sm_lastboss_dreadrate", "235", "Скорость затемнения зрения", FCVAR_NOTIFY);
	sm_lastboss_freezetime = CreateConVar("sm_lastboss_freezetime", "10", "Длительность заморозки выживших (сек)", FCVAR_NOTIFY);
	sm_lastboss_freezeinterval = CreateConVar("sm_lastboss_freezeinterval", "6.0", "Интервал замораживающих атак (сек)", FCVAR_NOTIFY);
	sm_lastboss_lazytime = CreateConVar("sm_lastboss_lazytime", "10.0", "Длительность замедления выживших (сек)", FCVAR_NOTIFY);
	sm_lastboss_lazyspeed = CreateConVar("sm_lastboss_lazyspeed", "0.3", "Множитель скорости замедленных выживших", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateConVar("sm_lastboss_rabiesdamage", "10", "Урон от бешенства за тик", FCVAR_NOTIFY);
	CreateConVar("sm_lastboss_lavadamage", "50", "Урон от лавы за тик", FCVAR_NOTIFY);
	sm_lastboss_rabiestime = CreateConVar("sm_lastboss_rabiestime", "10", "Длительность эффекта бешенства (сек)", FCVAR_NOTIFY);
	sm_lastboss_bombradius = CreateConVar("sm_lastboss_bombradius", "250", "Радиус взрывной атаки", FCVAR_NOTIFY);
	sm_lastboss_bombdamage = CreateConVar("sm_lastboss_bombdamage", "300", "Урон взрывной атаки", FCVAR_NOTIFY);
	sm_lastboss_bombardforce = CreateConVar("sm_lastboss_bombardforce", "600.0", "Сила отбрасывания взрывной атаки", FCVAR_NOTIFY);
	sm_lastboss_eighth_c5m5_bridge = CreateConVar("sm_lastboss_eigth_c5m5_bridge", "0", "Появляется ли танк 8-й фазы на финальном мосту? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_warp_interval = CreateConVar("sm_lastboss_warp_interval", "35.0", "Интервал телепортации (сек)", FCVAR_NOTIFY);
	
	HookEvent("round_start", Event_Round_Start);
	HookEvent("finale_start", Event_Finale_Start);
	HookEvent("tank_spawn", Event_Tank_Spawn);
	HookEvent("player_death", Event_Player_Death);
	HookEvent("player_hurt", Event_Player_Hurt);
	HookEvent("player_incapacitated", Event_Player_Hurt);
	HookEvent("round_end", Event_RoundEnd);

	if(!g_l4d1)
		HookEvent("finale_bridge_lowering", Event_Finale_Start);

	g_FadeUserMsgId = GetUserMessageId("Fade");

	laggedMovementOffset = FindSendPropInfo("CTerrorPlayer", "m_flLaggedMovementValue");
	
	AutoExecConfig(true, "l4d2_lastboss");
	
	force_default = FindConVar("z_tank_throw_force").IntValue;
	if((g_iVelocity = FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]")) == -1)
		LogError("Could not find offset for CBasePlayer::m_vecVelocity[0]");
}

void InitPrecache()
{
	PrecacheModel(ENTITY_PROPANE, true);
	PrecacheModel(ENTITY_GASCAN, true);
	PrecacheModel(ENTITY_TIRE, true);
	
	PrecacheSound(SOUND_EXPLODE, true);
	PrecacheSound(SOUND_SPAWN, true);
	PrecacheSound(SOUND_BCLAW, true);
	PrecacheSound(SOUND_GCLAW, true);
	PrecacheSound(SOUND_DCLAW, true);
	PrecacheSound(SOUND_QUAKE, true);
	PrecacheSound(SOUND_STEEL, true);
	PrecacheSound(SOUND_DEAD, true);
	PrecacheSound(SOUND_FREEZE, true);
	PrecacheSound(SOUND_DEFROST, true);
	PrecacheSound(SOUND_LAZY, true);
	PrecacheSound(SOUND_QUICK, true);
	PrecacheSound(SOUND_RABIES, true);
	PrecacheSound(SOUND_BOMBARD, true);
	PrecacheSound(SOUND_CHANGE, true);
	PrecacheSound(SOUND_HOWL, true);
	PrecacheSound(SOUND_WARP, true);
	
	PrecacheParticle(PARTICLE_SPAWN);
	PrecacheParticle(PARTICLE_DEATH);
	PrecacheParticle(PARTICLE_FOURTH);
	PrecacheParticle(PARTICLE_EIGHTH);
	PrecacheParticle(PARTICLE_WARP);
}

public void OnMapStart()
{
	InitPrecache();
	InitData();
	
	PrecacheModel("models/props_junk/propanecanister001a.mdl", true);
	PrecacheModel("models/props_junk/gascan001a.mdl", true);
	PrecacheParticle("gas_explosion_pump");
	PrecacheParticle("gas_explosion_main");
}

void InitData()
{
	g_hBossTanks.Clear();
	g_iBossCount = 0;
	FindConVar("z_tank_throw_force").SetInt(force_default, true, true);
}

public void OnMapEnd()
{
	InitData();
}

Action Event_Round_Start(Event event, const char[] name, bool dontBroadcast)
{
	InitData();
	return Plugin_Continue;
}

Action Event_Finale_Start(Event event, const char[] name, bool dontBroadcast)
{
	return Plugin_Continue;
}

Action Event_Tank_Spawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if(!IsValidClient(client) || GetEntProp(client, Prop_Send, "m_zombieClass") != CLASS_TANK)
        return Plugin_Continue;
    
    if(sm_lastboss_enable.IntValue == 0)
        return Plugin_Continue;
    
    if(g_hBossTanks.FindValue(GetClientUserId(client)) != -1)
        return Plugin_Continue;
    
    if(sm_lastboss_enable.IntValue == 1 && !event.GetBool("finale"))
        return Plugin_Continue;
    
    if(sm_lastboss_enable.IntValue == 3 && g_iBossCount > 0)
        return Plugin_Continue;
    
    // Закрываем старые таймеры для этого клиента
    SafeCloseTimer(g_hTankUpdateTimers[client]);
    SafeCloseTimer(g_hTankHealthTimers[client]);
    
    g_hBossTanks.Push(GetClientUserId(client));
    g_iBossCount++;
    
    // Создаем новые таймеры
    g_hTankHealthTimers[client] = CreateTimer(0.3, Timer_SetTankHealth, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    g_hTankUpdateTimers[client] = CreateTimer(1.0, Timer_TankUpdate, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    
    for(int j = 1; j <= MaxClients; j++)
    {
        if(IsClientInGame(j) && !IsFakeClient(j))
        {
            EmitSoundToClient(j, SOUND_SPAWN);
        }
    }
    
    if(sm_lastboss_enable_announce.IntValue)
    {
        PrintToChatAll(MESSAGE_SPAWN);
        PrintToChatAll(MESSAGE_SPAWN2);
    }
    
    return Plugin_Continue;
}

void SafeCloseTimer(Handle &timer)
{
    if(timer != null && timer != INVALID_HANDLE)
    {
        KillTimer(timer);
        timer = null;
    }
}

Action Event_Player_Death(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!IsValidClient(client) || GetEntProp(client, Prop_Send, "m_zombieClass") != CLASS_TANK)
		return Plugin_Continue;
	
	int index = g_hBossTanks.FindValue(GetClientUserId(client));
	if(index != -1)
	{
		// Закрываем таймеры
		SafeCloseTimer(g_hTankUpdateTimers[client]);
		g_hBossTanks.Erase(index);
		g_iBossCount--;
		
		float pos[3];
		GetClientAbsOrigin(client, pos);
		EmitSoundToAll(SOUND_EXPLODE, client);
		ShowParticle(pos, PARTICLE_DEATH, 5.0);
		LittleFlower(pos, MOLOTOV);
		LittleFlower(pos, EXPLODE);
	}
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		char model[128];
		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
		if (StrEqual(model, ENTITY_TIRE))
		{
			int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			
			if (owner != client) 
			{
				SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			}
			
			AcceptEntityInput(entity, "Kill");
		}
	}
	for (int target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target) && GetClientTeam(target) == 2)
		{
			isSlowed[target] = false;
			SetEntityGravity(target, 1.0);
			Rabies[target] = 0;
			Toxin[target] = 0;
		}
	}
	
	return Plugin_Continue;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    for(int i = 1; i <= MaxClients; i++)
    {
        SafeCloseTimer(g_hTankUpdateTimers[i]);
        SafeCloseTimer(g_hTankHealthTimers[i]);
        
        if(IsValidSurv(i))
        {
            isSlowed[i] = false;
            SetEntityGravity(i, 1.0);
            Rabies[i] = 0;
            Toxin[i] = 0;
        }
    }
    
    g_hBossTanks.Clear();
    g_iBossCount = 0;
    FindConVar("z_tank_throw_force").SetInt(force_default, true, true);
}

Action Timer_SetTankHealth(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	g_hTankHealthTimers[client] = null; // Обнуляем ссылку на таймер
	if(!IsValidClient(client) || GetEntProp(client, Prop_Send, "m_zombieClass") != CLASS_TANK)
		return Plugin_Stop;
	
	char CurrentMap[64];
	GetCurrentMap(CurrentMap, sizeof(CurrentMap));
	
	if(StrEqual(CurrentMap, "c5m5_bridge") && sm_lastboss_eighth_c5m5_bridge.IntValue)
		SetEntityHealth(client, RoundToFloor(sm_lastboss_health.FloatValue * sm_lastboss_health_percent.FloatValue / 100.0));
	else
		SetEntityHealth(client, sm_lastboss_health.IntValue);
	
	SetEntProp(client, Prop_Send, "m_iGlowType", 3);
	SetEntProp(client, Prop_Send, "m_glowColorOverride", 255 + (255 * 256) + (80 * 65536));
	
	return Plugin_Stop;
}

Action Event_Player_Hurt(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int target = GetClientOfUserId(event.GetInt("userid"));
	
	if(!IsValidClient(attacker) || !IsValidClient(target))
		return Plugin_Continue;
	
	if(g_hBossTanks.FindValue(GetClientUserId(attacker)) == -1)
		return Plugin_Continue;
	
	char weapon[64];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	
	int form = GetTankForm(attacker);
	
	if(StrEqual(weapon, "tank_claw"))
	{
		if(sm_lastboss_enable_quake.IntValue)
			SkillEarthQuake(attacker, target);
		
		if(form == FORMTWO && sm_lastboss_enable_gravity.IntValue)
			SkillGravityClaw(target);
		
		if(form == FORMTHREE && sm_lastboss_enable_bomb.IntValue)
			SkillBombClaw(attacker, target);
		
		if(form == FORMFOUR && sm_lastboss_enable_dread.IntValue)
			SkillDreadClaw(target);
		
		if(form == FORMFIVE && sm_lastboss_enable_lazy.IntValue)
			SkillLazyClaw(target);
		
		if(form == FORMSIX && sm_lastboss_enable_rabies.IntValue)
			SkillRabiesClaw(target);
		
		if(form == FORMSEVEN && sm_lastboss_enable_freeze.IntValue)
			SkillFreezeClaw(target);
			
		if(form == FORMEIGHT && sm_lastboss_enable_burn.IntValue)
			SkillBurnClaw(target);
	}
	else if(StrEqual(weapon, "tank_rock"))
	{
		if(sm_lastboss_enable_comet.IntValue)
		{
			if(form == FORMEIGHT)
				SkillCometStrike(target, MOLOTOV);
			else
				SkillCometStrike(target, EXPLODE);
		}
	}
	else if(StrEqual(weapon, "melee") && g_hBossTanks.FindValue(GetClientUserId(target)) != -1)
	{
		if(form == FORMTWO && sm_lastboss_enable_steel.IntValue)
		{
			EmitSoundToClient(attacker, SOUND_STEEL);
			SetEntityHealth(target, (GetEventInt(event,"dmg_health")+GetEventInt(event,"health")));
		}
		
		if(form == FORMFOUR)
		{
			int random = GetRandomInt(1, 4);
			if(random == 1)
			{
				ForceWeaponDrop(attacker);
				EmitSoundToClient(attacker, SOUND_DEAD);
			}
		}
		
		if(form == FORMEIGHT && sm_lastboss_enable_gush.IntValue)
			SkillFlameGush(attacker);
	}
	
	return Plugin_Continue;
}

int GetTankForm(int client)
{
	if(!IsValidClient(client) || g_hBossTanks.FindValue(GetClientUserId(client)) == -1)
		return DEAD;
	
	int maxHealth = sm_lastboss_health.IntValue;
	int currentHealth = GetClientHealth(client);
	float healthPercent = (float(currentHealth) / float(maxHealth)) * 100.0;
	float phasePercent = sm_lastboss_health_percent.FloatValue;

	// Определяем текущую фазу на основе процента здоровья
	if(healthPercent > (100.0 - phasePercent * 1)) return FORMONE;
	if(healthPercent > (100.0 - phasePercent * 2)) return FORMTWO;
	if(healthPercent > (100.0 - phasePercent * 3)) return FORMTHREE;
	if(healthPercent > (100.0 - phasePercent * 4)) return FORMFOUR;
	if(healthPercent > (100.0 - phasePercent * 5)) return FORMFIVE;
	if(healthPercent > (100.0 - phasePercent * 6)) return FORMSIX;
	if(healthPercent > (100.0 - phasePercent * 7)) return FORMSEVEN;
	return FORMEIGHT;
}

Action Timer_TankUpdate(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    
    // Проверка что таймер еще актуален
    if(timer != g_hTankUpdateTimers[client])
        return Plugin_Stop;
    
    if(!IsValidClient(client) || GetEntProp(client, Prop_Send, "m_zombieClass") != CLASS_TANK)
    {
        g_hTankUpdateTimers[client] = null;
        return Plugin_Stop;
    }
    
    if(g_hBossTanks.FindValue(userid) == -1)
    {
        g_hTankUpdateTimers[client] = null;
        return Plugin_Stop;
    }
    
    if(GetClientHealth(client) <= 0)
    {
        g_hTankUpdateTimers[client] = null;
        return Plugin_Stop;
    }
    
    int current_form = GetTankForm(client);
    int previous_form = GetEntProp(client, Prop_Send, "m_iGlowType") - 1;
    
    if(current_form != previous_form)
    {
        SetParameter(client, current_form);
        SetEntProp(client, Prop_Send, "m_iGlowType", current_form + 1);
    }
    
    return Plugin_Continue;
}

void SetParameter(int client, int form_next)
{
	int force;
	float speed;
	char color[32];
	
	if(form_next != FORMONE)
	{
		if(sm_lastboss_enable_abyss.IntValue)
			SkillCallOfAbyss(client);
		
		ExtinguishEntity(client);
		AttachParticle(client, PARTICLE_SPAWN);
		
		for(int j = 1; j <= MaxClients; j++)
		{
			if(!IsClientInGame(j) || GetClientTeam(j) != 2)
				continue;
			EmitSoundToClient(j, SOUND_CHANGE);
			ScreenFade(j, 200, 200, 255, 255, 100, 1);
		}
	}
	
	switch(form_next)
	{
		case FORMONE:
		{
			force = sm_lastboss_force_first.IntValue;
			speed = sm_lastboss_speed_first.FloatValue;
			sm_lastboss_color_first.GetString(color, sizeof(color));
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 255 + (255 * 256) + (80 * 65536));
			
			if(sm_lastboss_enable_warp.IntValue)
			{
				CreateTimer(3.0, Timer_GetSurvivorPosition, GetClientUserId(client), TIMER_REPEAT);
				CreateTimer(sm_lastboss_warp_interval.FloatValue, Timer_FatalMirror, GetClientUserId(client), TIMER_REPEAT);
			}
		}
		case FORMTWO:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_SECOND);
			force = sm_lastboss_force_second.IntValue;
			speed = sm_lastboss_speed_second.FloatValue;
			sm_lastboss_color_second.GetString(color, sizeof(color));
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 80 + (255 * 256) + (80 * 65536));
			SetEntityGravity(client, sm_lastboss_weight_second.FloatValue);
		}
		case FORMTHREE:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_THIRD);
			force = sm_lastboss_force_third.IntValue;
			speed = sm_lastboss_speed_third.FloatValue;
			sm_lastboss_color_third.GetString(color, sizeof(color));
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 153 + (153 * 256) + (255 * 65536));
		}
		case FORMFOUR:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_FOURTH);
			force = sm_lastboss_force_fourth.IntValue;
			speed = sm_lastboss_speed_fourth.FloatValue;
			sm_lastboss_color_fourth.GetString(color, sizeof(color));
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 80 + (80 * 256) + (255 * 65536));
			SetEntityGravity(client, 1.0);
			CreateTimer(0.8, Timer_Particle, GetClientUserId(client), TIMER_REPEAT);
			
			if(sm_lastboss_enable_stealth.IntValue)
				CreateTimer(sm_lastboss_stealth_fourth.FloatValue, Timer_Stealth, GetClientUserId(client));
		}
		case FORMFIVE:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_FIFTH);
			force = sm_lastboss_force_fifth.IntValue;
			speed = sm_lastboss_speed_fifth.FloatValue;
			sm_lastboss_color_fifth.GetString(color, sizeof(color));
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 200 + (150 * 256) + (200 * 65536));
		}
		case FORMSIX:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_SIXTH);
			force = sm_lastboss_force_sixth.IntValue;
			speed = sm_lastboss_speed_sixth.FloatValue;
			sm_lastboss_color_sixth.GetString(color, sizeof(color));
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 176 + (48 * 256) + (96 * 65536));
		}
		case FORMSEVEN:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_SEVENTH);
			force = sm_lastboss_force_seventh.IntValue;
			speed = sm_lastboss_speed_seventh.FloatValue;
			sm_lastboss_color_seventh.GetString(color, sizeof(color));
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 0 + (128 * 256) + (255 * 65536));
		}
		case FORMEIGHT:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_EIGHTH);
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
			SetEntityRenderColor(client, _, _, _, 255);
			force = sm_lastboss_force_eighth.IntValue;
			speed = sm_lastboss_speed_eighth.FloatValue;
			sm_lastboss_color_eighth.GetString(color, sizeof(color));
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 255 + (80 * 256) + (80 * 65536));
			SetEntityGravity(client, 1.0);
			IgniteEntity(client, 9999.9);
			
			if(sm_lastboss_enable_jump.IntValue)
				CreateTimer(sm_lastboss_jumpinterval_eighth.FloatValue, Timer_Jumping, GetClientUserId(client), TIMER_REPEAT);
				
			float Origin[3], Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += 90.0;
			int ent[3];
			
			for(int count = 1; count <= 2; count++)
			{
				ent[count] = CreateEntityByName("prop_dynamic_override");
				if(IsValidEntity(ent[count]))
				{
					char tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(ent[count], "model", ENTITY_TIRE);
					DispatchKeyValue(ent[count], "targetname", "TireEntity");
					DispatchKeyValue(ent[count], "parentname", tName);
					GetConVarString(sm_lastboss_color_eighth, color, sizeof(color));
					DispatchKeyValue(ent[count], "rendercolor", color);
					DispatchKeyValueVector(ent[count], "origin", Origin);
					DispatchKeyValueVector(ent[count], "angles", Angles);
					DispatchSpawn(ent[count]);
					SetVariantString(tName);
					AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
					
					switch(count)
					{
						case 1: SetVariantString("rfoot");
						case 2: SetVariantString("lfoot");
					}
					
					AcceptEntityInput(ent[count], "SetParentAttachment");
					AcceptEntityInput(ent[count], "Enable");
					AcceptEntityInput(ent[count], "DisableCollision");
					SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
	
	FindConVar("z_tank_throw_force").SetInt(force, true, true);
	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed);
	SetEntityRenderMode(client, view_as<RenderMode>(0));
	DispatchKeyValue(client, "rendercolor", color);
}

void SkillEarthQuake(int attacker, int target)
{
	float Pos[3], tPos[3];
	
	if(IsPlayerIncapped(target))
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(i == attacker || !IsClientInGame(i) || GetClientTeam(i) != 2)
				continue;
			GetClientAbsOrigin(attacker, Pos);
			GetClientAbsOrigin(i, tPos);
			if(GetVectorDistance(tPos, Pos) < sm_lastboss_quake_radius.FloatValue)
			{
				EmitSoundToClient(i, SOUND_QUAKE);
				ScreenShake(i, 50.0);
				Smash(attacker, i, sm_lastboss_quake_force.FloatValue, 1.0, 1.5);
			}
		}
	}
}

void SkillDreadClaw(int target)
{
	visibility = sm_lastboss_dreadrate.IntValue;
	CreateTimer(sm_lastboss_dreadinterval.FloatValue, DreadTimer, target);
	EmitSoundToAll(SOUND_DCLAW, target);
	ScreenFade(target, 0, 0, 0, visibility, 0, 0);
}

void SkillGravityClaw(int target)
{
	SetEntityGravity(target, 0.3);
	CreateTimer(sm_lastboss_gravityinterval.FloatValue, GravityTimer, target);
	EmitSoundToAll(SOUND_GCLAW, target);
	ScreenFade(target, 0, 0, 100, 80, 4000, 1);
	ScreenShake(target, 30.0);
}

void SkillFreezeClaw(int target)
{
	FreezePlayer(target, sm_lastboss_freezetime.FloatValue);
	CreateTimer(sm_lastboss_freezeinterval.FloatValue, FreezeTimer, target);
}

void SkillLazyClaw(int target)
{
	if(IsValidSurv(target) && !isSlowed[target])
	{
		isSlowed[target] = true;
		CreateTimer((sm_lastboss_lazytime.FloatValue), Quick, target);
		SetEntDataFloat(target, laggedMovementOffset, (sm_lastboss_lazyspeed.FloatValue), true);
		SetEntityRenderColor(target, 255, 255, 255, 135);
		EmitSoundToAll(SOUND_LAZY, target);
	}
	
}

void SkillRabiesClaw(int target)
{
	Rabies[target] = sm_lastboss_rabiestime.IntValue;
	CreateTimer(1.0, RabiesTimer, target);
	Toxin[target] = sm_lastboss_rabiestime.IntValue;
	CreateTimer(1.0, Toxin_Timer, target);
	EmitSoundToAll(SOUND_ROAR, target);
}

void SkillBombClaw(int attacker, int target)
{
	float Pos[3];
	GetClientAbsOrigin(target, Pos);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(i == attacker || !IsClientInGame(i) || GetClientTeam(i) != 2)
			continue;
		float PosOther[3];
		GetClientAbsOrigin(i, PosOther); // Получаем позицию игрока i
		if(GetVectorDistance(Pos, PosOther) < sm_lastboss_bombradius.FloatValue)
			DamageEffect(i, sm_lastboss_bombdamage.FloatValue);
	}
	
	EmitSoundToAll(SOUND_BOMBARD, target);
	ScreenShake(target, 100.0);
	LittleFlower(Pos, EXPLODE);
	PushAway(target, sm_lastboss_bombardforce.FloatValue, sm_lastboss_bombradius.FloatValue, 0.5);
}

void SkillBurnClaw(int target)
{
	EmitSoundToAll(SOUND_BCLAW, target);
	ScreenFade(target, 200, 0, 0, 150, 80, 1);
	ScreenShake(target, 50.0);
}

void SkillCometStrike(int target, int type)
{
	float pos[3];
	GetClientAbsOrigin(target, pos);

	if(type == MOLOTOV)
	{
		LittleFlower(pos, EXPLODE);
		LittleFlower(pos, MOLOTOV);
	}
	else if(type == EXPLODE)
	{
		LittleFlower(pos, EXPLODE);
	}
}

void SkillFlameGush(int target)
{
	SkillBurnClaw(target);
	LavaDamage(target);
	float pos[3];
	GetClientAbsOrigin(target, pos);
	LittleFlower(pos, MOLOTOV);
}

void SkillCallOfAbyss(int client)
{
	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i) || GetClientTeam(i) != SURVIVOR)
			continue;
		EmitSoundToClient(i, SOUND_HOWL);
		ScreenShake(i, 20.0);
	}
	
	int form = GetTankForm(client);
	if((form == FORMEIGHT && sm_lastboss_enable_abyss.IntValue == 1) || sm_lastboss_enable_abyss.IntValue == 2)
		TriggerPanicEvent();
	
	CreateTimer(5.0, Timer_Howl, GetClientUserId(client));
}

Action Timer_Particle(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || g_hBossTanks.FindValue(userid) == -1)
		return Plugin_Stop;
	
	int form = GetTankForm(client);
	if(form == FORMFOUR)
		AttachParticle(client, PARTICLE_FOURTH);
	else if(form == FORMEIGHT)
		AttachParticle(client, PARTICLE_EIGHTH);
	else
		return Plugin_Stop;
	
	return Plugin_Continue;
}

Action GravityTimer(Handle timer, int target)
{
	if(IsValidClient(target))
		SetEntityGravity(target, 1.0);
	return Plugin_Stop;
}

Action Timer_Jumping(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || g_hBossTanks.FindValue(userid) == -1 || GetTankForm(client) != FORMEIGHT)
		return Plugin_Stop;
	
	AddVelocity(client, sm_lastboss_jumpheight_eighth.FloatValue);
	return Plugin_Continue;
}

Action Timer_Stealth(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || g_hBossTanks.FindValue(userid) == -1 || GetTankForm(client) != FORMFOUR)
		return Plugin_Stop;
	
	Remove(client);
	return Plugin_Stop;
}

Action DreadTimer(Handle timer, int target)
{
	if(IsValidSurv(target))
	{
		visibility -= 8;
		if(visibility < 0) visibility = 0;
		ScreenFade(target, 0, 0, 0, visibility, 0, 1);
		if(visibility <= 0)
		{
			visibility = 0;
			timer = null;
		}
	}
	return Plugin_Stop;
}

Action FreezeTimer(Handle timer, int target)
{
	if(IsValidSurv(target))
	{
		EmitSoundToAll(SOUND_DEFROST, target);
		SetEntityMoveType(target, MOVETYPE_WALK);
		SetEntityRenderColor(target, 255, 255, 255, 255);
		ScreenFade(target, 0, 0, 0, 0, 0, 1);
		freeze[target] = OFF;
	}
	return Plugin_Stop;
}

Action RabiesTimer(Handle timer, any target)
{
	if(IsValidSurv(target))
	{
		if(Rabies[target] <= 0)
		{
			KillTimer(timer);
			return Plugin_Stop;
		}

		RabiesDamage(target);

		if(Rabies[target] > 0)
		{
			CreateTimer(1.0, RabiesTimer, target);
			Rabies[target] -= 1;
		}
		EmitSoundToAll(SOUND_RABIES, target);
	}
	return Plugin_Stop;
}

Action Toxin_Timer(Handle timer, any target)
{
	if(IsValidSurv(target))
	{
		if(Toxin[target] <= 0)
		{
			KillToxin(target);
			timer = null;
			return Plugin_Stop;
		}
		
		KillToxin(target);
		
		if(Toxin[target] > 0)
		{
			CreateTimer(1.0, Toxin_Timer, target);
			Toxin[target]--;
		}
		
		float pos[3];
		GetClientAbsOrigin(target, pos);
		
		float angs[3];
		GetClientEyeAngles(target, angs);
		
		angs[2] = ToxinAngle[GetRandomInt(0,100) % 20];
		
		TeleportEntity(target, pos, angs, NULL_VECTOR);
		
		int clients[2];
		clients[0] = target;
		
		Handle message = StartMessageEx(g_FadeUserMsgId, clients, 1);
		BfWriteShort(message, 255);
		BfWriteShort(message, 255);
		BfWriteShort(message, (0x0002));
		BfWriteByte(message, GetRandomInt(0,255));
		BfWriteByte(message, GetRandomInt(0,255));
		BfWriteByte(message, GetRandomInt(0,255));
		BfWriteByte(message, 128);
		
		EndMessage();
	}
	return Plugin_Stop;
}

void KillToxin(int target)
{
	float pos[3];
	GetClientAbsOrigin(target, pos);
	float angs[3];
	GetClientEyeAngles(target, angs);

	angs[2] = 0.0;

	TeleportEntity(target, pos, angs, NULL_VECTOR);

	int clients[1];
	clients[0] = target;

	Handle message = StartMessageEx(g_FadeUserMsgId, clients, 1);
	BfWriteShort(message, 1536);
	BfWriteShort(message, 1536);
	BfWriteShort(message, (0x0001 | 0x0010));
	BfWriteByte(message, 0);
	BfWriteByte(message, 0);
	BfWriteByte(message, 0);
	BfWriteByte(message, 0);
	EndMessage();
}

stock void RabiesDamage(int target)
{
	char dmg_str[16];
	char dmg_type_str[16];
	IntToString((1 << 17),dmg_str,sizeof(dmg_type_str));
	FindConVar("sm_lastboss_rabiesdamage").GetString(dmg_str, sizeof(dmg_str));
	int pointHurt = CreateEntityByName("point_hurt");
	DispatchKeyValue(target,"targetname","war3_hurtme");
	DispatchKeyValue(pointHurt,"DamageTarget","war3_hurtme");
	DispatchKeyValue(pointHurt,"Damage",dmg_str);
	DispatchKeyValue(pointHurt,"DamageType",dmg_type_str);
	DispatchKeyValue(pointHurt,"classname","point_hurt");
	DispatchSpawn(pointHurt);
	AcceptEntityInput(pointHurt,"Hurt",-1,(target>0)?target:-1);
	DispatchKeyValue(target,"targetname","war3_donthurtme");
	RemoveEdict(pointHurt);
}

Action Timer_Howl(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || g_hBossTanks.FindValue(userid) == -1)
		return Plugin_Stop;
	
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	return Plugin_Stop;
}

Action Timer_Warp(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || g_hBossTanks.FindValue(userid) == -1)
		return Plugin_Stop;
	
	float pos[3];
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == SURVIVOR)
			EmitSoundToClient(i, SOUND_WARP);
	}
	GetClientAbsOrigin(client, pos);
	ShowParticle(pos, PARTICLE_WARP, 2.0);
	
	float ftlPos[3];
	GetClientAbsOrigin(GetRandomSurvivor(), ftlPos);
	
	TeleportEntity(client, ftlPos, NULL_VECTOR, NULL_VECTOR);
	ShowParticle(ftlPos, PARTICLE_WARP, 2.0);
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	return Plugin_Stop;
}

Action Timer_GetSurvivorPosition(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || g_hBossTanks.FindValue(userid) == -1)
		return Plugin_Stop;
	
	int survivor = GetRandomSurvivor();
	if(survivor == -1)
		return Plugin_Stop;
	
	// Сохраняем позицию в отдельный массив для каждого танка
	float pos[3];
	GetClientAbsOrigin(survivor, pos);
	
	// Создаем или обновляем данные танка
	int index = g_hBossTanks.FindValue(userid);
	if(index != -1)
	{
		// Если данные уже есть - обновляем
		if(g_hBossTanks.Length > index + 1)
		{
			g_hBossTanks.SetArray(index + 1, pos, 3);
		}
		else
		{
			// Если данных нет - добавляем
			g_hBossTanks.PushArray(pos, 3);
		}
	}
	
	return Plugin_Continue;
}

Action Timer_FatalMirror(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || g_hBossTanks.FindValue(userid) == -1)
		return Plugin_Stop;
	
	int index = g_hBossTanks.FindValue(userid);
	if(index == -1)
		return Plugin_Stop;
	
	// Получаем сохраненную позицию
	float ftlPos[3];
	if(g_hBossTanks.Length > index + 1)
	{
		g_hBossTanks.GetArray(index + 1, ftlPos, 3);
	}
	else
	{
		// Если позиция не сохранена, телепортируем к случайному выжившему
		int survivor = GetRandomSurvivor();
		if(survivor == -1)
			return Plugin_Stop;
		
		GetClientAbsOrigin(survivor, ftlPos);
	}
	
	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	CreateTimer(1.5, Timer_Warp, userid);
	return Plugin_Continue;
}

Action Quick(Handle timer, int target)
{
	if(IsValidSurv(target))
	{
		SetEntDataFloat(target, laggedMovementOffset, 1.0, true);
		isSlowed[target] = false;
		SetEntityRenderColor(target, 255, 255, 255, 255);
		EmitSoundToAll(SOUND_QUICK, target);
	}
	return Plugin_Stop;
}

int GetRandomSurvivor()
{
	int survivors[MAXPLAYERS+1];
	int count = 0;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == SURVIVOR)
		{
			survivors[count] = i;
			count++;
		}
	}
	
	if(count == 0)
		return -1;
	
	return survivors[GetRandomInt(0, count-1)];
}

void FreezePlayer(int target, float Time)
{
	if(IsValidClient(target) && GetClientTeam(target) == 2)
	{
		SetEntityMoveType(target, MOVETYPE_NONE);
		SetEntityRenderColor(target, 0, 128, 255, 135);
		EmitSoundToAll(SOUND_FREEZE, target);
		CreateTimer(Time, FreezeTimer, target);
	}
}

void Remove(int ent)
{
	if(IsValidEntity(ent))
	{
		CreateTimer(0.1, Timer_FadeOut, ent, TIMER_REPEAT);
		SetEntityRenderMode(ent, RENDER_TRANSCOLOR);
	}
}

Action Timer_FadeOut(Handle Timer, int ent)
{
	if(!IsValidEntity(ent) || GetTankForm(ent) != FORMFOUR)
	{
		Timer = null;
		return Plugin_Stop;
	}
	
	int alpha = GetEntityAlpha(ent) - 2;
	if(alpha < 0) alpha = 0;
	SetEntityRenderMode(ent, RENDER_TRANSCOLOR);
	SetEntityRenderColor(ent, 80, 80, 255, alpha);
	
	if(alpha <= 0)
	{
		Timer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

int GetEntityAlpha(int entity)
{
	int offset = FindSendPropInfo("CBaseAnimating", "m_clrRender");
	if(offset <= 0)
		return 255;
	
	int color[4];
	GetEntDataArray(entity, offset, color, 4, 4);
	return color[3];
}

void AddVelocity(int client, float zSpeed)
{
	if(g_iVelocity == -1) return;
	
	float vecVelocity[3];
	GetEntDataVector(client, g_iVelocity, vecVelocity);
	vecVelocity[2] += zSpeed;
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);
}

void LittleFlower(float pos[3], int type)
{
	int entity = CreateEntityByName("prop_physics");
	if(entity != -1)
	{
		pos[2] += 10.0;
		if (type == 0)
			DispatchKeyValue(entity, "model", ENTITY_GASCAN);
		else
			DispatchKeyValue(entity, "model", ENTITY_PROPANE);
		DispatchSpawn(entity);
		SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "break");
	}
}

void Smash(int client, int target, float power, float powHor, float powVec)
{
	float HeadingVector[3], AimVector[3];
	GetClientEyeAngles(client, HeadingVector);
	
	AimVector[0] = Cosine(DegToRad(HeadingVector[1])) * power * powHor;
	AimVector[1] = Sine(DegToRad(HeadingVector[1])) * power * powHor;
	
	float current[3];
	GetEntPropVector(target, Prop_Data, "m_vecVelocity", current);
	
	float resulting[3];
	resulting[0] = current[0] + AimVector[0];
	resulting[1] = current[1] + AimVector[1];
	resulting[2] = power * powVec;
	
	TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, resulting);
}

void ScreenFade(int target, int red, int green, int blue, int alpha, int duration, int type)
{
	Handle msg = StartMessageOne("Fade", target);
	BfWriteShort(msg, 500);
	BfWriteShort(msg, duration);
	if (type == 0)
		BfWriteShort(msg, (0x0002 | 0x0008));
	else
		BfWriteShort(msg, (0x0001 | 0x0010));
	BfWriteByte(msg, red);
	BfWriteByte(msg, green);
	BfWriteByte(msg, blue);
	BfWriteByte(msg, alpha);
	EndMessage();
}

void ScreenShake(int target, float intensity)
{
	Handle msg;
	msg = StartMessageOne("Shake", target);
	
	BfWriteByte(msg, 0);
	BfWriteFloat(msg, intensity);
	BfWriteFloat(msg, 10.0);
	BfWriteFloat(msg, 3.0);
	EndMessage();
}

void TriggerPanicEvent()
{
	int flager = GetAnyClient();
	if(flager == -1) return;
	
	int flag = GetCommandFlags("director_force_panic_event");
	SetCommandFlags("director_force_panic_event", flag & ~FCVAR_CHEAT);
	FakeClientCommand(flager, "director_force_panic_event");
}

void LavaDamage(int target)
{
	char dmg_lava[16];
	char dmg_type_lava[16];
	IntToString((1 << 17),dmg_type_lava,sizeof(dmg_type_lava));
	FindConVar("sm_lastboss_lavadamage").GetString(dmg_lava, sizeof(dmg_lava));
	int pointHurt = CreateEntityByName("point_hurt");
	DispatchKeyValue(target,"targetname","war3_hurtme");
	DispatchKeyValue(pointHurt,"DamageTarget","war3_hurtme");
	DispatchKeyValue(pointHurt,"Damage",dmg_lava);
	DispatchKeyValue(pointHurt,"DamageType",dmg_type_lava);
	DispatchKeyValue(pointHurt,"classname","point_hurt");
	DispatchSpawn(pointHurt);
	AcceptEntityInput(pointHurt,"Hurt",-1,(target>0)?target:-1);
	DispatchKeyValue(target,"targetname","war3_donthurtme");
	RemoveEdict(pointHurt);
}

void DamageEffect(int target, float damage)
{
	char tName[20];
	Format(tName, 20, "target%d", target);
	int pointHurt = CreateEntityByName("point_hurt");
	DispatchKeyValue(target, "targetname", tName);
	DispatchKeyValueFloat(pointHurt, "Damage", damage);
	DispatchKeyValue(pointHurt, "DamageTarget", tName);
	DispatchKeyValue(pointHurt, "DamageType", "65536");
	DispatchSpawn(pointHurt);
	AcceptEntityInput(pointHurt, "Hurt");
	AcceptEntityInput(pointHurt, "Kill");
}

void ForceWeaponDrop(int client)
{
	if (GetPlayerWeaponSlot(client, 1) > 0)
	{
		int weapon = GetPlayerWeaponSlot(client, 1);
		SDKHooks_DropWeapon(client, weapon, NULL_VECTOR, NULL_VECTOR);
	}
}

void PushAway(int target, float force, float radius, float duration)
{
	int push = CreateEntityByName("point_push");
	DispatchKeyValueFloat (push, "magnitude", force);
	DispatchKeyValueFloat (push, "radius", radius);
	SetVariantString("spawnflags 24");
	AcceptEntityInput(push, "AddOutput");
	DispatchSpawn(push);
	
	float pos[3];
	GetClientAbsOrigin(target, pos);
	
	TeleportEntity(push, pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(push, "Enable", -1, -1);
	CreateTimer(duration, Timer_DeletePushForce, push);
}

void ShowParticle(float pos[3], const char[] particlename, float Time)
{
	int particle = CreateEntityByName("info_particle_system");
	if(particle != -1)
	{
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(Time, Timer_DeleteParticles, particle);
	}  
}

void AttachParticle(int ent, const char[] particleType)
{
	char tName[64];
	int particle = CreateEntityByName("info_particle_system");
	if(particle != -1)
	{
		float pos[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		GetEntPropString(ent, Prop_Data, "m_iName", tName, sizeof(tName));
		DispatchKeyValue(particle, "targetname", "tf2particle");
		DispatchKeyValue(particle, "parentname", tName);
		DispatchKeyValue(particle, "effect_name", particleType);
		DispatchSpawn(particle);
		SetVariantString(tName);
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
	}
}

Action Timer_DeleteParticles(Handle timer, int particle)
{
	if(IsValidEntity(particle))
	{
		char classname[64];
		GetEntityClassname(particle, classname, sizeof(classname));
		if(StrEqual(classname, "info_particle_system", false))
		{
			AcceptEntityInput(particle, "stop");
			AcceptEntityInput(particle, "kill");
			RemoveEdict(particle);
		}
	}
	return Plugin_Stop;
}

void PrecacheParticle(const char[] particlename)
{
	int particle = CreateEntityByName("info_particle_system");
	if(particle != -1)
	{
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(0.01, Timer_DeleteParticles, particle);
	}
}

Action Timer_DeletePushForce(Handle timer, int ent)
{
	if(ent > 0 && IsValidEntity(ent) && IsValidEdict(ent))
	{
		char classname[64];
		GetEntityClassname(ent, classname, sizeof(classname));
		if(StrEqual(classname, "point_push", false))
		{
			AcceptEntityInput(ent, "Disable");
			AcceptEntityInput(ent, "Kill"); 
			RemoveEntity(ent);
		}
	}
	return Plugin_Stop;
}

bool IsPlayerIncapped(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1));
}

int GetAnyClient()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
			return i;
	}
	return -1;
}

public bool IsValidClient(int client)
{
	return client > 0 && 
		   client <= MaxClients && 
		   IsClientInGame(client) && 
		   IsPlayerAlive(client) && 
		   IsValidEntity(client);
}

bool IsValidSurv(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) && IsValidEntity(client) && GetClientTeam(client) == 2;
}
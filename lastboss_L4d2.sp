/******************************************************
* 				L4D2: Last Boss v3.0
*					Author: ztar
* 			Web: http://ztar.blog7.fc2.com/
*           Fixed by: SourceMod Expert
*           Multi-Tank fix by: YourName
*******************************************************/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "3.0-multifix"
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

/* Звуки */
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

/* Частицы */
#define PARTICLE_SPAWN  "electrical_arc_01_system"
#define PARTICLE_DEATH  "gas_explosion_main"
#define PARTICLE_FOURTH "apc_wheel_smoke1"
#define PARTICLE_EIGHTH "aircraft_destroy_fastFireTrail"
#define PARTICLE_WARP   "water_splash"

/* Сообщения */
#define MESSAGE_SPAWN   "\x03[ФИНАЛЬНЫЙ БОСС] \x04\x01ОПАСНОСТЬ!!! ОСОБАЯ МУТАЦИЯ ТАНКА \x05 ПРИГОТОВЬТЕСЬ!!!\x01【\x03 ФИНАЛЬНЫЙ БОСС ИЗ 8 ФАЗ \x01】"
#define MESSAGE_SPAWN2  "\x03[ФИНАЛЬНЫЙ БОСС] \x04ПЕРВАЯ \x01ФАЗА \x05ОСОБЫЙ ЗАРАЖЕННЫЙ \x01| \x04СКОРОСТЬ: \x05 ИЗМЕНЯЕТСЯ"
#define MESSAGE_SECOND "\x03[ФИНАЛЬНЫЙ БОСС] \x04ВТОРАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03СТАЛЬНОЙ ГИГАНТ\x01】"
#define MESSAGE_THIRD  "\x03[ФИНАЛЬНЫЙ БОСС] \x04ТРЕТЬЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03СУПЕР СИЛА\x01】"
#define MESSAGE_FOURTH "\x03[ФИНАЛЬНЫЙ БОСС] \x04ЧЕТВЕРТАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03ТЕМНОЕ ЗРЕНИЕ\x01】"
#define MESSAGE_FIFTH  "\x03[ФИНАЛЬНЫЙ БОСС] \x04ПЯТАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03НЕПОДВИЖНОСТЬ\x01】"
#define MESSAGE_SIXTH  "\x03[ФИНАЛЬНЫЙ БОСС] \x04ШЕСТАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03ВЗРЫВНОЙ УДАР\x01】"
#define MESSAGE_SEVENTH "\x03[ФИНАЛЬНЫЙ БОСС] \x04СЕДЬМАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03ЗАМОРАЖИВАЮЩИЙ УДАР\x01】"
#define MESSAGE_EIGHTH "\x03[ФИНАЛЬНЫЙ БОСС] \x04ФИНАЛЬНАЯ \x01ФАЗА  \x03ТРАНСФОРМАЦИЯ \x05ТАНКА \x04==> \x01【\x03ОГНЕННЫЙ ЩИТ\x01】"

/* Структура для хранения данных о танке */
enum struct TankData {
    int client;
    int form;
    int startHealth;
    Handle timer;
    float ftlPos[3];
    float trsPos[MAXPLAYERS+1 * 3]; // Исправлено: одномерный массив для координат
    int freeze[MAXPLAYERS+1];
    int Rabies[MAXPLAYERS+1];
    int Toxin[MAXPLAYERS+1];
    int alpharate;
    int visibility;
}

/* Консольные переменные */
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

ConVar sm_lastboss_health_max;

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

/* Глобальные переменные */
ArrayList g_aTanks; // Массив для хранения данных о всех танках
int bossflag = OFF, lastflag = OFF, wavecount;
bool g_l4d1 = false;
bool isSlowed[MAXPLAYERS+1] = {false, ...};
int force_default, g_iVelocity = -1;
static int laggedMovementOffset = 0;
UserMsg g_FadeUserMsgId;

float ToxinAngle[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0};

public Plugin myinfo = 
{
	name = "[L4D2] Финальный босс (Multi-Tank Fix)",
	author = "ztar & IxAvnoMonvAxI, fixed by SourceMod Expert",
	description = "Особый танк появляется во время финала (исправленная версия с поддержкой нескольких танков)",
	version = PLUGIN_VERSION,
	url = "http://ztar.blog7.fc2.com/"
}

public void OnPluginStart()
{
	char game[32];
	GetGameFolderName(game, sizeof(game));
	g_l4d1 = StrEqual(game, "left4dead");
	
	g_aTanks = new ArrayList(sizeof(TankData));
	
	/* Включение/Отключение */
	sm_lastboss_enable		    = CreateConVar("sm_lastboss_enable", "2", "Появление особого танка (0: Нет | 1: После вызова | 2: Всегда | 3: Только 2-я фаза)", FCVAR_NOTIFY);
	sm_lastboss_enable_announce	= CreateConVar("sm_lastboss_enable_announce", "1", "Показывать информационные сообщения? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_steel	= CreateConVar("sm_lastboss_enable_steel", "1",	"Использовать стальную кожу? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_bomb	    = CreateConVar("sm_lastboss_enable_bomb", "1", "Использовать взрывные удары? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_stealth	= CreateConVar("sm_lastboss_enable_stealth", "1", "Танк постепенно становится невидимым и неуязвимым к огню? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_gravity	= CreateConVar("sm_lastboss_enable_gravity", "1", "Уменьшать гравитацию выживших при ударе? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_burn		= CreateConVar("sm_lastboss_enable_burn", "1", "Восстанавливать здоровье танка при атаке выживших? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_quake	= CreateConVar("sm_lastboss_enable_quake", "1",	"Может ли отбрасывать оглушенных выживших? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_jump		= CreateConVar("sm_lastboss_enable_jump", "1", "Часто ли танк прыгает? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_comet	= CreateConVar("sm_lastboss_enable_comet", "1", "Взрываются ли камни, брошенные танком? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_dread	= CreateConVar("sm_lastboss_enable_dread", "1", "Затемнять зрение выживших при атаке? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_lazy	    = CreateConVar("sm_lastboss_enable_lazy", "1", "Замедлять атакованных выживших? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_rabies	= CreateConVar("sm_lastboss_enable_rabies", "1", "Уменьшать здоровье атакованных выживших? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_freeze	= CreateConVar("sm_lastboss_enable_freeze", "1", "Замораживать атакованных выживших? (0: Нет | 1: Да)", FCVAR_NOTIFY);	
	sm_lastboss_enable_gush		= CreateConVar("sm_lastboss_enable_gush", "1", "Использовать огненные атаки (Lethal Weapon)? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_enable_abyss	= CreateConVar("sm_lastboss_enable_abyss", "1", "Вызывать орду при крике? (0: Нет | 1: Только 8-я фаза | 2: Все фазы)", FCVAR_NOTIFY);
	sm_lastboss_enable_warp		= CreateConVar("sm_lastboss_enable_warp", "1", "Использовать телепортацию? (0: Нет | 1: Да)", FCVAR_NOTIFY);

	/* Здоровье */
	sm_lastboss_health_max	  = CreateConVar("sm_lastboss_health_max", "6000", "Здоровье танка в 1-й фазе", FCVAR_NOTIFY);

	/* Цвет */
	sm_lastboss_color_first	  = CreateConVar("sm_lastboss_color_first", "255 255 80", "Цвет танка в 1-й фазе (желтый)", FCVAR_NOTIFY);
	sm_lastboss_color_second  = CreateConVar("sm_lastboss_color_second", "80 255 80", "Цвет танка во 2-й фазе (светло-зеленый)", FCVAR_NOTIFY);
	sm_lastboss_color_third	  = CreateConVar("sm_lastboss_color_third", "153 153 255", "Цвет танка в 3-й фазе (голубой)", FCVAR_NOTIFY);
	sm_lastboss_color_fourth  = CreateConVar("sm_lastboss_color_fourth", "80 80 255", "Цвет танка в 4-й фазе (фиолетовый → постепенно исчезает)", FCVAR_NOTIFY);
	sm_lastboss_color_fifth	  = CreateConVar("sm_lastboss_color_fifth", "200 150 200", "Цвет танка в 5-й фазе (темно-розовый)", FCVAR_NOTIFY);
	sm_lastboss_color_sixth	  = CreateConVar("sm_lastboss_color_sixth", "176 48 96", "Цвет танка в 6-й фазе (красно-коричневый)", FCVAR_NOTIFY);	
	sm_lastboss_color_seventh = CreateConVar("sm_lastboss_color_seventh", "0 128 255", "Цвет танка в 7-й фазе (синий)", FCVAR_NOTIFY);
	sm_lastboss_color_eighth  = CreateConVar("sm_lastboss_color_eighth", "255 80 80", "Цвет танка в 8-й фазе (красный)", FCVAR_NOTIFY);

	/* Сила */
	sm_lastboss_force_first	  = CreateConVar("sm_lastboss_force_first", "1000", "Сила удара в 1-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_second  = CreateConVar("sm_lastboss_force_second", "1500", "Сила удара во 2-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_third	  = CreateConVar("sm_lastboss_force_third", "1100", "Сила удара в 3-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_fourth  = CreateConVar("sm_lastboss_force_fourth", "800", "Сила удара в 4-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_fifth	  = CreateConVar("sm_lastboss_force_fifth", "2000", "Сила удара в 5-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_sixth	  = CreateConVar("sm_lastboss_force_sixth", "1600", "Сила удара в 6-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_seventh = CreateConVar("sm_lastboss_force_seventh", "1300", "Сила удара в 7-й фазе", FCVAR_NOTIFY);
	sm_lastboss_force_eighth  = CreateConVar("sm_lastboss_force_eighth", "1800", "Сила удара в 8-й фазе", FCVAR_NOTIFY);
	
	/* Скорость */
	sm_lastboss_speed_first	  = CreateConVar("sm_lastboss_speed_first", "0.9", "Доп. скорость движения в 1-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_second  = CreateConVar("sm_lastboss_speed_second", "0.9", "Доп. скорость движения во 2-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_third	  = CreateConVar("sm_lastboss_speed_third", "0.9", "Доп. скорость движения в 3-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_fourth  = CreateConVar("sm_lastboss_speed_fourth", "0.9", "Доп. скорость движения в 4-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_fifth	  = CreateConVar("sm_lastboss_speed_fifth", "0.9", "Доп. скорость движения в 5-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_sixth	  = CreateConVar("sm_lastboss_speed_sixth", "0.9", "Доп. скорость движения в 6-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_seventh = CreateConVar("sm_lastboss_speed_seventh", "0.9", "Доп. скорость движения в 7-й фазе", FCVAR_NOTIFY);
	sm_lastboss_speed_eighth  = CreateConVar("sm_lastboss_speed_eighth", "1.1", "Доп. скорость движения в 8-й фазе", FCVAR_NOTIFY);
	
	/* Способности */
	sm_lastboss_weight_second		= CreateConVar("sm_lastboss_weight_second", "8.0", "Длительность уменьшенной гравитации у выживших (сек)", FCVAR_NOTIFY);
	sm_lastboss_stealth_fourth		= CreateConVar("sm_lastboss_stealth_fourth", "10.0", "Интервал невидимости танка (сек)", FCVAR_NOTIFY);
	sm_lastboss_jumpinterval_eighth = CreateConVar("sm_lastboss_jumpinterval_eighth", "1.0", "Интервал прыжков танка (сек)", FCVAR_NOTIFY);
	sm_lastboss_jumpheight_eighth  	= CreateConVar("sm_lastboss_jumpheight_eighth", "300.0", "Высота прыжка танка", FCVAR_NOTIFY);
	sm_lastboss_gravityinterval		= CreateConVar("sm_lastboss_gravityinterval", "6.0", "Интервал атак с изменением гравитации (сек)", FCVAR_NOTIFY);
	sm_lastboss_quake_radius		= CreateConVar("sm_lastboss_quake_radius", "600.0", "Радиус отбрасывания оглушенных выживших", FCVAR_NOTIFY);
	sm_lastboss_quake_force			= CreateConVar("sm_lastboss_quake_force", "350.0", "Сила отбрасывания оглушенных выживших", FCVAR_NOTIFY);
	sm_lastboss_dreadinterval		= CreateConVar("sm_lastboss_dreadinterval", "8.0", "Интервал затемнения зрения (сек)", FCVAR_NOTIFY);
	sm_lastboss_dreadrate			= CreateConVar("sm_lastboss_dreadrate", "235", "Скорость затемнения зрения", FCVAR_NOTIFY);
	sm_lastboss_freezetime		    = CreateConVar("sm_lastboss_freezetime", "10", "Длительность заморозки выживших (сек)", FCVAR_NOTIFY);
	sm_lastboss_freezeinterval	    = CreateConVar("sm_lastboss_freezeinterval", "6.0", "Интервал замораживающих атак (сек)", FCVAR_NOTIFY);
	sm_lastboss_lazytime			= CreateConVar("sm_lastboss_lazytime", "10.0", "Длительность замедления выживших (сек)", FCVAR_NOTIFY);
	sm_lastboss_lazyspeed		    = CreateConVar("sm_lastboss_lazyspeed", "0.3", "Множитель скорости замедленных выживших", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateConVar("sm_lastboss_rabiesdamage", "10", "Урон от бешенства за тик", FCVAR_NOTIFY);
	CreateConVar("sm_lastboss_lavadamage", "50", "Урон от лавы за тик", FCVAR_NOTIFY);
	sm_lastboss_rabiestime		    = CreateConVar("sm_lastboss_rabiestime", "10", "Длительность эффекта бешенства (сек)", FCVAR_NOTIFY);
	sm_lastboss_bombradius			= CreateConVar("sm_lastboss_bombradius", "250", "Радиус взрывной атаки", FCVAR_NOTIFY);
	sm_lastboss_bombdamage		    = CreateConVar("sm_lastboss_bombdamage", "300", "Урон взрывной атаки", FCVAR_NOTIFY);
	sm_lastboss_bombardforce	    = CreateConVar("sm_lastboss_bombardforce", "600.0", "Сила отбрасывания взрывной атаки", FCVAR_NOTIFY);
	sm_lastboss_eighth_c5m5_bridge	= CreateConVar("sm_lastboss_eigth_c5m5_bridge", "0", "Появляется ли танк 8-й фазы на финальном мосту? (0: Нет | 1: Да)", FCVAR_NOTIFY);
	sm_lastboss_warp_interval		= CreateConVar("sm_lastboss_warp_interval", "35.0", "Интервал телепортации (сек)", FCVAR_NOTIFY);
	
	/* Event hook */
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
	/* Предзагрузка моделей */
	PrecacheModel(ENTITY_PROPANE, true);
	PrecacheModel(ENTITY_GASCAN, true);
	PrecacheModel(ENTITY_TIRE, true);
	
	/* Предзагрузка звуков */
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
	
	/* Предзагрузка частиц */
	PrecacheParticle(PARTICLE_SPAWN);
	PrecacheParticle(PARTICLE_DEATH);
	PrecacheParticle(PARTICLE_FOURTH);
	PrecacheParticle(PARTICLE_EIGHTH);
	PrecacheParticle(PARTICLE_WARP);
}

void InitData()
{
	/* Сброс флагов */
	bossflag = OFF;
	lastflag = OFF;
	wavecount = 0;
	FindConVar("z_tank_throw_force").SetInt(force_default, true, true);
	
	// Очистка массива танков
	for (int i = 0; i < g_aTanks.Length; i++) {
		TankData tank;
		g_aTanks.GetArray(i, tank);
		if (tank.timer != null) {
			KillTimer(tank.timer);
			tank.timer = null;
		}
	}
	g_aTanks.Clear();
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

public void OnMapEnd()
{
	InitData();
}

public Action Event_Round_Start(Event event, const char[] name, bool dontBroadcast)
{
	InitData();
	return Plugin_Continue;
}

public Action Event_Finale_Start(Event event, const char[] name, bool dontBroadcast)
{
	bossflag = ON;
	lastflag = OFF;
	
	/* Особые условия для некоторых карт */
	char CurrentMap[64];
	GetCurrentMap(CurrentMap, sizeof(CurrentMap));
	
	if(StrEqual(CurrentMap, "c1m4_atrium") || StrEqual(CurrentMap, "c2m5_concert") || 
	   StrEqual(CurrentMap, "c3m4_plantation") || StrEqual(CurrentMap, "c4m5_milltown_escape") || 
	   StrEqual(CurrentMap, "c5m5_bridge") || StrEqual(CurrentMap, "c6m3_port") || 
	   StrEqual(CurrentMap, "c7m3_port") || StrEqual(CurrentMap, "c8m5_rooftop") || 
	   StrEqual(CurrentMap, "c13m4_cutthroatcreek"))
	{
		wavecount = 2;
	}
	else
	{
		wavecount = 1;
	}
	
	return Plugin_Continue;
}

public Action Event_Tank_Spawn(Event event, const char[] name, bool dontBroadcast)
{
	char CurrentMap[64];
	GetCurrentMap(CurrentMap, sizeof(CurrentMap));
	
	/* Особые условия для некоторых карт */
	if(StrEqual(CurrentMap, "c1m4_atrium") || StrEqual(CurrentMap, "c2m5_concert") || 
	   StrEqual(CurrentMap, "c3m4_plantation") || StrEqual(CurrentMap, "c4m5_milltown_escape") || 
	   StrEqual(CurrentMap, "c5m5_bridge") || StrEqual(CurrentMap, "c6m3_port") || 
	   StrEqual(CurrentMap, "c7m3_port") || StrEqual(CurrentMap, "c8m5_rooftop") || 
	   StrEqual(CurrentMap, "c13m4_cutthroatcreek"))
	{
		bossflag = ON;
	}
	
	/* Только второй Танк? */
	if(wavecount < 2 && sm_lastboss_enable.IntValue == 3)
		return Plugin_Continue;
	
	/* Только в финале */
	if((bossflag && sm_lastboss_enable.IntValue == 1) || (sm_lastboss_enable.IntValue == 2) || (bossflag && sm_lastboss_enable.IntValue == 3))
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if(IsValidEntity(client) && IsClientInGame(client))
		{
			/* Получаем ID босса и устанавливаем таймер */
			CreateTimer(0.3, SetTankHealth, client);
			
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
		}
	}
	return Plugin_Continue;
}

public Action SetTankHealth(Handle timer, int client)
{
	/* Установка здоровья и ID после спавна */
	char CurrentMap[64];
	GetCurrentMap(CurrentMap, sizeof(CurrentMap));
	
	if(IsValidEntity(client) && IsClientInGame(client))
	{
		TankData tank;
		tank.client = client;
		tank.startHealth = sm_lastboss_health_max.IntValue;
		SetEntityHealth(client, tank.startHealth);
		
		if(lastflag || (StrEqual(CurrentMap, "c5m5_bridge") && sm_lastboss_eighth_c5m5_bridge.IntValue))
		{
			tank.form = FORMEIGHT;
		}
		else
		{
			tank.form = FORMONE;
		}
		
		// Создаем таймер для этого танка
		tank.timer = CreateTimer(1.0, TankUpdate, client, TIMER_REPEAT);
		
		// Добавляем танк в массив
		g_aTanks.PushArray(tank);
		
		SetParameter(client, tank.form);
	}
	return Plugin_Continue;
}

public Action Event_Player_Death(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(client <= 0 || client > MaxClients)
		return Plugin_Continue;
	if(!IsValidEntity(client) || !IsClientInGame(client))
		return Plugin_Continue;
	if(GetEntProp(client, Prop_Send, "m_zombieClass") != CLASS_TANK)
		return Plugin_Continue;
	if(wavecount < 2 && sm_lastboss_enable.IntValue == 3)
	{
		wavecount++;
		return Plugin_Continue;
	}

	if((bossflag && sm_lastboss_enable.IntValue == 1) || (sm_lastboss_enable.IntValue == 2) || (bossflag && sm_lastboss_enable.IntValue == 3))
	{
		// Находим танка в массиве
		int index = FindTankIndex(client);
		if (index != -1)
		{
			TankData tank;
			g_aTanks.GetArray(index, tank);
			
			/* Взрыв и огонь при смерти */
			float Pos[3];
			GetClientAbsOrigin(client, Pos);
			EmitSoundToAll(SOUND_EXPLODE, client);
			ShowParticle(Pos, PARTICLE_DEATH, 5.0);
			LittleFlower(Pos, MOLOTOV);
			LittleFlower(Pos, EXPLODE);
			
			// Удаляем все связанные с танком частицы
			int entity = -1;
			while ((entity = FindEntityByClassname(entity, "info_particle_system")) != INVALID_ENT_REFERENCE)
			{
				char targetname[32];
				GetEntPropString(entity, Prop_Data, "m_iName", targetname, sizeof(targetname));
				if (StrEqual(targetname, "tf2particle"))
				{
					AcceptEntityInput(entity, "Kill");
				}
			}
			
			// Удаляем шины
			entity = -1;
			while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
			{
				char model[128];
				GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
				if (StrEqual(model, ENTITY_TIRE))
				{
					int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					if (owner == client) 
					{
						AcceptEntityInput(entity, "Kill");
					}
				}
			}
			
			// Удаляем таймер и запись о танке
			if (tank.timer != null) {
				KillTimer(tank.timer);
				tank.timer = null;
			}
			g_aTanks.Erase(index);
		}
	}
	
	for (int target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target) && GetClientTeam(target) == 2)
		{
			isSlowed[target] = false;
			SetEntityGravity(target, 1.0);
		}
	}
	return Plugin_Continue;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	for (int target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target) && GetClientTeam(target) == 2)
		{
			isSlowed[target] = false;
			SetEntityGravity(target, 1.0);
		}
	}
	
	InitData();
}

public Action Event_Player_Hurt(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int target = GetClientOfUserId(event.GetInt("userid"));
	
	char weapon[64];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	
	// Находим танка в массиве (если атакующий - танк)
	int tankIndex = FindTankIndex(attacker);
	if (tankIndex == -1) return Plugin_Continue;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);
	
	/* Только второй Танк? */
	if(wavecount < 2 && sm_lastboss_enable.IntValue == 3)
		return Plugin_Continue;
	
	/* Специальные способности */
	if((bossflag && sm_lastboss_enable.IntValue == 1) || (sm_lastboss_enable.IntValue == 2) || (bossflag && sm_lastboss_enable.IntValue == 3))
	{
		if(StrEqual(weapon, "tank_claw") && attacker == tank.client)
		{
			GetClientAbsOrigin(target, tank.trsPos[target]);
			g_aTanks.SetArray(tankIndex, tank);
			
			if(sm_lastboss_enable_quake.IntValue)
			{
				/* Умение: Землетрясение (если цель оглушена) */
				SkillEarthQuake(tank.client, target);
			}
			if(sm_lastboss_enable_gravity.IntValue)
			{
				if(tank.form == FORMTWO)
				{
					/* Умение: Гравитационный коготь (только 2 форма) */
					SkillGravityClaw(tank.client, target);
				}
			}
			if(sm_lastboss_enable_bomb.IntValue)
			{
				if(tank.form == FORMTHREE)
				{
					/* Умение: Взрывной коготь (только 3 форма) */
					SkillBombClaw(tank.client, target);
				}
			}
			if(sm_lastboss_enable_dread.IntValue)
			{
				if(tank.form == FORMFOUR)
				{
					/* Умение: Коготь ужаса (только 4 форма) */
					SkillDreadClaw(tank.client, target);
				}
			}
			if(sm_lastboss_enable_lazy.IntValue)
			{
				if(tank.form == FORMFIVE)
				{
					/* Умение: Ленивый коготь (только 5 форма) */
					SkillLazyClaw(tank.client, target);
				}
			}
			if(sm_lastboss_enable_rabies.IntValue)
			{
				if(tank.form == FORMSIX)
				{
					/* Умение: Коготь бешенства (только 6 форма) */
					SkillRabiesClaw(tank.client, target);
				}
			}
			if(sm_lastboss_enable_freeze.IntValue)
			{
				if(tank.form == FORMSEVEN)
				{
					/* Умение: Ледяной коготь (только 7 форма) */
					SkillFreezeClaw(tank.client, target);
				}
			}			
			if(sm_lastboss_enable_burn.IntValue)
			{
				if(tank.form == FORMEIGHT)
				{
					/* Умение: Огненный коготь (только 8 форма) */
					SkillBurnClaw(tank.client, target);
				}
			}
		}
		if(StrEqual(weapon, "tank_rock") && attacker == tank.client)
		{
			if(sm_lastboss_enable_comet.IntValue)
			{
				if(tank.form == FORMEIGHT)
				{
					/* Умение: Удар кометы (только 8 форма) */
					SkillCometStrike(tank.client, target, MOLOTOV);
				}
				else
				{
					/* Умение: Взрывной камень (1-7 формы) */
					SkillCometStrike(tank.client, target, EXPLODE);
				}
			}
		}
		if(StrEqual(weapon, "melee") && target == tank.client)
		{
			if(sm_lastboss_enable_steel.IntValue)
			{
				if(tank.form == FORMTWO)
				{
					/* Умение: Стальная кожа (только 2 форма) */
					EmitSoundToClient(attacker, SOUND_STEEL);
					SetEntityHealth(tank.client, (GetEventInt(event,"dmg_health")+GetEventInt(event,"health")));
					g_aTanks.SetArray(tankIndex, tank);
				}
			}
			if(tank.form == FORMFOUR)
			{
				int random = GetRandomInt(1, 4);
				if(random == 1)
				{
					ForceWeaponDrop(attacker);
					EmitSoundToClient(attacker, SOUND_DEAD);
				}
			}
			if(sm_lastboss_enable_gush.IntValue)
			{
				if(tank.form == FORMEIGHT)
				{
					/* Умение: Огненный поток (только 8 форма) */
					SkillFlameGush(tank.client, attacker);
				}
			}
		}
	}
	return Plugin_Continue;
}

void SkillEarthQuake(int tankClient, int target)
{
	float Pos[3], tPos[3];
	
	if(IsPlayerIncapped(target))
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(i == tankClient)
				continue;
			if(!IsClientInGame(i) || GetClientTeam(i) != 2)
				continue;
			GetClientAbsOrigin(tankClient, Pos);
			GetClientAbsOrigin(i, tPos);
			if(GetVectorDistance(tPos, Pos) < sm_lastboss_quake_radius.FloatValue)
			{
				EmitSoundToClient(i, SOUND_QUAKE);
				ScreenShake(i, 50.0);
				Smash(tankClient, i, sm_lastboss_quake_force.FloatValue, 1.0, 1.5);
			}
		}
	}
}

void SkillDreadClaw(int tankClient, int target)
{
	int tankIndex = FindTankIndex(tankClient);
	if (tankIndex == -1) return;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);
	
	tank.visibility = sm_lastboss_dreadrate.IntValue;
	g_aTanks.SetArray(tankIndex, tank);
	
	CreateTimer(sm_lastboss_dreadinterval.FloatValue, DreadTimer, target);
	EmitSoundToAll(SOUND_DCLAW, target);
	ScreenFade(target, 0, 0, 0, tank.visibility, 0, 0);
}

void SkillGravityClaw(int tankClient, int target)
{
	SetEntityGravity(target, 0.3);
	CreateTimer(sm_lastboss_gravityinterval.FloatValue, GravityTimer, target);
	EmitSoundToAll(SOUND_GCLAW, target);
	ScreenFade(target, 0, 0, 100, 80, 4000, 1);
	ScreenShake(target, 30.0);
}

void SkillFreezeClaw(int tankClient, int target)
{
	int tankIndex = FindTankIndex(tankClient);
	if (tankIndex == -1) return;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);
	
	tank.freeze[target] = ON;
	g_aTanks.SetArray(tankIndex, tank);
	
	FreezePlayer(target, sm_lastboss_freezetime.FloatValue);
	CreateTimer(sm_lastboss_freezeinterval.FloatValue, FreezeTimer, target);
}

void SkillLazyClaw(int tankClient, int target)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(i == tankClient)
			continue;
		if(!IsClientInGame(i) || GetClientTeam(i) != 2)
			continue;
		if(GetEntProp(i, Prop_Send, "m_zombieClass") != 8)
		{
			LazyPlayer(i);
		}
	}
}

void SkillRabiesClaw(int tankClient, int target)
{
	int tankIndex = FindTankIndex(tankClient);
	if (tankIndex == -1) return;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);
	
	tank.Rabies[target] = sm_lastboss_rabiestime.IntValue;
	tank.Toxin[target] = sm_lastboss_rabiestime.IntValue;
	g_aTanks.SetArray(tankIndex, tank);
	
	CreateTimer(1.0, RabiesTimer, target);
	CreateTimer(1.0, Toxin_Timer, target);
	EmitSoundToAll(SOUND_ROAR, target);
}

void SkillBombClaw(int tankClient, int target)
{
	float Pos[3];
	int tankIndex = FindTankIndex(tankClient);
	if (tankIndex == -1) return;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || GetClientTeam(i) != 2)
			continue;
		GetClientAbsOrigin(i, Pos);
		if(GetVectorDistance(Pos, tank.trsPos[target]) < sm_lastboss_bombradius.FloatValue)
		{
			DamageEffect(i, sm_lastboss_bombdamage.FloatValue);
		}
	}
	EmitSoundToAll(SOUND_BOMBARD, target);
	ScreenShake(target, 100.0);

	/* Взрыв */
	LittleFlower(Pos, EXPLODE);

	/* Отбрасывание */
	PushAway(tankClient, target, sm_lastboss_bombardforce.FloatValue, sm_lastboss_bombradius.FloatValue, 0.5);
}

void SkillBurnClaw(int tankClient, int target)
{
	EmitSoundToAll(SOUND_BCLAW, target);
	ScreenFade(target, 200, 0, 0, 150, 80, 1);
	ScreenShake(target, 50.0);
}

void SkillCometStrike(int tankClient, int target, int type)
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

void SkillFlameGush(int tankClient, int target)
{
	float pos[3];

	SkillBurnClaw(tankClient, target);
	LavaDamage(target);
	GetClientAbsOrigin(tankClient, pos);
	LittleFlower(pos, MOLOTOV);
}

void SkillCallOfAbyss(int tankClient)
{
	int tankIndex = FindTankIndex(tankClient);
	if (tankIndex == -1) return;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);
	
	/* Остановка движения и защита от урона */
	SetEntityMoveType(tank.client, MOVETYPE_NONE);
	SetEntProp(tank.client, Prop_Data, "m_takedamage", 0, 1);
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsValidEntity(i) || !IsClientInGame(i) || GetClientTeam(i) != SURVIVOR)
			continue;
		EmitSoundToClient(i, SOUND_HOWL);
		ScreenShake(i, 20.0);
	}
	
	/* Событие паники */
	if((tank.form == FORMEIGHT && sm_lastboss_enable_abyss.IntValue == 1) || sm_lastboss_enable_abyss.IntValue == 2)
	{
		TriggerPanicEvent();
	}
	
	/* Через 5 секунд смена формы и возобновление движения */
	CreateTimer(5.0, HowlTimer, tank.client);
}

public Action TankUpdate(Handle timer, int client)
{
	int tankIndex = FindTankIndex(client);
	if (tankIndex == -1) return Plugin_Stop;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);

	if (!IsValidEntity(tank.client) || !IsClientInGame(tank.client))
	{
		if (tank.timer != null) {
			KillTimer(tank.timer);
			tank.timer = null;
		}
		g_aTanks.Erase(tankIndex);
		return Plugin_Stop;
	}

	int iCurrentHealth = GetClientHealth(tank.client);
	
	// Определяем текущую фазу на основе оставшегося здоровья
	float healthPercent = float(iCurrentHealth) / float(tank.startHealth);
	int form_next = tank.form;

	if (healthPercent > 0.8) form_next = FORMONE;
	else if (healthPercent > 0.7) form_next = FORMTWO;
	else if (healthPercent > 0.6) form_next = FORMTHREE;
	else if (healthPercent > 0.5) form_next = FORMFOUR;
	else if (healthPercent > 0.4) form_next = FORMFIVE;
	else if (healthPercent > 0.3) form_next = FORMSIX;
	else if (healthPercent > 0.2) form_next = FORMSEVEN;
	else form_next = FORMEIGHT;

	// Если фаза изменилась - обновляем параметры
	if (form_next != tank.form)
	{
		tank.form = form_next;
		g_aTanks.SetArray(tankIndex, tank);
		SetParameter(tank.client, form_next);
	}

	return Plugin_Continue;
}

void SetParameter(int client, int form_next)
{
	int tankIndex = FindTankIndex(client);
	if (tankIndex == -1) return;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);
	
	int force;
	float speed;
	char color[32];
	
	if(form_next != FORMONE)
	{
		if(sm_lastboss_enable_abyss.IntValue)
		{
			/* Умение: Зов Бездны (Рев и вызов паники) */
			SkillCallOfAbyss(client);
		}
		
		/* Умение: Очищение (гасит огонь) */
		ExtinguishEntity(client);
		
		/* Эффект при смене формы */
		AttachParticle(client, PARTICLE_SPAWN);
		for(int j = 1; j <= MaxClients; j++)
		{
			if(!IsClientInGame(j) || GetClientTeam(j) != 2)
				continue;
			EmitSoundToClient(j, SOUND_CHANGE);
			ScreenFade(j, 200, 200, 255, 255, 100, 1);
		}
	}
	
	/* Настройки для каждой формы */
	switch(form_next)
	{
		case FORMONE:
		{
			force = sm_lastboss_force_first.IntValue;
			speed = sm_lastboss_speed_first.FloatValue;
			sm_lastboss_color_first.GetString(color, sizeof(color));
			
			/* Умение: Фатальное зеркало (Телепорт к выжившим) */
			if(sm_lastboss_enable_warp.IntValue)
			{
				CreateTimer(3.0, GetSurvivorPosition, client, TIMER_REPEAT);
				CreateTimer(sm_lastboss_warp_interval.FloatValue, FatalMirror, client, TIMER_REPEAT);
			}
		}
		case FORMTWO:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_SECOND);
			force = sm_lastboss_force_second.IntValue;
			speed = sm_lastboss_speed_second.FloatValue;
			sm_lastboss_color_second.GetString(color, sizeof(color));
			
			/* Увеличение веса */
			SetEntityGravity(client, sm_lastboss_weight_second.FloatValue);
		}
		case FORMTHREE:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_THIRD);
			force = sm_lastboss_force_third.IntValue;
			speed = sm_lastboss_speed_third.FloatValue;
			sm_lastboss_color_third.GetString(color, sizeof(color));
		}
		case FORMFOUR:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_FOURTH);
			force = sm_lastboss_force_fourth.IntValue;
			speed = sm_lastboss_speed_fourth.FloatValue;
			sm_lastboss_color_fourth.GetString(color, sizeof(color));
			SetEntityGravity(client, 1.0);
			
			/* Прикрепление частиц */
			CreateTimer(0.8, ParticleTimer, client, TIMER_REPEAT);
			
			/* Умение: Стелс-кожа */
			if(sm_lastboss_enable_stealth.IntValue)
				CreateTimer(sm_lastboss_stealth_fourth.FloatValue, StealthTimer, client);
		}
		case FORMFIVE:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_FIFTH);
			force = sm_lastboss_force_fifth.IntValue;
			speed = sm_lastboss_speed_fifth.FloatValue;
			sm_lastboss_color_fifth.GetString(color, sizeof(color));
		}
		case FORMSIX:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_SIXTH);
			force = sm_lastboss_force_sixth.IntValue;
			speed = sm_lastboss_speed_sixth.FloatValue;
			sm_lastboss_color_sixth.GetString(color, sizeof(color));
		}
		case FORMSEVEN:
		{
			if(sm_lastboss_enable_announce.IntValue)
				PrintToChatAll(MESSAGE_SEVENTH);
			force = sm_lastboss_force_seventh.IntValue;
			speed = sm_lastboss_speed_seventh.FloatValue;
			sm_lastboss_color_seventh.GetString(color, sizeof(color));
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
			SetEntityGravity(client, 1.0);
			
			/* Поджигание */
			IgniteEntity(client, 9999.9);
			
			/* Умение: Безумный прыжок */
			if(sm_lastboss_enable_jump.IntValue)
				CreateTimer(sm_lastboss_jumpinterval_eighth.FloatValue, JumpingTimer, client, TIMER_REPEAT);
				
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
	
	/* Установка силы */
	FindConVar("z_tank_throw_force").SetInt(force, true, true);
	
	/* Установка скорости */
	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed);
	
	/* Установка цвета */
	SetEntityRenderMode(client, view_as<RenderMode>(0));
	DispatchKeyValue(client, "rendercolor", color);
}

public Action ParticleTimer(Handle timer, int client)
{
	int tankIndex = FindTankIndex(client);
	if (tankIndex == -1) return Plugin_Stop;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);
		
	if(tank.form == FORMFOUR)
		AttachParticle(client, PARTICLE_FOURTH);
	else if(tank.form == FORMEIGHT)
		AttachParticle(client, PARTICLE_EIGHTH);
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action GravityTimer(Handle timer, any target)
{
	if(IsValidClient(target))
		SetEntityGravity(target, 1.0);
	return Plugin_Stop;
}

public Action JumpingTimer(Handle timer, int client)
{
	int tankIndex = FindTankIndex(client);
	if (tankIndex == -1) return Plugin_Stop;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);

	if(tank.form == FORMEIGHT && IsValidEntity(tank.client) && IsClientInGame(tank.client))
	{
		AddVelocity(tank.client, sm_lastboss_jumpheight_eighth.FloatValue);
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action StealthTimer(Handle timer, int client)
{
	int tankIndex = FindTankIndex(client);
	if (tankIndex == -1) return Plugin_Stop;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);

	if(tank.form == FORMFOUR)
	{
		tank.alpharate = 255;
		g_aTanks.SetArray(tankIndex, tank);
		Remove(tank.client);
	}
	return Plugin_Stop;
}

public Action DreadTimer(Handle timer, any target)
{
	if(IsValidSurv(target))
	{
		// Находим все танки, которые могли вызвать эффект
		for (int i = 0; i < g_aTanks.Length; i++)
		{
			TankData tank;
			g_aTanks.GetArray(i, tank);
			
			if (tank.form == FORMFOUR)
			{
				tank.visibility -= 8;
				if(tank.visibility < 0) tank.visibility = 0;
				ScreenFade(target, 0, 0, 0, tank.visibility, 0, 1);
				g_aTanks.SetArray(i, tank);
				
				if(tank.visibility <= 0)
				{
					tank.visibility = 0;
					g_aTanks.SetArray(i, tank);
					return Plugin_Stop;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action FreezeTimer(Handle timer, any target)
{
	if(IsValidSurv(target))
	{
		EmitSoundToAll(SOUND_DEFROST, target);
		SetEntityMoveType(target, MOVETYPE_WALK);
		SetEntityRenderColor(target, 255, 255, 255, 255);
		ScreenFade(target, 0, 0, 0, 0, 0, 1);
		
		// Обнуляем флаг заморозки для всех танков
		for (int i = 0; i < g_aTanks.Length; i++)
		{
			TankData tank;
			g_aTanks.GetArray(i, tank);
			tank.freeze[target] = OFF;
			g_aTanks.SetArray(i, tank);
		}
	}
	return Plugin_Stop;
}

public Action RabiesTimer(Handle timer, any target)
{
	if(IsValidSurv(target))
	{
		bool stillAffected = false;
		
		// Проверяем все танки на наличие эффекта бешенства
		for (int i = 0; i < g_aTanks.Length; i++)
		{
			TankData tank;
			g_aTanks.GetArray(i, tank);
			
			if (tank.Rabies[target] > 0)
			{
				stillAffected = true;
				RabiesDamage(target);
				tank.Rabies[target] -= 1;
				g_aTanks.SetArray(i, tank);
				EmitSoundToAll(SOUND_RABIES, target);
				
				if (tank.Rabies[target] > 0)
				{
					CreateTimer(1.0, RabiesTimer, target);
				}
			}
		}
		
		if (!stillAffected)
		{
			return Plugin_Stop;
		}
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

public Action Toxin_Timer(Handle timer, any target)
{
	if(IsValidSurv(target))
	{
		bool stillAffected = false;
		
		// Проверяем все танки на наличие токсина
		for (int i = 0; i < g_aTanks.Length; i++)
		{
			TankData tank;
			g_aTanks.GetArray(i, tank);
			
			if (tank.Toxin[target] > 0)
			{
				stillAffected = true;
				KillToxin(target);
				tank.Toxin[target]--;
				g_aTanks.SetArray(i, tank);
				
				if (tank.Toxin[target] > 0)
				{
					CreateTimer(1.0, Toxin_Timer, target);
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
		}
		
		if (!stillAffected)
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Stop;
}

public Action HowlTimer(Handle timer, int client)
{
	if(IsValidEntity(client))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	}
	return Plugin_Stop;
}

public Action WarpTimer(Handle timer, int client)
{
	int tankIndex = FindTankIndex(client);
	if (tankIndex == -1) return Plugin_Stop;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);

	if(IsValidEntity(tank.client) && IsClientInGame(tank.client))
	{
		float pos[3];
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == SURVIVOR)
				EmitSoundToClient(i, SOUND_WARP);
		}
		GetClientAbsOrigin(tank.client, pos);
		ShowParticle(pos, PARTICLE_WARP, 2.0);
		TeleportEntity(tank.client, tank.ftlPos, NULL_VECTOR, NULL_VECTOR);
		ShowParticle(tank.ftlPos, PARTICLE_WARP, 2.0);
		SetEntityMoveType(tank.client, MOVETYPE_WALK);
		SetEntProp(tank.client, Prop_Data, "m_takedamage", 2, 1);
	}
	return Plugin_Stop;
}

public Action GetSurvivorPosition(Handle timer, int client)
{
	int tankIndex = FindTankIndex(client);
	if (tankIndex == -1) return Plugin_Stop;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);

	if(IsValidEntity(tank.client) && IsClientInGame(tank.client))
	{
		int count = 0;
		int idAlive[MAXPLAYERS+1];
		
		for(int i = 1; i <= MaxClients; i++)
		{
			if(!IsValidEntity(i) || !IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != SURVIVOR)
				continue;
			idAlive[count] = i;
			count++;
		}
		if(count == 0) return Plugin_Stop;
		int clientNum = GetRandomInt(0, count-1);
		GetClientAbsOrigin(idAlive[clientNum], tank.ftlPos);
		g_aTanks.SetArray(tankIndex, tank);
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;
	}
}

public Action FatalMirror(Handle timer, int client)
{
	int tankIndex = FindTankIndex(client);
	if (tankIndex == -1) return Plugin_Stop;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);

	if(IsValidEntity(tank.client) && IsClientInGame(tank.client))
	{
		/* Остановка движения и защита от урона */
		SetEntityMoveType(tank.client, MOVETYPE_NONE);
		SetEntProp(tank.client, Prop_Data, "m_takedamage", 0, 1);
		
		/* Телепортация к позиции выжившего 2 секунды назад */
		CreateTimer(1.5, WarpTimer, tank.client);
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;
	}
}

public Action Remove(int ent)
{
	if(IsValidEntity(ent))
	{
		CreateTimer(0.1, FadeOut, ent, TIMER_REPEAT);
		SetEntityRenderMode(ent, RENDER_TRANSCOLOR);
	}
	return Plugin_Continue;
}

public Action FadeOut(Handle Timer, int ent)
{
	int tankIndex = FindTankIndex(ent);
	if (tankIndex == -1) return Plugin_Stop;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);

	if(!IsValidEntity(ent) || tank.form != FORMFOUR)
	{
		return Plugin_Stop;
	}
	tank.alpharate -= 2;
	if(tank.alpharate < 0) tank.alpharate = 0;
	SetEntityRenderMode(ent, RENDER_TRANSCOLOR);
	SetEntityRenderColor(ent, 80, 80, 255, tank.alpharate);
	g_aTanks.SetArray(tankIndex, tank);
	
	if(tank.alpharate <= 0)
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
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
	/* Создать огонь (type=0) или взрыв (type=1) */
	int entity = CreateEntityByName("prop_physics");
	if(entity != -1)
	{
		pos[2] += 10.0;
		if (type == 0)
			/* fire */
			DispatchKeyValue(entity, "model", ENTITY_GASCAN);
		else
			/* explode */
			DispatchKeyValue(entity, "model", ENTITY_PROPANE);
		DispatchSpawn(entity);
		SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "break");
	}
}

void Smash(int client, int target, float power, float powHor, float powVec)
{
	/* Отбросить цель */
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

void FreezePlayer(int target, float Time)
{
	if(IsValidSurv(target))
	{
		SetEntityMoveType(target, MOVETYPE_NONE);
		SetEntityRenderColor(target, 0, 128, 255, 135);
		EmitSoundToAll(SOUND_FREEZE, target);
		
		// Устанавливаем флаг заморозки для всех танков
		for (int i = 0; i < g_aTanks.Length; i++)
		{
			TankData tank;
			g_aTanks.GetArray(i, tank);
			tank.freeze[target] = ON;
			g_aTanks.SetArray(i, tank);
		}
		
		CreateTimer(Time, FreezeTimer, target);
	}
}

void LazyPlayer(int target)
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

public Action Quick(Handle timer, int target)
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

void RabiesDamage(int target)
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

void LavaDamage(int target)
{
	char dmg_lava[16];
	char dmg_type_lava[16];
	IntToString((1 << 17),dmg_lava,sizeof(dmg_type_lava));
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

void PushAway(int tankClient, int target, float force, float radius, float duration)
{
	int tankIndex = FindTankIndex(tankClient);
	if (tankIndex == -1) return;
	
	TankData tank;
	g_aTanks.GetArray(tankIndex, tank);

	int push = CreateEntityByName("point_push");
	DispatchKeyValueFloat (push, "magnitude", force);
	DispatchKeyValueFloat (push, "radius", radius);
	SetVariantString("spawnflags 24");
	AcceptEntityInput(push, "AddOutput");
	DispatchSpawn(push);
	TeleportEntity(push, tank.trsPos[target], NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(push, "Enable", -1, -1);
	CreateTimer(duration, DeletePushForce, push);
}

void ShowParticle(float pos[3], const char[] particlename, float Time)
{
	/* Показать эффект частиц */
	int particle = CreateEntityByName("info_particle_system");
	if(particle != -1)
	{
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(Time, DeleteParticles, particle);
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

public Action DeleteParticles(Handle timer, int particle)
{
	/* Удалить частицы */
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
	/* Предзагрузка частиц */
	int particle = CreateEntityByName("info_particle_system");
	if(particle != -1)
	{
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(0.01, DeleteParticles, particle);
	}
}

public Action DeletePushForce(Handle timer, int ent)
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

// Найти индекс танка в массиве по его client index
int FindTankIndex(int client)
{
	for (int i = 0; i < g_aTanks.Length; i++)
	{
		TankData tank;
		g_aTanks.GetArray(i, tank);
		if (tank.client == client)
		{
			return i;
		}
	}
	return -1;
}

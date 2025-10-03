#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.1"

public Plugin myinfo = 
{
    name = "[L4D AND L4D2] Archangelo Tank",
    author = "Ernecio/ReBuild by Jasf",
    description = "Provides the Tanks special effects similar to those of an Archangel.",
    version = PLUGIN_VERSION,
    url = "https://steamcommunity.com/groups/American-Infernal"
};

// ConVars
ConVar g_hTankEnabled;
ConVar g_hTankBeacon;

// Variables
bool g_bL4D2;
bool g_bTankEnabled;
bool g_bTankBeacon;
int g_iLightIndex[MAXPLAYERS + 1];
int g_iBeamSprite;
int g_iHaloSprite;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion engine = GetEngineVersion();
    
    if (engine != Engine_Left4Dead && engine != Engine_Left4Dead2)
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead and Left 4 Dead 2.");
        return APLRes_SilentFailure;
    }
    
    g_bL4D2 = (engine == Engine_Left4Dead2);
    return APLRes_Success;
}

public void OnPluginStart()
{
    CreateConVar("tank_lightning_version", PLUGIN_VERSION, "Tank Lightning Version", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    
    g_hTankEnabled = CreateConVar("l4d_tank_archangelo_enabled", "1", "Enables/Disables Archangelo Tank (1 = Enabled, 0 = Disabled)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_hTankBeacon = CreateConVar("l4d_tank_beacon", "1", "Enables/Disables Beacon (1 = Enabled, 0 = Disabled)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    
    g_bTankEnabled = g_hTankEnabled.BoolValue;
    g_bTankBeacon = g_hTankBeacon.BoolValue;
    
    g_hTankEnabled.AddChangeHook(OnConVarChanged);
    g_hTankBeacon.AddChangeHook(OnConVarChanged);
    
    HookEvent("tank_spawn", Event_TankSpawn);
    HookEvent("player_death", Event_PlayerDeath);
    
    AutoExecConfig(true, "l4d_archangelo_tank");
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_bTankEnabled = g_hTankEnabled.BoolValue;
    g_bTankBeacon = g_hTankBeacon.BoolValue;
}

public void OnMapStart()
{
    PrecacheParticle("mini_fireworks");
    PrecacheParticle("barrel_fly_embers");
    PrecacheParticle("electrical_arc_01_parent");
    
    g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
    g_iHaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
}

public void OnClientDisconnect(int client)
{
    DeleteLight(client);
}

// Events
public void Event_TankSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    
    if (!g_bTankEnabled || client <= 0 || !IsClientInGame(client))
        return;
    
    CreateTimer(0.1, Timer_TankSpawn, client, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(0.5, Timer_AttachParticles, client, TIMER_FLAG_NO_MAPCHANGE);
    
    if (g_bTankBeacon)
    {
        TimerBeacon(client);
    }
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    
    if (client > 0 && IsClientInGame(client) && IsTank(client))
    {
        DeleteLight(client);
    }
}

// Timers
public Action Timer_TankSpawn(Handle timer, any client)
{
    if (client > 0 && IsTank(client))
    {
        CreateTimer(0.8, Timer_DelayCreateLight, client, TIMER_FLAG_NO_MAPCHANGE);
    }
    return Plugin_Stop;
}

public Action Timer_AttachParticles(Handle timer, any client)
{
    if (IsTank(client))
    {
        AttachParticle(client, "mini_fireworks", 0.8, 75.0);
        AttachParticle(client, "barrel_fly_embers", 1.2, 15.0);
        AttachParticle(client, "electrical_arc_01_parent", 0.8, 30.0);
    }
    return Plugin_Stop;
}

public Action Timer_DelayCreateLight(Handle timer, any client)
{
    if (client > 0 && IsTank(client))
    {
        DeleteLight(client);
        
        float vOrigin[3] = {0.0, 0.0, 0.0};
        float vAngles[3] = {0.0, 0.0, 0.0};
        
        int entity = MakeLightDynamic(vOrigin, vAngles, client);
        if (entity != -1)
        {
            g_iLightIndex[client] = EntIndexToEntRef(entity);
        }
    }
    return Plugin_Stop;
}

public Action Timer_BeaconAttach(Handle timer, any client)
{
    if (IsClientInGame(client) && IsPlayerAlive(client))
    {
        CreateBeacon(client);
        return Plugin_Continue;
    }
    return Plugin_Stop;
}

public Action Timer_DeleteParticles(Handle timer, any entity)
{
    if (IsValidEntity(entity))
    {
        char classname[64];
        GetEdictClassname(entity, classname, sizeof(classname));
        
        if (StrEqual(classname, "info_particle_system"))
        {
            AcceptEntityInput(entity, "Kill");
        }
    }
    return Plugin_Stop;
}

// Stock Functions
bool IsTank(int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client))
        return false;
    
    if (GetClientTeam(client) != 3)
        return false;
    
    int class = GetEntProp(client, Prop_Send, "m_zombieClass");
    int tankClass = g_bL4D2 ? 8 : 5;
    
    return (class == tankClass);
}

void DeleteLight(int client)
{
    int entity = g_iLightIndex[client];
    g_iLightIndex[client] = 0;
    
    if (IsValidEntRef(entity))
    {
        AcceptEntityInput(entity, "Kill");
    }
}

bool IsValidEntRef(int entity)
{
    if (entity && EntRefToEntIndex(entity) != -1)
    {
        return true;
    }
    return false;
}

void AttachParticle(int entity, const char[] particleName, float lifetime, float zOffset)
{
    if (entity <= 0 || !IsValidEntity(entity))
        return;
    
    int particle = CreateEntityByName("info_particle_system");
    if (particle == -1 || !IsValidEntity(particle))
        return;
    
    float pos[3];
    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
    pos[2] += zOffset;
    
    TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
    
    char tName[32];
    Format(tName, sizeof(tName), "target%d", entity);
    
    DispatchKeyValue(entity, "targetname", tName);
    DispatchKeyValue(particle, "effect_name", particleName);
    DispatchKeyValue(particle, "parentname", tName);
    
    DispatchSpawn(particle);
    ActivateEntity(particle);
    
    SetVariantString(tName);
    AcceptEntityInput(particle, "SetParent", particle, particle);
    
    AcceptEntityInput(particle, "Start");
    
    CreateTimer(lifetime, Timer_DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
}

void CreateBeacon(int client)
{
    if (client <= 0 || !IsClientInGame(client))
        return;
    
    int color[4];
    color[0] = GetRandomInt(1, 255);
    color[1] = GetRandomInt(1, 255);
    color[2] = GetRandomInt(1, 255);
    color[3] = 255;
    
    float position[3];
    GetClientAbsOrigin(client, position);
    position[2] += 135.0;
    
    TE_SetupBeamRingPoint(position, 10.0, 50.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.3, 2.0, 1.5, color, 300, 0);
    TE_SendToAll();
    
    if (IsTank(client) && g_bTankBeacon)
    {
        CreateTimer(0.2, Timer_BeaconAttach, client, TIMER_FLAG_NO_MAPCHANGE);
    }
}

void TimerBeacon(int client)
{
    CreateTimer(0.2, Timer_BeaconAttach, client, TIMER_FLAG_NO_MAPCHANGE);
}

int MakeLightDynamic(float pos[3], float ang[3], int parent)
{
    int entity = CreateEntityByName("light_dynamic");
    if (entity == -1)
    {
        LogError("Failed to create 'light_dynamic'");
        return -1;
    }
    
    char sBuffer[32];
    Format(sBuffer, sizeof(sBuffer), "%i %i %i 255", 
        GetRandomInt(0, 255), 
        GetRandomInt(0, 255), 
        GetRandomInt(0, 255));
    
    DispatchKeyValue(entity, "_light", sBuffer);
    DispatchKeyValue(entity, "brightness", "1");
    DispatchKeyValueFloat(entity, "spotlight_radius", 75.0);
    DispatchKeyValueFloat(entity, "distance", 255.0);
    DispatchKeyValue(entity, "style", "0");
    
    DispatchSpawn(entity);
    AcceptEntityInput(entity, "TurnOn");
    
    if (parent > 0)
    {
        SetVariantString("!activator");
        AcceptEntityInput(entity, "SetParent", parent);
    }
    
    TeleportEntity(entity, pos, ang, NULL_VECTOR);
    return entity;
}

void PrecacheParticle(const char[] particleName)
{
    int particle = CreateEntityByName("info_particle_system");
    if (particle != -1 && IsValidEntity(particle))
    {
        DispatchKeyValue(particle, "effect_name", particleName);
        DispatchSpawn(particle);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "Start");
        CreateTimer(0.1, Timer_DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
    }
}

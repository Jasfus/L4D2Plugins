#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define PLUGIN_VERSION "10.0.1"

public Plugin myinfo = 
{
	name = "[L4D & L4D2] No Friendly-fire",
	author = "Psyk0tik (cutted by BloodyBlade)",
	description = "Отключает дружественный огонь с улучшенной структурой кода",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=302822"
};

bool g_bLeft4Dead2 = false;

#define MODEL_FIREWORK "models/props_junk/explosive_box001.mdl"
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_OXYGEN "models/props_equipment/oxygentank01.mdl"
#define MODEL_PROPANE "models/props_junk/propanecanister001a.mdl"

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine == Engine_Left4Dead)
	{
		g_bLeft4Dead2 = false;
	}
	else if (evEngine == Engine_Left4Dead2)
	{
		g_bLeft4Dead2 = true;
	}
	else
	{
		strcopy(error, err_max, "Данный плагин работает только в Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

public void OnPluginStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	if(client > 0)
	{
		SDKHook(client, SDKHook_OnTakeDamage, OnTakePlayerDamage);
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (entity > MaxClients && IsValidEntity(entity) && IsValidEdict(entity))
	{
		// Хук для физических объектов
		if (StrEqual(classname, "physics_prop") || StrEqual(classname, "prop_physics"))
		{
			char sModel[64];
			GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
			if (StrEqual(sModel, MODEL_OXYGEN) || StrEqual(sModel, MODEL_PROPANE) || 
				StrEqual(sModel, MODEL_GASCAN) || (g_bLeft4Dead2 && StrEqual(sModel, MODEL_FIREWORK)))
			{
				SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
			}
		}
		// Хук для топливных баков
		else if (StrEqual(classname, "prop_fuel_barrel") || StrEqual(classname, "prop_fuel_barrel_piece"))
		{
			SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
		}
	}
}

Action OnTakePlayerDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidClient(victim) && IsValidClient(attacker) && GetClientTeam(victim) == GetClientTeam(attacker))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

Action OnTakePropDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidClient(attacker) && GetClientTeam(attacker) == 2 && IsFakeClient(attacker))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}

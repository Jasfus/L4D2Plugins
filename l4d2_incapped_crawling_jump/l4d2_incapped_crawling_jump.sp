#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define PLUGIN_VERSION 		"2.9"
#define CVAR_FLAGS FCVAR_NOTIFY

#define MODEL_COACH "models/survivors/survivor_coach.mdl"
#define MODEL_NICK "models/survivors/survivor_gambler.mdl"
#define EF_BONEMERGE (1 << 0)
#define EF_NOSHADOW (1 << 4)
#define EF_BONEMERGE_FASTCULL (1 << 7)
#define EF_PARENT_ANIMATES (1 << 9)

//LMC
native int LMC_GetClientOverlayModel(int iClient);
//LMC

ConVar g_hCvarAllow, g_hCvarCrawl, g_hCvarCrazy, g_hCvarGlow, g_hCvarHint, g_hCvarHintS, g_hCvarMPGameMode, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarRate, g_hCvarSpeed, g_hCvarSpeeds, g_hCvarView;
ConVar g_hCvarJumpEnabled, g_hCvarJumpForce; // Новые ConVar для прыжков
int g_iClone[MAXPLAYERS + 1] = {0, ...}, g_iDisplayed[MAXPLAYERS + 1] = {0, ...}, g_iHint = 0, g_iHints = 0, g_iRate = 0, g_iSpeed = 0, g_iView = 0;
bool g_bCvarAllow = false, g_bMapStarted = false, g_bCrazy = false, g_bGlow = false, g_bRoundOver = false, g_bTranslation = false, g_bJumpEnabled = false;
float g_fClientWait[MAXPLAYERS + 1] = {0.0, ...}, g_fJumpForce = 0.0;

// Переменные для прыжков
float g_fNextJump[MAXPLAYERS + 1] = {0.0, ...}; // Время следующего прыжка

// ====================================================================================================
//					PLUGIN LOAD
// ====================================================================================================
//LMC
bool bLMC_Available = false;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if (test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	MarkNativeAsOptional("LMC_GetClientOverlayModel");
	return APLRes_Success;
}

public void OnLibraryAdded(const char[] sName)
{
	if (strcmp(sName, "LMCCore") == 0)
		bLMC_Available = true;
}

public void OnLibraryRemoved(const char[] sName)
{
	if (strcmp(sName, "LMCCore") == 0)
		bLMC_Available = false;
}
//LMC

// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D2] Incapped Crawling with Animation and Multiple Jumps",
	author = "SilverShot, mod by Lux, extended by Jasf",
	description = "Allows incapped survivors to crawl, sets crawling animation, and allows multiple jumps while crawling.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=137381"
}

public void OnPluginStart()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, PLATFORM_MAX_PATH, "translations/incappedcrawlingjump.phrases.txt");
	
	if (!FileExists(sPath))
		g_bTranslation = false;
	else
	{
		LoadTranslations("incappedcrawlingjump.phrases");
		g_bTranslation = true;
	}
	
	g_hCvarAllow = CreateConVar("l4d2_crawling", "1", "0=Plugin off, 1=Plugin on.", CVAR_FLAGS);
	g_hCvarCrazy = CreateConVar("l4d2_crawling_crazy", "0", "0=Off. 1=Use crazy faces (original before version 2.0).", CVAR_FLAGS);
	g_hCvarGlow = CreateConVar("l4d2_crawling_glow", "1", "0=Disables survivor glow on crawling, 1=Enables glow if not realism.", CVAR_FLAGS);
	g_hCvarHint = CreateConVar("l4d2_crawling_hint", "2", "0=Disables, 1=Chat text, 2=Hint box.", CVAR_FLAGS);
	g_hCvarHintS = CreateConVar("l4d2_crawling_hint_num", "2", "How many times to display hints.", CVAR_FLAGS);
	g_hCvarModes = CreateConVar("l4d2_crawling_modes", "", "Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS);
	g_hCvarModesOff = CreateConVar("l4d2_crawling_modes_off", "", "Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS);
	g_hCvarModesTog = CreateConVar("l4d2_crawling_modes_tog", "0", "Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS);
	g_hCvarRate = CreateConVar("l4d2_crawling_rate", "150", "Sets the playback speed of the crawling animation.", CVAR_FLAGS);
	g_hCvarSpeeds = CreateConVar("l4d2_crawling_speed", "150", "Changes 'survivor_crawl_speed' cvar.", CVAR_FLAGS);
	g_hCvarView = CreateConVar("l4d2_crawling_view", "1", "0=Firstperson view when crawling, 1=Thirdperson view when crawling. 2=Firstperson view when crawling and hides own animation.", CVAR_FLAGS);
	g_hCvarJumpEnabled = CreateConVar("l4d2_crawling_jump_enabled", "1", "Enable/disable jumping while crawling. 0=Disable, 1=Enable.", CVAR_FLAGS);
	g_hCvarJumpForce = CreateConVar("l4d2_crawling_jump_force", "300.0", "Jump force while crawling.", CVAR_FLAGS);
	
	CreateConVar("l4d2_crawling_version", PLUGIN_VERSION, "Incapped Crawling plugin version.", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	AutoExecConfig(true, "l4d2_incapped_crawling_jump");
	
	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarCrazy.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarGlow.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHint.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHintS.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarView.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarRate.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarSpeeds.AddChangeHook(ConVarChanged_Speed);
	g_hCvarJumpEnabled.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarJumpForce.AddChangeHook(ConVarChanged_Cvars);
	
	g_hCvarCrawl = FindConVar("survivor_allow_crawling");
	g_hCvarSpeed = FindConVar("survivor_crawl_speed");
}

public void OnPluginEnd()
{
	g_hCvarCrawl.IntValue = 0;

	for (int i = 1; i <= MaxClients; i++)
		if (IsValidClient(i))
			RemoveClone(i);
}

public void OnClientPutInServer(int client)
{
	g_iDisplayed[client] = 0;
}

// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnMapStart()
{
	g_bMapStarted = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
}

public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Allow(ConVar convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void ConVarChanged_Speed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_iSpeed = g_hCvarSpeeds.IntValue;
	g_hCvarSpeed.IntValue = g_iSpeed;
}

void GetCvars()
{
	g_bCrazy = g_hCvarCrazy.BoolValue;
	g_bGlow = g_hCvarGlow.BoolValue;
	g_iHint = g_hCvarHint.IntValue;
	g_iHints = g_hCvarHintS.IntValue;
	g_iRate = g_hCvarRate.IntValue;
	g_iSpeed = g_hCvarSpeeds.IntValue;
	g_iView = g_hCvarView.IntValue;
	g_bJumpEnabled = g_hCvarJumpEnabled.BoolValue;
	g_fJumpForce = g_hCvarJumpForce.FloatValue;
	
	if (g_iHint > 2) g_iHint = 1; // Can no longer support instructor hints
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if (g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true)
	{
		g_bCvarAllow = true;
		HookEvents();
		g_hCvarCrawl.IntValue = 1;
		g_hCvarSpeed.IntValue = g_iSpeed;
	}
	else if (g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false))
	{
		g_bCvarAllow = false;
		UnhookEvents();
		g_hCvarCrawl.IntValue = 0;
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if (g_hCvarMPGameMode == null)
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if (iCvarModesTog != 0)
	{
		if (g_bMapStarted == false)
			return false;

		g_iCurrentMode = 0;

		int entity = CreateEntityByName("info_gamemode");
		if (IsValidEntity(entity))
		{
			DispatchSpawn(entity);
			HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "PostSpawnActivate");
			if (IsValidEntity(entity)) // Because sometimes "PostSpawnActivate" seems to kill the ent.
				RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
		}

		if (g_iCurrentMode == 0)
			return false;

		if (!(iCvarModesTog & g_iCurrentMode))
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModes.GetString(sGameModes, sizeof(sGameModes));
	if (sGameModes[0])
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if (StrContains(sGameModes, sGameMode, false) == -1)
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if (sGameModes[0])
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if (StrContains(sGameModes, sGameMode, false) != -1)
			return false;
	}

	return true;
}

void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if (strcmp(output, "OnCoop") == 0)
		g_iCurrentMode = 1;
	else if (strcmp(output, "OnSurvival") == 0)
		g_iCurrentMode = 2;
	else if (strcmp(output, "OnVersus") == 0)
		g_iCurrentMode = 4;
	else if (strcmp(output, "OnScavenge") == 0)
		g_iCurrentMode = 8;
}

// ====================================================================================================
//					EVENTS
// ====================================================================================================
void HookEvents()
{
	HookEvent("player_incapacitated", Event_Incapped); // Delay crawling by 1 second
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
}

void UnhookEvents()
{
	UnhookEvent("player_incapacitated", Event_Incapped);
	UnhookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	UnhookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
}

// ====================================================================================================
//					EVENT - ROUND START / END
// ====================================================================================================
void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundOver = false;
	CreateTimer(0.1, TimerRoundStart);
}

Action TimerRoundStart(Handle timer)
{
	if (g_bCvarAllow)
	{
		g_hCvarCrawl.IntValue = 1;
		g_hCvarSpeed.IntValue = g_iSpeed;
	}

	for (int i = 0; i < MAXPLAYERS; i++)
	{
		g_iClone[i] = 0;
	}

	return Plugin_Continue;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundOver = true;
	g_hCvarCrawl.IntValue = 0;
}

// ====================================================================================================
//					EVENT - INCAPACITATED
// ====================================================================================================
void Event_Incapped(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!IsFakeClient(client) && IsValidClient(client))
	{
		g_fClientWait[client] = GetGameTime() + 1.5;
		if (g_iHint && (g_iHint >= 3 || g_iDisplayed[client] < g_iHints))
			CreateTimer(1.5, TimerResetStart, GetClientUserId(client));
	}
	else if (GetClientTeam(client) == 3) // Tank bug with crawling
	{
		SetEntityMoveType(client, MOVETYPE_VPHYSICS);
	}
}

// Display hint message, allow crawling
Action TimerResetStart(Handle timer, any client)
{
	client = GetClientOfUserId(client);

	if (g_bRoundOver || !g_iHint || (g_iHint < 3 && g_iDisplayed[client] >= g_iHints) || !IsValidClient(client))
		return Plugin_Continue;

	g_iDisplayed[client]++;
	static char sBuffer[128];

	switch (g_iHint)
	{
		case 1: // Print to chat
		{
			if (g_bTranslation)
				Format(sBuffer, sizeof(sBuffer), "\x04[\x01Incapped Crawling\x04]\x01 %T", "Crawl", client);
			else
				Format(sBuffer, sizeof(sBuffer), "\x04[\x01Incapped Crawling\x04]\x01 Press FORWARD to crawl while incapped");

			PrintToChat(client, sBuffer);
		}

		case 2: // Display hint
		{
			if (g_bTranslation)
				Format(sBuffer, sizeof(sBuffer), "[Incapped Crawling] %T", "Crawl", client);
			else
				Format(sBuffer, sizeof(sBuffer), "[Incapped Crawling] - Press FORWARD to crawl while incapped");

			PrintHintText(client, sBuffer);
		}
	}

	return Plugin_Continue;
}

// ====================================================================================================
//					ON PLAYER RUN CMD
// ====================================================================================================
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	// Plugin enabled
	if (!g_bCvarAllow)
		return Plugin_Continue;

	if(GetEntPropEnt(client, Prop_Send, "m_reviveOwner") != -1)
	{
		RemoveClone(client);
	}
	if (IsNoIncapOrLedge(client))
	{
		RemoveClone(client);
	}
	// Incapped
	else 
	{
		// Если игрок нажимает кнопку прыжка
		if (g_bJumpEnabled && buttons & IN_JUMP)
		{
			// Проверяем, можно ли прыгать (задержка между прыжками)
			if (GetGameTime() >= g_fNextJump[client])
			{
				float vecVelocity[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", vecVelocity);
				vecVelocity[2] = g_fJumpForce; // Задаем вертикальную скорость
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);

				// Устанавливаем задержку перед следующим прыжком (например, 1 секунда)
				g_fNextJump[client] = GetGameTime() + 1.0;
			}

			// Сбрасываем кнопку прыжка, чтобы избежать множественных прыжков
			buttons &= ~IN_JUMP;
		}

		// Остальная логика для ползания
		if (buttons & IN_FORWARD)
		{
			if (!g_bRoundOver && GetGameTime() - g_fClientWait[client] >= 0.0 && IsValidClient(client) && !IsFakeClient(client))
			{
				if (g_iClone[client] == 0)
				{
					PlayAnim(client);
				}
			}
			else
			{
				buttons &= ~IN_FORWARD;
				RemoveClone(client);
			}
		}
		else
		{
			RemoveClone(client);
		}
	}

	return Plugin_Continue;
}
// ====================================================================================================
//					ANIMATION
// ====================================================================================================
Action PlayAnim(int client)
{
	// Prediction
	SendConVarValue(client, g_hCvarCrawl, "1");

	static char sModel[PLATFORM_MAX_PATH];
	GetEntPropString(client, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

	bool coach = sModel[29] == 'c'; // Coach

	// Create survivor clone
	int clone = CreateEntityByName(g_bCrazy ? "prop_dynamic" : "commentary_dummy");
	if (clone == -1)
	{
		LogError("Failed to create %s '%s' (%N)", g_bCrazy ? "prop_dynamic" : "commentary_dummy", sModel, client);
		return Plugin_Continue;
	}

	if (coach) SetEntityModel(clone, MODEL_NICK);
	else SetEntityModel(clone, sModel);

	g_iClone[client] = EntIndexToEntRef(clone); // Global clone ID

	// Attach to survivor
	SetVariantString("!activator");
	AcceptEntityInput(clone, "SetParent", client);
	SetVariantString("bleedout");
	AcceptEntityInput(clone, "SetParentAttachment");

	// Correct angles and origin
	float vPos[3], vAng[3];
	vPos[0] = -2.0;
	vPos[1] = -15.0;
	vPos[2] = -10.0;
	vAng[0] = -330.0;
	vAng[1] = -100.0;
	vAng[2] = 70.0;

	// Set angles and origin
	TeleportEntity(clone, vPos, vAng, NULL_VECTOR);

	// Set animation and playback rate
	SetEntPropFloat(clone, Prop_Send, "m_flPlaybackRate", float(g_iRate) / 15); // Default speed = 15, normal rate = 1.0

	// SetAnim
	SetVariantString("incap_crawl"); // "ACT_TERROR_INCAP_CRAWL" also works
	AcceptEntityInput(clone, "SetAnimation");

	//LMC
	int iEntity;
	if (bLMC_Available)
	{
		iEntity = LMC_GetClientOverlayModel(client);
		if (iEntity > MaxClients && IsValidEntity(iEntity))
		{
			SetEntityRenderMode(clone, RENDER_NONE);
			SetAttached(iEntity, clone);
		}
	}
	//LMC

	// Coach anim - Bone merge - Ignore if LMC handling.
	if (iEntity < 1)
	{
		int cloneCoach = CreateEntityByName(g_bCrazy ? "prop_dynamic" : "commentary_dummy");
		if (cloneCoach == -1)
		{
			LogError("Failed to create clone coach.");
			return Plugin_Continue;
		}

		SetEntityRenderMode(clone, RENDER_NONE); // Hide original clone.
		SetEntityModel(cloneCoach, sModel);
		SetEntProp(cloneCoach, Prop_Send, "m_fEffects", EF_BONEMERGE | EF_NOSHADOW | EF_PARENT_ANIMATES);

		// Attach to survivor
		SetVariantString("!activator");
		AcceptEntityInput(cloneCoach, "SetParent", clone);
	}

	// Make Survivor Invisible
	SetEntityRenderMode(client, RENDER_NONE);

	// Disable Glow
	if (!g_bGlow)
		SetEntProp(client, Prop_Send, "m_bSurvivorGlowEnabled", 0);

	// Thirdperson view
	if (g_iView == 1)
		GotoThirdPerson(client);
	else if (g_iView == 2)
		SDKHook(clone, SDKHook_SetTransmit, OnTransmit);

	return Plugin_Continue;
}

Action OnTransmit(int entity, int client)
{
	if (g_iClone[client]
		&& EntRefToEntIndex(g_iClone[client]) == entity
		&& GetEntProp(client, Prop_Send, "m_iObserverMode") == 0
		&& GetGameTime() > GetEntPropFloat(client, Prop_Send, "m_TimeForceExternalView"))
		return Plugin_Handled;

	return Plugin_Continue;
}

void GotoThirdPerson(int client)
{
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
}

void GotoFirstPerson(int client)
{
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", -1);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
}

bool IsValidClient(int client)
{
	if (client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2)
		return true;
	return false;
}

// ====================================================================================================
//					DELETE CLONE
// ====================================================================================================
void RemoveClone(int client)
{
	int clone = g_iClone[client];
	g_iClone[client] = 0;

	if (clone && EntRefToEntIndex(clone) != INVALID_ENT_REFERENCE)
	{
		// Prediction
		if (IsFakeClient(client) == false) SendConVarValue(client, g_hCvarCrawl, "0");

		//LMC
		if (bLMC_Available)
		{
			int iEntity;
			iEntity = LMC_GetClientOverlayModel(client);
			if (iEntity > MaxClients && IsValidEntity(iEntity))
			{
				SetAttached(iEntity, client);
			}
			else
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
			}
		}
		else
		{
			SetEntityRenderMode(client, RENDER_NORMAL);
		}
		//LMC

		RemoveEntity(clone);

		if (IsPlayerAlive(client))
		{
			if (g_iView == 1) // Firstperson view
				GotoFirstPerson(client);

			if (!g_bGlow) // Enable Glow
				SetEntProp(client, Prop_Send, "m_bSurvivorGlowEnabled", 1);
		}
	}
}

// LMC
// Lux: As a note this should only be used for dummy entity other entities need to remove EF_BONEMERGE_FASTCULL flag.
/*
*	Recreated "SetAttached" entity input from "prop_dynamic_ornament"
*/
stock void SetAttached(int iEntToAttach, int iEntToAttachTo)
{
	SetVariantString("!activator");
	AcceptEntityInput(iEntToAttach, "SetParent", iEntToAttachTo);

	SetEntityMoveType(iEntToAttach, MOVETYPE_NONE);

	SetEntProp(iEntToAttach, Prop_Send, "m_fEffects", EF_BONEMERGE | EF_BONEMERGE_FASTCULL | EF_PARENT_ANIMATES);

	// Thanks smlib for flag understanding
	int iFlags = GetEntProp(iEntToAttach, Prop_Data, "m_usSolidFlags", 2);
	iFlags = iFlags |= 0x0004;
	SetEntProp(iEntToAttach, Prop_Data, "m_usSolidFlags", iFlags, 2);

	TeleportEntity(iEntToAttach, view_as<float>({0.0, 0.0, 0.0}), view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR);
}
bool IsNoIncapOrLedge(int client)
{
return !view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)) && !view_as<bool>(GetEntProp(client, Prop_Send, "m_isHangingFromLedge", 1));
}

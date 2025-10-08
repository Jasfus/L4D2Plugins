#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
    name = "L4D2 Nickname Checker",
    author = "Your Name",
    description = "Checks player nicknames and prompts to change if needed",
    version = "1.2",
    url = ""
};

// Массив запрещенных ников
char g_BlockedNames[][] = 
{
    "FreeTP",
    "Freetp", 
    "freetp",
    "Pioneer",
    "pioneer",
    "FREETP",
    "PIONEER",
	"GhostRiP"
};

public void OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);

}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    
    if (IsValidClient(client) && !IsFakeClient(client))
    {
        CreateTimer(10.0, Timer_CheckNickname, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    }
    
    return Plugin_Continue;
}

public Action Timer_CheckNickname(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    
    if (IsValidClient(client) && !IsFakeClient(client))
    {
        char currentName[MAX_NAME_LENGTH];
        GetClientName(client, currentName, sizeof(currentName));
        
        if (IsNicknameBlocked(currentName))
        {
            ShowNotification(client, currentName);
        }
    }
    
    return Plugin_Stop;
}

void ShowNotification(int client, const char[] nickname)
{
    // Всегда показываем сообщение в чат
    PrintToChat(client, " \x04[Система] \x01Ваш никнейм '\x05%s\x01' находится в списке запрещенных.", nickname);
    PrintToChat(client, " \x04[Система] \x01Пожалуйста, смените ник командой: \x03!name <новый ник>");
    ShowMenuPanel(client);
}

// Текст через панель меню
void ShowMenuPanel(int client)
{
    Panel panel = new Panel();
    panel.SetTitle("=== ВНИМАНИЕ ===");
    panel.DrawText(" ");
    panel.DrawText("Ваш никнейм запрещен!");
    panel.DrawText(" ");
    panel.DrawText("Используйте в чате команду:");
    panel.DrawText("!name <новый ник>");
    panel.DrawText(" ");
    panel.DrawText("Для продолжения игры");
    panel.DrawText(" ");
    panel.DrawItem("Закрыть");
    
    panel.Send(client, MenuPanelHandler, 30); // Автозакрытие через 10 секунд
    delete panel;
}

public int MenuPanelHandler(Menu menu, MenuAction action, int client, int param2)
{
    // Обработчик панели
    if (action == MenuAction_Select)
    {
        // Игрок нажал кнопку
    }
    return 0;
}

bool IsNicknameBlocked(const char[] nickname)
{
    char tempNickname[MAX_NAME_LENGTH];
    strcopy(tempNickname, sizeof(tempNickname), nickname);
    StringToLower(tempNickname);
    
    for (int i = 0; i < sizeof(g_BlockedNames); i++)
    {
        char tempBlocked[MAX_NAME_LENGTH];
        strcopy(tempBlocked, sizeof(tempBlocked), g_BlockedNames[i]);
        StringToLower(tempBlocked);
        
        if (StrContains(tempNickname, tempBlocked) != -1)
        {
            return true;
        }
    }
    
    return false;
}

void StringToLower(char[] str)
{
    int length = strlen(str);
    for (int i = 0; i < length; i++)
    {
        str[i] = CharToLower(str[i]);
    }
}

bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}

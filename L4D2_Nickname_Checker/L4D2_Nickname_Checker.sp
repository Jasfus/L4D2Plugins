#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#pragma semicolon 1
#pragma newdecls required

Cookie cCookie;

public Plugin myinfo = 
{
	name = "L4D2 Nickname Checker And Change",
	author = "Jasf, Valedar",
	description = "Checks player nicknames and prompts to change if needed",
	version = "1.2",
	url = ""
};

// Массив запрещенных ников
char g_BlockedNames[][] = 
{
	"FreeTP",
	"Pioneer"
};

public void OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	cCookie = new Cookie("l4d_name", "change your name", CookieAccess_Private);
	RegConsoleCmd("sm_name", Cmd_ChangeName);

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

Action Cmd_ChangeName(int client, int args)
{
	if (client)
	{
		if (args != 0)
		{
			char sArg[64];
			GetCmdArgString(sArg, sizeof(sArg));
		
			if (IsValidString(sArg))
			{
				SetClientInfo(client, "name", sArg);
				cCookie.Set(client, sArg);
			}
			else
			{
				ReplyToCommand(client, "[SM] Допустимо только хотя бы одна буква или цифра и по желанию пробелы к ним.");
			}
		}
		else
		{
			ReplyToCommand(client, "[SM] Вы не ввели своё имя! Пример: sm_name player или если чат, то !name player");
		}
	}

	return Plugin_Handled;
}

public void OnClientCookiesCached(int client)
{
	if (!IsFakeClient(client))
	{
		char sCookieName[64];
		cCookie.Get(client, sCookieName, sizeof(sCookieName));

		if (sCookieName[0])
		{
			SetClientInfo(client, "name", sCookieName);
		}
	}
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
		
		if (StrContains(tempNickname, tempBlocked, false) >-1)
		{
			return true;
		}
	}
	
	return false;
}

bool IsValidString(const char[] str)
{	
	bool hasValid = false;
	int i = 0;

	while(str[i] != '\0')
	{
		// Проверка английских букв и цифр (1 байт)
		if((str[i] >= 'A' && str[i] <= 'Z') || 
		   (str[i] >= 'a' && str[i] <= 'z') || 
		   (str[i] >= '0' && str[i] <= '9'))
		{
			hasValid = true;
			i++;
		}
		// Проверка пробела (1 байт)
		else if(str[i] == ' ')
		{
			i++;
		}
		// Проверка русских букв UTF-8 (2 байта)
		else if((str[i] & 0xE0) == 0xC0 && str[i+1] != '\0')
		{
			// Первый байт русской буквы в UTF-8: 110xxxxx
			hasValid = true;
			i += 2; // Пропускаем 2 байта
		}
		else
		{
			return false; // Запрещенный символ
		}
	}

	return hasValid;
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

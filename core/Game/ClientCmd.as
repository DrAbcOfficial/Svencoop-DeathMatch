#include "../Class/CClientCmd"

enum ClientCmdFlag
{
    CCMD_NONE = 0,
    CCMD_ADMIN,
    CCMD_OWNER,
    CCMD_SERVER
}

namespace pvpClientCmd
{
    void PluginInit()
    {
        pvpLang::addLang("_CLIENTCMD_","ClientCmd");
        pvpClientCmd::RegistCommand("pvp_help","List avaliable keys","ClientCommand", @pvpClientCmd::ListCallback);
		pvpHook::RegisteHook(CHookItem(@pvpClientCmd::SayCmdCallBack,HOOK_PRESAY , "SayClientCmd"));
    }

	array<CClientCmd@> aryClientCmd = {};

	void ListCallback(const CCommand@ Argments)
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
		if(aryClientCmd.length() == 0)
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, pvpLang::getLangStr("_CLIENTCMD_","EMPCMD"));
		else
		{
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, pvpLang::getLangStr("_CLIENTCMD_","AVACMD") + "\n");
			for(uint i = 0; i < aryClientCmd.length(); i++ )
			{
				if( g_PlayerFuncs.AdminLevel(pPlayer) < CCMD_ADMIN && aryClientCmd[i].Flag != 0)
					continue;
				else
					g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[."+aryClientCmd[i].Name+"] | "+ aryClientCmd[i].HelpInfo + " | " + aryClientCmd[i].Printf + ".\n");
			}
		}
	}

	bool SayCmdCallBack(CBasePlayer@ pPlayer, const CCommand@ pArgument, ClientSayType SayType)
	{
		string tempStr = pArgument.GetCommandString();
		if(tempStr.StartsWith("!") || tempStr.StartsWith(".") || tempStr.StartsWith("/") || tempStr.StartsWith("\\"))
		{
			tempStr.Trim("!");
			tempStr.Trim(".");
			tempStr.Trim("//");
			tempStr.Trim("\\");
			for(uint i = 0; i < aryClientCmd.length(); i++)
			{
				if(aryClientCmd[i].Name == pArgument.Arg(0).SubString(1))
				{
					pvpUtility::ClientCommand(pPlayer, "." + tempStr);
					return false;
				}
			}
			pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_","QUECMD", tempStr), POSCHAT);
		}
		return true;
	}
	
	void RegistCommand( string szName, string szHelpInfo, string szPrintf, ClientCmdCallback@ pCallback, int iFlags = CCMD_NONE )
	{
		CClientCmd command(szName, szHelpInfo, szPrintf, iFlags, CClientCommand( szName, szHelpInfo, @HandelCallback, iFlags), pCallback);
		aryClientCmd.insertLast(command);
		aryClientCmd.sortAsc();
	}

	CClientCmd GetCommand( string szName )
	{
		for(uint i = 0; i < aryClientCmd.length(); i++)
		{
			if(aryClientCmd[i].Name == szName)
				return aryClientCmd[i];
		}
		pvpLog::log(pvpLang::getLangStr("_CLIENTCMD_","QUECMD", szName));
		return CClientCmd();
	}

	void HandelCallback( const CCommand@ Argments )
	{
		string ArgName = Argments[0].SubString(1,Argments[0].Length());
		string ArgVal = Argments[1];
		
		CClientCmd@ data = GetCommand(ArgName);
		
		if(data is null)
		{
			pvpLog::log(pvpLang::getLangStr("_CLIENTCMD_","NULCMD", ArgName, ArgVal));
			return;
		}
		
		if( data.ClientCallback is null )
		{
			pvpLog::log(pvpLang::getLangStr("_CLIENTCMD_","NULCBK", ArgName, ArgVal));
			return;
		}
		
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
		if( g_PlayerFuncs.AdminLevel(pPlayer) < CCMD_ADMIN && data.Flag != 0)
		{
			pvpLog::say(pPlayer, "[" + data.Printf + "]" + pvpLang::getLangStr("_CLIENTCMD_","NADMIN", pvpPlayerData::getData(pPlayer, "Lang")));
			return;
		}
		ClientCmdCallback@ Callback = @data.ClientCallback;
		Callback( Argments);
	}
}
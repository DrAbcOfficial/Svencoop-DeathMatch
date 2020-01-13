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
    }

	array<CClientCmd@> aryClientCmd = {};
    funcdef void ClientCmdCallback( const CCommand@ );

	void ListCallback(const CCommand@ Argments)
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
		string szPrint;
		if(aryClientCmd.length() == 0)
			szPrint = pvpLang::getLangStr("_CLIENTCMD_","EMPCMD");
		else
		{
			uint f = 0;
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, pvpLang::getLangStr("_CLIENTCMD_","AVACMD") + "\n");
			for(uint i = 0; i < aryClientCmd.length(); i++ )
			{
				if( g_PlayerFuncs.AdminLevel(pPlayer) < CCMD_ADMIN && aryClientCmd[i].Flag != 0)
					continue;
				else
				{
					szPrint = szPrint + "[."+aryClientCmd[i].Name+"] | "+ aryClientCmd[i].HelpInfo + " | " + aryClientCmd[i].Printf + ".\n";
					f++;
				}
				if( f % 2 == 0)
				{
					g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, szPrint);
					szPrint = "";
				}
			}
			if( szPrint != "" )
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, szPrint);
		}
	}

	class CClientCmd
	{
		private string szName = "";
		private string szHelpInfo = "";
		private string szPrintf = "";
		private uint8 usFlag = 0;
		private CClientCommand@ c_ClientCom;
		private ClientCmdCallback@ c_CallBack;

		CClientCmd(){}
		CClientCmd(string _Name, string _Help, string _Print, uint8 _Flag, CClientCommand@ _Client, ClientCmdCallback@ _Call)
		{
			szName = _Name;
			szHelpInfo = _Help;
			szPrintf = _Print;
			usFlag = _Flag;
			@c_ClientCom = @_Client;
			@c_CallBack = @_Call;
		}
		
		string Name
		{
			get const{ return szName;}
			set{ szName = value;}
		}
			
		string HelpInfo
		{
			get const{ return szHelpInfo;}
			set { szHelpInfo = value; }
		}
		
		string Printf
		{
			get const{ return szPrintf;}
			set { szPrintf = value; }
		}
		
		uint8 Flag
		{
			get const{ return usFlag;}
			set { usFlag = value; }
		}
			
		CClientCommand@ ClientCommand
		{
			get{ return c_ClientCom;}
			set{ @c_ClientCom = value;}
		}
		
		ClientCmdCallback@ ClientCallback
		{
			get{ return c_CallBack;}
			set{ @c_CallBack = value;}
		}
	}

	void RegistCommand( string szName, string szHelpInfo, string szPrintf, ClientCmdCallback@ pCallback, int iFlags = CCMD_NONE )
	{
		CClientCmd command(szName, szHelpInfo, szPrintf, iFlags, CClientCommand( szName, szHelpInfo, @HandelCallback, iFlags), pCallback);
		aryClientCmd.insertLast(command);
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
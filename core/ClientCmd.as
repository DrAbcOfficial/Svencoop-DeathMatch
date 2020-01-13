enum ClientCmdFlag
{
    CCMD_YES = 0,
    CCMD_ADMIN,
    CCMD_OWNER,
    CCMD_SERVER
}

namespace pvpClientCmd
{
    void PluginInit()
    {
        pvpLang::addLang("_CLIENTCMD_","ClientCmd");
        @pvpClientCmd::aryCmdKeys = pvpClientCmd::dicCmdList.getKeys();
    }

	dictionary dicCmdList;
	array<string> @aryCmdKeys;
    funcdef void ClientCmdCallback( const CCommand@ );
	CClientCommand g_Onekeylist("pvp_help", "List all key", @ListCallback);

	void ListCallback(const CCommand@ Argments)
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
		string szPrint;
		if(aryCmdKeys.length() == 0)
			szPrint = pvpLang::getLangStr("_CLIENTCMD_","EMPCMD");
		else
		{
			uint f = 0;
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, pvpLang::getLangStr("_CLIENTCMD_","AVACMD") + "\n");
			for(uint i = 0; i <= aryCmdKeys.length() - 1; i++ )
			{
				CClientCmd@ data = cast<CClientCmd@>(dicCmdList[aryCmdKeys[i]]);
				if(g_PlayerFuncs.AdminLevel(pPlayer) < ADMIN_YES && data.Flag != 0)
					continue;
				else
				{
					szPrint = szPrint + "[."+data.Name+"] | "+ data.HelpInfo + " | " + data.Printf + ".\n";
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

	void RegistCommand( string szName, string szHelpInfo, string szPrintf, ClientCmdCallback@ pCallback, int iFlags = 0 )
	{
		CClientCmd command;
		command.Name = szName;
		command.HelpInfo = szHelpInfo;
		command.Printf = szPrintf;
		command.Flag = iFlags;
		@command.ClientCallback = pCallback;
		@command.ClientCommand = CClientCommand( szName, szHelpInfo, @HandelCallback, iFlags);
		dicCmdList[szName] = command;
	}

	CClientCmd GetCommand( string szName )
	{
		if(dicCmdList.exists(szName))
		{
			CClientCmd@ data = cast<CClientCmd@>(dicCmdList[szName]);
			return data;
		}
		else
		{
			pvpLog::log(pvpLang::getLangStr("_CLIENTCMD_","QUECMD", szName));
			CClientCmd data;
			return data;
		}
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
		if(g_PlayerFuncs.AdminLevel(pPlayer) < ADMIN_YES)
		{
			if( data.Flag != 0)
				pvpLog::say(pPlayer, "[" + data.Printf + "]" + pvpLang::getLangStr("_CLIENTCMD_","NADMIN", pvpPlayerData::getData(pPlayer, "Lang")));
		}
		ClientCmdCallback@ Callback = @data.ClientCallback;
		Callback( Argments);
	}
}
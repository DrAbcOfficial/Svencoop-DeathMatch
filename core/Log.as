enum LogWarnLevel
{
    SYSLOG = 0,
    SYSWARN,
    SYSERROR
}

enum LogPosition
{
    POSNON = -1,
    POSCONSOLE,
    POSCHAT,
    POSCENTER,
    POSNOTIFY,
    POSBOTH
}

namespace pvpLog
{
    //重载
    void log(string&in szString,int&in level = SYSLOG,int&in iPosition = POSNON)
    {
       Printf(szString, level, iPosition);
    }

    void log(CBaseEntity@&in pEntity,int&in level = SYSLOG,int&in iPosition = POSNON)
    {
        string szString = "";
        szString += "classname:" + pEntity.pev.classname + "\n";
        szString += "targetname:" + pEntity.pev.targetname + "\n";
        szString += "netname:" + pEntity.pev.netname + "\n";
        szString += "origin:(" + pvpUtility::vecToStr(pEntity.pev.origin) + ")\n";
        szString += "angles:(" + pvpUtility::vecToStr(pEntity.pev.angles) +  ")\n";
        Printf(szString, level, iPosition);
    }

    void log(entvars_t@&in pevEntity,int&in level = SYSLOG,int&in iPosition = POSNON)
    {
        string szString = "";
        szString += "classname:" + pevEntity.classname + "\n";
        szString += "targetname:" + pevEntity.targetname + "\n";
        szString += "netname:" + pevEntity.netname + "\n";
        szString += "origin:(" + pvpUtility::vecToStr(pevEntity.origin) +  ")\n";
        szString += "angles:(" + pvpUtility::vecToStr(pevEntity.angles) +  ")\n";
        Printf(szString, level, iPosition);
    }

    void log(Vector&in vecStr,int&in level = SYSLOG,int&in iPosition = POSNON)
    {
       Printf("(" + vecStr.x + "," + vecStr.y + "," + vecStr.z + ")", level, iPosition);
    }

    void log(array<string>&in ayString,int&in level = SYSLOG,int&in iPosition = POSNON)
    {
        string szBuffer = "";
        for(uint i = 0; i < ayString.length(); i++)
        {
            szBuffer += ayString[i] + ",";
        }
        Printf(szBuffer, level, iPosition);
    }

    //为模块载入提供一个输出函数
    void moduleLog(string&in szString, string&in Author)
    {
        string szBuffer = pvpLang::getLangStr("_MAIN_","PLULOADED", szString, Author);
        Printf(szBuffer, SYSLOG, POSNON);
    }

    void Printf(string&in szString,int&in level = SYSLOG ,int&in iPosition = POSNON)
    {
         //消息等级
        string szBuffer = "LOG";
        switch(level)
        {
            case SYSWARN:szBuffer = "WARN";break;
            case SYSERROR:szBuffer = "ERROR";break;
            default:break;
        }
        //合并字符串
        //时间::标题::[标签]:内容
        szString.Trim();
        szBuffer = pvpUtility::getTime() + "::PvP::[" + szBuffer + "]:" + szString + "\n";
        //消息记录
        switch(iPosition)
        {
            //在控制台推送
            case POSCONSOLE: g_Game.AlertMessage( at_console, szBuffer );break;
            //在聊天窗推送
            case POSCHAT: g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, szBuffer );break;
            //在屏幕中推送
            case POSCENTER: g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, szBuffer );break;
            //不对玩家推送
            default: break;
        }
        //记录进入AngelScript.log内
        //以Log标题为开头
        g_Log.PrintF( szBuffer );
    }

    //向玩家推送消息
    void say(CBasePlayer@pPlayer, string&in szString, int&in iPosition = POSCONSOLE)
    {
        PrintToPlayer(pPlayer, szString, iPosition);
    }
    //推送多条消息
    void say(CBasePlayer@pPlayer, array<string>&in ayString, int&in iPosition = POSCONSOLE)
    {
        for(uint i = 0; i < ayString.length(); i++)
        {
            PrintToPlayer(pPlayer, ayString[i], iPosition);
        }
    }

    //向所有玩家推送消息
    void say(string&in szString, int&in iPosition = POSCONSOLE)
    {
        for (int i = 0; i <= g_Engine.maxClients; i++)
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pPlayer !is null && pPlayer.IsConnected())
			{
                PrintToPlayer(pPlayer, szString, iPosition);
            }
        }
    }
    //推送多条消息
    void say(array<string>&in ayString, int&in iPosition = POSCONSOLE)
    {
        for (int i = 0; i <= g_Engine.maxClients; i++)
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pPlayer !is null && pPlayer.IsConnected())
			{
                for(uint j = 0; j < ayString.length(); j++)
                {
                    PrintToPlayer(pPlayer, ayString[j], iPosition);
                }
            }
        }
    }

    void PrintToPlayer(CBasePlayer@pPlayer, string&in szString, int&in iPosition = POSCONSOLE)
    {
        string szBuffer = "[" + pvpConfig::getConfig("General","Title").getString() + "]" + szString + "\n";
        switch(iPosition)
        {
            //在控制台推送
            case POSCONSOLE: g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, szBuffer );break;
            //在聊天窗推送
            case POSCHAT: g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, szBuffer );break;
            //在屏幕中推送
            case POSCENTER: g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, szBuffer );break;
            //在左上角推送
            case POSNOTIFY:  g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, szBuffer );break;
            //在左上角推送
            case POSBOTH:  g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, szBuffer );g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, szBuffer );break;
        }
        //获取昵称
        string pName = string(pPlayer.pev.netname);
        //记录下
        g_Log.PrintF( pvpUtility::getTime() + "-" + pName + "@:" + szBuffer );
    }

    //替换原来的全员发送消息
    void SayDelg(CBasePlayer@&in pPlayer, string szSth, ClientSayType SayType)
    {
        if(szSth.IsEmpty())
            return;
        if( SayType == CLIENTSAY_SAY )
		{
			if ( pPlayer.IsAlive() == true )
				szSth = string( pPlayer.pev.netname ) + ": " + szSth + "\n";
			else
				szSth = "*DEAD* " + pPlayer.pev.netname + ": " + szSth + "\n";
            g_PlayerFuncs.SayTextAll( pPlayer, szSth );
            g_Log.PrintF( "Msg. " + pvpUtility::getTime() + " - " + szSth);
		}
		else
		{
            //先判断再发送消息，一来减少占用，而来避免bug
            if ( pPlayer.IsAlive() == true )
				szSth = "(TEAM) " + string(pPlayer.pev.netname) + ": " + szSth + "\n";
			else
				szSth = "(TEAM) *DEAD* " + string(pPlayer.pev.netname) + ": " + szSth + "\n";
			for ( int i = 1; i <= g_Engine.maxClients; ++i )
			{
				CBasePlayer@ tPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if ( tPlayer !is null && tPlayer.IsConnected() && tPlayer.GetClassification( 0 ) == pPlayer.GetClassification( 0 ) )
                    g_PlayerFuncs.SayText( tPlayer, szSth );
			}
		}
        g_Log.PrintF( "Msg. " + (SayType == CLIENTSAY_SAY ? "" : "in team" + pPlayer.GetClassification(0)) + "." + pvpUtility::getTime() + " - " + szSth);
    }
}
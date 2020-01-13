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
    POSNOTIFY
}

namespace pvpLog
{
    //重载
    void log(string&in szString,int&in level = SYSLOG,int&in iPosition = POSNON)
    {
       Printf(szString, level, iPosition);
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

    void PrintToPlayer(CBasePlayer@pPlayer, string&in szString, int&in iPosition = POSCONSOLE)
    {
        string szBuffer = "[" + pvpConfig::getConfig("General","Title") + "]" + szString + "\n";
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
        }
        //获取昵称
        string pName = string(pPlayer.pev.netname);
        //记录下
        g_Log.PrintF( pvpUtility::getTime() + "-" + pName + "@:" + szBuffer );
    }
}
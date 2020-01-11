namespace pvpLog
{
    //重载
    void log(string&in szString,int&in level = 0,int&in iPosition = 3)
    {
       Printf(szString, level, iPosition);
    }

    void log(array<string>&in ayString,int&in level = 0,int&in iPosition = 3)
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
        string szBuffer = pvpLang::getLangStr("_MAIN_","PLULOADED").Replace("%1", szString).Replace("%2", Author);
        Printf(szBuffer, 0, 3);
    }

    void Printf(string&in szString,int&in level = 0,int&in iPosition = 3)
    {
         //消息等级
        string szBuffer = "LOG";
        switch(level)
        {
            case 1:szBuffer = "WARN";break;
            case 2:szBuffer = "ERROR";break;
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
            case 0: g_Game.AlertMessage( at_console, szBuffer + "\n");break;
            //在聊天窗推送
            case 1: g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, szBuffer );break;
            //在屏幕中推送
            case 2: g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, szBuffer );;break;
            //不对玩家推送
            default: break;
        }
        //记录进入AngelScript.log内
        //以Log标题为开头
        g_Log.PrintF( szBuffer );
    }
}
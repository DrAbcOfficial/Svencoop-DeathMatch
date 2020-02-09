namespace pvpTimerStop
{
    //名字不能随便改
    string hudName;
    //需要预缓存的不能随便改
    string sprName;
    void PluginInit()
    {
        hudName = pvpConfig::getConfig("TimerStop","HUDName").getString();
        sprName = pvpConfig::getConfig("TimerStop","SprName").getString();
        pvpHud::CTimeHUD@ pHud = pvpHud::CreateTimeHUD
        (
            hudName,
            0,
            RGBA_SVENCOOP,
            pvpConfig::getConfig("TimerStop","HUDPos").getVector2D(),
            pvpConfig::getConfig("TimerStop","HUDChannel").getInt(),
            1.1,
            HUD_TIME_MINUTES | HUD_TIME_SECONDS | HUD_ELEM_SCR_CENTER_X | HUD_TIME_COUNT_DOWN
        );

        pvpTimer::addTimer(pvpTimer::CTimerFunc(hudName, @SendHud));
    }

    bool SendHud()
    {
        pvpHud::CTimeHUD@ pHud = pvpHud::GetTimeHUD(hudName); 
   
        if(pvpConfig::getConfig("TimerStop","TotalTime").getFloat() - g_Engine.time < pvpConfig::getConfig("TimerStop","WarnTime").getFloat())
        {
            pHud.HUD.flags |=  HUD_TIME_MILLISECONDS ;
            pHud.HUD.color1 = RGBA_RED;
        }
        else
        {
            pHud.HUD.flags =   HUD_TIME_MINUTES | HUD_TIME_SECONDS | HUD_ELEM_SCR_CENTER_X | HUD_TIME_COUNT_DOWN ;
            pHud.HUD.color1 = RGBA_SVENCOOP;
        }

        if(pvpConfig::getConfig("TimerStop","TotalTime").getFloat() - g_Engine.time < 0)
        {
            pvpEndGame::End();
            return false;
        }
        pHud.HUD.value = pvpConfig::getConfig("TimerStop","TotalTime").getFloat() - g_Engine.time;
        pHud.SetSpr(sprName);
        pHud.Send();
       return true;
    }
}
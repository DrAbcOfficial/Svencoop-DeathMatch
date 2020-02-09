namespace Autobhop
{
    CScheduledFunction@ g_pBhopThinkFunc = null;
    dictionary g_PlayerBhop;

    void PluginInit()
    { 
        pvpClientCmd::RegistCommand("player_autobhop","Toggle the auto bhop","Autobhop", @Autobhop::BhopCallBack);
        if(g_pBhopThinkFunc !is null)
		    g_Scheduler.RemoveTimer(g_pBhopThinkFunc);

	    @g_pBhopThinkFunc = g_Scheduler.SetInterval("think", 0.007f);
    }

    void BhopCallBack(const CCommand@ pArgs)
    {
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        string szSteamId = pvpUtility::getSteamId(pPlayer);
        if(g_PlayerBhop.exists(szSteamId))
			g_PlayerBhop.delete(szSteamId);
		else
			g_PlayerBhop.set(szSteamId, true);
        pvpLog::say(pPlayer, "[AutoBHOP] " +(g_PlayerBhop.exists(szSteamId) ? "Enabled" : "Disabled") , POSCHAT);
    }

    void AutoBhop(CBasePlayer@ pPlayer)
    {
        int iOldButtons = pPlayer.pev.oldbuttons;
        if(pPlayer.pev.oldbuttons & IN_JUMP != 0 && pPlayer.pev.flags & FL_ONGROUND != 0)
        {
            iOldButtons &= ~IN_JUMP;
            pPlayer.pev.oldbuttons = iOldButtons;
            pPlayer.pev.sequence = PLAYER_JUMP;
        }
    }

    void think() 
    {
        for (int i = 1; i <= g_Engine.maxClients; ++i) 
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if (pPlayer !is null && pPlayer.IsConnected()) 
            {
                string szSteamId = pvpUtility::getSteamId(pPlayer);
                if(g_PlayerBhop.exists(szSteamId))
                    AutoBhop(pPlayer);
            }
        }
    }
}
namespace pvpClientSay
{
    funcdef bool sayCallback(CBasePlayer@, const CCommand@, ClientSayType);

    array<pvpSayFunc@> arypreSayfuncs = {};
    array<pvpSayFunc@> arypostSayfuncs = {};

    bool bSayParament = false;
    class pvpSayFunc
    {
         //提供构造函数方便创建类
	    pvpSayFunc(string _uniName, sayCallback@ _callBack ) 
        {
            uniName = _uniName; 
            @callBack = @_callBack;
        }
        //唯一标识字符串
        string uniName;
        //需要执行的函数
        sayCallback@ callBack;
        //输出为string
        string ToString() 
        { 
            return uniName; 
        }
    }

    void PluginInit()
    {
        bSayParament = pvpConfig::getConfig("ClientSay","Enable").getBool();
        arypreSayfuncs.insertLast(pvpSayFunc("Sayparament", @paramentSayHook));
        //查看系统语言和可选语言
        pvpClientCmd::RegistCommand("admin_sayparament","Toggle the say parament","Say", @pvpClientSay::sayRepCallback, CCMD_ADMIN);
    }

    void sayRepCallback(const CCommand@ pArgs)
	{
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        int pIndex = pvpLang::getPlayerLangIndex(pPlayer);
        int tempInt = 0;
        if(pArgs.ArgC() == 1)
        {
            bSayParament = !bSayParament;
            pvpConfig::setConfig("ClientSay","Enable", bSayParament);
            pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDTLG", pIndex));
            return;
        }
        string tempStr = pArgs[1].ToUppercase();
        tempStr.Trim();
        tempInt = Math.clamp(0 ,1, atoi(tempStr));
        switch(tempInt)
        {
            case 0: bSayParament = false;pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDOFF", pIndex));break;
            case 1: bSayParament = true; pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDON", pIndex));break;
        }
        pvpConfig::setConfig("ClientSay","Enable", bSayParament);
	}

    void sayDelg(CBasePlayer@&in pPlayer, string szSth, ClientSayType SayType)
    {
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
			for ( int i = 1; i <= g_Engine.maxClients; ++i )
			{
				CBasePlayer@ tPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if ( tPlayer !is null && tPlayer.IsConnected() && tPlayer.GetClassification( 0 ) == pPlayer.GetClassification( 0 ) )
				{
					if ( pPlayer.IsAlive() == true )
						szSth = "(TEAM) " + string(pPlayer.pev.netname) + ": " + szSth + "\n";
					else
						szSth = "(TEAM) *DEAD* " + string(pPlayer.pev.netname) + ": " + szSth + "\n";
                    g_PlayerFuncs.SayText( tPlayer, szSth );
				}
			}
            g_Log.PrintF( "Msg. in team" + pPlayer.GetClassification(0) + "." + pvpUtility::getTime() + " - " + szSth);
		}
        
    }

    bool paramentSayHook(CBasePlayer@ pPlayer, const CCommand@ pArgument, ClientSayType SayType)
    {
        if(bSayParament == false)
            return true;
        int pIndex = pvpLang::getPlayerLangIndex(pPlayer);
        string tempStr = pArgument.GetCommandString();
        if(tempStr.IsEmpty())
            return true;
        string repStr = pvpConfig::getConfig("ClientSay","Weapon").getString();
        if(tempStr.Find(repStr) != String::INVALID_INDEX )
        {
            string weaponStr = string(pPlayer.m_hActiveItem.GetEntity().pev.classname);
            weaponStr = string(pvpLang::getLangStr("_HITBOX_",weaponStr)) == "" ? weaponStr : string(pvpLang::getLangStr("_HITBOX_",weaponStr, pIndex));
            tempStr = tempStr.Replace(repStr, weaponStr);
        }
        repStr = pvpConfig::getConfig("ClientSay","Pos").getString();
        if(tempStr.Find(repStr) != String::INVALID_INDEX )
        {
            string vecStr = "(" + int(pPlayer.pev.origin.x) + "," + int(pPlayer.pev.origin.y) + "," + int(pPlayer.pev.origin.z) + ")";
            tempStr = tempStr.Replace(repStr, vecStr);
        }
        repStr = pvpConfig::getConfig("ClientSay","Hp").getString();
        if(tempStr.Find(repStr) != String::INVALID_INDEX )
            tempStr = tempStr.Replace(repStr, int(pPlayer.pev.health));
        repStr = pvpConfig::getConfig("ClientSay","Ap").getString();
        if(tempStr.Find(repStr) != String::INVALID_INDEX )
            tempStr = tempStr.Replace(repStr, int(pPlayer.pev.armorvalue));
        sayDelg(pPlayer, tempStr, SayType);
        return false;
    }

    bool preSayHook(CBasePlayer@ pPlayer, const CCommand@ pArgument, ClientSayType SayType)
    {
        bool bFlag = true;
        //遍历数组挨个执行
        for(uint i = 0; i< pvpClientSay::arypreSayfuncs.length(); i++)
        {
            //执行类里的函数,只要有false，那就阻断
            bFlag = bFlag && pvpClientSay::arypreSayfuncs[i].callBack(pPlayer, pArgument, SayType);
        }
        return bFlag;
    }

    void postSayHook(CBasePlayer@ pPlayer, const CCommand@ pArgument, ClientSayType SayType)
    {
        //遍历数组挨个执行
        for(uint i = 0; i< pvpClientSay::arypostSayfuncs.length(); i++)
        {
            pvpClientSay::arypostSayfuncs[i].callBack(pPlayer, pArgument, SayType);
        }
    }
}
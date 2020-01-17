namespace Sayreplace
{
    bool bSayParament = false;

    //替换发言内容
    void PluginInit()
    {
        bSayParament = pvpConfig::getConfig("Sayreplace","Enable").getBool();

        pvpClientSay::RegisteSayFunc("Sayreplace", @Sayreplace::paramentSayHook);

        pvpClientCmd::RegistCommand("admin_sayreplace","Toggle the say replace","Say", @Sayreplace::sayRepCallback, CCMD_ADMIN);
    }

    void sayRepCallback(const CCommand@ pArgs)
	{
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        int pIndex = pvpLang::getPlayerLangIndex(pPlayer);
        int tempInt = 0;
        if(pArgs.ArgC() == 1)
        {
            bSayParament = !bSayParament;
            pvpConfig::setConfig("Sayreplace","Enable", bSayParament);
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
        pvpConfig::setConfig("Sayreplace","Enable", bSayParament);
	}

    bool paramentSayHook(CBasePlayer@ pPlayer, const CCommand@ pArgument, ClientSayType SayType)
    {
        if(bSayParament == false)
            return true;
        int pIndex = pvpLang::getPlayerLangIndex(pPlayer);
        string tempStr = pArgument.GetCommandString();
        if(tempStr.IsEmpty())
            return true;
        string repStr = pvpConfig::getConfig("Sayreplace","Weapon").getString();
        if(tempStr.Find(repStr) != String::INVALID_INDEX )
        {
            string weaponStr = string(pPlayer.m_hActiveItem.GetEntity().pev.classname);
            weaponStr = string(pvpLang::getLangStr("_HITBOX_",weaponStr)) == "" ? weaponStr : string(pvpLang::getLangStr("_HITBOX_",weaponStr, pIndex));
            tempStr = tempStr.Replace(repStr, weaponStr);
        }
        repStr = pvpConfig::getConfig("Sayreplace","Pos").getString();
        if(tempStr.Find(repStr) != String::INVALID_INDEX )
        {
            string vecStr = "(" + int(pPlayer.pev.origin.x) + "," + int(pPlayer.pev.origin.y) + "," + int(pPlayer.pev.origin.z) + ")";
            tempStr = tempStr.Replace(repStr, vecStr);
        }
        repStr = pvpConfig::getConfig("Sayreplace","Hp").getString();
        if(tempStr.Find(repStr) != String::INVALID_INDEX )
            tempStr = tempStr.Replace(repStr, int(pPlayer.pev.health));
        repStr = pvpConfig::getConfig("Sayreplace","Ap").getString();
        if(tempStr.Find(repStr) != String::INVALID_INDEX )
            tempStr = tempStr.Replace(repStr, int(pPlayer.pev.armorvalue));
        pvpClientSay::sayDelg(pPlayer, tempStr, SayType);
        return false;
    }
}
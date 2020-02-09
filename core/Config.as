namespace pvpConfig
{
    dictionary config;
    bool PluginInit()
    {
        config = pvpFile::getINIData( "scripts/plugins/pvp/config.ini" );
        pvpClientCmd::RegistCommand("admin_setconfig","Changeconfig","Config", @pvpConfig::SetConfigCallBack);
        return !config.isEmpty();
    }


    void SetConfigCallBack(const CCommand@ Argments)
    {
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        if(Argments.ArgC() < 4)
        {
            pvpLog::say(pPlayer, "Error Input\nExample:.admin_setconfig <Section> <key> <val>");
            return;
        }
        string section = Argments[1];
        string key = Argments[2];
        string val = Argments[3];
        array<string> tempAry;
        val.Trim();
        switch(pvpUtility::getStringType(val))
        {
            case PDATA_BOOL:setConfig(section, key, val.ToLowercase()  == "true" ? true : false);break;
            case PDATA_INT:setConfig(section, key, atoi(val));break;
            case PDATA_FLOAT:setConfig(section, key, atof(val));break;
            case PDATA_VECTOR2D: tempAry = val.Split(",");setConfig(section, key, Vector2D(atof(tempAry[0]), atof(tempAry[1])));break;
            case PDATA_VECTOR: tempAry = val.Split(",");setConfig(section, key, Vector(atof(tempAry[0]), atof(tempAry[1]), atof(tempAry[2])));break;
            case PDATA_RGBA: tempAry = val.Split(",");setConfig(section, key, RGBA(atoui(tempAry[0]), atoui(tempAry[1]), atoui(tempAry[2]), atoui(tempAry[3])));break;
            case PDATA_STRING:setConfig(section, key, val);break;
            default:setConfig(section, key, val);break;
        }
        pvpLog::say(pPlayer, "Config " + section + " Has been set to key: " + key + "val: "+ val);
    }

    pvpFile::CINIValue getConfig(string&in section, string&in key)
    {
        if(!config.exists(section))
            pvpLog::log("Can not found this section: " + section + " in config data!");
        else
        {
            dictionary tempConf = dictionary(config[section]);
            if(!tempConf.exists(key))
                pvpLog::log("Can not found this key: " + key + " in config data!");
            else
                return cast<pvpFile::CINIValue@>(tempConf[key]);
        }
        return pvpFile::CINIValue();
    }

    bool preConfig(string&in section)
    {
        bool bFlag = config.exists(section);
        if(!bFlag)
            pvpLog::log("Can not found this section: " + section + " in config data!");
        return bFlag;
    }

    void setConfig(string&in section, string&in key, string&in val)
    {
        if(preConfig(section))
            return;
        dictionary(config[section]).set(key, pvpFile::CINIValue(val));
    }

    void setConfig(string&in section, string&in key, int&in val)
    {
        if(preConfig(section))
            return;
        dictionary(config[section]).set(key, pvpFile::CINIValue(val));
    }

    void setConfig(string&in section, string&in key, float&in val)
    {
        if(preConfig(section))
            return;
        dictionary(config[section]).set(key, pvpFile::CINIValue(val));
    }

    void setConfig(string&in section, string&in key, uint&in val)
    {
        if(preConfig(section))
            return;
        dictionary(config[section]).set(key, pvpFile::CINIValue(val));
    }

    void setConfig(string&in section, string&in key, bool&in val)
    {
        if(preConfig(section))
            return;
        dictionary(config[section]).set(key, pvpFile::CINIValue(val));
    }

    void setConfig(string&in section, string&in key, Vector&in val)
    {
        if(preConfig(section))
            return;
        dictionary(config[section]).set(key, pvpFile::CINIValue(val));
    }

    void setConfig(string&in section, string&in key, Vector2D&in val)
    {
        if(preConfig(section))
            return;
        dictionary(config[section]).set(key, pvpFile::CINIValue(val));
    }

    void setConfig(string&in section, string&in key, RGBA&in val)
    {
        if(preConfig(section))
            return;
        dictionary(config[section]).set(key, pvpFile::CINIValue(val));
    }
}
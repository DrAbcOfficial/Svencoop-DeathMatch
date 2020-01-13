namespace pvpConfig
{
    dictionary config;
    bool PluginInit()
    {
        config = pvpFile::getINIData( "scripts/plugins/pvp/config.ini" );
        return !config.isEmpty();
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
}
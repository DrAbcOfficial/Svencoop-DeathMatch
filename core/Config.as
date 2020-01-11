namespace pvpConfig
{
    dictionary config;
    bool PluginInit()
    {
        config = pvpFile::getINIData( "scripts/plugins/pvp/config.ini" );
        return !config.isEmpty();
    }

    string getConfig(string&in section, string&in key)
    {
        if(!config.exists(section))
            pvpLog::log("Can not found this section: " + section + " in config data!");
        else
        {
            dictionary tempConf = dictionary(config[section]);
            if(!tempConf.exists(key))
                pvpLog::log("Can not found this key: " + key + " in config data!");
            else
                return string(tempConf[key]);
        }
        return "";
    }
}
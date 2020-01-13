namespace pvpLang
{
    void PluginInit()
    {
        pvpLang::addLang("_MAIN_","Main");

        pvpLang::sysLang = pvpConfig::getConfig("Lang","SysLang");
        pvpLang::sysIndex = pvpLang::getLangIndex(sysLang);

        pvpLog::log(pvpLang::getLangStr("_MAIN_", "SYSLANG", sysLang));

        //改变自己的语言
        pvpClientCmd::RegistCommand("pvp_language","Change or get your language here","Language",@pvpLang::ChangeLangCallback);
        //查看系统语言和可选语言
        pvpClientCmd::RegistCommand("pvp_syslang","Tell me the system language","Language",@pvpLang::SysLangCallback);
    }

    void SysLangCallback(const CCommand@ pArgs)
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        pvpLog::say(pPlayer, pvpLang::getLangStr("_MAIN_", "SYSLANG", pvpLang::sysLang, getPlayerLangIndex(pPlayer)));
        pvpLog::say(pPlayer, pvpLang::getLangStr("_MAIN_", "AVALANG", getPlayerLangIndex(pPlayer)));
        string tempStr = " | ";
        for(uint i = 0; i < langIndex.length(); i++)
        {
            tempStr += langIndex[i] + " | ";
        }
        pvpLog::say(pPlayer, tempStr);
	}

    void ChangeLangCallback(const CCommand@ pArgs)
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        int pIndex = getPlayerLangIndex(pPlayer);
        if(pArgs.ArgC() == 1)
        {
            pvpLog::say(pPlayer, pvpLang::getLangStr("_MAIN_", "SYSLANG", getIndexLang(pIndex), pIndex));
            return;
        }
        string tempStr = pArgs[1].ToUppercase();
        tempStr.Trim();
        int index = getLangIndex(tempStr); 
        if(index != -1)
        {
            pvpPlayerData::addData(pPlayer,"Lang", index);
            pvpLog::say(pPlayer, pvpLang::getLangStr("_MAIN_", "SYSLANG", tempStr, index));
            return;
        }
        pvpLog::say(pPlayer, pvpLang::getLangStr("_MAIN_", "LANGERR", tempStr, pIndex));
	}

    bool PlayerPutinServer(CBasePlayer@pPlayer)
    {
        if(pPlayer !is null)
        {
            pvpPlayerData::addData(pPlayer,"Lang", sysIndex);
            return true;
        }
        return false;
    }

    /**
        这个结构
        {
            {
                Name名称
                Path路径
                Data
                {
                    EN
                    {
                        balabl
                    }
                    CN
                    {
                        Balabala
                    }
                }
            }
        }
    **/
    class CpvpLang
    {
        string Name;
        string Path;
        dictionary Data;
        CpvpLang(string _Name, string _Path)
        {
            Name = _Name;
            Path = _Path;
            //构造函数问题只能固定位置
            Data = pvpFile::getINIData( "scripts/plugins/pvp/lang/" + Path + ".ini" );
        }

        string toString()
        {
            return Name + "::" + Path;
        }
    }

    //所有语言数据储存在这里
    array<CpvpLang@> ayLangs = {};
    //从序号获取语言字符串
    array<string> langIndex = {};
    //系统语言
    string sysLang;
    int sysIndex;

    void addLang(string&in name, string&in path)
    {
        //添加新语言
        pvpLang::CpvpLang buffer(name,path);
        //判断是否存在
        int iBuffer = pvpUtility::isExists(ayLangs, name);
        if(iBuffer != -1)
        {
            //存在即替换
            ayLangs.removeAt(iBuffer);
            ayLangs.insertAt(iBuffer, buffer);
        }
        else
        {
            //不存在即添加
            ayLangs.insertLast(buffer);
        }

        //为新语言添加一个Index
        array<string>@ dataKey = buffer.Data.getKeys();
        for(uint i = 0; i < dataKey.length();i++)
        {
            if(pvpUtility::isExists(langIndex, dataKey[i]) == -1)
                langIndex.insertLast(dataKey[i]);
        }
    }

    int getPlayerLangIndex(CBasePlayer@&in pPlayer)
    {
        return atoi(pvpPlayerData::getData(pPlayer, "Lang"));
    }

    //获取语言序号
    int getLangIndex(string&in key)
    {
        return pvpUtility::isExists(langIndex, key);
    }
    //获取序号语言
    string getIndexLang(int&in index)
    {
        uint ui = uint(index);
        if(ui > langIndex.length() - 1)
        {
            pvpLog::log("Lang index out of range! index: " + index, SYSWARN);
            return "";
        }
        return langIndex[ui];
    }

    string sendQueryStr(string&in name, string&in key ,int&in langIndex = sysIndex )
    {
        dictionary dic;
        int iBuffer = pvpUtility::isExists(ayLangs, name);
        if(iBuffer == -1)
        {
            pvpLog::log("Can not get the language info!", 2);
            return "";
        }

        string lang = pvpLang::getIndexLang(langIndex);

        dic = ayLangs[iBuffer].Data;
        //从语言数据内获取字符串
        string tempStr = "";
        //如果没有对应的语言，则使用系统语言
        if(!dic.exists(lang))
            lang = sysLang;
        dictionary tempDic = dictionary(dic[lang]);
        //是不是空的
        if(tempDic is null)
        {
            pvpLog::log("Null language info!Name: " + name + " Key: " + key + " Lang: " + lang, 2);
            return tempStr;
        }
        if(tempDic.exists(key))
        {
            //如果存在该键值则赋值
            tempStr = string(tempDic[key]);
        }
        else
        {
            pvpLog::log("Can not found language info!Name: " + name + " Key: " + key+ " Lang: " + lang, 2);
        }
        return tempStr;
    }

    //方便替换%1 %2的重载
    string getLangStr(string&in name, string&in key ,int&in langIndex = sysIndex)
    {
        return sendQueryStr(name, key, langIndex);
    }

    string getLangStr(string&in name, string&in key ,string&in r1 ,int&in langIndex = sysIndex)
    {
        return sendQueryStr(name, key, langIndex).Replace("%1", r1);
    }

    string getLangStr(string&in name, string&in key ,string&in r1 ,string&in r2 ,int&in langIndex = sysIndex)
    {
        return sendQueryStr(name, key, langIndex).Replace("%1", r1).Replace("%2", r2);
    }

    string getLangStr(string&in name, string&in key ,string&in r1 ,string&in r2 ,string&in r3, int&in langIndex = sysIndex)
    {
        return sendQueryStr(name, key, langIndex).Replace("%1", r1).Replace("%2", r2).Replace("%3", r3);
    }

    string getLangStr(string&in name, string&in key ,string&in r1 ,string&in r2 ,string&in r3, string&in r4, int&in langIndex = sysIndex)
    {
        return sendQueryStr(name, key, langIndex).Replace("%1", r1).Replace("%2", r2).Replace("%3", r3).Replace("%4", r4);
    }
    //四个够了吧
}
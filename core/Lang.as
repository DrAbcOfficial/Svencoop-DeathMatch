namespace pvpLang
{
    void PluginInit()
    {
        pvpLang::addLang("_MAIN_","Main");
        pvpLog::log(pvpLang::getLangStr("_MAIN_", "SYSLANG") + pvpConfig::getConfig("Lang","SysLang"));
    }

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

    array<CpvpLang@> ayLangs = {};

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
    }

    string getLangStr(string&in name, string&in key ,string&in lang = pvpConfig::getConfig("Lang","SysLang"))
    {
        dictionary dic;
        int iBuffer = pvpUtility::isExists(ayLangs, name);
        if(iBuffer == -1)
        {
            pvpLog::log("Can not get the language info!", 2);
            return "";
        }

        dic = ayLangs[iBuffer].Data;
        //从语言数据内获取字符串
        string tempStr = "";
        //如果没有对应的语言，则使用系统语言
        if(!dic.exists(lang))
            lang = pvpConfig::getConfig("Lang","SysLang");
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
}
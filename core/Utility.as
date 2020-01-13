namespace pvpUtility
{
    //取对数
    float getLog(float&in natural, float &in base = 10)
    {
        return log(natural)/log(base);
    }
    //获取SteamId
    string getSteamId( CBasePlayer@ pPlayer )
	{
		return g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	}
    //%Y 年
    //%m 月
    //%d 日
    //%H 时
    //%M 分
    //%S 秒
    string getTime(string&in szFormat = "%Y.%m.%d - %H:%M:%S")
    {
        string szCurrentTime;
        DateTime time;
        time.Format(szCurrentTime, szFormat );
        return szCurrentTime;
    }

    /**
        输出格式应该是
        {
            "key": "val",
            "key": "val",
            "key": "val"
        }
    **/
    string dictionaryToStr(dictionary&in dic)
    {
        string tempStr = "{";
        array<string>@ arKeys = dic.getKeys();   
        for(uint i = 0; i < arKeys.length(); i++)
        {
            tempStr += "\"" + arKeys[i] + "\": \"" + string(dic[arKeys[i]]) + "\"";
            if( i != arKeys.length() - 1)
                tempStr += ",";
        }
        tempStr += "}";
        return tempStr;
    }

    //字符串数组是否存在元素
    int isExists(array<string>&in arr, string&in key)
    {
        for(uint i = 0; i < arr.length(); i++)
        {
            if(key == arr[i])
                return i;
        }
        return -1;
    }

    //语言数据数组是否存在元素
    int isExists(array<pvpLang::CpvpLang@>&in arr, string&in key)
    {
        for(uint i = 0; i < arr.length(); i++)
        {
            if(key == arr[i].Name)
                return i;
        }
        return -1;
    }
}
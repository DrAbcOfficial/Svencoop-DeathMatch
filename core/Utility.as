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

    //字符串到布尔
    bool strTobool(string&in str)
    {
        bool bTemp = false;
        str = tolower(str);
        if(str == "true" || str == "1")
            bTemp = true;
        return bTemp;
    }

    //向量到字符串
    string vecToStr(Vector&in vec)
    {
        return string(vec.x) + "," + string(vec.y) + "," + string(vec.z);
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

    //使用户输入的颜色明显化(将最高一项拉到255)
    Vector preProcessColor(Vector&in vec)
    {
        float max = vec.x;
        max = Math.max(max, vec.y);
        max = Math.max(max, vec.z);
        if(max == 0)
            return Vector(255, 255, 255);
        max = 255/max;
        return Vector(vec.x * max, vec.y * max, vec.z * max);
    }
    //RGBA格式的重载
    RGBA preProcessColor(RGBA&in rgb)
    {
        float max = rgb.r;
        max = Math.max(max, rgb.g);
        max = Math.max(max, rgb.b);
        if(max == 0)
            return RGBA(255, 255, 255, 255);
        max = 255/max;
        return RGBA(uint(rgb.r * max), uint(rgb.g * max), uint(rgb.b * max), 255);
    }
}
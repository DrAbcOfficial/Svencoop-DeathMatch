namespace pvpUtility
{
    //注册一个大家都能用的不带参数的FuncDef
    funcdef void VoidFuncCall();
    //获取字符串类型
    int getStringType(string sz)
    {
        sz.Trim();
        //实数
        Regex::Regex@ pRegex = Regex::Regex("^(-?\\d+)(\\.\\d+)?$");
        //整数
        Regex::Regex@ fRegex = Regex::Regex("^-?[1-9]\\d*$");
        //向量
        Regex::Regex@ vRegex = Regex::Regex("^(-?\\d+)(\\.\\d+)?,(-?\\d+)(\\.\\d+)?,(-?\\d+)(\\.\\d+)?$");
        //二维向量
        Regex::Regex@ v2Regex = Regex::Regex("^(-?\\d+)(\\.\\d+)?,(-?\\d+)(\\.\\d+)?$");
        //颜色
        Regex::Regex@ cRegex = Regex::Regex("^(-?\\d+)?,(-?\\d+)?,(-?\\d+)?,(-?\\d+)?$");
        //布尔型
        string temp = sz;
        if(sz.ToLowercase() == "true" || sz.ToLowercase() == "false")
            return PDATA_BOOL;
        //整数型
        else if(Regex::Match(temp, @fRegex))
            return PDATA_INT;
        //实数型
        else if(Regex::Match(temp, @pRegex))
            return PDATA_FLOAT;
        //二维向量型
        else if(Regex::Match(temp, @v2Regex))
            return PDATA_VECTOR2D;
        //向量型
        else if(Regex::Match(temp, @vRegex))
            return PDATA_VECTOR;
        //颜色型
        else if(Regex::Match(temp, @cRegex))
            return PDATA_RGBA;
        else if(temp.StartsWith("<ARRAY>"))
            return PDATA_ARRAY;
        //字符串
        else
            return PDATA_STRING;
    }
    
    //取对数
    float getLog(float natural, float  base = 10)
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
    string getTime(string szFormat = "%Y.%m.%d - %H:%M:%S")
    {
        string szCurrentTime;
        DateTime time;
        time.Format(szCurrentTime, szFormat );
        return szCurrentTime;
    }

    //获取地图名
    string getMapName()
    {
        return string(g_Engine.mapname).ToLowercase();
    }

    /**
        输出格式应该是
        {
            "key": "val",
            "key": "val",
            "key": "val"
        }
    **/
    string dictionaryToStr(dictionary dic)
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
    bool strTobool(string str)
    {
        bool bTemp = false;
        str = tolower(str);
        if(str == "true" || str == "1")
            bTemp = true;
        return bTemp;
    }

    //向量到字符串
    string vecToStr(Vector vec)
    {
        return string(vec.x) + "," + string(vec.y) + "," + string(vec.z);
    }

    //字符串数组是否存在元素
    int isExists(array<string> arr, string key)
    {
        for(uint i = 0; i < arr.length(); i++)
        {
            if(key == arr[i])
                return i;
        }
        return -1;
    }

    //语言数据数组是否存在元素
    int isExists(array<CPVPLang@> arr, string key)
    {
        for(uint i = 0; i < arr.length(); i++)
        {
            if(key == arr[i].Name)
                return i;
        }
        return -1;
    }

    //使用户输入的颜色明显化(将最高一项拉到255)
    Vector preProcessColor(Vector vec)
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
    RGBA preProcessColor(RGBA rgb)
    {
        float max = rgb.r;
        max = Math.max(max, rgb.g);
        max = Math.max(max, rgb.b);
        if(max == 0)
            return RGBA(255, 255, 255, 255);
        max = 255/max;
        return RGBA(uint(rgb.r * max), uint(rgb.g * max), uint(rgb.b * max), 255);
    }

    //是hitbox吗
    bool isHitbox( CBaseEntity@ pEntity, CBaseEntity@ pOther )
    {
        return pOther.pev.classname == "trigger_hitbox" && pEntity.pev.owner is pOther.pev.owner;
    }

    //帮玩家执行一点小小的指令
    void ClientCommand(CBasePlayer@ pPlayer, const string Arg)
	{
		NetworkMessage m(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict());
			m.WriteString(Arg);
		m.End();
	}

    //所有人，打开菜单！
    void OpenMenuAll(CTextMenu@ pMenu, int page = 0, int item = 0)
    {
        for (int i = 0; i <= g_Engine.maxClients; i++)
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pPlayer !is null && pPlayer.IsConnected())
			{
                 pMenu.Open(page, item, pPlayer);
            }
        }
    }

    //HL式的发送消息
    void SendHLHUDText(string str)
    {
        NetworkMessage message(MSG_BROADCAST, NetworkMessages::HudText, null);
            message.WriteString(str);
            message.WriteByte(2);
        message.End();
    }

    //展示大大的HL标题，哇撒
    void SendHLTitle()
    {
        NetworkMessage m(MSG_BROADCAST, NetworkMessages::GameTitle, null);
            m.WriteByte(1);
        m.End();
    }

    /**
        替换实体成别的东西
    **/
    bool BeApply( CBaseEntity@ ent, const string& in strReplacement )
	{
		CBaseEntity@ pEntity = g_EntityFuncs.Create( strReplacement, ent.pev.origin, ent.pev.angles ,  false , null );
		if ( pEntity is null )
			return false;

		pEntity.pev.targetname = ent.pev.targetname;
		pEntity.pev.maxs = ent.pev.maxs;
		pEntity.pev.mins = ent.pev.mins;
		pEntity.pev.target = ent.pev.target;
		pEntity.pev.scale = ent.pev.scale;
		
		g_EntityFuncs.Remove(ent);
		return true;
	}
	
	void EntityReplacer( string str_Replacee , string str_Replacer )
	{
		CBaseEntity@ entEntity = null;
		while( ( @entEntity = g_EntityFuncs.FindEntityByClassname( entEntity, str_Replacee ) ) !is null )
		{
			if ( BeApply( entEntity, str_Replacer ) )
				continue;
		}
	}

    bool IsPlayerAlive(CBasePlayer@ pPlayer)
	{
		if(pPlayer !is null)
			return pPlayer.IsAlive() && pPlayer.IsConnected() && pPlayer.IsNetClient() && pPlayer.IsPlayer() && !pPlayer.GetObserver().IsObserver();
		return false;
	}
}
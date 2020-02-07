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

    //该结束啦
    void EndGame(float&in flTime = 0.01)
    {
        g_EngineFuncs.CVarSetFloat("mp_timelimit", flTime);
    }

    //重新开启游戏
    void Restart(bool keepInventory = false, bool keepScore = false)
    {
        for (int i = 0; i <= g_Engine.maxClients; i++)
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pPlayer !is null && pPlayer.IsConnected())
			{
                g_PlayerFuncs.RespawnPlayer(pPlayer, true, true);
                pPlayer.pev.health = 100;
		        pPlayer.pev.armorvalue = 0;

                if(!keepInventory)
                {
                    pPlayer.RemoveAllItems(false);
		            pPlayer.SetItemPickupTimes(0);
                    pPlayer.m_fLongJump = false;
                }
                if(!keepScore)
                {
                    pPlayer.pev.frags = 0;
		            pPlayer.m_iDeaths = 0;
                }
            }
        }
    }

    //所有人，打开菜单！
    void OpenMenuAll(CTextMenu@&in pMenu, int&in page = 0, int&in item = 0)
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
    void SendHLHUDText(string&in str)
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
}
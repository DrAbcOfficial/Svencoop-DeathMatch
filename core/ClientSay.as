namespace pvpClientSay
{
    funcdef bool sayCallback(CBasePlayer@, const CCommand@, ClientSayType);

    array<pvpSayFunc@> arypreSayfuncs = {};
    array<pvpSayFunc@> arypostSayfuncs = {};

    class pvpSayFunc
    {
         //提供构造函数方便创建类
	    pvpSayFunc(string _uniName, sayCallback@ _callBack ) 
        {
            uniName = _uniName; 
            @callBack = @_callBack;
        }
        //唯一标识字符串
        string uniName;
        //需要执行的函数
        sayCallback@ callBack;
        //输出为string
        string ToString() 
        { 
            return uniName; 
        }
    }
    //注册
    void RegisteSayFunc(string&in name, sayCallback@&in callback)
    {
        pvpClientSay::arypreSayfuncs.insertLast(pvpClientSay::pvpSayFunc(name, @callback));
    }
    
    //替换原来的全员发送消息
    void sayDelg(CBasePlayer@&in pPlayer, string szSth, ClientSayType SayType)
    {
        if( SayType == CLIENTSAY_SAY )
		{
			if ( pPlayer.IsAlive() == true )
				szSth = string( pPlayer.pev.netname ) + ": " + szSth + "\n";
			else
				szSth = "*DEAD* " + pPlayer.pev.netname + ": " + szSth + "\n";
            g_PlayerFuncs.SayTextAll( pPlayer, szSth );
            g_Log.PrintF( "Msg. " + pvpUtility::getTime() + " - " + szSth);
		}
		else
		{
            //先判断再发送消息，一来减少占用，而来避免bug
            if ( pPlayer.IsAlive() == true )
				szSth = "(TEAM) " + string(pPlayer.pev.netname) + ": " + szSth + "\n";
			else
				szSth = "(TEAM) *DEAD* " + string(pPlayer.pev.netname) + ": " + szSth + "\n";
			for ( int i = 1; i <= g_Engine.maxClients; ++i )
			{
				CBasePlayer@ tPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if ( tPlayer !is null && tPlayer.IsConnected() && tPlayer.GetClassification( 0 ) == pPlayer.GetClassification( 0 ) )
                    g_PlayerFuncs.SayText( tPlayer, szSth );
			}
            g_Log.PrintF( "Msg. in team" + pPlayer.GetClassification(0) + "." + pvpUtility::getTime() + " - " + szSth);
		}
        
    }

    bool preSayHook(CBasePlayer@ pPlayer, const CCommand@ pArgument, ClientSayType SayType)
    {
        bool bFlag = true;
        //遍历数组挨个执行
        for(uint i = 0; i< pvpClientSay::arypreSayfuncs.length(); i++)
        {
            //执行类里的函数,只要有false，那就阻断
            bFlag = bFlag && pvpClientSay::arypreSayfuncs[i].callBack(pPlayer, pArgument, SayType);
        }
        return bFlag;
    }

    void postSayHook(CBasePlayer@ pPlayer, const CCommand@ pArgument, ClientSayType SayType)
    {
        //遍历数组挨个执行
        for(uint i = 0; i< pvpClientSay::arypostSayfuncs.length(); i++)
        {
            pvpClientSay::arypostSayfuncs[i].callBack(pPlayer, pArgument, SayType);
        }
    }
}
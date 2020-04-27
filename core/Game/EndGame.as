#include "../Class/CEndFunc"

namespace pvpEndGame
{
    array<CEndFunc@> aryEndFunc;
    void addEnd(CEndFunc@ data)
    {
        //添加函数到数组内
        aryEndFunc.insertLast(data);
    }

    void setEnd(string&in replaceName, CEndFunc@ data)
    {
        //替换函数
        for(uint i = 0; i< aryEndFunc.length();i++)
        {
            if(aryEndFunc[i].uniName == replaceName)
            {
                aryEndFunc.removeAt(i);
                aryEndFunc.insertAt(i, data);
                return;
            }
        }
        pvpLog::log(pvpLang::getLangStr("_TIMER_","SETERROR") + replaceName, 1);
    }

    void delEnd(string&in funcName)
    {
        //字符串查找数组内函数
        for(uint i = 0; i < aryEndFunc.length(); i++ )
        {
            if(aryEndFunc[i].uniName == funcName)
            {
                //是这个了，删掉
                aryEndFunc.removeAt(i);
                return;
            }
        }
    }

    void delEnd(array<string>&in funcNames)
    {
        //提供一个批量删除的重载
        for(uint j = 0; j < funcNames.length();j++)
        {
            for(uint i = 0; i < aryEndFunc.length(); i++ )
            {
                if(aryEndFunc[i].uniName == funcNames[i])
                {
                    //是这个了，删掉
                    aryEndFunc.removeAt(i);
                }
            }
        }
    }

    //该结束啦
    void End()
    {
        for(uint i = 0; i < aryEndFunc.length();i++)
        {
            aryEndFunc[i].callBack;
        }
        EndGame();
    }

    //直接结束游戏，没事你就不应该调用它
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
}
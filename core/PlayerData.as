#include "Class/CPlayerData"

namespace pvpPlayerData
{
    void PluginInit()
    {
        pvpLang::addLang("_PLAYERDATA_","PlayerData");
        pvpHook::RegisteHook(CHookItem(@pvpPlayerData::PlayerPutinServer, HOOK_PUTINSERVER, "PLAYERDATAPUTINSERVER"));
    }

    void PlayerPutinServer(CBasePlayer@pPlayer)
    {
        if(pPlayer !is null)
            pvpPlayerData::add(pPlayer);
    }

    array<CPlayerData@> arrpData = {};

    void add(CBasePlayer@ pPlayer)
    {
        //添加新的
        for(uint i = 0; i < arrpData.length();i++ )
        {
            //有了
            if(pPlayer is arrpData[i].pPlayer)
            {
                CPlayerData@ pData = CPlayerData(pPlayer);
                pData.Data = arrpData[i].Data;
                arrpData.removeAt(i);
                arrpData.insertAt(i, pData);
                return;
            }
        }
        //没有
        arrpData.insertLast(CPlayerData(pPlayer));
    }

    string getData(CBasePlayer@&in pPlayer, string&in key)
    {
        for(uint i = 0; i < arrpData.length();i++ )
        {
            //有了
            if(pPlayer is arrpData[i].pPlayer)
                return string(arrpData[i].Data[key]);
        }
        //没有
        return "";
    }

    void removeData(CBasePlayer@&in pPlayer, string&in key)
    {
        for(uint i = 0; i < arrpData.length();i++ )
        {
            //有了
            if(pPlayer is arrpData[i].pPlayer)
            {
                arrpData[i].Data.delete(key);
                return;
            }
        }
        //没有
        pvpLog::log(pvpLang::getLangStr("_PLAYERDATA_","QUERROR"));
    }

    //使用前需先转成dValue
    void postData(CBasePlayer@ pPlayer, string&in key, string&in val)
    {
        for(uint i = 0; i < arrpData.length();i++ )
        {
            //有了
            if(pPlayer is arrpData[i].pPlayer)
            {
                arrpData[i].Data.set(key, val);
                return;
            }
        }
        //没有
        pvpLog::log(pvpLang::getLangStr("_PLAYERDATA_","QUERROR"));
    }

    //常见类型的重载
    void addData(CBasePlayer@ pPlayer, string&in key, string&in val)
    {
        postData(pPlayer, key, val);
    }
    void addData(CBasePlayer@ pPlayer, string&in key, int&in val)
    {
        postData(pPlayer, key, string(val));
    }
    void addData(CBasePlayer@ pPlayer, string&in key, uint&in val)
    {
        postData(pPlayer, key, string(val));
    }
    void addData(CBasePlayer@ pPlayer, string&in key, float&in val)
    {
        postData(pPlayer, key, string(val));
    }
    void addData(CBasePlayer@ pPlayer, string&in key, bool&in val)
    {
        postData(pPlayer, key, string(val));
    }
}
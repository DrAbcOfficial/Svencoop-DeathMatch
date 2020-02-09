#include "../Entity/core/CBaseHitbox"

enum DEADTYPE
{
    DEAD_NONE = -1,
    DEAD_KILLED,
    DEAD_SUICIDE,
    DEAD_MONSTER,
    DEAD_ACCIDENT
}

enum PANICHUD_POS
{
    POS_NONE,
    POS_ALL,
    POS_UPPERLEFT = 1,
    POS_TOP,
    POS_UPPERRIGHT,
    POS_RIGHT,
    POS_DOWNERRIGHT,
    POS_DOWN,
    POS_DOWNERLEFT,
    POS_LEFT,
    POS_CENTER
}

namespace pvpHitbox
{
    //复活时间
    const float m_flRespwantime = g_EngineFuncs.CVarGetFloat("mp_respawndelay");
    /**
    @受害者
    @攻击者
    @原始伤害
    @伤害类型
    **/
    funcdef bool preDamageCallback(CBasePlayer@, entvars_t@, float, int);
    //@受害者
    funcdef void postDamageCallback(CBasePlayer@);

    funcdef void deathCallBack(CBasePlayer@, entvars_t@);

    //模型
    string strHitbox = "models/player.mdl";
    //是否显示模型
    bool bShowHitbox = false;
    //伤害指示器spr
    string strPanic;
    //伤害指示器频道
    uint8 uiPanicChannel = 15;
    //友伤指示器spr
    string strFriendly;
    //友伤指示器频道
    uint8 uiFriendlyChannel = 14;
    //玩家RGBA数据库
    dictionary dicPlayerColor;

    void PluginInit()
    {
        pvpLang::addLang("_HITBOX_","Hitbox");
        strHitbox = pvpConfig::getConfig("Hitbox","Model").getString();
        strPanic = pvpConfig::getConfig("Hitbox","PanicSpr").getString();
        bShowHitbox = pvpConfig::getConfig("Hitbox","Show").getBool();
        uiPanicChannel = uint8(pvpConfig::getConfig("Hitbox","PanicChannel").getInt());

        strFriendly = pvpConfig::getConfig("Hitbox","FriendlySpr").getString();
        uiFriendlyChannel = uint8(pvpConfig::getConfig("Hitbox","FriendlyChanel").getInt());
        
        //显示hitbox
        pvpClientCmd::RegistCommand("admin_showhitbox","Show hitbox or not","Hitbox",@pvpHitbox::ChangeShowCall, CCMD_ADMIN);
        //改变伤害指示器颜色
        pvpClientCmd::RegistCommand("player_paniccolor","Change your panic indicator color","Hitbox",@pvpHitbox::PanicColorCall);
    }

    void MapInit()
    {
        HitboxRegister();
    }

    void playerSpawn( CBasePlayer@ pPlayer )
	{
		CreateHitbox(pPlayer);
	}

    void RemoveHitbox(CBasePlayer@ pPlayer)
    {
        CBaseEntity@ pEntity = null;
        while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, pvpUtility::getSteamId(cast<CBasePlayer@>(pPlayer)))) !is null)
        {
            g_EntityFuncs.Remove(pEntity);
        }
    }

    void checkPlayerHitbox(CBasePlayer@ pPlayer)
    {
        //能触发，但是不阻挡
        pPlayer.pev.solid = SOLID_TRIGGER;
    }

    void PanicColorCall(const CCommand@ pArgs)
    {
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        if(pArgs.ArgC() < 4)
        {
            pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "AVACMD", pPlayer));
            pvpLog::say(pPlayer, ".player_paniccolor <Red> <Green> <Blue>");
            pvpLog::say(pPlayer, "Example: player_paniccolor 255 0 123");
            return;
        }
        dicPlayerColor[pvpUtility::getSteamId(pPlayer)] = pvpUtility::preProcessColor(RGBA(atoui(pArgs[1]), atoui(pArgs[2]), atoui(pArgs[3]), 255));
        pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDON", pPlayer));
    }

    void doCommand()
    {
        pvpConfig::setConfig("Hitbox","Show", bShowHitbox);

        CBaseEntity@ pEntity = null;
        while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "trigger_hitbox")) !is null)
        {
            if(bShowHitbox == false)
            {
                pEntity.pev.rendermode = kRenderTransTexture;
                pEntity.pev.renderamt = 0;
            }
            else
            {
                pEntity.pev.rendermode = 0;
                pEntity.pev.renderamt = 100;
            }
        }
    }

    void ChangeShowCall(const CCommand@ pArgs)
	{
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        int tempInt = 0;
        if(pArgs.ArgC() == 1)
        {
            bShowHitbox = !bShowHitbox;
            doCommand();
            pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDTLG", pPlayer));
            return;
        }
        string tempStr = pArgs[1].ToUppercase();
        tempStr.Trim();
        tempInt = Math.clamp(0 ,1, atoi(tempStr));
        switch(tempInt)
        {
            case 0: bShowHitbox = false;pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDOFF", pPlayer));break;
            case 1: bShowHitbox = true; pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDON", pPlayer));break;
        }
        doCommand();
	}

    //角度分划表
    const array<double> aryPanicAngles = { 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5 };
    //区块分划表
    const array<array<int>> mapPanicIndex = {
        {POS_TOP},
        {POS_UPPERRIGHT},
        {POS_NONE, POS_RIGHT},
        {POS_NONE, POS_NONE, POS_DOWNERRIGHT},
        {POS_NONE, POS_NONE, POS_NONE, POS_DOWN},
        {POS_NONE, POS_NONE, POS_NONE, POS_NONE, POS_DOWNERLEFT},
        {POS_NONE, POS_NONE, POS_NONE, POS_NONE, POS_NONE, POS_LEFT},
        {POS_NONE, POS_NONE, POS_NONE, POS_NONE, POS_NONE, POS_NONE, POS_UPPERLEFT, POS_TOP}
    };
    //SPR区块分划表
    const array<array<uint8>> mapHudPos={
        {0,0,0},
        {170,0,86},
        {86,0,84},
        {0,0,86},
        {0,86,84},
        {0,170,86},
        {86,170,84},
        {170,170,86},
        {170,86,84},
        {86,86,84}
    };
    //XY偏移量表
    const array<Vector2D> mapSprXY={
        Vector2D(0,0),
        Vector2D(0.1,-0.1),
        Vector2D(0,-0.1),
        Vector2D(-0.1,-0.1),
        Vector2D(-0.1,0),
        Vector2D(-0.1,0.1),
        Vector2D(0,0.1),
        Vector2D(0.1,0.1),
        Vector2D(0.1,0),
        Vector2D(0,0)
    };
    void sendPanicFeed(CBasePlayer@pPlayer, entvars_t@ pevAttacker, entvars_t@ pevInflictor)
    {
         /**
            spr切分序号
            3 2 1
            4 9 8       0 代表不切分整个送出
            5 6 7
        **/
        //HUD序号，默认整个HUD图都推送
        int indexHud = 0;

        //是大地打的你！
        CBaseEntity@ pAttacker = g_EntityFuncs.Instance(pevAttacker);
        if(!pAttacker.IsPlayer() && !pAttacker.IsMonster())
            indexHud = 9;
        else
        {
            //谁才是真的攻击者
            entvars_t@ tempEntity = null;
            if( pevInflictor.classname == "player" )
                @tempEntity = @pevAttacker;
            else
                @tempEntity = @pevInflictor;

            //获取攻击者坐标
            Vector vecAttack = tempEntity.origin;
            //获取受害者坐标
            Vector vecVictim = pPlayer.pev.origin;
            //获取最终的向量
            Vector vecFinal = vecAttack - vecVictim;
            //不要z轴，即取xy面的投影
            vecFinal = Vector(vecFinal.x, vecFinal.y, 0);
            //获取长度
            float flLength = vecFinal.Length();
            //只有不在你头上脚下的才全推
            if(flLength > 32)
            {
                //化向量为极坐标
                vecFinal = Math.VecToAngles(vecFinal);
                //以玩家角度为轴
                vecFinal = vecFinal - pPlayer.pev.angles;
                //pvpLog::log(vecFinal);
                /**
                    只需要y坐标
                        0
                    90 你  270
                        180
                **/
                float flAngle = vecFinal.y;
                //pvpLog::log(flAngle);
                /**
                        大于   小于
                    1: 292.5 ~ 337.5
                    2: 337.5 | 22.5
                    3: 22.5 ~ 67.5
                    4: 67.5 ~ 112.5
                    5: 112.5 ~ 157.5
                    6: 157.5 ~ 202.5
                    7: 202.5 ~ 247.5
                    8: 247.5 ~ 292.5
                **/
                //获取比较值最小的序号
                int indexMin = -1;
                for(uint i = 0; i < aryPanicAngles.length();i++)
                {
                    if( flAngle < aryPanicAngles[i])
                    {
                        indexMin = i;
                        break;
                    }
                }
                //没有比这个大的，返回数组长度 - 1
                if(indexMin == -1)
                    indexMin = aryPanicAngles.length() - 1;
                //获取比较值最大的序号
                int indexMax = -1;
                for(uint i = aryPanicAngles.length() - 1; i > 0;i--)
                {
                    if( flAngle > aryPanicAngles[i])
                    {
                        indexMax = i;
                        break;
                    }
                }
                //没有比这个小的，返回0
                if(indexMax == -1)
                    indexMax = 0;
                /** Min Max Index
                    0    0 - 2
                    1    0 - 3
                    2    1 - 4
                    3    2 - 5
                    4    3 - 6
                    5    4 - 7
                    6    5 - 8
                    7    6 - 1
                    7    7 - 2
                **/
                indexHud = mapPanicIndex[indexMin][indexMax];
            }
        }
        /**     top↓
            left→ ←width
                height↑
            i   l   t   w   h
            1   170 0   86  86
            2   86  0   84  84
            3   0   0   86  86
            4   0   86  84  84
            5   0   170 86  86
            6   86  170 84  84
            7   170 170 86  86
            8   170 86  84  84
            9   86  86  84  84
        **/
        //输出hud了
        HUDSpriteParams params;
            params.channel = uiPanicChannel;
		    params.flags = HUD_ELEM_DEFAULT_ALPHA | HUD_ELEM_SCR_CENTER_X | HUD_ELEM_SCR_CENTER_Y;
            params.x = mapSprXY[indexHud].x;
            params.y = mapSprXY[indexHud].y;
            params.spritename = strPanic;
            string steamId = pvpUtility::getSteamId(pPlayer);
            params.color1 = dicPlayerColor.exists(steamId) ? RGBA(dicPlayerColor[steamId]) : RGBA_RED;
            params.holdTime = 1;
            params.fadeoutTime = 0.1;
            params.left = mapHudPos[indexHud][0];
            params.top = mapHudPos[indexHud][1];
            params.width = mapHudPos[indexHud][2];
            params.height = mapHudPos[indexHud][2];
        g_PlayerFuncs.HudCustomSprite(pPlayer, params);
    }

    //我他妈血流满地啊
    void FriendlyFire(CBasePlayer@ vPlayer, entvars_t@ pevAttacker)
    {
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(pevAttacker));
        //不是玩家你看你🐎呢？
        if(pPlayer.IsPlayer() && pPlayer.IsNetClient())
        {
            HUDSpriteParams params;
                params.channel = uiFriendlyChannel;
                params.flags = HUD_ELEM_DEFAULT_ALPHA | HUD_ELEM_SCR_CENTER_X | HUD_ELEM_SCR_CENTER_Y;
                params.x = 0;
                params.y = 0;
                params.spritename = strFriendly;
                string steamId = pvpUtility::getSteamId(pPlayer);
                params.color1 = dicPlayerColor.exists(steamId) ? RGBA(dicPlayerColor[steamId]) : RGBA_GREEN;
                params.holdTime = 1;
                params.fadeoutTime = 0.1;
            g_PlayerFuncs.HudCustomSprite(pPlayer, params);
        }
    }

    //这些都是写死的静态的东西，大概这样能少点内存占用？
    //他杀
    string doKillFeed(CBaseEntity@ pAttacker , CBaseEntity@ pInflictor ,int&in index)
    {
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(pAttacker);
        string Inflicetor = pInflictor.GetClassname();
        if( Inflicetor == "player" )
            Inflicetor = string(pPlayer.m_hActiveItem.GetEntity().pev.classname);
        return string(pvpLang::getLangStr("_HITBOX_",Inflicetor)) == "" ? Inflicetor : string(pvpLang::getLangStr("_HITBOX_",Inflicetor, index));
    }
    
    //自杀
    string doSuicide(CBasePlayer@ m_pPlayer, int bitsDamageType, int&in index)
    {
        string suicidereason = "";
        int8 deathtype = 0;
        if((bitsDamageType & DMG_BLAST != 0) || (bitsDamageType & DMG_MORTAR != 0))
             deathtype = Math.RandomLong(4,5);
        else
            deathtype = Math.RandomLong(0,3);
        suicidereason = pvpLang::getLangStr("_HITBOX_","DSUI" + deathtype, string(m_pPlayer.pev.netname), index);
        return suicidereason;
    }
    //怪物杀
    string doMonsterKill(CBasePlayer@ m_pPlayer, CBaseEntity@ pInflictor ,int&in index)
    {
        CBaseMonster@ pMonster = cast<CBaseMonster@>(pInflictor);
        string szOwnername = "";
        if(pMonster.pev.owner !is null)
            szOwnername = pvpLang::getLangStr("_HITBOX_","DMN0", string(pMonster.pev.owner.vars.netname), index);
        return szOwnername + pvpLang::getLangStr("_HITBOX_","DMN" + Math.RandomLong(1,2), string(pMonster.m_FormattedName), string(m_pPlayer.pev.netname), index);
    }
    //意外杀
    string doAccident(CBasePlayer@ m_pPlayer, int bitsDamageType ,int&in pIndex)
    {
        int index = int(pvpUtility::getLog(bitsDamageType,2));
        string szReturn = pvpLang::getLangStr("_HITBOX_","DAC" + index + Math.RandomLong(0,1), string(m_pPlayer.pev.netname), pIndex);
        return szReturn.IsEmpty() ? pvpLang::getLangStr("_HITBOX_","DACA" + Math.RandomLong(0,1), string(m_pPlayer.pev.netname), pIndex) : szReturn;
    }

    //创建一个Hitbox方法
    CBaseHitbox@ CreateHitbox( CBasePlayer@ pPlayer)
    {
        CBaseEntity@ preEntity = g_EntityFuncs.Create( "trigger_hitbox", pPlayer.pev.origin, pPlayer.pev.angles, true, pPlayer.edict());
        CBaseHitbox@ pHitbox = cast<CBaseHitbox@>(CastToScriptClass(preEntity));
        pHitbox.pev.targetname = pvpUtility::getSteamId(pPlayer);
        g_EntityFuncs.DispatchSpawn( preEntity.edict() );
        return pHitbox;
    }

    //获得玩家的hitbox
    CBaseHitbox@ GetHitBox(CBasePlayer@&in pPlayer)
    {
        CBaseEntity@ preEntity = g_EntityFuncs.FindEntityByTargetname(preEntity, pvpUtility::getSteamId(cast<CBasePlayer@>(pPlayer)));
        return cast<CBaseHitbox@>(CastToScriptClass(preEntity));
    }
 
    //伤害前hook
    array<preDamageCallback@> preCallList = {};
    bool PreTakeDamage(CBasePlayer@pPlayer, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
    {
        bool bFlag = true;
        //遍历数组挨个执行
        for(uint i = 0; i< pvpHitbox::preCallList.length(); i++)
        {
            //执行类里的函数,只要有false，那就阻断
            bFlag = bFlag && pvpHitbox::preCallList[i](pPlayer, pevAttacker, flDamage, bitsDamageType);
        }
        return bFlag;
    }

    void addPreTakeDamage(preDamageCallback@ data)
    {
        //添加函数到数组内
        preCallList.insertLast(data);
    }

    void setPreTakeDamage(preDamageCallback@ data1, preDamageCallback@ data2)
    {
        //替换函数
        for(uint i = 0; i< preCallList.length();i++)
        {
            if(preCallList[i] is data1)
            {
                preCallList.removeAt(i);
                preCallList.insertAt(i, data2);
                return;
            }
        }
    }

    void delPreTakeDamage(preDamageCallback@ data)
    {
        //字符串查找数组内函数
        for(uint i = 0; i < preCallList.length(); i++ )
        {
            if(preCallList[i] is data)
            {
                //是这个了，删掉
                preCallList.removeAt(i);
                return;
            }
        }
    }

    //伤害后hook
    array<postDamageCallback@> postCallList = {};
    void PostTakeDamage(CBasePlayer@pPlayer)
    {
        //遍历数组挨个执行
        for(uint i = 0; i< pvpHitbox::postCallList.length(); i++)
        {
            //执行类里的函数
            pvpHitbox::postCallList[i](pPlayer);
        }
    }

    void addPostTakeDamage(postDamageCallback@ data)
    {
        //添加函数到数组内
        postCallList.insertLast(data);
    }

    void setPostTakeDamage(postDamageCallback@ data1, postDamageCallback@ data2)
    {
        //替换函数
        for(uint i = 0; i< postCallList.length();i++)
        {
            if(postCallList[i] is data1)
            {
                postCallList.removeAt(i);
                postCallList.insertAt(i, data2);
                return;
            }
        }
    }

    void delPostTakeDamage(postDamageCallback@ data)
    {
        //字符串查找数组内函数
        for(uint i = 0; i < postCallList.length(); i++ )
        {
            if(postCallList[i] is data)
            {
                //是这个了，删掉
                postCallList.removeAt(i);
                return;
            }
        }
    }

    //死亡后hook
    array<deathCallBack@> deathCallList = {};
    void PostDeath(CBasePlayer@pPlayer, entvars_t@ pevAttacker)
    {
        //遍历数组挨个执行
        for(uint i = 0; i< pvpHitbox::deathCallList.length(); i++)
        {
            //执行类里的函数
            pvpHitbox::deathCallList[i](pPlayer, pevAttacker);
        }
    }

    void addPostDeath(deathCallBack@ data)
    {
        //添加函数到数组内
        deathCallList.insertLast(data);
    }

    void setPostDeath(deathCallBack@ data1, deathCallBack@ data2)
    {
        //替换函数
        for(uint i = 0; i< deathCallList.length();i++)
        {
            if(deathCallList[i] is data1)
            {
                deathCallList.removeAt(i);
                deathCallList.insertAt(i, data2);
                return;
            }
        }
    }

    void delPostDeath(deathCallBack@ data1)
    {
        //字符串查找数组内函数
        for(uint i = 0; i < deathCallList.length(); i++ )
        {
            if(deathCallList[i] is data1)
            {
                //是这个了，删掉
                deathCallList.removeAt(i);
                return;
            }
        }
    }

}
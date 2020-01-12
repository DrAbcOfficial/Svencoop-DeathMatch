/**
    TO DO
    1.只有第一个玩家才有伤害，或者会乱掉
    2.玩家碰撞体积删不掉
    3.爆炸伤害判定神秘
    4.或许可以关掉怪物的AI然后用怪物载入？这样就不会内存泄漏了
**/

namespace pvpHitbox
{
    void PluginInit()
    {
        pvpLang::addLang("_HITBOX_","Hitbox");
    }

    void MapInit()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "trigger_hitbox", "trigger_hitbox" );
		g_Game.PrecacheOther("trigger_hitbox");
    }

    void playerSpawn( CBasePlayer@ pPlayer )
	{
		CBaseEntity@ pEntity = g_EntityFuncs.Create( "trigger_hitbox", pPlayer.pev.origin, pPlayer.pev.angles, true, pPlayer.edict());
        pEntity.pev.targetname = pvpUtility::getSteamId(pPlayer);
        g_EntityFuncs.DispatchSpawn( pEntity.edict() );
	}

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

    array<preDamageCallback@> preCallList = {};
    array<postDamageCallback@> postCallList = {};
}

class trigger_hitbox : ScriptBaseMonsterEntity
{
    private Vector m_vecMins,m_vecMaxs;
    private CBasePlayer@ m_pPlayer = null;
    CBaseEntity@ OwnerEnt
    {
        get const	{ return g_EntityFuncs.Instance( pev.owner ); }
    }
    
    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        return BaseClass.KeyValue( szKey, szValue );
    }

    void Precache()
    {
        BaseClass.Precache();
        g_Game.PrecacheModel( self, "models/player.mdl" );
        g_Game.PrecacheModel( self, "models/playert.mdl" );
    }

    void Spawn()
    {
        Precache();
        @m_pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(pev.owner));
        g_EntityFuncs.SetModel( self, "models/player.mdl" );
        
        if( pev.owner !is null )
        {
            pev.health = Math.FLOAT_MAX;
            pev.movetype	= MOVETYPE_FOLLOW;
            @pev.aiment		= @pev.owner;
            pev.solid		= SOLID_SLIDEBOX;
            pev.flags |= FL_MONSTER;
            pev.takedamage	= DAMAGE_YES;
            m_pPlayer.pev.solid = SOLID_NOT;
            pev.colormap	= pev.owner.vars.colormap;
            self.m_bloodColor	= BLOOD_COLOR_RED;
            self.m_FormattedName = m_pPlayer.pev.netname;

            m_vecMins = pev.owner.vars.mins;
            m_vecMaxs = pev.owner.vars.maxs;
            g_EntityFuncs.SetSize( pev, m_vecMins, m_vecMaxs );
        }
        //self.MonsterInit();
    }

    //他杀
    string doKillFeed(CBaseEntity@ pAttacker , CBaseEntity@ pInflictor )
    {
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(pAttacker);
        string Inflicetor = pInflictor.GetClassname();
        if( Inflicetor == "player" )
            Inflicetor = string(pPlayer.m_hActiveItem.GetEntity().pev.classname);
        pAttacker.pev.frags++;
        return string(pvpLang::getLangStr("_HITBOX_",Inflicetor)) == "" ? Inflicetor : string(pvpLang::getLangStr("_HITBOX_",Inflicetor));
    }
    
    //自杀
    string doSuicide(int bitsDamageType)
    {
        string suicidereason = "";
        int8 deathtype = 0;
        if((bitsDamageType & DMG_BLAST != 0) || (bitsDamageType & DMG_MORTAR != 0))
             deathtype = Math.RandomLong(4,5);
        else
            deathtype = Math.RandomLong(0,3);
        suicidereason = pvpLang::getLangStr("_HITBOX_","DSUI" + deathtype).Replace("%1", string(m_pPlayer.pev.netname));
        --m_pPlayer.pev.frags;
        return suicidereason;
    }
    //怪物杀
    string doMonsterKill(CBaseEntity@ pInflictor )
    {
        CBaseMonster@ pMonster = cast<CBaseMonster@>(pInflictor);
        string szOwnername = "";
        if(pMonster.pev.owner !is null)
            szOwnername = pvpLang::getLangStr("_HITBOX_","DMN0").Replace("%1", string(pMonster.pev.owner.vars.netname));
        return szOwnername + pvpLang::getLangStr("_HITBOX_","DMN" + Math.RandomLong(1,2)).Replace("%1", string(pMonster.m_FormattedName)).Replace("%2", string(m_pPlayer.pev.netname));
    }
    //意外杀
    string doAccident( int bitsDamageType )
    {
        int index = int(pvpUtility::getLog(bitsDamageType,2));
        string szReturn = pvpLang::getLangStr("_HITBOX_","DAC" + index + Math.RandomLong(0,1)).Replace("%1", string(m_pPlayer.pev.netname));
        return szReturn.IsEmpty() ? pvpLang::getLangStr("_HITBOX_","DACA" + Math.RandomLong(0,1)).Replace("%1", string(m_pPlayer.pev.netname)) : szReturn;
    }
    //大概是真的死了
    void doDeath( float&in flTake )
    {
        if( flTake <= 200 )
            m_pPlayer.SetAnimation( PLAYER_DIE );
        else
        {	
            m_pPlayer.pev.rendermode = 1;
            m_pPlayer.pev.renderamt = 0;
            g_EntityFuncs.SpawnRandomGibs(m_pPlayer.pev, 1, 1);
            g_SoundSystem.PlaySound(m_pPlayer.edict(), CHAN_AUTO, "common/bodysplat.wav", 1.0f, 1.0f);
        }
        m_pPlayer.pev.health = 0;
        m_pPlayer.pev.armorvalue = 0;
        m_pPlayer.pev.deadflag = DEAD_DYING;
        ++m_pPlayer.m_iDeaths;
        //别忘了摧毁这个Hitbox
        g_EntityFuncs.Remove(self);
    }

    int DeliverDamage(float&in Ap, float&in Hp,float&in Take, entvars_t@ pevAttacker, entvars_t@ pevInflictor, int bitsDamageType)
    {
        CBasePlayer@ pAttacker = cast<CBasePlayer@>(g_EntityFuncs.Instance(pevAttacker));
        CBaseEntity@ pInflictor = g_EntityFuncs.Instance(pevInflictor);
        //扣血扣甲
        m_pPlayer.pev.armorvalue = Ap;
        m_pPlayer.pev.health = Hp;
        //如果死亡将玩家传递死亡，并用keyvalue标记为已死
        if (m_pPlayer.pev.health <= 0)
        {
            string szPrintf = "";
            if(pAttacker !is null && pAttacker.IsPlayer() && pAttacker.IsNetClient())
            {
                if(g_Engine.time - m_pPlayer.m_fDeadTime > pvpHitbox::m_flRespwantime)
                {
                    if( pAttacker !is m_pPlayer )	
                        szPrintf = string(pAttacker.pev.netname) + " :: ["  + doKillFeed(pAttacker, pInflictor) + "] :: " + string(m_pPlayer.pev.netname) + "\n";
                    else
                        szPrintf = doSuicide(bitsDamageType);
                }
            }
            else if(pAttacker !is null && pAttacker.IsMonster())
                szPrintf = doMonsterKill(pInflictor);
            else
                szPrintf = doAccident(bitsDamageType);
            //大概是真的死了
            doDeath(Take);
            //左上角来点输出
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTNOTIFY, szPrintf);
            //此时返回1
            return 1;
        }
        //0代表正常,玩家未死
        return 0;
    }

    bool PreTakeDamage(entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
    {
        bool bFlag = true;
        //遍历数组挨个执行
        for(uint i = 0; i< pvpHitbox::preCallList.length(); i++)
        {
            //执行类里的函数,只要有false，那就阻断
            bFlag = bFlag && pvpHitbox::preCallList[i](m_pPlayer, pevAttacker, flDamage, bitsDamageType);
        }
        return bFlag;
    }

    void PostTakeDamage()
    {
        //遍历数组挨个执行
        for(uint i = 0; i< pvpHitbox::preCallList.length(); i++)
        {
            //执行类里的函数
            pvpHitbox::postCallList[i](m_pPlayer);
        }
    }

    int TakeDamage(entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
    {
        BaseClass.TakeDamage( pevInflictor,  pevAttacker, flDamage, bitsDamageType);
        //摔伤不用这个算
        if(pevAttacker is null)
            return 0;
        //先修改伤害信息
        //先获取属主血量护甲量
        float pPlayerHp = m_pPlayer.pev.health;
        float pPlayerAp = m_pPlayer.pev.armorvalue;
        if (pPlayerAp != 0 && !(bitsDamageType & (DMG_FALL | DMG_DROWN) != 0) )
	    {
            //从配置中获取减伤率和加成量
            float flARRatio = 0;
            flARRatio = atof(pvpConfig::getConfig("Hitbox","ARRatio"));
            float flARBonus = 0;
            flARBonus = atof(pvpConfig::getConfig("Hitbox","ARBonus"));
            //计算护甲减伤，算出扣甲量
            float flDamageNew = flDamage * flARRatio;
            float flArmor = (flDamage - flDamageNew) * flARBonus;
            if (flArmor > pPlayerAp)
            {
                flArmor = pPlayerAp;
                flArmor *= (1.0f/flARBonus);
                flDamageNew = flDamage - flArmor;
                pPlayerAp = 0;
            }
            else
                pPlayerAp -= flArmor;
            flDamage = flDamageNew;
        }

        float flTake = flDamage;
        //g_Game.AlertMessage( at_console, "2." + flTake + "\n" );
        pPlayerHp -= flTake;
        //然后传递给属主
        if(PreTakeDamage(pevAttacker, flDamage, bitsDamageType))
            DeliverDamage(pPlayerAp, pPlayerHp, flTake, pevAttacker, pevInflictor, bitsDamageType);
        PostTakeDamage();
        //直接结束，不call原来的
        flDamage = 0;//记得清空这个
        bitsDamageType = 0;
        return 0;
    }

    //该死的这样会导致内存分配打架
    //他死，我不能死
    //void Killed(entvars_t@ pevAttacker, int iGib)
    //{
    //    return;
    //}
}

#include "../Class/CHookItem"

enum HOOKTYPE
{
    HOOK_NULL,
    HOOK_DISCONNECT = 1,
    HOOK_KILLED,
    HOOK_SPAWN,
    HOOK_PUTINSERVER,
    HOOK_PRESAY,
    HOOK_POSTSAY,
    HOOK_PRETHINK,
    HOOK_PREDAMAGE,
    HOOK_POSTDAMAGE
}
namespace pvpHook
{
    void PluginInit()
    {
        g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage);
		g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
        g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
        g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
        g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @PlayerKilled);
        g_Hooks.RegisterHook(Hooks::Player::PlayerPreThink, @PlayerPreThink);
        g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);

        pvpLang::addLang("_HOOK_","Hook");
    }

    array<CHookItem@> aryHooks = {};

    /**
    @受害者
    @攻击者
    @原始伤害
    @伤害类型
    **/
    funcdef bool HookFuncPreDamage(CBasePlayer@, entvars_t@, float, int);
    funcdef void HookFuncDeath(CBasePlayer@, CBaseEntity@);
    funcdef void HookFuncPlayer (CBasePlayer@);
    funcdef bool HookFuncPreSay(CBasePlayer@, const CCommand@, ClientSayType);
    funcdef void HookFuncPostSay(CBasePlayer@, const CCommand@, ClientSayType);

    string GetTypeName(int Type)
    {
        string tempStr;
        switch(Type)
        {
            case HOOK_NULL:tempStr = "Null";break;
            case HOOK_DISCONNECT:tempStr = "Player Disconnect";break;
            case HOOK_KILLED:tempStr = "Player Killed";break;
            case HOOK_SPAWN:tempStr = "Player Spawn";break;
            case HOOK_PUTINSERVER:tempStr = "Player Put in Server";break;
            case HOOK_PRESAY:tempStr = "Player Pre-Say";break;
            case HOOK_POSTSAY:tempStr = "Player Post-Say";break;
            case HOOK_PRETHINK:tempStr = "Player Pre-Think";break;
            case HOOK_PREDAMAGE:tempStr = "Player Pre-Damage";break;
            case HOOK_POSTDAMAGE:tempStr = "Player Post-Damage";break;
            default:tempStr = "Null";break;
        }
        return tempStr;
    }

    void RegisteHook(CHookItem@ pHook)
    {
        if(GetHook(pHook) is null)
        {
            aryHooks.insertLast(pHook);
            pvpLog::log(pvpLang::getLangStr("_HOOK_", "REGISTED", pHook.Name, GetTypeName(pHook.Type)));
        }
        else
            pvpLog::log(pvpLang::getLangStr("_HOOK_", "EXISTHOOK", pHook.Name));
    }

    void RegisteHook(ref@ pRef, int Type, string Name)
    {
        if(!GetHook(Name).IsNull())
        {
            aryHooks.insertLast(CHookItem(pRef, Type, Name));
            pvpLog::log(pvpLang::getLangStr("_HOOK_", "REGISTED", Name, GetTypeName(Type)));
        }
        else
            pvpLog::log(pvpLang::getLangStr("_HOOK_", "EXISTHOOK", Name));
    }

    CHookItem@ GetHook(string name)
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Name == name)
                return @aryHooks[i];
        }
        return null;
    }

    CHookItem@ GetHook(CHookItem@ pHook)
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(@aryHooks[i] is @pHook)
                return @aryHooks[i];
        }
        return null;
    }

    bool RemoveHook(string name)
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Name == name)
            {
                aryHooks.removeAt(i);
                return true;
            }
        }
        pvpLog::log(pvpLang::getLangStr("_HOOK_", "REMOVEFAIL"));
        return false;
    }

    HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer )
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Type == HOOK_DISCONNECT)
                cast<HookFuncPlayer@>(aryHooks[i].Get())(pPlayer);
        }
        return HOOK_HANDLED;
    }


    HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Type == HOOK_KILLED)
                cast<HookFuncDeath@>(aryHooks[i].Get())(pPlayer, pAttacker);
        }
        return HOOK_HANDLED;
    }

    HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Type == HOOK_SPAWN && !aryHooks[i].IsNull())
                cast<HookFuncPlayer@>(aryHooks[i].Get())(pPlayer);
        }
        return HOOK_HANDLED;
    }

    bool PreTakeDamage(CBasePlayer@pPlayer, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
    {
        bool bFlag = true;
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Type == HOOK_PREDAMAGE && !aryHooks[i].IsNull())
                cast<HookFuncPreDamage@>(aryHooks[i].Get())(pPlayer, pevAttacker, flDamage, bitsDamageType);
        }
        return bFlag;
    }
   
    void PostTakeDamage(CBasePlayer@pPlayer)
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Type == HOOK_POSTDAMAGE && !aryHooks[i].IsNull())
                cast<HookFuncPlayer@>(aryHooks[i].Get())(pPlayer);
        }
    }

    void PostDeath(CBasePlayer@pPlayer, CBaseEntity@ pAttacker)
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Type == HOOK_KILLED && !aryHooks[i].IsNull())
                cast<HookFuncDeath@>(aryHooks[i].Get())(pPlayer, pAttacker);
        }
    }

    HookReturnCode PlayerTakeDamage(DamageInfo@ info)
    {
        CBaseEntity@ pPlayer = g_EntityFuncs.Instance(info.pVictim.pev);
        CBaseEntity@ pAttacker = g_EntityFuncs.Instance(info.pAttacker.pev);
        CBaseEntity@ pInflictor = g_EntityFuncs.Instance(info.pInflictor.pev);
        if(pPlayer is pAttacker || (pAttacker !is null && pInflictor!is null))
        {
            CBaseHitbox@ pHitbox = pvpHitbox::GetHitBox(cast<CBasePlayer@>(pPlayer));
            if(pHitbox !is null)
                pHitbox.TakeDamage(info.pInflictor.pev, info.pAttacker.pev, info.flDamage, info.bitsDamageType);
        }
        info.flDamage = 0;
        return HOOK_CONTINUE;
    }

    HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Type == HOOK_PUTINSERVER && !aryHooks[i].IsNull())
                cast<HookFuncPlayer@>(aryHooks[i].Get())(pPlayer);
        }
        return HOOK_HANDLED;
    }

    bool PreSayHook(CBasePlayer@ pPlayer, const CCommand@ pArgument, ClientSayType SayType)
    {
        bool bFlag = true;
        //遍历数组挨个执行
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Type == HOOK_PRESAY && !aryHooks[i].IsNull())
                bFlag = bFlag && cast<HookFuncPreSay@>(aryHooks[i].Get())(pPlayer, pArgument, SayType);
        }
        return bFlag;
    }

    void PostSayHook(CBasePlayer@ pPlayer, const CCommand@ pArgument, ClientSayType SayType)
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Type == HOOK_POSTSAY && !aryHooks[i].IsNull())
                cast<HookFuncPostSay@>(aryHooks[i].Get())(pPlayer, pArgument, SayType);
        }
    }

    HookReturnCode ClientSay(SayParameters@ pParams) 
    {
        CBasePlayer@ pPlayer = pParams.GetPlayer();
        ClientSayType type = pParams.GetSayType();
        pParams.set_ShouldHide(true);
        if(pvpHook::PreSayHook(pPlayer, pParams.GetArguments(), type))
            pvpLog::SayDelg(pPlayer, pParams.GetCommand(), type);
        pvpHook::PostSayHook(pPlayer, pParams.GetArguments(), type);
        return HOOK_HANDLED;
    }

    HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
    {
        for(uint i = 0; i < aryHooks.length(); i++)
        {
            if(aryHooks[i].Type == HOOK_PRETHINK && !aryHooks[i].IsNull())
                cast<HookFuncPlayer@>(aryHooks[i].Get())(pPlayer);
        }
        return HOOK_HANDLED;
    }
}
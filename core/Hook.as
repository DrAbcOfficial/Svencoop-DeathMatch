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
    }

    HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer )
    {
        pvpHitbox::RemoveHitbox(pPlayer);
        pvpTeam::ClientDisconnect(pPlayer);
        return HOOK_HANDLED;
    }


    HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
    {
        pvpHitbox::RemoveHitbox(pPlayer);
        return HOOK_HANDLED;
    }

    HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
    {
        pvpHitbox::playerSpawn(pPlayer);
        ClassiscWeapon::PlayerSpwan(pPlayer);
        CS::PlayerSpawn(pPlayer);
        return HOOK_HANDLED;
    }

    HookReturnCode PlayerTakeDamage(DamageInfo@ info)
    {
        CBaseEntity@ pPlayer = g_EntityFuncs.Instance(info.pVictim.pev);
        CBaseEntity@ pAttacker = g_EntityFuncs.Instance(info.pAttacker.pev);
        CBaseEntity@ pInflictor = g_EntityFuncs.Instance(info.pInflictor.pev);

        //我杀我自己
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
        pvpPlayerData::PlayerPutinServer(pPlayer);
        pvpLang::PlayerPutinServer(pPlayer);
        ClassiscWeapon::PlayerPutinServer(pPlayer);
        CS::PlayerPutinServer(pPlayer);
        
        return HOOK_HANDLED;
    }

    HookReturnCode ClientSay(SayParameters@ pParams) 
    {
        CBasePlayer@ pPlayer = pParams.GetPlayer();
        ClientSayType type = pParams.GetSayType();
        pParams.set_ShouldHide(true);
        if(!pvpClientSay::preSayHook(pPlayer, pParams.GetArguments(), type))
        {
            return HOOK_HANDLED;
        }
        pvpClientSay::postSayHook(pPlayer, pParams.GetArguments(), type);
        return HOOK_HANDLED;
    }

    HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
    {
        pvpHitbox::checkPlayerHitbox(pPlayer);
        return HOOK_HANDLED;
    }
}
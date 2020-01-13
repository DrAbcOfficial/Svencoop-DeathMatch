namespace pvpHook
{
    void PluginInit()
    {
        g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage);
		g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
        g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
    }

    HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
    {
        pvpHitbox::playerSpawn(pPlayer);
        return HOOK_HANDLED;
    }

    HookReturnCode PlayerTakeDamage(DamageInfo@ info)
    {
        CBaseEntity@ pPlayer = g_EntityFuncs.Instance(info.pVictim.pev);
        CBaseEntity@ pAttacker = g_EntityFuncs.Instance(info.pAttacker.pev);
        CBaseEntity@ pInflictor = g_EntityFuncs.Instance(info.pInflictor.pev);
        if (pPlayer !is null && pAttacker !is null && pInflictor!is null && ((pPlayer.Classify() == pAttacker.Classify())))
                if( pPlayer !is pAttacker )
                        return HOOK_CONTINUE;
        CBaseEntity@ pEntity = null;
        while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, pvpUtility::getSteamId(cast<CBasePlayer@>(pPlayer)))) !is null)
        {
            pEntity.TakeDamage(info.pInflictor.pev, info.pAttacker.pev, info.flDamage, info.bitsDamageType);
        }
        info.flDamage = 0;
        return HOOK_CONTINUE;
    }

    HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
    {
        pvpPlayerData::PlayerPutinServer(pPlayer);
        pvpLang::PlayerPutinServer(pPlayer);
        return HOOK_HANDLED;
    }
}
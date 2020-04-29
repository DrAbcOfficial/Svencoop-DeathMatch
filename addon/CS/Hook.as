namespace CSHook
{
    void PlayerPutinServer(CBasePlayer@ pPlayer)
    {
        if(!CS::IsCs)
            return;
        string steamId = pvpUtility::getSteamId(pPlayer);
        if(!CSMenu::playerBank.exists(steamId))
            CSMenu::playerBank.set(steamId, CS::DEFAULT_MONEY);
    }

    void PlayerSpawn(CBasePlayer@ pPlayer)
    {
        if(pPlayer.m_hActiveItem.GetEntity() is null)
        {
            if(pPlayer.pev.team == CS::CTClass)
                pPlayer.GiveNamedItem( "weapon_usp" , 0 , 0 );
            else
                pPlayer.GiveNamedItem( "weapon_csglock18" , 0 , 0 );
            pPlayer.GiveNamedItem( "weapon_csknife" , 0 , 0 );
        }
    }

    void PlayerDeath(CBasePlayer@ pPlayer, CBaseEntity@ eAttacker)
    {
        CBasePlayer@ pAttacker = cast<CBasePlayer@>(eAttacker);
        if(pvpUtility::IsPlayerAlive(pAttacker))
        {
            string steamId = pvpUtility::getSteamId(pAttacker);
            if(CSMenu::playerBank.exists(steamId))
                CSMenu::AddMoney(steamId, 300);
            pPlayer.DropItem("weapon_c4");   
        }
    }

    bool PreTakeDamage(CBasePlayer@pPlayer, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
    {
        if(g_EntityFuncs.Instance(pevAttacker).IsPlayer())
            pPlayer.pev.velocity = Vector(0, 0, 0);
        return true;
    }
}

class func_buyzone : ScriptBaseEntity
{
    private int Team = 0;

    int ObjectCaps()
	{
		return ( BaseClass.ObjectCaps() & ~FCAP_ACROSS_TRANSITION ) | int( FCAP_IMPULSE_USE );
	}
	
	bool IsBSPModel()
	{
		return true;
	}

    void Spawn()
    {
        BaseClass.Spawn();

        g_EntityFuncs.SetModel( self, pev.model );

		g_EntityFuncs.SetSize( pev, pev.mins, pev.maxs );
		g_EntityFuncs.SetOrigin( self, pev.origin );
        pev.movetype = MOVETYPE_PUSHSTEP;
        pev.solid	= SOLID_TRIGGER;
        pev.rendermode = kRenderTransColor;
        pev.renderamt = 0;

        switch(pev.team)
        {
            case 1:Team = CS::TEClass;break;
            case 2:Team = CS::CTClass;break;
            default:Team = 0;break;
        }
    }  

    bool KeyValue(const string& in szKeyName, const string& in szValue)
    {
        return BaseClass.KeyValue( szKeyName, szValue );
    }

    void Touch( CBaseEntity@ pOther)
    {
        if( pOther is null)
            return;
        if(!pOther.IsPlayer() && !pOther.IsNetClient())
            return;
        if(Team == 0 || Team == pOther.pev.team)
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>(pOther);
            g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), "$i_IsInBuyZone", 1);
            CustomKeyvalue pCustom = pPlayer.GetCustomKeyvalues().GetKeyvalue("$i_IsCalledCSBuy");
            if (pCustom.Exists() && pCustom.GetInteger() == 1)
            {
                g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), "$i_IsCalledCSBuy", 0);
                if(pPlayer.pev.team == pev.team && pev.team != 0)
                    CSMenu::CTMenu.Open(5,0,pPlayer);
                else
                    CSMenu::TEMenu.Open(5,0,pPlayer);
            }
        }
    }
}
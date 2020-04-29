
class func_bomb_target : ScriptBaseEntity
{
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
        g_EntityFuncs.DispatchKeyValue(pOther.edict(), "$i_inBombZone", 1);
    }
}
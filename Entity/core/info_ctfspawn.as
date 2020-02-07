//提供可使用OF地图CTF出生点的支持

class info_ctfspawn : ScriptBaseEntity
{	
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if(szKey == "team_no")
		{
			CBaseEntity@ pSpwan = g_EntityFuncs.Create("info_player_deathmatch", self.GetOrigin(), self.pev.angles, false);
			//筛选玩家
			pSpwan.pev.spawnflags = 8;
			if(szValue == 2)
			{
				pSpwan.pev.message = "team2";
			}
			else if (szValue == 1)
			{
				pSpwan.pev.message = "team1";
			}			
			g_EntityFuncs.Remove(self);
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}
}

void CTFSpwanRegister()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "info_ctfspawn", "info_ctfspawn" );
}
namespace CS
{
    const string CTName = "Counter-Strike";
    const string TEName = "Terriost";
    const int DEFAULT_MONEY = 800;
    const string moneyIcon = "dmg_chem";
    const array<string> avaliableMaps = {"de_dust2"};
    const dictionary WeaponList = 
    {
        {"USP", array<string> = {"weapon_usp", "500"}},
        {"Glock", array<string> = {"weapon_csglock18", "400"}},
        {"P228", array<string> = {"weapon_p228", "600"}},
        {"Desert Eagle", array<string> = {"weapon_csdeagle", "650"}},
        {"Five-Seven", array<string> = {"weapon_fiveseven", "750"}},
        {"Akimbo Pistols", array<string> = {"weapon_dualelites", "800"}},
        {"M3", array<string> = {"weapon_m3", "1700"}},
        {"XM1014", array<string> = {"weapon_xm1014", "3000"}},
        {"M249", array<string> = {"weapon_csm249", "5750"}},
        {"TMP-9", array<string> = {"weapon_tmp", "1250"}},
        {"MAC-10", array<string> = {"weapon_mac10", "1400"}},
        {"UMP-45", array<string> = {"weapon_ump45", "1700"}},
        {"MP5", array<string> = {"weapon_mp5navy", "1500"}},
        {"P90", array<string> = {"weapon_p90", "2350"}},
        {"FAMAS", array<string> = {"weapon_famas", "2250"}},
        {"M4A1", array<string> = {"weapon_m4a1", "3100"}},
        {"AUG", array<string> = {"weapon_aug", "3500"}},
        {"Scout", array<string> = {"weapon_scout", "2750"}},
        {"AWP", array<string> = {"weapon_awp", "4750"}},
        {"SG550", array<string> = {"weapon_sg550", "4200"}},
        {"G3SG1", array<string> = {"weapon_g3sg1", "5000"}},
        {"AK47", array<string> = {"weapon_ak47", "2500"}},
        {"SG552", array<string> = {"weapon_sg552", "3500"}},
        {"Grenade", array<string> = {"weapon_hegrenade", "300"}},
        {"FlashBang", array<string> = {"weapon_hegrenade", "300"}},
        {"Smoke", array<string> = {"weapon_hegrenade", "300"}}
    };

    const dictionary CTWeaponMenu = 
    {
        {"Pistol",array<string> = {
            "USP",
            "Glock",
            "P228",
            "Desert Eagle",
            "Five-Seven"
        }},
        {"Heavy Weapons",array<string> = {
            "M3",
            "XM1014",
            "M249"
        }},
        {"Submechine gun",array<string> = {
            "TMP-9",
            "UMP-45",
            "MP5",
            "P90"
        }},
        {"Rifle",array<string> = {
            "FAMAS",
            "M4A1",
            "AUG",
            "Scout",
            "AWP",
            "SG550"
        }},
        {"Equipment",array<string> = {
            "Grenade",
            "FlashBang",
            "Smoke"
        }}
    };

    const dictionary TEWeaponMenu = 
    {
        {"Pistol",array<string> = {
            "USP",
            "Glock",
            "P228",
            "Desert Eagle",
            "Akimbo Pistols"
        }},
        {"Heavy Weapons",array<string> = {
            "M3",
            "XM1014",
            "M249"
        }},
        {"Submechine gun",array<string> = {
            "MAC-10",
            "UMP-45",
            "MP5",
            "P90"
        }},
        {"Rifle",array<string> = {
            "Galil",
            "AK47",
            "SG552",
            "Scout",
            "AWP",
            "G3SG1"
        }},
        {"Equipment",array<string> = {
            "Grenade",
            "FlashBang",
            "Smoke"
        }}
    };

    void PluginInit()
    {
        //注册CS
        pvpGameMode::RegistMode("CS", @StartTeam, @EndTeam, MODE_TEAM);
    }

    bool IsCs = false;
    void MapInit()
    {
        IsCs = false;
        for(uint i = 0; i < avaliableMaps.length();i++)
        {
            if(pvpUtility::getMapName() == avaliableMaps[i])
            {
                pvpGameMode::Change("CS");
                IsCs = true;
                break;
            }
        }

        if(!IsCs)
        {
            pvpGameMode::Change("FFA");
            return;
        }

        ClassiscWeapon::bIsEnable = false;

        

        g_Game.PrecacheModel( "sprites/" + BUYZONE_ICON );
        g_Game.PrecacheModel( pvpConfig::getConfig("Team","RedSpr").getString() );
        g_Game.PrecacheModel( pvpConfig::getConfig("Team","BlueSpr").getString() );
        g_CustomEntityFuncs.RegisterCustomEntity( "func_buyzone", "func_buyzone" );
    }

    void MapActivate()
    {
        if(!IsCs)
            return;

		CBaseEntity@ entEntity = null;
		while( ( @entEntity = g_EntityFuncs.FindEntityByClassname( entEntity, "info_player_start" ) ) !is null )
		{
            CBaseEntity@ ctEntity = g_EntityFuncs.Create( "info_player_dm2", entEntity.pev.origin, entEntity.pev.angles ,  true , null );
            ctEntity.pev.spawnflags = 8;
            ctEntity.pev.message = CTName;
            g_EntityFuncs.DispatchSpawn(ctEntity.edict());
            g_EntityFuncs.Remove(entEntity);
		} 

        CBaseEntity@ eEntity = null;
		while( ( @eEntity = g_EntityFuncs.FindEntityByClassname( eEntity, "info_player_deathmatch" ) ) !is null )
		{
            CBaseEntity@ teSpawn = g_EntityFuncs.Create( "info_player_dm2", eEntity.pev.origin, eEntity.pev.angles ,  true , null );
            teSpawn.pev.spawnflags = 8;
            teSpawn.pev.message = TEName;
            g_EntityFuncs.DispatchSpawn(teSpawn.edict());
            g_EntityFuncs.Remove(eEntity);
		} 
    }

    void PlayerPutinServer(CBasePlayer@ pPlayer)
    {
        if(!IsCs)
            return;
        string steamId = pvpUtility::getSteamId(pPlayer);
        if(!playerBank.exists(steamId))
        {
            playerBank.set(steamId, DEFAULT_MONEY);
        }
    }

    void PlayerSpawn(CBasePlayer@ pPlayer)
    {
        if(pPlayer.m_hActiveItem.GetEntity() is null)
        {
            if(pPlayer.pev.team == CTClass)
                pPlayer.GiveNamedItem( "weapon_usp" , 0 , 0 );
            else
                pPlayer.GiveNamedItem( "weapon_csglock18" , 0 , 0 );
        }
    }

    bool IsRestarting = false;
    bool CheckTeam()
    {
        int ctAlive = 0;
        int teAlive = 0;
        int player = 0;
        for (int i = 0; i <= g_Engine.maxClients; i++)
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pPlayer !is null && pPlayer.IsConnected())
			{
                pvpHud::CNumHUD@ pHud = pvpHud::GetNumHUD("CS-Money");
                string steamId = pvpUtility::getSteamId(pPlayer);
                pHud.SetValue(int(playerBank[steamId]));
                pHud.SetSpr(moneyIcon);
                pHud.Send(pPlayer);
                player++;
                if(pPlayer.pev.team == 0)
                {
                    pvpTeam::OpenMenu(pPlayer);
                }
                if(pPlayer.IsAlive())
                {
                    if(pPlayer.pev.team == CTClass)
                        ctAlive++;
                    if(pPlayer.pev.team == TEClass)
                        teAlive++;
                }
            }
        }
        if(pvpTeam::GetTeamByName(CTName).Count != 0 && pvpTeam::GetTeamByName(TEName).Count != 0)
        {
            if(ctAlive == 0 || teAlive == 0)
            {
                if(!IsRestarting)
                {
                    IsRestarting = true;
                    g_PlayerFuncs.ClientPrintAll(HUD_PRINTCENTER, (ctAlive == 0 ? TEName : CTName) + " Win!\n" );
                    g_Scheduler.SetTimeout( "Respawn", 15);
                }
            }
        }

        if(player != 0 && teAlive + ctAlive == 0)
        {
            if(!IsRestarting)
            {
                IsRestarting = true;
                g_PlayerFuncs.ClientPrintAll(HUD_PRINTCENTER, "Draw!\n" );
                g_Scheduler.SetTimeout( "Respawn", 15);
            }
        }
        return true;
    }

    void Respawn()
    {
        pvpEndGame::Restart(true, true);
        IsRestarting = false;
    }

    int CTClass = CLASS_HUMAN_MILITARY;
    int TEClass = CLASS_XRACE_SHOCK;

    const string BUYZONE_ICON = "misc/buyzone.spr";
    HUDSpriteParams params;

    void StartTeam()
    {
        pvpTeam::AddTeam(TEName, RGBA(255,0,0,255), CLASS(TEClass), pvpConfig::getConfig("Team","RedSpr").getString());
        pvpTeam::AddTeam(CTName, RGBA(0,0,255,255), CLASS(CTClass), pvpConfig::getConfig("Team","BlueSpr").getString());
        pvpTeam::RegistTeamMenu("Chose Your Team");
        pvpHitbox::addPostDeath(@PlayerDeath);
        pvpTimer::addTimer(pvpTimer::CTimerFunc("CS-TimerFunc", @CheckTeam));

        RegistCTMenu();
        RegistTEMenu();

        pvpHud::CNumHUD@ pHud =  pvpHud::CreateNumHUD(
            "CS-Money",
            0,
            RGBA_SVENCOOP,
            Vector2D(1,0.9),
            12,
            1.1,
            HUD_ELEM_DEFAULT_ALPHA | HUD_NUM_RIGHT_ALIGN,
            moneyIcon
        );
        pHud.SetDigits(1,5);

        params.channel = 13;
        params.flags = HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_DEFAULT_ALPHA ;
        params.x = 0.001;
        params.y = 0;
        params.spritename = BUYZONE_ICON;
        params.color1 = RGBA_GREEN;
        params.holdTime = 0.5;
        
        //允许生存模式
        g_SurvivalMode.EnableMapSupport();
        g_SurvivalMode.SetStartOn(true);
        g_SurvivalMode.Enable(true);
    }

    void EndTeam()
    {
        pvpTeam::RemoveTeam();
        pvpHitbox::delPostDeath(@PlayerDeath);
        pvpTimer::delTimer("CS-TimerFunc");
    }

    void PlayerDeath(CBasePlayer@ pPlayer, entvars_t@ pevAttacker)
    {
        CBasePlayer@ pAttacker = cast<CBasePlayer@>(g_EntityFuncs.Instance(pevAttacker));
        string steamId = pvpUtility::getSteamId(pAttacker);
        if(playerBank.exists(steamId))
        {
            AddMoney(pAttacker, 300);
        }
    }

    CTextMenu@ CTMenu;
    CTextMenu@ TEMenu;
    array<CTextMenu@> aryCTMenus;
    array<CTextMenu@> aryTEMenus;
    dictionary playerBank;

    void AddMoney(CBasePlayer@ pPlayer, int i)
    {
        string steamId = pvpUtility::getSteamId(pPlayer);
        if(playerBank.exists(steamId))
            playerBank.set(steamId, int(playerBank[steamId]) + i);
    }

    CTextMenu@ GetMenu(string&in name, int ct)
    {
        if(ct == CTClass)
        {
            for(uint i = 0; i < aryCTMenus.length();i++)
            {
                if(aryCTMenus[i].GetTitle() == "[" + name + "]\n")
                    return aryCTMenus[i];
            }
        }
        else
        {
            for(uint i = 0; i < aryTEMenus.length();i++)
            {
                if(aryTEMenus[i].GetTitle() == "[" + name + "]\n")
                    return aryTEMenus[i];
            }
        }
        return null;
    }

    void RegistCTMenu()
    {
        @CTMenu = CTextMenu(MainMenuRespond);
        CTMenu.Unregister();
        array<string> @keys = @CTWeaponMenu.getKeys();
        for(uint i = 0; i < keys.length(); i++)
        {
            CTextMenu@ tempMenu = CTextMenu(BuyMenuRespond);
            tempMenu.SetTitle("[" + keys[i] + "]\n");
            CTMenu.AddItem(keys[i], null);
            array<string> tempItems = array<string>(CTWeaponMenu[keys[i]]);
            for(uint j = 0; j < tempItems.length(); j++)
            {
                tempMenu.AddItem(tempItems[j], null);
            }
            tempMenu.AddItem("<Cancel>", null);
            tempMenu.Register();
            aryCTMenus.insertLast(tempMenu);
        }
        CTMenu.AddItem("<Cancel>", null);
        CTMenu.Register();
    }

    void RegistTEMenu()
    {
        @TEMenu = CTextMenu(MainMenuRespond);
        TEMenu.Unregister();
        array<string> @keys = TEWeaponMenu.getKeys();
        for(uint i = 0; i < keys.length(); i++)
        {
            CTextMenu@ tempMenu = CTextMenu(BuyMenuRespond);
            tempMenu.SetTitle("[" + keys[i] + "]\n");
            TEMenu.AddItem(keys[i], null);
            array<string> tempItems = array<string>(TEWeaponMenu[keys[i]]);
            for(uint j = 0; j < tempItems.length(); j++)
            {
                tempMenu.AddItem(tempItems[j], null);
            }
            tempMenu.AddItem("<Cancel>", null);
            tempMenu.Register();
            aryTEMenus.insertLast(tempMenu);
        }
        TEMenu.AddItem("<Cancel>", null);
        TEMenu.Register();
    }

    void MainMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem)
	{
		if(mItem !is null)
		{
			if(mItem.m_szName == "<Cancel>")
                return;
			else
            {
                CTextMenu@ pMenu = GetMenu(mItem.m_szName, pPlayer.pev.team);
                if(pMenu !is null)
                    pMenu.Open(0, 0, pPlayer);
            }
		}
	}

    void BuyMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem)
	{
		if(mItem !is null)
		{
			if(mItem.m_szName == "<Cancel>")
                return;
			else
            {
                array<string> szTemp = array<string>(WeaponList[mItem.m_szName]);
                string steamId = pvpUtility::getSteamId(pPlayer);
                int money = int(playerBank[steamId]);
                if(money - atoi(szTemp[1]) > 0)
                {
                    pPlayer.GiveNamedItem( szTemp[0] , 0 , 0 );
                    AddMoney(pPlayer, -atoi(szTemp[1]));
                }
            }
		}
	}
}

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
    }  

    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        return BaseClass.KeyValue( szKey, szValue );
    }

    void Touch( CBaseEntity@ pOther)
    {
        if( pOther is null)
            return;

        if(!pOther.IsPlayer() && !pOther.IsNetClient())
            return;

        CBasePlayer@ pPlayer = cast<CBasePlayer@>(pOther);
        g_PlayerFuncs.HudCustomSprite(pPlayer, CS::params);
        if (pPlayer.pev.flags & FL_DUCKING != 0)
        {
            if(pPlayer.pev.team == pev.team && pev.team != 0)
                CS::CTMenu.Open(1,0,pPlayer);
            else
                CS::TEMenu.Open(1,0,pPlayer);
        }
    }
}
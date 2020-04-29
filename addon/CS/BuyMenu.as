
 namespace CSMenu
 {
     const dictionary WeaponList = 
    {
        {"USP", array<string> = {"weapon_usp", "500"}},
        {"Glock", array<string> = {"weapon_csglock18", "400"}},
        {"P228", array<string> = {"weapon_p228", "600"}},
        {"Desert-Eagle", array<string> = {"weapon_csdeagle", "650"}},
        {"Five-Seven", array<string> = {"weapon_fiveseven", "750"}},
        {"Akimbo-Pistols", array<string> = {"weapon_dualelites", "800"}},
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
        {"Galil", array<string> = {"weapon_galil", "2250"}},
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
            "Desert-Eagle",
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
            "Desert-Eagle",
            "Akimbo-Pistols"
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

    CTextMenu@ CTMenu;
    CTextMenu@ TEMenu;
    array<CTextMenu@> aryCTMenus;
    array<CTextMenu@> aryTEMenus;
    dictionary playerBank;

    void BuyCallBack(const CCommand@ Argments)
	{
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        if(pvpGameMode::GetMode().uniName != "CS")
        {
            pvpLog::say(pPlayer, "Game Mode Not CS");
            return;
        }
        if(pvpUtility::IsPlayerAlive(pPlayer))
		    g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), "$i_IsCalledCSBuy", 1);
	}

    void AddTeamMoney(int iSituation, int Money)
    {
        for (int i = 0; i <= g_Engine.maxClients; i++)
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pPlayer !is null && pPlayer.IsConnected())
            {
                string steamId = pvpUtility::getSteamId(pPlayer);
                switch(iSituation)
                {
                    case CS::NO_WIN: AddMoney(steamId, Money);break;
                    default:
                    {
                        if(pPlayer.pev.team == (iSituation == CS::CT_WIN ? CS::CTClass : CS::TEClass))
                            AddMoney(steamId, Money + 300);
                        else
                            AddMoney(steamId, Money);
                    }break;
                }
            }
        }
    }

    void AddMoney(string steamid, int i)
    {
        playerBank.set(steamid, int(playerBank[steamid]) + i);
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
                tempMenu.AddItem(tempItems[j] + " $" + array<string>(WeaponList[tempItems[j]])[1], null);
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
                tempMenu.AddItem(tempItems[j] + " $" + array<string>(WeaponList[tempItems[j]])[1], null);
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
                array<string> szTemp = array<string>(WeaponList[mItem.m_szName.Split(" ")[0]]);
                string steamId = pvpUtility::getSteamId(pPlayer);
                int money = int(playerBank[steamId]);
                if(money - atoi(szTemp[1]) >= 0)
                {
                    pPlayer.GiveNamedItem( szTemp[0] , 0 , 0 );
                    AddMoney(steamId, -atoi(szTemp[1]));
                }
                else
                    pvpLog::say(pPlayer, {"You don't have enough money to buy it.", mItem.m_szName.Split(" ")[0] + " | $" + szTemp[1]}, POSCHAT);
            }
		}
	}

    CTextMenu@ GetMenu(string&in name, int ct)
    {
        if(ct == CS::CTClass)
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
}
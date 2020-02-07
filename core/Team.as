namespace pvpTeam
{
    enum TEAMICONSTATE
    {
        ICON_HIDE = -1,
        ICON_TEAM,
        ICON_ALL
    }
    class CTeam
    {
        string Name;
        string Spr;
        RGBA Color;
        int Class;
        int Score;
        private bool Free;
        array<CBasePlayer@> List;

        CTeam(string&in _Name, RGBA&in _Color, int&in _Class, string&in _Spr)
        {
            Name = _Name;
            Color = _Color;
            Class = _Class;
            Spr = _Spr;
            Free = false;
        }

        bool IsFree()
        {
            return this.Free;
        }

        uint Count
        {
            get {return List.length();}
        }

        int Classify()
        {
            return Class;
        }

        void AddScore(int i = 1)
        {
            this.Score += i;
        }

        void Add(CBasePlayer@&in pPlayer)
        {
            CTeam@ oTeam = pvpTeam::GetPlayerTeam(pPlayer);
            if(oTeam !is null)
                oTeam.Remove(pPlayer);
            this.List.insertLast(pPlayer);
            pPlayer.pev.team = this.Class;
            pPlayer.SetClassification(this.Class);
            CBaseHitbox@ pHitbox = pvpHitbox::GetHitBox(cast<CBasePlayer@>(pPlayer));
            if(pHitbox !is null)
                pHitbox.Update();
        }

        bool Remove(CBasePlayer@&in pPlayer)
        {
            for(uint i = 0; i < this.Count; i++)
            {
                if(this.List[i] is pPlayer)
                {
                    this.List.removeAt(i);
                    pPlayer.pev.team = 0;
                    pPlayer.SetClassification(CLASS_PLAYER);
                    return true;
                }
            }
            return false;
        }

        void Clear()
        {
            for(uint i = 0; i < this.Count; i++)
            {
                this.List[i].pev.team = 0;
                this.List[i].SetClassification(CLASS_PLAYER);
                pvpHitbox::GetHitBox(this.List[i]).Update();
            }
            this.List = {};
            this.Score = 0;
        }

        void Destory()
        {
            this.Clear();
            this.Name = "";
            this.Spr= "";
            this.Color = RGBA(0,0,0,0);
            this.Class = -1;
            this.Free = true;
        }

        bool Exist(CBasePlayer@&in pPlayer)
        {
            for(uint i = 0; i < this.Count; i++)
            {
                if(this.List[i] is pPlayer)
                    return true;
            }
            return false;
        }
    }

    bool bTDMState = false;
    array<CTeam@> aryTeams;
    CTextMenu@ TeamMenu = CTextMenu(TeamMenuRespond);
    CScheduledFunction@ TeamColor = null;
    int iIconState = 0;

    void PluginInit()
    {
        pvpLang::addLang("_TEAM_","Team");
        pvpClientCmd::RegistCommand("vote_tdm","Start Team Death Match","Team", @pvpTeam::VoteCallback);
        pvpClientCmd::RegistCommand("player_team","Change Your Team in Team Death Match","Team", @pvpTeam::TeamCallBack);
        pvpClientCmd::RegistCommand("admin_tdm","Admin Start Team Death Match","Team", @pvpTeam::AdminCallBack, CCMD_ADMIN);
        pvpClientCmd::RegistCommand("admin_showtdmicon","Admin Show everyone's icon","Team", @pvpTeam::AdminIconCallBack, CCMD_ADMIN);

        AddTeam("Lambda", RGBA(255,165,0,255), CLASS_PLAYER, pvpConfig::getConfig("Team","OrangeSpr").getString());
        AddTeam("HECU", RGBA(0,255,0,255), CLASS_HUMAN_MILITARY, pvpConfig::getConfig("Team","GreenSpr").getString());
        AddTeam("XEN", RGBA(255,0,0,255), CLASS_ALIEN_MILITARY, pvpConfig::getConfig("Team","RedSpr").getString());
        AddTeam("X-Race", RGBA(0,0,255,255), CLASS_XRACE_SHOCK, pvpConfig::getConfig("Team","BlueSpr").getString());

        pvpHud::CreateTextHUD(
            pvpConfig::getConfig("Team","HUDName").getString(),
            "",
            RGBA(0,0,0,0),
            pvpConfig::getConfig("Team","HUDPos").getVector2D(),
            pvpConfig::getConfig("Team","HUDChannel").getInt(),
            pvpConfig::getConfig("Team","HUDHold").getFloat()
        );

        RegistTeamMenu();

        pvpHitbox::deathCallList.insertLast(@PlayerDeath);
    }

    void MapInit()
    {
        for(uint i = 0; i < aryTeams.length();i++)
        {
            g_Game.PrecacheModel(aryTeams[i].Spr);
        }
        
    }

    void PlayerSpawn(CBasePlayer@ pPlayer)
    {
        CTeam@ pTeam = GetPlayerTeam(pPlayer);
        if(pTeam is null)
            return;
        pPlayer.pev.team = pTeam.Class;
    }

    void PlayerDeath(CBasePlayer@ pPlayer, entvars_t@ pevAttacker)
    {
        if(!bTDMState)
            return;

        CTeam@ pTeam = GetPlayerTeam(pPlayer);
        if(pTeam is null)
            TeamMenu.Open(0, 0, pPlayer);

        CBasePlayer@ pAttacker = cast<CBasePlayer@>(g_EntityFuncs.Instance(pevAttacker));
        @pTeam = GetPlayerTeam(pAttacker);
        if(pTeam !is null)
            pTeam.AddScore();
    }

    bool GetState()
    {
        return bTDMState;
    }

    void AdminCallBack(const CCommand@ Argments)
	{
		StartTeam(null, false, 0);
	}

    void AdminIconCallBack(const CCommand@ Argments)
	{
		iIconState = atoi(Argments[1]);
	}

    void VoteCallback(const CCommand@ Argments)
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
		CPVPVote@ pVote = pvpVote::CreatVote(pvpLang::getLangStr("_TEAM_", "VOTENAME"), 
            pvpLang::getLangStr("_TEAM_", "VOTEDES",  pvpLang::getLangStr("_TEAM_", bTDMState ? "DISABLE" : "ENABLE")), pPlayer);
        if(pVote is null)
            return;
        pVote.setCallBack(@StartTeam);
        pVote.Start();
	}

    void TeamCallBack(const CCommand@ Argments)
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
		if(bTDMState)
            TeamMenu.Open(0,0,pPlayer);
	}

    void RemoveTeam(string&in _Name)
    {
        for(uint i = 0; i < aryTeams.length(); i++)
        {
            if(aryTeams[i].Name == _Name)
            {
                aryTeams[i].Destory();
                aryTeams.removeAt(i);
                return;
            }
        }
    }

    void RegistTeamMenu()
    {
        TeamMenu.SetTitle("[" + pvpLang::getLangStr("_TEAM_", "MENUTITLE") + "]\n");
        for(uint i = 0; i < aryTeams.length();i++)
        {
            if(!aryTeams[i].IsFree())
                TeamMenu.AddItem(aryTeams[i].Name, null);
        }
        TeamMenu.AddItem("<Cancel>", null);
        TeamMenu.Register();
    }

    void AddTeam(string&in _Name, RGBA&in _Color, int&in _Class, string&in _Spr)
    {
        for(uint i = 0; i < aryTeams.length();i++)
        {
            if(aryTeams[i].IsFree())
            {
                aryTeams[i].Name = _Name;
                aryTeams[i].Color = _Color;
                aryTeams[i].Class = _Class;
                aryTeams[i].Spr = _Spr;
                return;
            }
        }
        aryTeams.insertLast(CreateTeam(_Name, _Color, _Class, _Spr));
    }

    CTeam@ CreateTeam(string&in _Name, RGBA&in _Color, int&in _Class, string&in _Spr)
    {
        CTeam pTeam(_Name, _Color, _Class, _Spr);
        return pTeam;
    }

    CTeam@ GetPlayerTeam(CBasePlayer@ pPlayer)
    {
        for(uint i = 0; i < aryTeams.length();i++)
        {
            if(aryTeams[i].Exist(pPlayer))
                return aryTeams[i];
        }
        return null;
    }

    CTeam@ GetTeamByName(string&in szName)
    {
        for(uint i = 0; i < aryTeams.length();i++)
        {
            if(aryTeams[i].Name == szName)
                return aryTeams[i];
        }
        return null;
    }

    CTeam@ GetTeamByIndex(uint&in uiIndex)
    {
        if(uiIndex < aryTeams.length())
                return aryTeams[uiIndex];
        return null;
    }

    void ClearAllTeam()
    {
        for(uint i = 0; i < aryTeams.length();i++)
        {
            aryTeams[i].Clear();
        }
    }

    void TeamMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem)
	{
		if(mItem !is null)
		{
			if(mItem.m_szName == "<Cancel>")
			{
                if(GetPlayerTeam(pPlayer) is null)
                {
                    mMenu.Open(0, 0, pPlayer);
                    pvpLog::say(pPlayer, pvpLang::getLangStr("_TEAM_", "HASTOCHOSE", pPlayer), POSCHAT);
                }
			}
			else
            {
                CTeam@ pTeam = GetTeamByName(mItem.m_szName);
                pTeam.Add(pPlayer);
                pvpLog::say(pPlayer, pvpLang::getLangStr("_TEAM_", "JOINEDTEAM", mItem.m_szName, pPlayer), POSCHAT);
            }
		}
	}

    void StartTeam( CPVPVote@ pVote, bool bResult, int iVoters )
    {
        bTDMState = !bTDMState;
        if(bTDMState)
        {
            pvpUtility::Restart();
            pvpUtility::SendHLHUDText("Team Death Match");
            pvpUtility::SendHLTitle();
            pvpUtility::OpenMenuAll(TeamMenu);
            @TeamColor = g_Scheduler.SetInterval( "SendTeamTimer", 1, g_Scheduler.REPEAT_INFINITE_TIMES );
        }
        else
        {
            pvpUtility::SendHLHUDText("Team Death Match Disabled");
            array<string> tempStr = {pvpLang::getLangStr("_TEAM_", "SCOREREPORT")};
            for(uint i = 0 ; i < aryTeams.length();i++)
            {
                tempStr.insertLast(aryTeams[i].Name + "\t:\t" + aryTeams[i].Score + (i == aryTeams.length() - 1 ? "" : "\n"));
            }
            pvpLog::log( tempStr);
            ClearAllTeam();
            g_Scheduler.RemoveTimer(TeamColor);
            @TeamColor = null;
        }
        
    }


    //头上有标的都是队友
    void SendTeamTimer()
    {
        string tempStr = "";
        for(uint i = 0; i < aryTeams.length(); i++)
        {
            tempStr += aryTeams[i].Name + "\t| Score : " + aryTeams[i].Score + "\t| Player : " + aryTeams[i].Count + "\n";
        }

        for (int i = 0; i <= g_Engine.maxClients; i++)
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pPlayer !is null && pPlayer.IsConnected())
			{
                CTeam@ pTeam = GetPlayerTeam(pPlayer);
                //发送HUD
                pvpHud::CTextHUD@ pHud = pvpHud::GetTextHUD(pvpConfig::getConfig("Team","HUDName").getString());
                pHud.Content = tempStr;
                if( pTeam is null)
                    pHud.Color1 = RGBA(255, 125, 255, 255);
                else
                    pHud.Color1 = pTeam.Color;
                pHud.Send(pPlayer);

                //发送队友图标
                if( pTeam is null)
                    continue;
                if(iIconState == ICON_HIDE)
                    return;

                for (int j = 0; j <= g_Engine.maxClients; j++)
                {
                    CBasePlayer@ tPlayer = g_PlayerFuncs.FindPlayerByIndex(j);
                    if(tPlayer !is null && tPlayer.IsConnected())
                    {
                        if(iIconState != ICON_ALL)
                            if( tPlayer is pPlayer || tPlayer.pev.team != pPlayer.pev.team )
                                continue;

                        @ pTeam = GetPlayerTeam(tPlayer);
                        if( pTeam is null)
                            continue;

                        NetworkMessage m(MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict());
                            m.WriteByte(TE_PLAYERATTACHMENT);
                            m.WriteByte(tPlayer.entindex());
                            m.WriteCoord(40);
                            m.WriteShort(g_EngineFuncs.ModelIndex(pTeam.Spr));
                            m.WriteShort(10);
                        m.End();
                    }
                }
            }
        }
    }
}
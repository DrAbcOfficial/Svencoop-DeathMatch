#include "../Class/CTeam"

namespace pvpTeam
{
    enum TEAMICONSTATE
    {
        ICON_HIDE = -1,
        ICON_TEAM,
        ICON_ALL
    }

    array<CTeam@> aryTeams;
    CTextMenu@ TeamMenu;
    int iIconState = 0;

    void PluginInit()
    {
        pvpClientCmd::RegistCommand("admin_showtdmicon","Admin Show everyone's icon","Team", @pvpTeam::AdminIconCallBack, CCMD_ADMIN);
        pvpHud::CreateTextHUD
        (
            pvpConfig::getConfig("Team","HUDName").getString(),
            "",
            RGBA(0,0,0,0),
            pvpConfig::getConfig("Team","HUDPos").getVector2D(),
            pvpConfig::getConfig("Team","HUDChannel").getInt(),
            pvpConfig::getConfig("Team","HUDHold").getFloat()
        );
        pvpTimer::addTimer(CTimerFunc("TeamIcon", @SendTeamTimer));
        pvpHook::RegisteHook(CHookItem(@pvpTeam::ClientDisconnect, HOOK_DISCONNECT, "TEAM_DISCONNECT"));
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
        pPlayer.pev.targetname = pTeam.Name;
    }

    void PlayerDeath(CBasePlayer@ pPlayer, entvars_t@ pevAttacker)
    {
        CBasePlayer@ pAttacker = cast<CBasePlayer@>(g_EntityFuncs.Instance(pevAttacker));
        CTeam@ pTeam = GetPlayerTeam(pAttacker);
        if(pTeam !is null)
            pTeam.AddScore();
    }

    void ClientDisconnect(CBasePlayer@ pPlayer)
    {
        CTeam@ pTeam = GetPlayerTeam(pPlayer);
        if(pTeam !is null)
            pTeam.Remove(pPlayer);
    }

    void AdminIconCallBack(const CCommand@ Argments)
	{
		iIconState = atoi(Argments[1]);
	}

    void RemoveTeam()
    {
        pvpLog::log(aryTeams.length());
        for(uint i = 0; i < aryTeams.length(); i++)
        {
            aryTeams[i].Destory();
        }
        aryTeams = {};
    }

    void RemoveTeam(string _Name)
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

    void RegistTeamMenu(string Title)
    {
        if(TeamMenu !is null)
            TeamMenu.Unregister();
        CTextMenu@ tempMenu = CTextMenu(TeamMenuRespond);
        tempMenu.SetTitle("[" + Title + "]\n");
        for(uint i = 0; i < aryTeams.length();i++)
        {
            if(!aryTeams[i].IsFree())
                tempMenu.AddItem(aryTeams[i].Name, null);
        }
        tempMenu.AddItem("<Cancel>", null);
        tempMenu.Register();
        @TeamMenu = @tempMenu;
    }

    void AddTeam(string _Name, RGBA _Color, int _Class, string _Spr)
    {
        for(uint i = 0; i < aryTeams.length();i++)
        {
            if(aryTeams[i].IsFree())
            {
                aryTeams[i].Name = _Name;
                aryTeams[i].Color = _Color;
                aryTeams[i].Class = _Class;
                aryTeams[i].Spr = _Spr;
                pvpLog::log("free");
                return;
            }
        }
        aryTeams.insertLast(CreateTeam(_Name, _Color, _Class, _Spr));
    }

    void OpenMenu(CBasePlayer@ pPlayer)
    {
        TeamMenu.Open(0, 0, pPlayer);
    }

    CTeam@ CreateTeam(string _Name, RGBA _Color, int _Class, string _Spr)
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

    CTeam@ GetTeamByName(string szName)
    {
        for(uint i = 0; i < aryTeams.length();i++)
        {
            if(aryTeams[i].Name == szName)
                return aryTeams[i];
        }
        return null;
    }

    CTeam@ GetTeamByIndex(uint uiIndex)
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
                    pvpLog::say(pPlayer, pvpLang::getLangStr("_MAIN_", "HASTOCHOSE", pPlayer), POSCHAT);
                }
			}
			else
            {
                CTeam@ pTeam = GetTeamByName(mItem.m_szName);
                if(pTeam !is null)
                {
                    pTeam.Add(pPlayer);
                    pvpLog::say(pPlayer, pvpLang::getLangStr("_MAIN_", "JOINEDTEAM", mItem.m_szName, pPlayer), POSCHAT);
                }
            }
		}
	}

    //头上有标的都是队友
    bool SendTeamTimer()
    {
        if(pvpGameMode::GetMode().Team != MODE_TEAM)
            return true;

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
                    return true;

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
        return true;
    }
}
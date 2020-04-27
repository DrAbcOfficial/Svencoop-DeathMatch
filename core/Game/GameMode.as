#include "../Class/CGameMode"

enum GameModeTeam
{
    MODE_NOT = 0,
    MODE_TEAM,
    MODE_OTHER
}

//所有的游戏模式请通过这个注册
namespace pvpGameMode
{
    //此处注册FFA模式
    void PluginInit()
    {
        pvpGameMode::RegistMode("FFA", @Dummy, @Dummy);
        pvpLang::addLang("_GAMEMODE_","GameMode");
        pvpClientCmd::RegistCommand("info_gamemode","List avaliable gamemode","GameMode", @pvpGameMode::ListCallback);
        pvpClientCmd::RegistCommand("vote_gamemode","Vote to change gamemode","GameMode", @pvpGameMode::VoteCallback);
        pvpClientCmd::RegistCommand("admin_gamemode","Admin change gamemode","GameMode", @pvpGameMode::AdminCallBack, CCMD_ADMIN);
    }

    void Dummy()
    {
        //超级有用高效优雅无敌的神奇代码
    }

    void ListCallback(const CCommand@ Argments)
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        pvpLog::say(pPlayer, pvpLang::getLangStr("_GAMEMODE_","GAMEMODE", GetMode().uniName));
		pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_","AVACMD"));
		string tempStr = " | ";
        for(uint i = 0; i < aryGameModeList.length(); i++)
        {
            tempStr += aryGameModeList[i].uniName + " | ";
        }
        pvpLog::say(pPlayer, tempStr);
	}

    void VoteTeamCall( CPVPVote@ pVote, bool bResult, int iVoters )
    {
        Change(tempGamemode);
    }

    string tempGamemode;

    void VoteCallback(const CCommand@ Argments)
	{
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

        if(Argments.ArgC() < 2)
        {
            pvpLog::say(pPlayer, "Error Input\nExample:." + Argments[0] + " <Mode>");
            return;
        }

        if(GetMode(Argments[1]) is null)
        {
            pvpLog::log(pvpLang::getLangStr("_GAMEMODE_","FINDERROR", Argments[1]));
            return;
        }

        tempGamemode = Argments[1];
		CPVPVote@ pVote = pvpVote::CreatVote(pvpLang::getLangStr("_GAMEMODE_", "VOTENAME"), 
            pvpLang::getLangStr("_GAMEMODE_", "VOTEDES", tempGamemode ), pPlayer);
        if(pVote is null)
            return;
        pVote.setCallBack(@VoteTeamCall);
        pVote.Start();
	}

    void AdminCallBack(const CCommand@ Argments)
	{
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        if(Argments.ArgC() < 2)
        {
            pvpLog::say(pPlayer, "Error Input\nExample:.vote_gamemode <Mode>");
            return;
        }
        if(GetMode(Argments[1]) is null)
        {
            pvpLog::log(pvpLang::getLangStr("_GAMEMODE_","FINDERROR", Argments[1]));
            return;
        }

        tempGamemode = Argments[1];
		VoteTeamCall(null, false, 0);
	}
    
    uint inNowMode = 0;

    array<CGameMode@> aryGameModeList;

    CGameMode@ GetMode()
    {
        return aryGameModeList[inNowMode];
    }
    CGameMode@ GetMode(string Name)
    {
        for(uint i = 0; i < aryGameModeList.length(); i++)
        {
            if(aryGameModeList[i].uniName == Name)
                return aryGameModeList[i];
        }
        return null;
    }
	
	const dictionary dummyVar = {};
    void RegistMode(string _Name, CGameModeCall@ start, CGameModeCall@ end, int Team = MODE_NOT, dictionary dicCVar = dummyVar)
    {
        if(GetMode(_Name) is null)
        {
            aryGameModeList.insertLast(CGameMode(_Name, start, end, Team, dicCVar));
        }
        else
            pvpLog::log(pvpLang::getLangStr("_GAMEMODE_","GAMEMODEREGISTERROR", _Name));
    }

    void Start()
    {
        aryGameModeList[inNowMode].Start();
    }

    void End()
    {
        aryGameModeList[inNowMode].End();
    }

    void Change(string Name)
    {
        aryGameModeList[inNowMode].End();
        for(uint i = 0; i < aryGameModeList.length(); i++)
        {
            if(aryGameModeList[i].uniName == Name)
            {
                aryGameModeList[i].Start();
                inNowMode = i;
                break;
            }
        }
        pvpLog::log(pvpLang::getLangStr("_GAMEMODE_","GAMEMODECHANGE", Name));
    }
}
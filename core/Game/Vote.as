#include "../Class/CPVPVote"

namespace pvpVote
{
    funcdef void PVPVoteYesCallBack( CPVPVote@, bool, int );
    funcdef void PVPVoteNoCallBack( CPVPVote@, bool, int );
    funcdef void PVPVoteBlockCallBack(CPVPVote@, float);

    dictionary dicVotes;
    dictionary dicPlayerTime;

    void PluginInit()
    {
        pvpLang::addLang("_VOTE_","Vote");
    }

    //重新开始投票
    void RestartVote(CPVPVote@&in pVote)
    {
        pVote.Start();
    }

    //由Vote获取CPVPVote
    CPVPVote@ GetVoteClass(Vote@ pVote)
    {
        return cast<CPVPVote@>(dicVotes[pVote.GetName()]);
    }

    //创建新的投票
    CPVPVote@ CreatVote(string&in _Name, string&in _Describe, CBasePlayer@ pPlayer = null)
    {
        if(pPlayer !is null)
        {
            string steamId = pvpUtility::getSteamId(pPlayer);
            if(dicPlayerTime.exists(steamId))
            {
                float flTime = float(dicPlayerTime[steamId]);
                float flDes = g_Engine.time - flTime;
                if(flDes <=  pvpConfig::getConfig("Vote","VoteCold").getFloat())
                {
                    pvpLog::say(pPlayer, pvpLang::getLangStr( "_VOTE_", "REJECT", string(int(pvpConfig::getConfig("Vote","VoteCold").getFloat() - flDes))), POSCHAT);
                    return null;
                }
            }
            dicPlayerTime.set(steamId, g_Engine.time);   
        }

        CPVPVote pVote(_Name, _Describe, pPlayer);
        dicVotes.set(_Name, @pVote);
        return pVote;
    }

    //被阻挡时函数
    void Blocked( Vote@ pVote, float flTime )
	{
        CPVPVote@ cVote = GetVoteClass(pVote);

		//g_Scheduler.SetTimeout( "RestartVote", flTime, @cVote );
        if(cVote.pBlock !is null)
            cVote.pBlock(cVote, flTime);
        g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, pvpLang::getLangStr("_VOTE_", "BLOCK", cVote.Name ) );
	}

    //结束时函数
	void End( Vote@ pVote, bool bResult, int iVoters )
	{
        CPVPVote@ cVote = GetVoteClass(pVote);
		if( !bResult )
		{
            if(cVote.pNo !is null)
                cVote.pNo(cVote, bResult, iVoters);
		}
        else
        {
            if(cVote.pYes !is null)
                cVote.pYes(cVote, bResult, iVoters);
        }
        //从词典中删除该投票
        dicVotes.delete(pVote.GetName());
        g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, pvpLang::getLangStr("_VOTE_", bResult ? "PASS" : "FAIL", cVote.Name ) );
	}
}
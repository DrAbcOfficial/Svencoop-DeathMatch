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

//Vote类
//实例化或继承使用
class CPVPVote
{
    private Vote@ m_pVote = null;
    private CBasePlayer@ pOwner = null; 
    pvpVote::PVPVoteYesCallBack@ pYes = null;
    pvpVote::PVPVoteNoCallBack@ pNo = null;
    pvpVote::PVPVoteBlockCallBack@ pBlock = null;

    CPVPVote( string&in _Name, string&in _Describe, CBasePlayer@ pPlayer = null)
    {
        float flVoteTime = g_EngineFuncs.CVarGetFloat( "mp_votetimecheck" );
            
        if( flVoteTime <= 0 )
            flVoteTime = pvpConfig::getConfig("Vote","VoteTime").getInt();
                
        float flPercentage = g_EngineFuncs.CVarGetFloat( "mp_voteclassicmoderequired" );
            
        if( flPercentage <= 0 )
            flPercentage = pvpConfig::getConfig("Vote","VotePercentage").getInt();

        @this.m_pVote = @Vote( _Name, _Describe, flVoteTime, flPercentage );

        this.m_pVote.SetVoteEndCallback( @pvpVote::End);
        this.m_pVote.SetVoteBlockedCallback( @pvpVote::Blocked );

        if(pPlayer !is null)
            @this.pOwner = @pPlayer;
    }

    Vote@ getVote()
    {
        return m_pVote;
    }

    string Name
	{
		get const{ return this.m_pVote.GetName();}
	}

    any@ setOwner
	{
        set { this.m_pVote.SetUserData(value); }
	}

    void setCallBack(pvpVote::PVPVoteYesCallBack@ _pYes, pvpVote::PVPVoteNoCallBack@ _pNo = null, pvpVote::PVPVoteBlockCallBack@ _pBlock = null)
    {
	    @this.pYes = @_pYes;
        if(_pNo !is null)
            @this.pNo = @_pNo;
        if(_pBlock !is null)
            @this.pBlock = @_pBlock;
            
    }

    void setText(string&in szText, string&in szYes = "Yes", string&in szNo = "No")
    {
        this.m_pVote.SetVoteText(szText);
        this.m_pVote.SetYesText(szYes);
        this.m_pVote.SetNoText(szNo);
    }

    void Start()
    {
        if(this.pOwner !is null)
        { 
            pvpLog::say(pvpLang::getLangStr("_VOTE_", "PLAYER", this.pOwner.pev.netname, this.Name ), POSCHAT);
        }
        this.m_pVote.Start();
    }

    //我不知道为什么你想把这玩意儿塞进数组还对他排序的
	int opCmp(CPVPVote &in other) const
	{
		return this.Name.opCmp(other.Name);
	}
}
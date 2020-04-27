class CTeam
{
    string Name;
    string Spr;
    RGBA Color;
    int Class;
    int Score;
    int TeamScore;
    private bool Free = false;
    array<CBasePlayer@> List;

    CTeam(string _Name, RGBA _Color, int _Class, string _Spr)
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

    void AddTeamScore(int i = 1)
    {
        this.TeamScore += i;
    }

    void Add(CBasePlayer@ pPlayer)
    {
        CTeam@ oTeam = pvpTeam::GetPlayerTeam(pPlayer);
        if(oTeam !is null)
            oTeam.Remove(pPlayer);
        this.List.insertLast(pPlayer);
        pPlayer.pev.team = this.Class;
        pPlayer.pev.targetname = this.Name;
        pPlayer.SetClassification(this.Class);
        pvpLog::log(pPlayer.pev.targetname);
        CBaseHitbox@ pHitbox = pvpHitbox::GetHitBox(cast<CBasePlayer@>(pPlayer));
        if(pHitbox !is null)
            pHitbox.Update();
    }

    bool Remove(CBasePlayer@ pPlayer)
    {
        for(uint i = 0; i < this.Count; i++)
        {
            if(this.List[i] is pPlayer)
            {
                this.List.removeAt(i);
                pPlayer.pev.team = 0;
                pPlayer.pev.targetname = "";
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
            this.List[i].pev.targetname = "";
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

    bool Exist(CBasePlayer@ pPlayer)
    {
        for(uint i = 0; i < this.Count; i++)
        {
            if(this.List[i] is pPlayer)
                return true;
        }
        return false;
    }
}
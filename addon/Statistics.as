namespace Statistics
{
    class CStatistic
    {
        //槽位是否空闲
        bool Free;
        //唯一标识符
        string SteamID;
        //网络名称
        string NetName;

        /**
            0   分数
            1   死亡数
            2   射击数
            3   击中数
            4   自杀数
            5   意外死亡数
            6   击中队友数
            7   连杀数
        **/
        array<uint> Content(8, 0);
        //最长存活时间
        float AliveTime;
        //武器击杀数
        dictionary WeaponKill; 
    }

    //左键排除的武器
    const array<string> LeftExcluede;
    //右键
    const array<string> RightExcluede;
    //谁统计中键啊
    
    void PluginInit()
    {
        pvpEndGame::addEnd(pvpEndGame::CEndFunc("End", @End));
    }

    void End()
    {
        string tempStr = "\n[Score Statistic]\nMap: " + pvpUtility::getMapName + "\n";
        if(pvpTeam::GetState())
        {
            for(uint i = 0 ; i < pvpTeam::aryTeams.length();i++)
            {
                tempStr.insertLast(aryTeams[i].Name + "\t:\t" + pvpTeam::aryTeams[i].Score + (i == apvpTeam::ryTeams.length() - 1 ? "" : "\n"));
            }
        }
        pvpLog::log(tempStr);
    }
}
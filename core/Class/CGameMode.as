funcdef void CGameModeCall();

class CGameMode
{
    //提供构造函数方便创建类
    CGameMode(string _uniName, CGameModeCall@ _callBack, CGameModeCall@ _callBack2, int _Team = MODE_NOT, dictionary _CVar = {}) 
    {
        uniName = _uniName; 
        @StartMethod = @_callBack;
        @End = @_callBack2;
        Team = _Team;
		CVar = _CVar;
    }
    //唯一标识字符串
    string uniName;
    //需要执行的函数
    CGameModeCall@ StartMethod;
    CGameModeCall@ End;
    int Team;
	dictionary CVar;
	
	void Start()
	{
		array<string>@ tempAry = CVar.getKeys();
		for(uint i = 0;i < tempAry.length();i++)
		{
			g_EngineFuncs.CVarSetFloat(tempAry[i], float(CVar[tempAry[i]]));
		}
		this.StartMethod();
	}
    //输出为string
    string ToString() 
    { 
        return uniName; 
    }
}
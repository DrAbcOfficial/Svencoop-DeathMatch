funcdef void ClientCmdCallback( const CCommand@ );

class CClientCmd
{
	private string szName = "";
	private string szHelpInfo = "";
	private string szPrintf = "";
	private uint8 usFlag = 0;
	private CClientCommand@ c_ClientCom;
	private ClientCmdCallback@ c_CallBack;

	CClientCmd(){}
	CClientCmd(string _Name, string _Help, string _Print, uint8 _Flag, CClientCommand@ _Client, ClientCmdCallback@ _Call)
	{
		szName = _Name;
		szHelpInfo = _Help;
		szPrintf = _Print;
		usFlag = _Flag;
		@c_ClientCom = @_Client;
		@c_CallBack = @_Call;
	}
	
	string Name
	{
		get const{ return szName;}
		set{ szName = value;}
	}
		
	string HelpInfo
	{
		get const{ return szHelpInfo;}
		set { szHelpInfo = value; }
	}
	
	string Printf
	{
		get const{ return szPrintf;}
		set { szPrintf = value; }
	}
	
	uint8 Flag
	{
		get const{ return usFlag;}
		set { usFlag = value; }
	}
		
	CClientCommand@ ClientCommand
	{
		get{ return c_ClientCom;}
		set{ @c_ClientCom = value;}
	}
	
	ClientCmdCallback@ ClientCallback
	{
		get{ return c_CallBack;}
		set{ @c_CallBack = value;}
	}
	
	//排序
	int opCmp(CClientCmd &in other) const
	{
		return szName.opCmp(other.szName);
	}
}
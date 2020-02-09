#include "../addon/SayReplace"
#include "../addon/ClassicWeapon"
#include "../addon/Autobhop"
#include "../addon/TeamDeathMatch"

enum moduleCallType
{
    MODULE_PLUGIN = 0,
    MODULE_MAPINIT,
    MODULE_MAPACTIVE
}

void RegistAddonModule()
{
    //在这里注册
    pvpAddon::RegisteModule( "Say Replacement", "Replace keyword to something" ,"Dr.Abc", @Sayreplace::PluginInit);
    pvpAddon::RegisteModule( "Classic Weapons", "HL weapons, wow!" ,"Dr.Abc", @ClassiscWeapon::PluginInit, @ClassiscWeapon::MapInit, @ClassiscWeapon::MapActivate);
    pvpAddon::RegisteModule( "Auto Bhop", "Enable auto bhop" ,"Null", @Autobhop::PluginInit);
    pvpAddon::RegisteModule( "Team Death Match", "Enable Team Death Match" ,"Dr.Abc", @TeamDeathMatch::PluginInit);
}

namespace pvpAddon
{
    //提供方便的扩展功能
    funcdef void moduleCall();
    array<array<string>> aryRegistedModule = {};
    array<moduleCall@> aryModulePluginCall = {};
    array<moduleCall@> aryModuleMapInit = {};
    array<moduleCall@> aryModuleMapActive = {};

    void PluginInit()
    {
        pvpClientCmd::RegistCommand("info_listmodule","List all used modules","Addon", @pvpAddon::listCallback);
        RegistAddonModule();
        for(uint i = 0; i < aryModulePluginCall.length(); i++)
        {
            aryModulePluginCall[i]();
        }
    }

    void MapInit()
    {
        for(uint i = 0; i < aryModuleMapInit.length(); i++)
        {
            aryModuleMapInit[i]();
        }
    }

    void MapActivate()
    {
        for(uint i = 0; i < aryModuleMapActive.length(); i++)
        {
            aryModuleMapActive[i]();
        }
    }

    void listCallback(const CCommand@ pArgs)
	{
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
		string szPrint;
		if(aryRegistedModule.length() == 0)
			szPrint = pvpLang::getLangStr("_CLIENTCMD_","EMPCMD");
		else
		{
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, pvpLang::getLangStr("_CLIENTCMD_","AVACMD") + "\n");
			for(uint i = 0; i < aryRegistedModule.length(); i++ )
			{

				szPrint = szPrint + "["+aryRegistedModule[i][0]+"] | "+ aryRegistedModule[i][1] + " | Author: " + aryRegistedModule[i][2] + ".\n";
			}
			if( szPrint != "" )
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, szPrint);
		}
	}

    void RegisteModule( string&in Name, string&in Helpinfo, string&in Author, moduleCall@ call1, moduleCall@ call2 = null, moduleCall@ call3 = null)
    {
        aryModulePluginCall.insertLast(call1);
        if(call2 !is null)
            aryModuleMapInit.insertLast(call2);
        if(call3 !is null)
            aryModuleMapActive.insertLast(call3);
        aryRegistedModule.insertLast(array<string> = {Name, Helpinfo, Author});
        pvpLog::moduleLog(Name, Author);
    }
}
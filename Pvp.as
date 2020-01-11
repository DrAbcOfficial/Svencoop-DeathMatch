#include "core/Timer"
#include "core/Log"
#include "core/Lang"
#include "core/File"
#include "core/Utility"
#include "core/Config"
#include "core/Addon"

bool LoadFlag = false;
void PluginInit()
{
    //信息
    g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("NahNah");

    LoadFlag = pvpConfig::PluginInit();
    //配置文件不对，小伙子
    if(!LoadFlag)
    {
        pvpLog::log("Config data broken! Plugin won't work", 2);
        return;
    }
    
    pvpLang::PluginInit();
    pvpTimer::PluginInit();

    //全部载入完毕啦！赶紧打印个消息爽爽！
    pvpLog::log("""

       _______          _______   
       |_ __  \         |_ __  \  
       | |__) |_    __  | |__) | 
       |   ___/[ \ [  ] |  ___/  
      _|  |_    \ \/ / _| |_     
      |_____|    \__/ |_____|         Plugin
    """);
    pvpLog::log(pvpLang::getLangStr("_MAIN_","INITSUCC"));
}

void MapInit()
{
    //注册自定义monster
}

void MapActivited()
{
    
}
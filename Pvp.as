#include "core/Timer"
#include "core/Log"
#include "core/Lang"
#include "core/File"
#include "core/Utility"
#include "core/Config"
#include "core/Hitbox"
#include "core/Hook"
#include "core/Hud"
#include "core/PlayerData"
#include "core/Team"
#include "core/Vote"
#include "core/ClientCmd"
#include "core/ClientSay"
#include "core/EndGame"
#include "core/GameMode"
#include "core/TimerStop"
#include "core/Addon"

bool LoadFlag = false;
void PluginInit()
{
    //信息
    g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("NahNah");

    //非常重
    LoadFlag = pvpConfig::PluginInit();
    //配置文件不对，小伙子
    if(!LoadFlag)
    {
        pvpLog::log("Config data broken! Plugin won't work", SYSERROR);
        return;
    }
    //重中之重
    pvpLang::PluginInit();
    pvpHook::PluginInit();
    pvpHitbox::PluginInit();
    pvpGameMode::PluginInit();
    //不那么重
    pvpTimer::PluginInit();
    pvpPlayerData::PluginInit();
    pvpClientCmd::PluginInit();
    pvpVote::PluginInit();
    pvpTeam::PluginInit();
    pvpTimerStop::PluginInit();
    //完全没影响
    pvpAddon::PluginInit();
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
    if(!LoadFlag)
        return;

    //注册自定义monster
    pvpHitbox::MapInit();
    pvpTeam::MapInit();
    pvpAddon::MapInit();
}

void MapActivate()
{
    if(!LoadFlag)
        return;
    pvpAddon::MapActivate();
}
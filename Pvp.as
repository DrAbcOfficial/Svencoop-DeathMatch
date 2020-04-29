
#include "core/Log"
#include "core/Lang"
#include "core/Utility"
#include "core/PlayerData"
#include "core/Addon"
#include "core/VersionInfo"
#include "core/Class/CHandlePackage"
#include "core/IO/File"
#include "core/IO/Config"
#include "core/Hook/Hook"
#include "core/Game/Timer"
#include "core/Game/Hitbox"
#include "core/Game/Hud"
#include "core/Game/Team"
#include "core/Game/Vote"
#include "core/Game/ClientCmd"
#include "core/Game/EndGame"
#include "core/Game/GameMode"
#include "core/Game/TimerStop"

bool LoadFlag = false;
void PluginInit()
{
    //信息
    g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("NahNah");

    //非常重
    LoadFlag = pvpConfig::PluginInit();

    //pvpLog::log(pvpConfig::getConfig("General","PluginVersion").getValType());

    pvpVersion::PluginInit();
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
    pvpLog::log(pvpLang::getLangStr("_MAIN_","VERSION", pvpVersion::Version.Version));
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
    g_EngineFuncs.ServerCommand("as_reloadplugin pvp\n");
}
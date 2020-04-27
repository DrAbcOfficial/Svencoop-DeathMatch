#include "Class/CVersionInfo"

namespace pvpVersion
{
    CVersionInfo@ Version = null;
    void PluginInit()
    {
        pvpClientCmd::RegistCommand("info_version","Get the serverVersion","ServerVersion", @pvpVersion::VersionCallBack);
        @Version = @CVersionInfo(pvpConfig::getConfig("General","Version").getString());
    }

    void VersionCallBack(const CCommand@ Argments)
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        pvpLog::say(pPlayer, pvpLang::getLangStr("_MAIN_","VERSION", pvpVersion::Version.Version), POSBOTH);
	}
}
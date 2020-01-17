#include "../Entity/weapons/classic/monster_penguin"
#include "../Entity/weapons/classic/proj_shockbeam"
#include "../Entity/weapons/classic/weapon_hl9mmhandgun"
#include "../Entity/weapons/classic/weapon_hl357"
#include "../Entity/weapons/classic/weapon_hlcrossbow"
#include "../Entity/weapons/classic/weapon_hlcrowbar"
#include "../Entity/weapons/classic/weapon_hlegon"
#include "../Entity/weapons/classic/weapon_hlgauss"
#include "../Entity/weapons/classic/weapon_hlhandgrenade"
#include "../Entity/weapons/classic/weapon_hlhornet"
#include "../Entity/weapons/classic/weapon_hlmp5"
#include "../Entity/weapons/classic/weapon_hlpenguin"
#include "../Entity/weapons/classic/weapon_hlrpg"
#include "../Entity/weapons/classic/weapon_hlsatchel"
#include "../Entity/weapons/classic/weapon_hlshockrifle"
#include "../Entity/weapons/classic/weapon_hlshotgun"
#include "../Entity/weapons/classic/weapon_hlsnark"
#include "../Entity/weapons/classic/weapon_hltripmine"

const array<array<string>> aryWeapons = {
    {"weapon_9mmhandgun", "weapon_hl9mmhandgun"},
    {"weapon_357", "weapon_hl357"},
    {"weapon_crossbow", "weapon_hlcrossbow"},
    {"weapon_crowbar", "weapon_hlcrowbar"},
    {"weapon_egon", "weapon_hlegon"},
    {"weapon_gauss", "weapon_hlgauss"},
    {"weapon_handgrenade", "weapon_hlhandgrenade"},
    {"weapon_hornetgun", "weapon_hlhornetgun"},
    {"weapon_9mmAR", "weapon_hlmp5"},
    {"weapon_penguin", "weapon_hlpenguin"},
    {"weapon_rpg", "weapon_hlrpg"},
    {"weapon_satchel", "weapon_hlsatchel"},
    {"weapon_shockrifle", "weapon_hlshockrifle"},
    {"weapon_shotgun", "weapon_hlshotgun"},
    {"weapon_snark", "weapon_hlsnark"},
    {"weapon_tripmine", "weapon_hltripmine"}
};

enum COLOR_TYPE
{
    COLOR_LASER = 0,
    COLOR_DOT,
    COLOR_TRAIL,
    COLOR_GAUSSL,
    COLOR_GAUSSR,
    COLOR_EGON
}

namespace ClassiscWeapon
{
    bool bIsEnable = false;
    bool bIsMultiPlay = true;
    void PluginInit()
    {
        bIsEnable = pvpConfig::getConfig("Classic","Enable").getBool();
        bIsMultiPlay = pvpConfig::getConfig("Classic","Multi").getBool();

        pvpClientCmd::RegistCommand("admin_classicmode","Toggle the classic weapons","ClassicWeapons", @ClassiscWeapon::ClassicCall, CCMD_ADMIN);
        pvpClientCmd::RegistCommand("admin_multimode","Toggle the Multiplay mode","ClassicWeapons", @ClassiscWeapon::MultiCall, CCMD_ADMIN);

        pvpClientCmd::RegistCommand("player_weaponcolor","Change Your Weapons's color!","ClassicWeapons", @ClassiscWeapon::ColorCall);
    }

    void MapInit()
    {
        if(!bIsEnable)
            return;
        RegisterHLCrowbar();
        RegisterDMPenguin();
        RegisterPJshockbeam();
        RegisterHL9mmhandgun();
        RegisterHL357();
        RegisterHLCrossbow();
        RegisterHLEgon();
        RegisterHLGauss();
        RegisterHLHandgrenade();
        RegisterDMHornetGun();
        RegisterDMMP5();
        RegisterHLPenguinNade();
        RegisterHLRpg();
        RegisterHLSatchel();
        RegisterDMShockRifle();
        RegisterHLShotgun();
        RegisterHLSnark();
        RegisterHLTripmine();
    }

    void MapActivate()
    {
        if(!bIsEnable)
            return;
        for(uint i = 0; i < aryWeapons.length(); i++)
        {
            WeaponReplacer(aryWeapons[i][0], aryWeapons[i][1]);
        }
    }

    array<PlayerColor@> aryColors = {};
    class PlayerColor
    {
        CBasePlayer@ Player = null;
        Vector Laser = pvpConfig::getConfig("Classic","LaserColor").getVector();
        Vector Dot = pvpConfig::getConfig("Classic","DotColor").getVector();
        Vector GaussL = pvpConfig::getConfig("Classic","GaussColorL").getVector();
        Vector GaussR = pvpConfig::getConfig("Classic","GaussColorR").getVector();
        Vector Egon = pvpConfig::getConfig("Classic","EgonColor").getVector();
        Vector Trail = pvpConfig::getConfig("Classic","TrailColor").getVector();

        PlayerColor( CBasePlayer@ _pPlayer)
        {
            @Player = @_pPlayer;
        }
    }

    void setPlayerColor(CBasePlayer@ pPlayer, Vector vecColor ,int colortype)
    {
        for(uint i = 0; i < aryColors.length(); i ++)
        {
            if(aryColors[i].Player is pPlayer)
            {
                switch(colortype)
                {
                    case COLOR_LASER:aryColors[i].Laser = vecColor;return;
                    case COLOR_DOT:aryColors[i].Dot = vecColor;return;
                    case COLOR_GAUSSL:aryColors[i].GaussL = vecColor;return;
                    case COLOR_GAUSSR:aryColors[i].GaussR = vecColor;return;
                    case COLOR_EGON:aryColors[i].Egon = vecColor;return;
                    case COLOR_TRAIL:aryColors[i].Trail = vecColor;return;
                }
            }
        }
    }

    Vector getPlayerColor(CBasePlayer@ pPlayer, int colortype)
    {
        for(uint i = 0; i < aryColors.length(); i ++)
        {
            if(aryColors[i].Player is pPlayer)
            {
                switch(colortype)
                {
                    case COLOR_LASER:return aryColors[i].Laser;
                    case COLOR_DOT:return aryColors[i].Dot;
                    case COLOR_GAUSSL:return aryColors[i].GaussL;
                    case COLOR_GAUSSR:return aryColors[i].GaussR;
                    case COLOR_EGON:return aryColors[i].Egon;
                    case COLOR_TRAIL:return aryColors[i].Trail;
                }
            }
        }
        switch(colortype)
        {
            case COLOR_LASER:return pvpConfig::getConfig("Classic","LaserColor").getVector();
            case COLOR_DOT:return pvpConfig::getConfig("Classic","DotColor").getVector();
            case COLOR_GAUSSL:return pvpConfig::getConfig("Classic","GaussColorL").getVector();
            case COLOR_GAUSSR:return pvpConfig::getConfig("Classic","GaussColorR").getVector();
            case COLOR_EGON:return pvpConfig::getConfig("Classic","EgonColor").getVector();
            case COLOR_TRAIL:return pvpConfig::getConfig("Classic","TrailColor").getVector();
        }
        return pvpConfig::getConfig("Classic","DotColor").getVector();
    }

    bool PlayerPutinServer(CBasePlayer@pPlayer)
    {
        if(!bIsEnable)
            return false;
        if(pPlayer !is null)
        {
            aryColors.insertLast(PlayerColor(pPlayer));
            return true;
        }
        return false;
    }

    bool PlayerSpwan(CBasePlayer@pPlayer)
    {
        if(!bIsEnable)
            return false;
        if(pPlayer !is null)
        {
            pPlayer.RemoveAllItems(false);
		    pPlayer.SetItemPickupTimes(0);
		    pPlayer.GiveNamedItem( "weapon_hl9mmhandgun" , 0 , 34 );
		    pPlayer.GiveNamedItem( "weapon_hlcrowbar" , 0 , 0 );
            return true;
        }
        return false;
    }

    bool BeApply( CBaseEntity@ ent, const string& in strReplacement )
	{
		CBaseEntity@ pEntity = g_EntityFuncs.Create( strReplacement, ent.pev.origin, ent.pev.angles ,  false , null );
		if ( pEntity is null )
			return false;

		pEntity.pev.targetname = ent.pev.targetname;
		pEntity.pev.maxs = ent.pev.maxs;
		pEntity.pev.mins = ent.pev.mins;
		pEntity.pev.target = ent.pev.target;
		pEntity.pev.scale = ent.pev.scale;
		
		g_EntityFuncs.Remove(ent);
		return true;
	}
	
	void WeaponReplacer( string str_Replacee , string str_Replacer )
	{
		CBaseEntity@ entWeapon = null;
		while( ( @entWeapon = g_EntityFuncs.FindEntityByClassname( entWeapon, str_Replacee ) ) !is null )
		{
			if ( BeApply( entWeapon, str_Replacer ) )
				continue;
		}
	}

    void ClassicCall(const CCommand@ pArgs)
	{
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        int pIndex = pvpLang::getPlayerLangIndex(pPlayer);
        int tempInt = 0;
        if(pArgs.ArgC() == 1)
        {
            bIsEnable = !bIsEnable;
            pvpConfig::setConfig("Classic","Enable", bIsEnable);
            pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDTLG", pIndex));
            return;
        }
        string tempStr = pArgs[1].ToUppercase();
        tempStr.Trim();
        tempInt = Math.clamp(0 ,1, atoi(tempStr));
        switch(tempInt)
        {
            case 0: bIsEnable = false;pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDOFF", pIndex));break;
            case 1: bIsEnable = true; pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDON", pIndex));break;
        }
        pvpConfig::setConfig("Classic","Enable", bIsEnable);
	}

    void MultiCall(const CCommand@ pArgs)
	{
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        int pIndex = pvpLang::getPlayerLangIndex(pPlayer);
        int tempInt = 0;
        if(pArgs.ArgC() == 1)
        {
            bIsMultiPlay = !bIsMultiPlay;
            pvpConfig::setConfig("Classic","Multi", bIsMultiPlay);
            pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDTLG", pIndex));
            return;
        }
        string tempStr = pArgs[1].ToUppercase();
        tempStr.Trim();
        tempInt = Math.clamp(0 ,1, atoi(tempStr));
        switch(tempInt)
        {
            case 0: bIsMultiPlay = false;pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDOFF", pIndex));break;
            case 1: bIsMultiPlay = true; pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDON", pIndex));break;
        }
        pvpConfig::setConfig("Classic","Multi", bIsMultiPlay);
	}

    void ColorCall(const CCommand@ pArgs)
	{
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        int pIndex = pvpLang::getPlayerLangIndex(pPlayer);
        if(pArgs.ArgC() < 5)
        {
            pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "AVACMD", pIndex));
            pvpLog::say(pPlayer, "Laser | Dot | Trail | GaussR | GaussL | Egon");
            pvpLog::say(pPlayer, "Example: player_weaponcolor Laser 255 126 80");
            return;
        }
        string tempStr = pArgs[1].ToUppercase();
        tempStr.Trim();
        Vector tempVec = prepraseColor(Vector(atof(pArgs[2]), atof(pArgs[3]), atof(pArgs[4])));
        if(tempStr == "LASER")
            setPlayerColor(pPlayer, tempVec, COLOR_LASER);
        else if(tempStr == "DOT")
            setPlayerColor(pPlayer, tempVec, COLOR_DOT);
        else if(tempStr == "GAUSSR")
            setPlayerColor(pPlayer, tempVec, COLOR_GAUSSR);
        else if(tempStr == "GAUSSL")
            setPlayerColor(pPlayer, tempVec, COLOR_GAUSSL);
        else if(tempStr == "EGON")
            setPlayerColor(pPlayer, tempVec, COLOR_EGON);
        else if(tempStr == "TRAIL")
            setPlayerColor(pPlayer, tempVec, COLOR_TRAIL);
        pvpLog::say(pPlayer, pvpLang::getLangStr("_CLIENTCMD_", "CMDON", pIndex));
	}

    Vector prepraseColor(Vector&in vec)
    {
        float max = vec.x;
        max = Math.max(max, vec.y);
        max = Math.max(max, vec.z);
        if(max == 0)
            return Vector(255, 255, 255);
        max = 255/max;
        return Vector(vec.x * max, vec.y * max, vec.z * max);
    }
}
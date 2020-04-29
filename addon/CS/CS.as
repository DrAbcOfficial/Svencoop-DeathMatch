#include "Hook"
#include "BuyMenu"
#include "func_buyzone"
#include "func_bomb_target"
#include "weapon_C4"

namespace CS
{
    const string CTName = "Counter-Strike";
    const string TEName = "Terriost";
    const string WinText = " Win!\n";
    const int DEFAULT_MONEY = 800;
    const string moneyIcon = "dmg_chem";
    const string teIcon = "dmg_rad";
    const string ctIcon = "dmg_cold";
    const uint buyZoneChannel = 11;
    const uint teChannel = 12;
    const uint ctChannel = 13;
    const uint moneyChannel = 14;
    const uint timeChannle = 15;
    const uint roundTime = 120;
    const uint respawnTime = 7;
    const int endMoney = 1200;
    const int CTClass = CLASS_HUMAN_MILITARY;
    const int TEClass = CLASS_XRACE_SHOCK;
    const string BUYZONE_ICON = "misc/buyzone.spr";
    const array<string> avaliableMaps = {"de_dust2", "de_dust", "de_aztec", "de_nuke", "de_inferno"};

    bool IsCs = false;
    uint roundSpendTime = 0;
    bool IsRestarting = false;
    bool IsBlockTimer = false;
    bool IsBoomMode = false;
    HUDSpriteParams params;
    pvpHud::CNumHUD@ pHud1 = null;
    pvpHud::CNumHUD@ pHud2 = null;
    pvpHud::CNumHUD@ pHud3 = null;
    pvpHud::CTimeHUD@ pHud4 = null;


    enum ROUNDENTEVENT
    {
        CT_WIN = 1,
        TE_WIN,
        NO_WIN
    }
    
    void PluginInit()
    {
        //注册CS
        pvpGameMode::RegistMode("CS", @StartTeam, @EndTeam, MODE_TEAM, dictionary = {{"sv_maxspeed", 230},{"sv_airaccelerate", 1}});
        pvpClientCmd::RegistCommand("cs_buy","Buy something","CS", @CSMenu::BuyCallBack);
    }

    void MapInit()
    {
        IsCs = false;
        for(uint i = 0; i < avaliableMaps.length();i++)
        {
            if(pvpUtility::getMapName() == avaliableMaps[i])
            {
                pvpGameMode::Change("CS");
                IsCs = true;
                break;
            }
        }

        if(!IsCs)
        {
            pvpGameMode::Change("FFA");
            return;
        }

        ClassiscWeapon::bIsEnable = false;

        g_Game.PrecacheModel( "sprites/" + BUYZONE_ICON );
        g_Game.PrecacheModel( pvpConfig::getConfig("Team","RedSpr").getString());
        g_Game.PrecacheModel( pvpConfig::getConfig("Team","BlueSpr").getString());
        g_CustomEntityFuncs.RegisterCustomEntity( "func_buyzone", "func_buyzone" );
        g_CustomEntityFuncs.RegisterCustomEntity( "func_bomb_target", "func_bomb_target" );
        
        RegisterC4();
    }

    void MapActivate()
    {
        if(!IsCs)
            return;

		CBaseEntity@ entEntity = null;
		while( ( @entEntity = g_EntityFuncs.FindEntityByClassname( entEntity, "info_player_start" ) ) !is null )
		{
            CBaseEntity@ ctEntity = g_EntityFuncs.Create( "info_player_dm2", entEntity.pev.origin, entEntity.pev.angles ,  true , null );
            ctEntity.pev.spawnflags = 8;
            ctEntity.pev.message = CTName;
            g_EntityFuncs.DispatchSpawn(ctEntity.edict());
            g_EntityFuncs.Remove(entEntity);
		} 

        @entEntity = g_EntityFuncs.FindEntityByClassname( entEntity, "func_bomb_target" );
        if(@entEntity !is null)
		{
           IsBoomMode = true;
		} 

        CBaseEntity@ eEntity = null;
		while( ( @eEntity = g_EntityFuncs.FindEntityByClassname( eEntity, "info_player_deathmatch" ) ) !is null )
		{
            CBaseEntity@ teSpawn = g_EntityFuncs.Create( "info_player_dm2", eEntity.pev.origin, eEntity.pev.angles ,  true , null );
            teSpawn.pev.spawnflags = 8;
            teSpawn.pev.message = TEName;
            g_EntityFuncs.DispatchSpawn(teSpawn.edict());
            g_EntityFuncs.Remove(eEntity);
		} 
    }

    void Respawn()
    {
        CBaseEntity@ entEntity = null;
		while( ( @entEntity = g_EntityFuncs.FindEntityByClassname( entEntity, "weapon_*" ) ) !is null )
		{
            if(entEntity.pev.owner is null)
                g_EntityFuncs.Remove(entEntity);
            if(entEntity.pev.classname == "weapon_c4")
                g_EntityFuncs.Remove(entEntity);
		}

        CBaseEntity@ pEntity = null;
        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "c4" ) ) !is null )
		{
            g_EntityFuncs.Remove(pEntity);
		}

        roundSpendTime = 0;
        pHud4.Hide = false;
        IsBlockTimer = false;
        pvpEndGame::Restart(true, true);
        IsRestarting = false;

        if(IsBoomMode)
        {
            pvpTeam::CTeam@ pTeam = pvpTeam::GetTeamByName(TEName);
            if(pTeam.Count != 0)
                pTeam.GetRandomPlayer.GiveNamedItem("weapon_c4", 0, 0);
        }
            
    }

    void RoundEnd(int situation)
    {
        string szTemp;
        switch(situation)
        {
            case TE_WIN: pvpTeam::GetTeamByName(TEName).AddScore();szTemp = TEName + WinText;break;
            case CT_WIN: pvpTeam::GetTeamByName(CTName).AddScore();szTemp = CTName + WinText;break;
            case NO_WIN: szTemp = "Draw!\n";break; 
            default:break;
        }
        IsRestarting = true;
        g_PlayerFuncs.ClientPrintAll(HUD_PRINTCENTER, szTemp);
        CSMenu::AddTeamMoney(situation, endMoney);
        g_Scheduler.SetTimeout("Respawn", respawnTime);
    }

    bool CheckTeam()
    {
        int ctAlive = 0;
        int teAlive = 0;
        int player = 0;
        
        if(!g_SurvivalMode.IsEnabled() && pvpTeam::GetTeamByName(CTName).Count + pvpTeam::GetTeamByName(TEName).Count != 0)
            g_SurvivalMode.Activate(true);
            
        if(!IsBlockTimer)
            roundSpendTime++;
        else
            pHud4.Hide = true;
            
        for (int i = 0; i <= g_Engine.maxClients; i++)
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pPlayer !is null && pPlayer.IsConnected())
			{
                pHud1.SetValue(pvpTeam::GetTeamByName(TEName).Score);
                pHud1.Send(pPlayer);

                pHud2.SetValue(pvpTeam::GetTeamByName(CTName).Score);
                pHud2.Send(pPlayer);
                
                string steamId = pvpUtility::getSteamId(pPlayer);
                pHud3.SetValue(int(CSMenu::playerBank[steamId]));
                pHud3.SetSpr(moneyIcon);
                pHud3.Send(pPlayer);

                if(!IsBlockTimer)
                {
                    pHud4.SetValue(Math.max(int(roundTime - roundSpendTime), int(0)));
                    pHud4.Send(pPlayer);
                }

                player++;
                if(pPlayer.pev.team == 0)
                    pvpTeam::OpenMenu(pPlayer);
                if(pPlayer.IsAlive())
                {
                    if(pPlayer.pev.team == CTClass)
                        ctAlive++;
                    if(pPlayer.pev.team == TEClass)
                        teAlive++;
                    
                    CustomKeyvalue pCustom = pPlayer.GetCustomKeyvalues().GetKeyvalue("$i_IsInBuyZone");
                    if (pCustom.Exists() && pCustom.GetInteger() == 1)
                    {
                        g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), "$i_IsInBuyZone", 0);
                        g_PlayerFuncs.HudCustomSprite(pPlayer, CS::params);
                    }
                }

                g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), "$i_IsCalledCSBuy", 0);
                g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), "$i_inBombZone", 0);
            }
        }

        if(IsRestarting)
            return true;

        if(roundTime - roundSpendTime <= 0)
            RoundEnd(CT_WIN);
        else if(pvpTeam::GetTeamByName(CTName).Count != 0 && pvpTeam::GetTeamByName(TEName).Count != 0)
        {
            if(ctAlive == 0)
                RoundEnd(TE_WIN);
            else if (teAlive == 0 && !IsBlockTimer)
                RoundEnd(CT_WIN);  
        }
        else if(player != 0 && teAlive + ctAlive == 0)
            RoundEnd(NO_WIN);
        return true;
    }

    void StartTeam()
    {
        pvpTeam::AddTeam(TEName, RGBA(255,0,0,255), CLASS(TEClass), pvpConfig::getConfig("Team","RedSpr").getString());
        pvpTeam::AddTeam(CTName, RGBA(0,0,255,255), CLASS(CTClass), pvpConfig::getConfig("Team","BlueSpr").getString());
        pvpTeam::RegistTeamMenu("Chose Your Team");
        pvpHook::RegisteHook(CHookItem(@CSHook::PlayerDeath, HOOK_KILLED, "CSDeathHook"));
        pvpHook::RegisteHook(CHookItem(@CSHook::PlayerSpawn, HOOK_SPAWN, "CSSPawnHook"));
        pvpHook::RegisteHook(CHookItem(@CSHook::PlayerPutinServer, HOOK_PUTINSERVER, "CSPUTINSERVER"));
        pvpHook::RegisteHook(CHookItem(@CSHook::PreTakeDamage, HOOK_PREDAMAGE, "CSPREDAMAGE"));
        pvpTimer::addTimer(CTimerFunc("CS-TimerFunc", @CheckTeam));
        pvpHud::GetTimeHUD(pvpTimerStop::hudName).Hide = true;

        CSMenu::RegistCTMenu();
        CSMenu::RegistTEMenu();

        @pHud1 = pvpHud::CreateNumHUD(
            "CS-TEScore",
            0,
            RGBA_RED,
            Vector2D(0.4,0.06),
            teChannel,
            1.1,
            HUD_ELEM_DEFAULT_ALPHA | HUD_NUM_SEPARATOR,
            teIcon
        );
        pHud1.SetDigits(1,5);

        @pHud2 = pvpHud::CreateNumHUD(
            "CS-CTScore",
            0,
            RGBA_BLUE,
            Vector2D(0.55,0.06),
            ctChannel,
            1.1,
            HUD_ELEM_DEFAULT_ALPHA | HUD_NUM_RIGHT_ALIGN | HUD_NUM_SEPARATOR,
            ctIcon
        );
        pHud2.SetDigits(1,5);

        @pHud3 = pvpHud::CreateNumHUD(
            "CS-Money",
            0,
            RGBA_SVENCOOP,
            Vector2D(1,0.9),
            moneyChannel,
            1.1,
            HUD_ELEM_DEFAULT_ALPHA | HUD_NUM_RIGHT_ALIGN,
            moneyIcon
        );
        pHud3.SetDigits(1,5);

        @pHud4 = pvpHud::CreateTimeHUD(
            "CS-RoundTime",
            0,
            RGBA_SVENCOOP,
            Vector2D(0,0.06),
            timeChannle,
            1.1,
            HUD_TIME_MINUTES | HUD_TIME_SECONDS | HUD_ELEM_SCR_CENTER_X | HUD_TIME_COUNT_DOWN
        );

        params.channel = buyZoneChannel;
        params.flags = HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_DEFAULT_ALPHA ;
        params.x = 0.001;
        params.y = 0;
        params.spritename = BUYZONE_ICON;
        params.color1 = RGBA_GREEN;
        params.holdTime = 2;
        
        //允许生存模式
        g_SurvivalMode.EnableMapSupport();
        g_SurvivalMode.SetDelayBeforeStart(0);
    }

    void EndTeam()
    {
        pvpTeam::RemoveTeam();
        pvpHook::RemoveHook("CSDeathHook");
        pvpHook::RemoveHook("CSSPawnHook");
        pvpTimer::delTimer("CS-TimerFunc");
    }
}
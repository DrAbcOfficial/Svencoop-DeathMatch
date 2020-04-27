class CPlayerData
{
    CPlayerData(CBasePlayer@ _pPlayer)
    {
        @pPlayer = @_pPlayer;
        steamId = pvpUtility::getSteamId(_pPlayer);
        Data = {};
    }

    CBasePlayer@ pPlayer;
    string steamId;
    dictionary Data;
}
/**
    Time HUD部分
**/

class CTimeHUD : CNumHUD
{
    void Send()
    {
        if(Hide)
            return;
        for (int i = 0; i <= g_Engine.maxClients; i++)
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if(pPlayer !is null && pPlayer.IsConnected())
                g_PlayerFuncs.HudTimeDisplay(pPlayer, this.HUD);
        }
    }

    void Send(CBasePlayer@ pPlayer)
    {
        if(Hide)
            return;
        g_PlayerFuncs.HudTimeDisplay(pPlayer, this.HUD);
    }

    void Update(CBasePlayer@ pPlayer, float&in _value, int&in _channel = this.Channel)
    {
        this.Value = _value;
        this.Channel = _channel;
        
        g_PlayerFuncs.HudUpdateTime(pPlayer, _channel, _value);
    }

    void Update(float&in _value, int&in _channel = this.Channel)
    {
        this.Value = _value;
        this.Channel = _channel;

        for (int i = 0; i <= g_Engine.maxClients; i++)
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if(pPlayer !is null && pPlayer.IsConnected())
                g_PlayerFuncs.HudUpdateTime(pPlayer, _channel, _value);
        }
    }
}
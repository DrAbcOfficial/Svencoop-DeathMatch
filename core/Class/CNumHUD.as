/**
    这一部分是Num HUD
**/

class CNumHUD
{
    HUDNumDisplayParams HUD;
    string Name;
    float Value;
    protected uint8 InDefdigits = 2;
    protected uint8 InMaxdigits;
    protected RGBA inColor1;
    protected RGBA inColor2;
    protected Vector2D Pos;
    protected Vector2D FadeTime;
    protected int Flag;
    protected int Effect;
    protected int Channel;
    protected float HoldTime;
    protected float EffectTime;
    protected string SpriteName;
    bool Hide = false;


    void Create(string&in _Name, float&in _Value, RGBA&in _Color1, Vector2D&in _Pos, int&in _Channel, float&in _HoldTime, 
    int&in _Flag, string&in _SpriteName = "", RGBA&in _Color2 = RGBA(0,0,0,255), Vector2D _FadeTime = Vector2D(0,0), int&in _Effect = 0, float&in _EffectTime = 0.0f)
    {
        Name = _Name;
        Value = _Value;
        inColor1 = _Color1;
        inColor2 = _Color2;
        Pos = _Pos;
        FadeTime = _FadeTime;
        Effect = _Effect;
        Channel = _Channel;
        HoldTime = _HoldTime;
        EffectTime = _EffectTime;
        Flag = _Flag;
        SpriteName = _SpriteName;

        HUD.flags = Flag;
        HUD.spritename = SpriteName;
        HUD.value = Value;
        HUD.x = Pos.x;
        HUD.y = Pos.y;
        HUD.effect = Effect;
        HUD.color1 = inColor1;
        HUD.color2 = inColor2;

        HUD.fadeinTime = FadeTime.x;
        HUD.fadeoutTime = FadeTime.y;
        HUD.holdTime = HoldTime;
        HUD.fxTime = EffectTime;
        HUD.channel = Channel;
    }

    RGBA Color1
    {
        get {return inColor1;}
        set 
        { 
            inColor1 = value;
            HUD.color1 = inColor1;
        }
    }

    RGBA Color2
    {
        get {return inColor2;}
        set 
        { 
            inColor2 = value;
            HUD.color2 = inColor2;
        }
    }

    void SetValue(float fl)
    {
        Value = fl;
        HUD.value = fl;
    }

    void SetDigits(uint8&in defdigits, uint8&in maxdigits)
    {
        HUD.defdigits = defdigits;
        HUD.maxdigits = maxdigits;
    }

    void SetSpr(string&in spr)
    {
        SpriteName = HUD.spritename = spr;
    }

    void Send(CBasePlayer@ pPlayer)
    {
        if(Hide)
            return;
        g_PlayerFuncs.HudNumDisplay(pPlayer, this.HUD);
    }

    void Send()
    {
        if(Hide)
            return;
        for (int i = 0; i <= g_Engine.maxClients; i++)
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if(pPlayer !is null && pPlayer.IsConnected())
                g_PlayerFuncs.HudNumDisplay(pPlayer, this.HUD);
        }
    }

    void Update(CBasePlayer@ pPlayer, float&in _value, int&in _channel = Channel)
    {
        this.Value = _value;
        this.Channel = _channel;
        
        g_PlayerFuncs.HudUpdateNum(pPlayer, _channel, _value);
    }

    void Update(float&in _value, int&in _channel = Channel)
    {
        this.Value = _value;
        this.Channel = _channel;

        for (int i = 0; i <= g_Engine.maxClients; i++)
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if(pPlayer !is null && pPlayer.IsConnected())
                g_PlayerFuncs.HudUpdateNum(pPlayer, _channel, _value);
        }
    }
}
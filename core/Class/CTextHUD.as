/**
    这一部分是TextHUD
**/
class CTextHUD
{
    HUDTextParams HUD;
    string Name;
    string Content;
    private RGBA inColor1;
    private RGBA inColor2;
    private Vector2D Pos;
    private Vector2D FadeTime;
    private int Effect;
    private int Channel;
    private float HoldTime;
    private float EffectTime;

    CTextHUD(string&in _Name, string&in _Content, RGBA&in _Color1, Vector2D&in _Pos, int&in _Channel, float&in _HoldTime, 
    RGBA&in _Color2 = RGBA(0,0,0,255), Vector2D _FadeTime = Vector2D(0,0), int&in _Effect = 0, float&in _EffectTime = 0.0f)
    {
        Name = _Name;
        Content = _Content;
        inColor1 = _Color1;
        inColor2 = _Color2;
        Pos = _Pos;
        FadeTime = _FadeTime;
        Effect = _Effect;
        Channel = _Channel;
        HoldTime = _HoldTime;
        EffectTime = _EffectTime;

        HUD.x = Pos.x;
        HUD.y = Pos.y;
        HUD.effect = Effect;
        HUD.r1 = inColor1.r;
        HUD.g1 = inColor1.g;
        HUD.b1 = inColor1.b;
        HUD.a1 = inColor1.a;
        HUD.r2 = inColor2.r;
        HUD.g2 = inColor2.g;
        HUD.b2 = inColor2.b;
        HUD.a2 = inColor2.a;
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
            HUD.r1 = inColor1.r;
            HUD.g1 = inColor1.g;
            HUD.b1 = inColor1.b;
            HUD.a1 = inColor1.a;
        }
    }

    RGBA Color2
    {
        get {return inColor2;}
        set 
        { 
            inColor2 = value;
            HUD.r2 = inColor2.r;
            HUD.g2 = inColor2.g;
            HUD.b2 = inColor2.b;
            HUD.a2 = inColor2.a;
        }
    }

    void Send(CBasePlayer@ pPlayer)
    {
        g_PlayerFuncs.HudMessage(pPlayer, HUD, Content);
    }

    void Send()
    {
        g_PlayerFuncs.HudMessageAll( HUD, Content);
    }
}
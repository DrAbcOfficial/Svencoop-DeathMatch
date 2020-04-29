#include "../Class/CTextHUD"
#include "../Class/CNumHUD"
#include "../Class/CTimeHUD"

namespace pvpHud
{
    array<CTextHUD@> aryTextHUD;

    CTextHUD@ CreateTextHUD(string&in _Name, string&in _Content, RGBA&in _Color1, Vector2D&in _Pos, int&in _Channel, float&in _HoldTime, 
        RGBA&in _Color2 = RGBA(0,0,0,255), Vector2D _FadeTime = Vector2D(0,0), int&in _Effect = 0, float&in _EffectTime = 0.0f)
    {
        CTextHUD pHud (_Name, _Content,_Color1, _Pos, _Channel,_HoldTime, _Color2, _FadeTime, _Effect, _EffectTime);
        aryTextHUD.insertLast(@pHud);
        return @pHud;
    }

    CTextHUD@ GetTextHUD(string&in Name)
    {
        for(uint i = 0; i < aryTextHUD.length(); i++ )
        {
            if(aryTextHUD[i].Name == Name)
                return aryTextHUD[i];
        }
        return null;
    }

    CTextHUD@ GetTextHUD(uint&in Index)
    {
        if(Index < aryTextHUD.length())
            return aryTextHUD[Index];
        return null;
    }

    array<CNumHUD@> aryNumHUD;

    CNumHUD@ CreateNumHUD(string&in _Name, float&in _Value, RGBA&in _Color1, Vector2D&in _Pos, int&in _Channel, float&in _HoldTime, 
        int&in _Flag, string&in _SpriteName = "", RGBA&in _Color2 = RGBA(0,0,0,255), Vector2D _FadeTime = Vector2D(0,0), int&in _Effect = 0, float&in _EffectTime = 0.0f)
    {
        CNumHUD pHud;
        pHud.Create(_Name, _Value, _Color1, _Pos, _Channel, _HoldTime, _Flag, _SpriteName, _Color2, _FadeTime, _Effect, _EffectTime);
        aryNumHUD.insertLast(@pHud);
        return @pHud;
    }

    CNumHUD@ GetNumHUD(string&in Name)
    {
        for(uint i = 0; i < aryNumHUD.length(); i++ )
        {
            if(aryNumHUD[i].Name == Name)
                return aryNumHUD[i];
        }
        return null;
    }

    CNumHUD@ GetNumHUD(uint&in Index)
    {
        if(Index < aryNumHUD.length())
            return aryNumHUD[Index];
        return null;
    }

    CTimeHUD@ CreateTimeHUD(string&in _Name, float&in _Value, RGBA&in _Color1, Vector2D&in _Pos, int&in _Channel, float&in _HoldTime, 
        int&in _Flag, string&in _SpriteName = "", RGBA&in _Color2 = RGBA(0,0,0,255), Vector2D _FadeTime = Vector2D(0,0), int&in _Effect = 0, float&in _EffectTime = 0.0f)
    {
        CTimeHUD pHud;
        pHud.Create(_Name, _Value, _Color1, _Pos, _Channel, _HoldTime, _Flag, _SpriteName, _Color2, _FadeTime, _Effect, _EffectTime);
        aryNumHUD.insertLast(cast<CNumHUD@>(@pHud));
        return @pHud;
    }

    CTimeHUD@ GetTimeHUD(string&in Name)
    {
        for(uint i = 0; i < aryNumHUD.length(); i++ )
        {
            if(aryNumHUD[i].Name == Name)
                return cast<CTimeHUD@>(aryNumHUD[i]);
        }
        return null;
    }

    CTimeHUD@ GetTimeHUD(uint&in Index)
    {
        if(Index < aryNumHUD.length())
            return cast<CTimeHUD@>(aryNumHUD[Index]);
        return null;
    }
}
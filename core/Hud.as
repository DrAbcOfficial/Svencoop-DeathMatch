namespace pvpHud
{
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

    array<CTextHUD@> aryTextHUD;

    CTextHUD@ CreateTextHUD(string&in _Name, string&in _Content, RGBA&in _Color1, Vector2D&in _Pos, int&in _Channel, float&in _HoldTime, 
        RGBA&in _Color2 = RGBA(0,0,0,255), Vector2D _FadeTime = Vector2D(0,0), int&in _Effect = 0, float&in _EffectTime = 0.0f)
    {
        CTextHUD pHud (_Name, _Content,_Color1, _Pos, _Channel,_HoldTime, _Color2, _FadeTime, _Effect, _EffectTime);
        aryTextHUD.insertLast(pHud);
        return pHud;
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
            g_PlayerFuncs.HudNumDisplay(pPlayer, this.HUD);
        }

        void Send()
        {
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

    array<CNumHUD@> aryNumHUD;

    CNumHUD@ CreateNumHUD(string&in _Name, float&in _Value, RGBA&in _Color1, Vector2D&in _Pos, int&in _Channel, float&in _HoldTime, 
        int&in _Flag, string&in _SpriteName = "", RGBA&in _Color2 = RGBA(0,0,0,255), Vector2D _FadeTime = Vector2D(0,0), int&in _Effect = 0, float&in _EffectTime = 0.0f)
    {
        CNumHUD pHud;
        pHud.Create(_Name, _Value, _Color1, _Pos, _Channel, _HoldTime, _Flag, _SpriteName, _Color2, _FadeTime, _Effect, _EffectTime);
        aryNumHUD.insertLast(pHud);
        return pHud;
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

    /**
        Time HUD部分
    **/

    class CTimeHUD : CNumHUD
    {
        void Send()
        {
            for (int i = 0; i <= g_Engine.maxClients; i++)
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
                if(pPlayer !is null && pPlayer.IsConnected())
                    g_PlayerFuncs.HudTimeDisplay(pPlayer, this.HUD);
            }
        }

        void Send(CBasePlayer@ pPlayer)
        {
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

    CTimeHUD@ CreateTimeHUD(string&in _Name, float&in _Value, RGBA&in _Color1, Vector2D&in _Pos, int&in _Channel, float&in _HoldTime, 
        int&in _Flag, string&in _SpriteName = "", RGBA&in _Color2 = RGBA(0,0,0,255), Vector2D _FadeTime = Vector2D(0,0), int&in _Effect = 0, float&in _EffectTime = 0.0f)
    {
        CTimeHUD pHud;
        pHud.Create(_Name, _Value, _Color1, _Pos, _Channel, _HoldTime, _Flag, _SpriteName, _Color2, _FadeTime, _Effect, _EffectTime);
        aryNumHUD.insertLast(cast<CNumHUD@>(pHud));
        return pHud;
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
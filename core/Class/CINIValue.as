class CINIValue
{
    int8 Type = PDATA_NULL;
    int iInt;
    uint uiUint;
    float flFloat;
    bool bBool;
    string szString;
    Vector vecVector;
    Vector2D vecVector2D;
    RGBA vecRGBA;
	array<string> aryStr;

    CINIValue()
    {

    }
    CINIValue(int _Type)
    {
        set(_Type);
    }
    CINIValue(uint _Type)
    {
        set(_Type);
    }
    CINIValue(float _Type)
    {
        set(_Type);
    }
    CINIValue(bool _Type)
    {
        set(_Type);
    }
    CINIValue(string _Type)
    {
        set(_Type);
    }
    CINIValue(string _Type1, string _Type2, string _Type3, string _Type4)
    {
        set(RGBA(atoui(_Type1), atoui(_Type2), atoui(_Type3), atoui(_Type4)));
    }
    CINIValue(string _Type1, string _Type2, string _Type3)
    {
        set(Vector(atof(_Type1), atof(_Type2), atof(_Type3)));
    }
    CINIValue(string _Type1, string _Type2)
    {
        set(Vector2D(atof(_Type1), atof(_Type2)));
    }
    CINIValue(RGBA _Type)
    {
        set(_Type);
    }
    CINIValue(Vector _Type)
    {
        set(_Type);
    }
    CINIValue(Vector2D _Type)
    {
        set(_Type);
    }
	CINIValue(array<string> _Type)
    {
        set(_Type);
    }
    
    void set(int _Type)
    {
        Type = PDATA_INT;
        iInt = _Type;
    }
    void set(uint _Type)
    {
        Type = PDATA_UINT;
        uiUint = _Type;
    }
    void set(float _Type)
    {
        Type = PDATA_FLOAT;
        flFloat = _Type;
    }
    void set(bool _Type)
    {
        Type = PDATA_BOOL;
        bBool = _Type;
    }
    void set(string _Type)
    {
        Type = PDATA_STRING;
        szString = _Type;
    }
    void set(Vector _Type)
    {
        Type = PDATA_VECTOR;
        vecVector = _Type;
    }
    void set(Vector2D _Type)
    {
        Type = PDATA_VECTOR2D;
        vecVector2D = _Type;
    }
    void set(RGBA _Type)
    {
        Type = PDATA_RGBA;
        vecRGBA = _Type;
    }
	void set(array<string> _Type)
    {
        Type = PDATA_ARRAY;
        aryStr = _Type;
    }

    int8 getValType()
    {
        return Type;
    }
    int getInt()
    {
        return iInt;
    }
    uint getUint()
    {
        return uiUint;
    }
    float getFloat()
    {
        return flFloat;
    }
    bool getBool()
    {
        return bBool;
    }
    string getString()
    {
        return szString;
    }
    Vector getVector()
    {
        return vecVector;
    }
    Vector2D getVector2D()
    {
        return vecVector2D;
    }
    RGBA getRGBA()
    {
        return vecRGBA;
    }
	array<string> getArray()
    {
        return aryStr;
    }
}
/**
    这个结构
    {
        {
            Name名称
            Path路径
            Data
            {
                EN
                {
                    balabl
                }
                CN
                {
                    Balabala
                }
            }
        }
    }
**/
class CPVPLang
{
    string Name;
    string Path;
    dictionary Data;
    CPVPLang(string _Name, string _Path)
    {
        Name = _Name;
        Path = _Path;
        //构造函数问题只能固定位置
        Data = pvpFile::getINIData( "scripts/plugins/pvp/lang/" + Path + ".ini" );
    }

    string toString()
    {
        return Name + "::" + Path;
    }
}
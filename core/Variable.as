class CpvpVar
{
    //这里放一些可可设置的变量
    //string szXXX
    //int iXXX
    //float flXXX
    //bool bXXX
    //Vector vecXXX
    //dicitionary dcXXX
    //array ayXXX
    //同一用驼峰法命名
    string szTitle = pvpConfig::getConfig("General","Title");
}
CpvpVar g_pvpVar;
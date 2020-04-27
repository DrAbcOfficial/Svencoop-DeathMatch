class CEndFunc
{
    CEndFunc(string _uniName, pvpUtility::VoidFuncCall@ _callBack ) 
    {
        uniName = _uniName; 
        @callBack = @_callBack;
    }
    //唯一标识字符串
    string uniName;
    //需要执行的函数
    pvpUtility::VoidFuncCall@ callBack;
    //输出为string
    string ToString() 
    { 
        return uniName; 
    }
}
funcdef bool timerCallback();
//timer类
class CTimerFunc
{
    //提供构造函数方便创建类
    CTimerFunc(string _uniName, timerCallback@ _callBack ) 
    {
        uniName = _uniName; 
        @callBack = @_callBack;
    }
    //唯一标识字符串
    string uniName;
    //需要执行的函数
    timerCallback@ callBack;
    //输出为string
    string ToString() 
    { 
        return uniName; 
    }
}
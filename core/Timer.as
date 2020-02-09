namespace pvpTimer
{
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

    //一秒一次
    int8 timeStep = 1;
    //需要执行函数的数组，1为成功执行，0为失败
    array<CTimerFunc@> funcArray = {};
    //计时器
    CScheduledFunction@ pTimer;
    void PluginInit()
    {
        //读取语言文件
        pvpLang::addLang("_TIMER_","Timer");
        //初始化计时器
        @pTimer = g_Scheduler.SetInterval( "doFuncTimer", timeStep, g_Scheduler.REPEAT_INFINITE_TIMES );
    }

    void doFuncTimer()
    {
        array<string> errorName = {};
        //遍历数组挨个执行
        for(uint i = 0; i< funcArray.length(); i++)
        {
             //执行类里的函数
             bool flag = funcArray[i].callBack();
             //如果执行失败将失败标识字符串给出
            if(!flag)
            {
                errorName.insertLast(funcArray[i].uniName);
            }
        }

        //打印出执行失败函数
        if(errorName.length() > 0)
        {
            for(uint i = 0; i < errorName.length(); i++)
            {
                //使用统一的Log输出函数
                pvpLog::log(errorName[i]);
            }
        }
    }

    void addTimer(CTimerFunc@ data)
    {
        //添加函数到数组内
        funcArray.insertLast(data);
    }

    void setTimer(string&in replaceName, CTimerFunc@ data)
    {
        //替换函数
        for(uint i = 0; i< funcArray.length();i++)
        {
            if(funcArray[i].uniName == replaceName)
            {
                funcArray.removeAt(i);
                funcArray.insertAt(i, data);
                return;
            }
        }
        pvpLog::log(pvpLang::getLangStr("_TIMER_","SETERROR") + replaceName, 1);
    }

    void delTimer(string&in funcName)
    {
        //字符串查找数组内函数
        for(uint i = 0; i < funcArray.length(); i++ )
        {
            if(funcArray[i].uniName == funcName)
            {
                //是这个了，删掉
                funcArray.removeAt(i);
                return;
            }
        }
    }

    void delTimer(array<string>&in funcNames)
    {
        //提供一个批量删除的重载
        for(uint j = 0; j < funcNames.length();j++)
        {
            for(uint i = 0; i < funcArray.length(); i++ )
            {
                if(funcArray[i].uniName == funcNames[i])
                {
                    //是这个了，删掉
                    funcArray.removeAt(i);
                }
            }
        }
    }
}
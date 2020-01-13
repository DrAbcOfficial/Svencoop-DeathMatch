enum typeOfDictionary
{
    PDATA_NULL,
    PDATA_INT=0,
    PDATA_UINT,
    PDATA_FLOAT,
    PDATA_BOOL,
    PDATA_STRING
}

namespace pvpFile
{
    class CINIValue
    {
        int8 Type = PDATA_NULL;
        int iInt;
        uint uiUint;
        float flFloat;
        bool bBool;
        string szString;
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
    }

    dictionary AddDicData(dictionary&in dic, string&in key,string&in sz)
    {
        sz.Trim();
        Regex::Regex@ pRegex = Regex::Regex("^\\d*[0-9](|.\\d*[0-9]|,\\d*[0-9])?$");
        Regex::Regex@ fRegex = Regex::Regex("^-?[1-9]\\d*$");
        //布尔型
        string temp = sz;
        if(sz.ToLowercase() == "true")
            dic.set(key,CINIValue(true));
        else if(sz.ToLowercase() == "false")
            dic.set(key,CINIValue(false));
        //实数型
        else if(Regex::Match(temp, @pRegex))
            dic.set(key,CINIValue(atof(temp)));
        //整数型
        else if(Regex::Match(temp, @fRegex))
            dic.set(key,CINIValue(atoi(temp)));
        //字符串
        else
            dic.set(key,CINIValue(temp));
        return dic;
    }

    dictionary getINIData(string&in path)
    {
        dictionary returnDic;
        //读取文件
        File@ file = g_FileSystem.OpenFile(path, OpenFile::READ);
		if (file !is null && file.IsOpen()) 
		{
            string section = "";
            dictionary tempDic;
			while(!file.EOFReached()) 
			{
				string sLine;
				file.ReadLine(sLine);
				if (sLine.IsEmpty())
					continue;
                //是否为注释
                if(sLine.StartsWith(";") || sLine.StartsWith("//"))
                {
                    continue;
                }
                //首字符是否是[
                else if(sLine.StartsWith("["))
                {
                    //如果section不为空，则向返回词典添加"section", dictionary
                    if(!section.IsEmpty())
                    {
                        returnDic[section] = tempDic;
                        tempDic.deleteAll();
                    }
                    //是则为节赋值
                    section = sLine.Replace("[","").Replace("]","");
                }
                else
                {
                    //否则添加键值进入临时词典
                    array<string> parseds = sLine.Split("=");
				    if (parseds.length() != 2)
					    continue;

                    //判断类型添加相应数据
                    tempDic = AddDicData(tempDic, parseds[0], parseds[1]);
                }
			}
            //循环结束后别忘了还剩一个
            returnDic[section] = tempDic;
			file.Close();
		}
        else
        {
            //提示错误文件
            pvpLog::log("Can not found file: " + path, 2);
        }
        //最后返回返回词典
        return returnDic;
    }
}
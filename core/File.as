enum typeOfDictionary
{
    PDATA_NULL,
    PDATA_INT=0,
    PDATA_UINT,
    PDATA_FLOAT,
    PDATA_BOOL,
    PDATA_STRING,
    PDATA_VECTOR,
    PDATA_VECTOR2D,
    PDATA_RGBA
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
        Vector vecVector;
        Vector2D vecVector2D;
        RGBA vecRGBA;

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
    }

    dictionary AddDicData(dictionary&in dic, string&in key,string&in sz)
    {
        sz.Trim();
        //实数
        Regex::Regex@ pRegex = Regex::Regex("^(-?\\d+)(\\.\\d+)?$");
        //整数
        Regex::Regex@ fRegex = Regex::Regex("^-?[1-9]\\d*$");
        //向量
        Regex::Regex@ vRegex = Regex::Regex("^(-?\\d+)(\\.\\d+)?,(-?\\d+)(\\.\\d+)?,(-?\\d+)(\\.\\d+)?$");
        //二维向量
        Regex::Regex@ v2Regex = Regex::Regex("^(-?\\d+)(\\.\\d+)?,(-?\\d+)(\\.\\d+)?$");
        //颜色
        Regex::Regex@ cRegex = Regex::Regex("^(-?\\d+)?,(-?\\d+)?,(-?\\d+)?,(-?\\d+)?$");
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
        //二维向量型
        else if(Regex::Match(temp, @v2Regex))
        {
            array<string> tempAry = temp.Split(",");
            dic.set(key,CINIValue(tempAry[0], tempAry[1]));
        }  
        //向量型
        else if(Regex::Match(temp, @vRegex))
        {
            array<string> tempAry = temp.Split(",");
            dic.set(key,CINIValue(tempAry[0], tempAry[1], tempAry[2]));
        }  
        //颜色型
        else if(Regex::Match(temp, @cRegex))
        {
            array<string> tempAry = temp.Split(",");
            dic.set(key,CINIValue(tempAry[0], tempAry[1], tempAry[2], tempAry[3]));
        } 
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
            uint uiLine = 0;
			while(!file.EOFReached()) 
			{
                uiLine++;
				string sLine;
				file.ReadLine(sLine);

                //是否是空白
				if (sLine.IsEmpty())
					continue;
                //是否为注释
                else if(sLine.StartsWith(";") || sLine.StartsWith("//"))
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
                    //你这写的什么破小节啊
                    if(!sLine.EndsWith("]"))
                    {
                        pvpLog::log("config file: " + path + " | Skipped: unrecognized section \"" + sLine + "\" in line: " + uiLine + " pointer: " + string(file.Tell()) , SYSWARN);
                        continue;
                    }
                    else
                    {
                        //是则为节赋值
                        section = sLine.Replace("[","").Replace("]","");
                    }
                }
                else if( sLine.Find("=") != String::INVALID_INDEX)
                {
                    //否则添加键值进入临时词典
                    array<string> parseds = sLine.Split("=");

                    //你写的什么破玩意儿啊
				    if (parseds.length() != 2)
                    {
                        pvpLog::log("config file: " + path + " | Skipped: unrecognized key \"" + sLine + "\" in line: " + uiLine + " pointer: " + string(file.Tell()) , SYSWARN);
                        continue;
                    }
					    
                    //判断类型添加相应数据
                    tempDic = AddDicData(tempDic, parseds[0], parseds[1]);
                }
                else
                {
                    //第一行不能正常判断，为啥
                    if(uiLine == 1)
                        continue;
                    //你到底写的啥玩意儿这是
                    pvpLog::log("config file: " + path + " | Skipped: unrecognized charactor \"" + sLine + "\" in line: " + uiLine + " pointer: " + string(file.Tell()) , SYSWARN);
                    continue;
                }
			}
            //节呢？劳资的小节呢
            if(section == "")
            {
                pvpLog::log("config file: " + path + " | Aborted read: can not found any avaliable sections" , SYSERROR);
                file.Close();
                return returnDic;
            }
            //循环结束后别忘了还剩一个
            returnDic[section] = tempDic;
			file.Close();
		}
        else
        {
            //提示错误文件
            pvpLog::log("config file: " + path + " | Aborted read: can not found or open file", SYSERROR);
        }
        //最后返回返回词典
        return returnDic;
    }
}
#include "../Class/CINIValue"

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
    PDATA_RGBA,
	PDATA_ARRAY
}

namespace pvpFile
{
    dictionary AddDicData(dictionary&in dic, string&in key,string&in sz)
    {
        sz.Trim();
        array<string> tempAry;
        switch(pvpUtility::getStringType(sz))
        {
            case PDATA_BOOL: dic.set(key,CINIValue(sz.ToLowercase() == "true" ? true : false));break;
            case PDATA_INT: dic.set(key,CINIValue(atoi(sz)));break;
            case PDATA_FLOAT: dic.set(key,CINIValue(atof(sz)));break;
            case PDATA_VECTOR2D: tempAry = sz.Split(","); dic.set(key,CINIValue(tempAry[0], tempAry[1]));break;
            case PDATA_VECTOR: tempAry = sz.Split(","); dic.set(key,CINIValue(tempAry[0], tempAry[1], tempAry[2]));break;
            case PDATA_RGBA: tempAry = sz.Split(",");dic.set(key,CINIValue(tempAry[0], tempAry[1], tempAry[2], tempAry[3]));break;
            case PDATA_STRING: dic.set(key,CINIValue(sz));break;
			case PDATA_ARRAY: tempAry = sz.Replace("<ARRAY>","").Split("&|");dic.set(key,CINIValue(tempAry));break;
            default:dic.set(key,CINIValue(sz));break;
        }
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
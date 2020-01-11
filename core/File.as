namespace pvpFile
{
    dictionary AddDicData(dictionary&in dic, string&in key,string&in sz)
    {
        sz.Trim();
        Regex::Regex@ pRegex = Regex::Regex("^\\d*[0-9](|.\\d*[0-9]|,\\d*[0-9])?$");
        Regex::Regex@ fRegex = Regex::Regex("^-?[1-9]\\d*$");
        //布尔型
        if(tolower(sz) == "true")
            dic.set(key,true);
        else if(tolower(sz) == "false")
            dic.set(key,false);
        //实数型
        else if(Regex::Match(sz, @pRegex))
            dic.set(key,atof(sz));
        //整数型
        else if(Regex::Match(sz, @fRegex))
            dic.set(key,atoi(sz));
        //字符串
        else
            dic.set(key,sz);
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
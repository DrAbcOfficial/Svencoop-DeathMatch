class CVersionInfo
{
    int Version;
    int Build;
    int Edit;
    string Version
    {
        get { return string(Version) + "." + string(Build) + "." + string(Edit);}
		set
        { 
            value.Trim();
            array<string> tempAry = value.Split(".");
            Version = atoi(tempAry[0]);
            Build = atoi(tempAry[1]);
            Edit = atoi(tempAry[2]);
        }
    } 
    CVersionInfo(string _Version)
    {
        Version = _Version;
    }
}
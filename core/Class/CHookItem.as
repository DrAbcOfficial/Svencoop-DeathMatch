class CHookItem : CHandlePackage
{
    int Type = HOOK_NULL;
    string Name;
    CHookItem(ref@ _Hook, int _Type, string _Name)
    {
        Set(_Hook);
        Type = _Type;
        Name = _Name;
    }
}
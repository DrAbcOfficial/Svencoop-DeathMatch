funcdef void funcPackageCall(CHandlePackage@);
/**
    接口
**/
interface IHandlePackage
{
    void Set(ref@ obj);
    ref Get();
    bool IsEmpty();
    bool IsNull();
}
/**
    包装类
**/
class CHandlePackage : IHandlePackage
{
    private ref@ objHandle = null;
    private bool bEmpty = true;
    /**
        构造函数
    **/
    CHandlePackage()
    {

    }
    
    CHandlePackage(ref@ obj)
    {
        Set(@obj);
    }
    /**
        外露值
    **/
    ref Value
    {
        get { return objHandle;}
		set{ @objHandle = value;}
    } 
    /**
        赋值方法
    **/
    void Set(ref@ obj)
    {
        @objHandle = @obj;
        bEmpty = false;
    }
    /**
        取值方法
    **/
    ref Get()
    {
        return @objHandle;
    }
    /**
        是否已被赋值
    **/
    bool IsEmpty()
    {
        return bEmpty;
    }
    /**
        被包装值是否为空
    **/
    bool IsNull()
    {
        return @objHandle is null;
    }
    /**
        被包装值不为空则执行
        fCall 被执行的函数
    **/
    void IsNullOr(funcPackageCall@ fCall)
    {
        if(!IsNull())
            fCall(this);
    }
    /**
        被包装值为空则执行
        fCall 被执行的函数
    **/
    void IsNullThen(funcPackageCall@ fCall)
    {
        if(IsNull())
            fCall(this);
    }
    /**
        判断被包装值是否为空选择执行
        fNullCall 为空执行的函数
        fFullCall 不为空执行的函数
    **/
    void IsNullCall(funcPackageCall@ fNullCall = null, funcPackageCall@ fFullCall = null)
    {
        if(fNullCall !is null)
            IsNullThen(fNullCall);
        if(fFullCall !is null)
            IsNullOr(fFullCall);
    }
}
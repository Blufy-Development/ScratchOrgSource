public class SearchClassesCompController {
    
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
    public educato__Class__c classObj;
    public Boolean showClsBtton {get;set;}
    public WrapperClass objClassWrpper {get;set;}
    
    public Boolean getshowClsBtton(){return showClsBtton;}
    public void setshowClsBtton(Boolean clsBtn){
        if(clsBtn != showClsBtton){
            showClsBtton = clsBtn;
        }
    }
    public educato__Class__c getclassObj(){return classObj;}
    public void setclassObj(educato__Class__c cls){
        if(cls != classObj){
            classObj = cls;
            fetchClasses();
        }
    }
    
    public void fetchClasses(){
        objClassWrpper = new WrapperClass();
        if(classObj != NULL)
            objClassWrpper = fillWrapper(classObj);
    }
    
    private WrapperClass fillWrapper(Class__c cls){
        Date tDate = System.today();
        WrapperClass wrpCls = new WrapperClass();
        wrpCls.clsId = cls.Id;
        wrpCls.clsName = cls.Name;
        wrpCls.clsDays = cls.educato__Days_of_Week__c;
        wrpCls.clsTeacher = cls.educato__Teacher__r.Name;
        wrpCls.clsLocation = cls.educato__Location__r.Name;
        //wrpCls.clsStrtTym = Datetime.newInstance(tDate, cls.educato__Start_Time__c);
        //wrpCls.clsEndTym = Datetime.newInstance(tDate, cls.educato__End_Time__c);
        wrpCls.clsStrtDte = (cls.educato__Start_Date__c != null ? cls.educato__Start_Date__c : null);
        wrpCls.clsEndDte = (cls.educato__End_Date__c != null ? cls.educato__End_Date__c : null);
        return wrpCls;
    }
    
    public Class WrapperClass{
        public String clsId {get;set;}
        public String clsName {get;set;}
        public String clsDays {get;set;}
        public String clsTeacher {get;set;}
        public String clsLocation {get;set;}
        public DateTime clsStrtTym {get;set;}
        public DateTime clsEndTym {get;set;}
        public Date clsStrtDte {get;set;}
        public Date clsEndDte {get;set;}
    }
}
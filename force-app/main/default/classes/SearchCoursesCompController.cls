public class SearchCoursesCompController {
    
   public List<educato__Class__c> listClass {get;set;}
    public string locationValue; 
    public string categoryValue;
    public string levelValue;
    public string typeValue;
    public List<WrapperClass> listWrapperClass{get;set;}
    
    public SearchCoursesCompController(){
        listClass = new List<educato__Class__c>();
        searchCourses();
    }
    
    public id getlocationValue(){return locationValue;}     
    public void setlocationValue(String str){
        if(str != locationValue){
            locationValue = str;
            searchCourses();
        }
    }
    
    public id getcategoryValue(){return categoryValue;}     
    public void setcategoryValue(String str){
        if(str != categoryValue){
            categoryValue = str;
            searchCourses();
        }
    } 
    
    public id getlevelValue(){return levelValue;}     
    public void setlevelValue(String str){
        if (str != levelValue){
            levelValue = str;
            searchCourses();
        }
    }
    
    public id gettypeValue(){return typeValue;}     
    public void settypeValue(String str){
        if(str != typeValue){
            typeValue = str;
            searchCourses();
        }
    }
    
    public void searchCourses(){
        Boolean isCourseAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Course__c',new Set<String>{'Id',
            'Name','Duration__c','Duration_Type__c','Description__c'},false);
        
        Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Class__c',new Set<String>{'Id',
            'Name'},false);
        
        Boolean isCourseFeeAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Course_Fee__c',new Set<String>{'Id',
            'Fee__c'},false);
        
        Boolean isFeeAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Fee__c',new Set<String>{'Id',
            'Amount__c','Type__c'},false);
        
        if(isCourseAccessible && isClassAccessible && isCourseFeeAccessible && isFeeAccessible){
            String query = ' SELECT Id,Name,educato__Duration__c,educato__Duration_Type__c,educato__Description__c,(SELECT educato__Fee__r.educato__Amount__c ';
            query +=' FROM Course_Fee__r WHERE educato__Fee__r.educato__Type__c = \'Tuition Fee\'),(SELECT Id,Name, ';
            query += ' educato__Days_of_Week__c,educato__Start_Date__c,educato__End_Date__c,educato__Course__c, ';
            query += ' educato__Teacher__c,educato__Teacher__r.Name,educato__Location__c,educato__Location__r.Name, ';
            query += ' educato__Start_Time__c,educato__End_Time__c ';
            query += ' FROM Classes__r';
            
            if(String.isNotBlank(locationValue))
                query += ' WHERE educato__Location__c =: locationValue ';
            system.debug('locationValue-->'+locationValue);
            query += ') FROM educato__Course__c WHERE educato__Class_Count__c > 0 ';
            
            if(String.isNotBlank(categoryValue))
                query += ' AND educato__Category__c =: categoryValue ';
            
            if(String.isNotBlank(levelValue))
                query += ' AND educato__Level__c =: levelValue '; 
            
            if(String.isNotBlank(typeValue))
                query += ' AND educato__Type__c =: typeValue ';
            
            query += ' LIMIT 5 ';
            system.debug('query-->'+query);
            listWrapperClass = new List<WrapperClass>();
            for(educato__Course__c course : Database.query(query)){
                if(course.Classes__r.size() > 0){
                    listWrapperClass.add(fillWrapper(course));
                }
            }
        }
    }
    
    private WrapperClass fillWrapper(educato__Course__c course){
        WrapperClass wrpCls = new WrapperClass(); 
        wrpCls.courseId = course.Id;
        wrpCls.courseName = course.Name;
        wrpCls.courseDes = course.educato__Description__c;
        wrpCls.courseDuration = String.valueOf(course.educato__Duration__c);
        wrpCls.courseDurType = course.educato__Duration_Type__c;
        wrpCls.fee = (course.Course_Fee__r.size() > 0 ? course.Course_Fee__r[0].educato__Fee__r.educato__Amount__c : 0); 
        wrpCls.listClass.addAll(course.Classes__r);
        return wrpCls;
    }
    
    public Class WrapperClass{
        public String courseId {get;set;}
        public String courseName {get;set;}
        public String courseDes {get;set;}
        public String courseDuration {get;set;}
        public String courseDurType {get;set;}
        public Double fee {get; set;} 
        public List<educato__Class__c> listClass {get;set;}
        public WrapperClass(){
            listClass = new List<educato__Class__c>();
            fee = 0;
        }
    }
}
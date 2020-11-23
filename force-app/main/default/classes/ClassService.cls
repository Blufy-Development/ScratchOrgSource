/**
Name        :   ClassService
Date        :   11 JULY 2020
Description :   This class is use for to perform DML operation on Class Object
*/
public  class ClassService{   
    
    /**
getClassData on  10-07-20  get the class data based on class set Ids    
*/  
    public static List<Class__c> getById(Set<Id> classId){
        if(!classid.isEmpty()){
            try {
                List<Class__c> clasList = new List<Class__c>();
                for(Class__c clsObj : [SELECT Id, Name, Course__c,Current_Course_Module__c,Current_Course_Module__r.Sequence__c,
                                       Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Location__c,Location__r.Name,
                                       Last_Session_Scheduled_Date__c,Last_Session_Date__c,Advance_Scheduling_Period__c,
                                       Advance_Scheduling_Unit__c,Next_Schedule_Date__c,Teacher__r.Name, Type__c,Frequency__c,
                                       Status__c, Capacity__c, Days_of_Week__c, Sessions__c
                                       FROM Class__c WHERE  Id IN: classId WITH SECURITY_ENFORCED]){
                                           clasList.add(clsObj);
                                       }
                return clasList;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<Class__c> getClassTermsAndSessionsByClassId(Set<String> classId){
        if(!classid.isEmpty()){
            try {
                List<Class__c> clasList = [SELECT Id, Name, (SELECT Id, Name FROM Class_Terms__r),
                                           (SELECT Id,Class__c FROM Sessions__r)
                                           FROM Class__c WHERE Id IN:classId WITH SECURITY_ENFORCED];
                return clasList;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<Class__c> getClassTermsByClassId(Set<String> setClassId){
        try{
            List<Class__c> listClass = [SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Location__c, Location__r.Name,  
                                        Teacher__r.Name, Type__c, Frequency__c, Status__c, Capacity__c, Days_of_Week__c, Sessions__c,
                                        (SELECT Id, Name, Sequence__c, Sessions__c, Start_Date__c, End_Date__c,Class__r.Advance_Billing__c,
                                         Class__r.Advance_Billing_Unit__c
                                         FROM Class_Terms__r WHERE Status__c =:ConstantClass.ScheduledStatus AND Sessions__c > 0 
                                         AND Start_Date__c != null ORDER BY Sequence__c)
                                        FROM Class__c WHERE Id IN:setClassId AND Days_of_Week__c != null WITH SECURITY_ENFORCED];
            return listClass;
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        }        
        return null;
    }
    
    //Update of Class Records
    public static List<Class__c> updateClassRecords(List<Class__c> listClass){
        try{
            if(listClass.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listClass,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Class Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    update securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Class Error Message-->'+e.getMessage());
        }
        return null;
    }
    
    //Added on 17-08-20 get records by Teacher Id
    public static List<Class__c> getByTeacherId(Set<String> teacherIds){
        if(teacherIds.size() > 0){
            try{
                return [ SELECT id, Course__c FROM Class__c WHERE Teacher__c IN: teacherIds WITH SECURITY_ENFORCED];
            }catch(System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<Class__c> getByStringQuery(String query){
        if(String.isNotBlank(query)){
            try{
                return Database.query(query+' WITH SECURITY_ENFORCED');
            }catch(Exception e){
                System.debug('Error while excute dynamic query in class services '+e.getMessage());
            }
        }
        return null;
    }
    
    public static List<Class__c> getByCourseIdAlongWithClassTerms(String courseId){
        if(String.isNotBlank(courseId)){
            try {
                List<Class__c> clasList = [SELECT Id, Name, Enrollments__c,Start_Date__c, End_Date__c, Start_Time__c, End_Time__c,Location__c, 
                                           Location__r.Name,Teacher__r.Name, Course__r.Name, Type__c, Frequency__c, Status__c, Capacity__c, 
                                           Days_of_Week__c,Seats_Available__c,
                                           (SELECT Id, Name, Start_Date__c, End_Date__c,Sessions__c, Status__c 
                                            FROM  Class_Terms__r WHERE Status__c =:ConstantClass.ScheduledStatus AND 
                                            Allow_Enrollment__c = True AND  Start_Date__c != null AND  
                                            End_Date__c != null ORDER BY Sequence__c
                                           ),(SELECT Id, Enrollments__c, Type__c, Teacher__r.name, 
                                                Start_Time__c, End_Time__c,Seats_Left__c, 
                                                Day_of_Week__c FROM Class_Sessions__r ) FROM Class__c 
                                           WHERE Course__c =:courseId AND  Type__c != null AND Frequency__c != null 
                                           AND (Status__c =: ConstantClass.clsOpenStatus OR 
                                                (Allow_Overbooking__c = True AND Status__c =: ConstantClass.clsClosedStatus))
                                           WITH SECURITY_ENFORCED];
                
                return clasList;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    } 
    
    public static List<Class__c> getByIdAlongWithEnrolDate(String classId,Date enrolDate){
        if(String.isNotBlank(classId) && enrolDate != NULL){
            try {
                List<Class__c> clasList = [SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Location__c,
                                           Location__r.Name,Teacher__r.Name, Type__c, Frequency__c, Status__c, Capacity__c, 
                                           Days_of_Week__c, Sessions__c,
                                           (SELECT Id, Name, Sequence__c, Sessions__c, Start_Date__c, End_Date__c 
                                            FROM Class_Terms__r WHERE Status__c =:ConstantClass.ScheduledStatus 
                                            AND Allow_Enrollment__c = True AND Sessions__c > 0 AND Start_Date__c != null AND 
                                            End_Date__c >: enrolDate ORDER BY Sequence__c)
                                           FROM Class__c WHERE Id =:classId AND Days_of_Week__c != null AND Format__c != null 
                                           WITH SECURITY_ENFORCED];
                
                return clasList;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    } 
    
    public static List<Class__c> getByIdAlongWithStartDate(Set<String> setClassId){
        if(setClassId.size() > 0){
            try {
                List<Class__c> clasList = [SELECT Id, Name,
                                           (SELECT Id, Name, Sequence__c, Start_Date__c, End_Date__c, 
                                            Class__r.Advance_Billing_Unit__c, Class__r.Advance_Billing__c 
                                            FROM Class_Terms__r 
                                            WHERE Start_Date__c > TODAY AND Sequence__c != null ORDER BY Start_Date__c) 
                                           FROM Class__c WHERE Id IN: setClassId
                                           WITH SECURITY_ENFORCED];
                
                return clasList;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    } 
    
    public static List<Class__c> getClassByClassIdAlongWithClassTermId(String clsTermId,String classId){
        if(String.isNotBlank(classId) && String.isNotBlank(clsTermId)){
            try {
                List<Class__c> clasList = [SELECT Id, Name,Teacher__c,Teacher__r.Name,Start_Date__c,End_Date__c,Days_of_Week__c, 
                                           Sessions__c,Location__c,Course__c,Exclude_Public_Holidays__c,Advance_Scheduling_Unit__c,
                                           (SELECT Id,Name,Sessions__c,Start_Date__c,End_Date__c
                                            FROM Class_Terms__r WHERE Id=:clsTermId AND Status__c='Draft' LIMIT 1),
                                           (SELECT Id,Name,Duration_In_Minutes__c,Start_Time__c,Teacher__c,Teacher__r.Name,Room__c,Room__r.Name 
                                            FROM Class_Sessions__r ORDER BY Start_Time__c),
                                           (SELECT Id,Sequence__c FROM Sessions__r ORDER BY Sequence__c DESC LIMIT 1)
                                           FROM Class__c WHERE Id =: classId
                                           WITH SECURITY_ENFORCED];
                
                return clasList;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    } 
    
}
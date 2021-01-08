public class StudentSessionService {
    
    //Insertion of Student Session Term Records
    public static List<Student_Session__c> insertStudentSessionRecords(List<Student_Session__c> listStudentSession){
        try{
            if(listStudentSession.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE,listStudentSession,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Student Session Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Student Session Error Message-->'+e.getMessage());
        }
        return null;
    }
    
    //Updation of Student Session Records
    public static List<Student_Session__c> updateStudentSessionRecords(List<Student_Session__c> listStudentSession){
        try{
            if(listStudentSession.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listStudentSession,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Student Session Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    update securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Student Session Error Message-->'+e.getMessage());
        }
        return null;
    }
    
    public static List<Student_Session__c> getBySessionId(Set<Id> sessionIds){
        if(sessionIds.size() > 0){
            try{
                return [SELECT Session__c, Session__r.Teacher__r.Name,
                        Account__r.Name, Session__r.Class__r.Name, 
                        Status__c, Notes__c, Enrollment__c,Enrollment__r.Comments__c,
                        Enrollment__r.Start_Date__c,Enrollment__r.Status__c,Enrollment__r.Subject__c, Session__r.Class__r.Course__r.Name
                        FROM Student_Session__c
                        WHERE Session__c IN :sessionIds
                        WITH SECURITY_ENFORCED];
            }catch(System.QueryException e){
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<Student_Session__c> getByEnrolDetails(String enrolId,Date nextBilldate,Date enrolEndDate){
        if(String.isNotBlank(enrolId) && nextBilldate != NULL && enrolEndDate != NULL){
            try{
                List<Student_Session__c> listStudentSession =  [SELECT Id,Name FROM Student_Session__c WHERE Enrollment__c =: enrolId 
                                                                AND Session_Date__c >= :nextBillDate AND Session_Date__c <=: enrolEndDate
                                                                WITH SECURITY_ENFORCED];
                return listStudentSession;
            }catch(System.QueryException e){
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<Student_Session__c> getByEnrolIdAndEnrolCancelDate(String enrolmentid,Date enrolCanDate){
        if(string.isNotBlank(enrolmentid) && enrolCanDate != null){
            try{
                List<Student_Session__c> listStudentSession =  [SELECT Account__c,Billable__c,Class_Type__c,
                                                                Course_Type__c, educato__Duration__c,Enrollment__c, 
                                                                Notes__c,Session_Date__c,Session__c, 
                                                                Status__c, Name, Id 
                                                                FROM Student_Session__c
                                                                Where Enrollment__c =: enrolmentid
                                                                And Session_Date__c <=: enrolCanDate
                                                                WITH SECURITY_ENFORCED
                                                                order by Session_Date__c desc];
                return listStudentSession;
            }catch(System.QueryException e){
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    public static List<Student_Session__c> getStudentSessionList(String enrolmentid,Date enrolCanDate){
        if(string.isNotBlank(enrolmentid) && enrolCanDate != null){
            try{
                List<Student_Session__c> listStudentSession =  [SELECT Session_Date__c, Id 
                                                                FROM Student_Session__c
                                                                Where Enrollment__c =: enrolmentid
                                                                And Session_Date__c >=: enrolCanDate
                                                                WITH SECURITY_ENFORCED];
                return listStudentSession;
            }catch(System.QueryException e){
                System.debug(e.getMessage());
            }        
        }
        return null;
    }

     //Updation of Student Session Records
     public static void deleteStudentSessionRecords(List<educato__Student_Session__c> listStudentSession){
        try{
            if(listStudentSession.size() > 0){
                Delete listStudentSession;
            }
        }
        catch(Exception e){
            System.debug('Student Session Error Message-->'+e.getMessage());
        }
        
    }
}
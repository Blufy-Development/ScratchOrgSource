/*
	Name		 : ClassSessionService	
	Description	 : This Service Class is used for DML operations.
	CH1			 : Updated on 20th Nov 2020 by Mohit, this method will update the Class Session records.
	CH2			 : Updated on 11th Dec 2020 by Mohit, this method will retrieve the Class Session records. 
*/
public class ClassSessionService {
    //CH1
    public static List<Class_Session__c> updateClassSessionRecords(List<Class_Session__c> clsSessList){
        try{
            if(clsSessList.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, clsSessList,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    System.debug('securityDecision@@'+securityDecision);
                    update securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Class Session Error Message-->'+e.getMessage());
        }
        return null;
    }
    //CH1

	//CH2
    public static List<Class_Session__c> getClassSessionsByIds(List<Class_Session__c> clsSessList){  
        try{
            if(clsSessList.size() > 0){
                List<Class_Session__c> listClassSession = [SELECT Id, Name, Class__c, Class__r.Status__c, Class__r.Scheduled_Till__c, 
                                                            Class__r.Location__c, Class__r.Course__c
                                                            FROM Class_Session__c WHERE Id IN:clsSessList AND 
                                                            Class__r.Status__c =:ConstantClass.openStatus AND 
                                                            Class__r.Scheduled_Till__c != null];
                return listClassSession;   
            }            
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;    
    }
	
    public static List<Class_Session__c> getClassSessionsById(set<String> clsSessList){  
        try{
            if(clsSessList.size() > 0){
                List<Class_Session__c> listClassSession = [SELECT Id, Name, Class__c, Class__r.Status__c, Class__r.Scheduled_Till__c, 
                                                            Class__r.Location__c, Class__r.Course__c, Class__r.Course__r.Name
                                                            FROM Class_Session__c WHERE Id IN:clsSessList];
                return listClassSession;   
            }            
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;    
    }

    public static List<Class_Session__c> getClassSessionsByClssId(Set<String> setClassId){  
        try{
            if(setClassId.size() > 0){
                List<Class_Session__c> listClassSession = [SELECT Id,Name,Duration_In_Minutes__c,Day_of_Week__c,Start_Time__c,Class__c,Teacher__c,Room__c 
                                                           FROM Class_Session__c
                                                           WHERE Class__c IN: setClassId WITH SECURITY_ENFORCED 
                                                           ORDER BY Start_Time__c];
                return listClassSession;   
            }            
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;    
    }
    
    //Added on 10-12-20 get records by teacher Id
    public static List<Class_Session__c> getByTeacherId(Set<String> teacherIds){
        if(teacherIds.size() > 0){
            try{
                return [SELECT Id, Class__c, Class__r.Course__c 
                        FROM Class_Session__c 
                        WHERE Teacher__c IN: teacherIds
                        WITH SECURITY_ENFORCED];             
            }catch(System.QueryException e) {
                System.debug(e.getMessage());
            }             
        }
        return null;
    }
    
    //Added on 21-12-20 get records by Id
    public static List<Class_Session__c> getById(Set<String> clsSessionIds){
        if(clsSessionIds.size() > 0){
            try{
                return [SELECT Id, Class__r.Course__c
                        FROM Class_Session__c 
                        WHERE Id IN: clsSessionIds
                        WITH SECURITY_ENFORCED];             
            }catch(System.QueryException e) {
                System.debug(e.getMessage());
            }             
        }
        return null;
    }
}
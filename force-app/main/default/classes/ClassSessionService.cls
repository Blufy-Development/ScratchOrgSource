/*
	Name		 : ClassSessionService	
	Description	 : This Service Class is used for DML operations.
	CH1			 : Updated on 20th Nov 2020 by Mohit, this method will update the Class Session records.
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
    
}
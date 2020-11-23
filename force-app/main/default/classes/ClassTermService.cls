public class ClassTermService {
    
    public static List<Class_Term__c> getByClassIds(Set<String> setClassId){
        if(!setClassId.isEmpty()){
            try{
                List<Class_Term__c> listClassTerm = [SELECT Sessions__c, Sequence__c,Start_Date__c,Class__c,
                                                     Class__r.Advance_Billing__c,Class__r.Advance_Billing_Unit__c 
                                                     FROM Class_Term__c WHERE Class__c IN: setClassId WITH SECURITY_ENFORCED 
                                                     ORDER By Start_Date__c];
                return listClassTerm;
            }catch(System.QueryException e){
                System.debug(e.getMessage());
            }        
        }
        return new List<Class_Term__c>();
    }
    
    //Insertion of Class Term Records
    public static List<Class_Term__c> insertClassTermRecords(List<Class_Term__c> listClassTerm){
        try{
            if(listClassTerm.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listClassTerm,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Class Term Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Error Message-->'+e.getMessage());
        }
        return null;
    }
    
    //Updation of Class Term Records
    public static List<Class_Term__c> updateClassTermRecords(List<Class_Term__c> listClassTerm){
        try{
            if(listClassTerm.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listClassTerm,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Class Term  Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    update securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Class Term Error Message-->'+e.getMessage());
        }
        return null;
    }
}
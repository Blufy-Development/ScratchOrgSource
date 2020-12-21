public class FamilyService {
    public static List<Family__c> insertRecords(List<Family__c> obList){
        if(obList.size() > 0){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.CREATABLE, obList, true);
            
            try {
                insert securityDecision.getRecords();
                return securityDecision.getRecords();
            } catch (Exception e) {
                System.debug('Family Error->'+e.getMessage());
            }
            
        }
        return null;
    }
    
    public static List<Family__c> upsertRecords(List<Family__c> obList){
        if(obList.size() > 0){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.UPSERTABLE, obList, true);
            try{
                upsert securityDecision.getRecords();
                return securityDecision.getRecords();
            }catch (Exception e) {
                System.debug('Family Error->'+e.getMessage());
            }
            
        }
        return null;
    }
    
    public static List<Family__c> getByParentAccountId(String parentAccountId){
        List<Family__c> listFamily = new List<Family__c>();
        if(String.isNotBlank(parentAccountId)){
            try {
                listFamily = [SELECT Id FROM Family__c WHERE Account__c =: parentAccountId
                              WITH SECURITY_ENFORCED];
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }
        }
        return listFamily;
    }
}
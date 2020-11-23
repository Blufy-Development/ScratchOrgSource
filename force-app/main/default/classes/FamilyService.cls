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
}
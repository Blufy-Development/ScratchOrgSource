public class BlufyConfigService {
    
    public static List<Blufy_Config__mdt> getByDeveloperName(String developerName){
        if(String.isNotBlank(developerName)){
            try {
                List<Blufy_Config__mdt> listBlufyConfig = [SELECT Monthly_Invoice_Cycle__c,Terms_and_Conditions_Description__c,
                                                           Terms_and_Conditions_Title__c,GST_VAT_Applicable__c,GST_VAT_Rate__c,
                                                           Invoice_Due_Days__c,Logo__c,Segment_Type__c
                                                           FROM Blufy_Config__mdt 
                                                           WHERE DeveloperName =: developerName 
                                                           WITH SECURITY_ENFORCED];
                return listBlufyConfig;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
}
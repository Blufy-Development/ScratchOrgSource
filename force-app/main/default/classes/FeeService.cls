public class FeeService{
	
    public static List<Fee__c> getFeeById(String feeId){
        if(String.isNotBlank(feeId)){
            try {
                List<Fee__c> listFee = [SELECT Id, Name, Amount__c, Units__c, Unit_Price__c, Frequency__c, Schedule__c 
                                        FROM Fee__c WHERE Id =: feeId AND Amount__c > 0 AND  Unit_Price__c != null AND 
                                        Prorate__c = true WITH SECURITY_ENFORCED];
                
                return listFee;
            }catch(System.QueryException e){
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<Fee__c> getRelatedFeeById(Set<String> feeIds){
        if(feeIds.size() > 0){
            try {
                List<Fee__c> listFee = [SELECT Id, Name, Type__c, Frequency__c, Amount__c, Schedule__c, Units__c, Unit_Price__c,Parent__c,
                                        Override__c,Required__c,GST_Applicable__c,RecordType.Name
                                        FROM Fee__c WHERE Parent__c IN: feeIds  AND 
                                        RecordType.Id =: ConstantClass.secondaryFeeRecordTypeId WITH SECURITY_ENFORCED];
                
                return listFee;
            }catch(System.QueryException e){
                System.debug(e.getMessage());
            }        
        }
        return null;
    }     
}
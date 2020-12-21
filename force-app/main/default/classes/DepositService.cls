public class DepositService {
    
    //Get Deposit Amount For Parent Id
    public static decimal getDepositAmountByParentId(string parentId){
        decimal totalDepositAmount =0;
        List<AggregateResult> AggregateResultList = [select educato__Account__c ,Sum(educato__Amount__c)amt 
                                                     from educato__Deposit__c 
                                                     where educato__Account__c =: parentId
                                                     WITH SECURITY_ENFORCED
                                                     group by educato__Account__c ]; 
        if(AggregateResultList != null && AggregateResultList.size() > 0){ 
            for(AggregateResult objdeposit : AggregateResultList){
                totalDepositAmount=(decimal)objdeposit.get('amt'); 
            }
        }
        return totalDepositAmount;
    }
    
    //Insertion of Deposit Records
    public static List<Deposit__c> insertDepositRecords(List<Deposit__c> listDeposit){
        try{
            if(listDeposit.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listDeposit,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Deposit Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Deposit Error Message-->'+e.getMessage());
        }
        return null;
    }
}
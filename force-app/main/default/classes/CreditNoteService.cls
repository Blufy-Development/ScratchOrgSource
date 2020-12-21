public class CreditNoteService {
    
    public static decimal getTotalCreditNoteAmountByParentId(string parentId){
        decimal totalCreditNoteAmount =0;
        List<AggregateResult> AggregateResultList = [select Id,Sum(educato__Amount__c)amt 
                                                     from educato__Credit_Note__c 
                                                     where educato__Account__c =: parentId 
                                                     WITH SECURITY_ENFORCED
                                                     group by Id]; 
        if(AggregateResultList != null && AggregateResultList.size() > 0){ 
            if(AggregateResultList != null && AggregateResultList.size() > 0){ 
                for(AggregateResult objCreditNote : AggregateResultList){
                    totalCreditNoteAmount=(decimal)objCreditNote.get('amt'); 
                }
            } 
        }
        return totalCreditNoteAmount;
    }
    
    public static List<Credit_Note__c> getByParentIds(Set<String>accId){
        try{
            if(accId.size() > 0){
                return [SELECT Id, Account__c, Amount__c, Status__c
                        FROM Credit_Note__c 
                        WHERE Account__c IN: accId AND Status__c = 'Status__c'] ;
            }
        }catch(System.QueryException e){           
            System.debug(e.getMessage());
        }
        return null;       
    }    
}
public class PaymentAccountService {
	
    //Insertion of Payment Account Records
    public static List<Payment_Account__c> insertPaymentAccountRecords(List<Payment_Account__c> listPaymentAccount){
        try{
            if(listPaymentAccount.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listPaymentAccount,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Payment Account Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Payment Account Error Message-->'+e.getMessage());
        }
        return null;
    }
}
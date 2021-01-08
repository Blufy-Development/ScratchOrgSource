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

    /*
     * By   : Jatin 
     * Date : 04th Jan 2021
     * Desc : Will update the Payment_Account__c records 
    **/
    public static List<Payment_Account__c> updatePaymentAccountRecords(List<Payment_Account__c> lstPaymentAccounts){
        try{
            if(lstPaymentAccounts.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, lstPaymentAccounts,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Payment Account Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    UPDATE securityDecision.getRecords();
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
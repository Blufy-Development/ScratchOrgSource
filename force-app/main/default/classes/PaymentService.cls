public class PaymentService {
    
    public static List<AggregateResult> getPaymentByAggResult(Set<String> setInvoiceId){
        if(!setInvoiceId.isEmpty()){
            try {
                List<AggregateResult> listPayment = [SELECT SUM(AMOUNT__C) totalAmount,Type__c,Invoice__c FROM Payment__c 
                                                     WHERE Invoice__c IN: setInvoiceId 
                                                     AND Type__c != NULL AND Status__c IN ('paid','Success') 
                                                     WITH SECURITY_ENFORCED
                                                     GROUP BY Invoice__c, Type__c];
                
                return listPayment;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    //Insertion of Payment Records
    public static List<Payment__c> insertPaymentRecords(List<Payment__c> listPayment){
        try{
            if(listPayment.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listPayment,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Payment Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Payment Error Message-->'+e.getMessage());
        }
        return null;
    }
    /**
     * Created By   : Jatin Motiani
     * Date         : 04th Jan 2021
     * Description  : To update the Payment__c object Records 
     */
    public static List<Payment__c> updatePaymentRecords(List<Payment__c> lstPayments){
        try {
            if(lstPayments.size()>0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, lstPayments, true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Error :: Payment Removed Fields :: '+securityDecision.getRemovedFields());
                }
                else{
                    UPDATE securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        } catch (Exception e) {
            System.debug('Payment Error Message :: '+e.getMessage());
        }
        return null;
    }
}
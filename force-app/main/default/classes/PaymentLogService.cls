/*
 * Created By   :   Jatin Motiani
 * Date         :   04th Jan 2021
 * Description  :   This class will be used to perform all the CURD and Serching operations only for Payment_Log__c objects
 **/
public class PaymentLogService {
    //Insertion of Payment Logs Records
    public static List<Payment_Log__c> insertPaymentLogRecords(List<Payment_Log__c> listPaymentLogs){
        try{
            if(listPaymentLogs.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listPaymentLogs,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Payment Logs Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Payment Logs Error Message-->'+e.getMessage());
        }
        return null;
    }
}
public class PaymentAccountTriggerHelper {
    public PaymentAccountTriggerHelper() {

    }
    public static void afterInsert(){
        System.debug('JM :: PaymentAccountTriggerHelper :: afterInsert method called');
        System.debug('JM :: '+Trigger.new.size());
        Map<Id, Id> mapAccIdPaymentAccs = new Map<Id, Id>();
        List<Payment_Account__c> lstOldPaymentAccounts = new List<Payment_Account__c>();
        // List<Payment_Account__c> lstNewPaymentAccountsCards = new List<Payment_Account__c>();
        for(Payment_Account__c obj : (List<Payment_Account__c>)Trigger.new){
            if((obj.Verification_Status__c == '' || obj.Verification_Status__c == 'Verified' || String.isBlank(obj.Verification_Status__c) == true) && obj.Active__c == true){
                System.debug('JM :: inside 2nd if : values : AccountId : '+obj.Account__c + ' : PaymentAccount Id : '+obj.Id);
                mapAccIdPaymentAccs.put(obj.Account__c, obj.Id);
            }
        }
        for(Payment_Account__c obj : [SELECT ID, Active__c 
                                        FROM Payment_Account__c
                                        WHERE Account__c IN :mapAccIdPaymentAccs.keySet() AND 
                                            ID NOT IN :mapAccIdPaymentAccs.values() AND 
                                            Active__c = true]){
                                                obj.Active__c = false;
                                                lstOldPaymentAccounts.add(obj);
                                            }
        System.debug('JM :: lstOldPaymentAccounts size :: '+lstOldPaymentAccounts.size());
        if(lstOldPaymentAccounts.size()>0){
            Update lstOldPaymentAccounts;
        }
    }
}
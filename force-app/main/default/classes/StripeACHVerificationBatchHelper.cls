//Modified by ___ 09-12-2020 : Removed with sharing
public class StripeACHVerificationBatchHelper {
    public static void verifyACHAccounts(List<Payment_Account__c> lstPaymentAccs){
        List<Payment_Account__c> paymentAccounts = new List<Payment_Account__c>();
        System.debug('JM :: verifyACHAccounts method is called');
        for(Payment_Account__c paymentAccount : lstPaymentAccs){
            //if(paymentAccount.Type__c == 'ACH' && paymentAccount.Is_Verified__c == FALSE){
                String verficationStatus = StripeUtility.getVerfiyStripeBank(paymentAccount.Account__r.Customer_key__c,paymentAccount.Stripe_ID__c);
                System.debug('FOR : ' + paymentAccount.Id + ' :: Verfication Status :: '+verficationStatus);
                
                if(paymentAccount.Verification_Status__c != verficationStatus){
                    paymentAccount.Verification_Status__c = verficationStatus;
                    paymentAccount.Active__c = verficationStatus.compareTo('pass') == 0 || verficationStatus.compareTo('verfication') == 0 ? true : false;  
                    paymentAccounts.add(paymentAccount);
                }
            //}
        }
        System.debug('JM : paymentAccounts.size() ' + paymentAccounts.size());
        System.debug('JM : paymentAccounts values : '+ paymentAccounts);
        if(paymentAccounts.size()>0){
            update paymentAccounts;
        }
    }
}
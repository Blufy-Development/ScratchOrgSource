/*
Name        :       StripeAccountVerifyBatchHelper
Date        :       8th Dec 2020
Description :       StripeAccountVerifyBatchHelper will be used by StripeAccountVerifyBatch and here the Payment_Account__c records will be verified.
Developer   :       TMC
*/
public without sharing class StripeAccountVerifyBatchHelper {
    public static void verifyACHAccounts(List<Payment_Account__c> lstPaymentAccs){
        List<Payment_Account__c> paymentAccounts = new List<Payment_Account__c>();
        System.debug('JM :: verifyACHAccounts method is called');
        for(Payment_Account__c paymentAccount : lstPaymentAccs){
            //if(paymentAccount.Type__c == 'ACH' && paymentAccount.Is_Verified__c == FALSE){
                String verficationStatus = StripeUtility.getVerfiyStripeBank(paymentAccount.Account__r.Customer_key__c,paymentAccount.Stripe_ID__c);
                System.debug('FOR : ' + paymentAccount.Id + ' :: Verfication Status :: '+verficationStatus);
                
                if( String.isNotBlank(verficationStatus) && paymentAccount.Verification_Status__c != verficationStatus){
                    paymentAccount.Verification_Status__c = verficationStatus;
                    paymentAccount.Active__c = verficationStatus.compareTo('pass') == 0 || verficationStatus.compareTo('verfication') == 0 || verficationStatus.compareTo('verified') == 0 ? true : false;  
                    paymentAccounts.add(paymentAccount);
                }
            //}
        }
        System.debug('JM : paymentAccounts.size() ' + paymentAccounts.size());
        System.debug('JM : paymentAccounts values : '+ paymentAccounts);
        if(paymentAccounts.size()>0){
            PaymentAccountService.updatePaymentAccountRecords(paymentAccounts);
        }
    }
}
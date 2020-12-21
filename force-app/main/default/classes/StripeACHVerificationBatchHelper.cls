//Modified by ___ 09-12-2020 : Removed with sharing
public class StripeACHVerificationBatchHelper {
    /*public StripeACHVerificationBatchHelper() {

    }*/

    public static Set<Id> verifyACHAccounts(List<Enrollment__c> enrollmentList){
        Set<String> parentIds = new Set<String>();
        List<Payment_Account__c> paymentAccounts = new List<Payment_Account__c>();

        for(Enrollment__c enrollmentObj : enrollmentList)
            parentIds.add(enrollmentObj.Parent__c);
        System.debug('JM :: parentIds : '+parentIds);
        for(Payment_Account__c paymentAccount : [SELECT Id, Account__r.Customer_key__c, Stripe_Token__c, Is_Verified__c,Stripe_Bank_Account_Token__c FROM Payment_Account__c 
                                                WHERE Account__c IN: parentIds AND Active__c = TRUE AND Type__c = 'ACH' 
                                                AND Is_Verified__c = FALSE AND Account__r.Customer_key__c != NULL
                                                AND Stripe_Token__c != NULL]){
                                                    //Added by ___ 09-12-2020: If the Is_Verified__c field values is changed then only add that record to list that is going to update
                                                    Boolean isVerfied = StripeUtility.getVerfiyStripeBank(paymentAccount.Account__r.Customer_key__c,paymentAccount.Stripe_Bank_Account_Token__c);
                                                    if(paymentAccount.Is_Verified__c != isVerfied){
                                                        paymentAccount.Is_Verified__c = isVerfied;
                                                        paymentAccounts.add(paymentAccount);
                                                    }
        }
        Set<Id> setParentIds = new Set<Id>();
        //Added by ___ 09-12-2020: Update the Is_Verified__c fields value of Payment_Account__c objects 
        if(paymentAccounts.size()>0){
            update paymentAccounts;
            for(Payment_Account__c obj : paymentAccounts){
                if(obj.Is_Verified__c)
                setParentIds.add(obj.Account__c);
            }
        }
        return setParentIds;
    }
}
/*
Name        :       StripeAccountVerifyBatch
Date        :       7th Dec 2020 
Description :       StripeAccountVerifyBatch is used to have all the Payment Account records of ACH type to verify the Status and Activate them.
Developer   :       TMC
*/
global without sharing class StripeAccountVerifyBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('JM :: StripeAccountVerifyBatch start method called');
        //Date pastDate = System.today().addDays(-2);
        Date pastDate = System.today();//For Testing purpose only
        System.debug(Database.query('SELECT Id, Verification_Status__c,Account__c, Account__r.Customer_key__c, Active__c, Stripe_Token__c, Is_Verified__c,Type__c,Stripe_ID__c '+
                                                'FROM Payment_Account__c '+
                                                'WHERE CreatedDate <= :pastDate AND '+ 
                                                //'Is_Verified__c = FALSE AND '+
                                                '(Verification_Status__c != \'Pass\' OR Verification_Status__c != \'New\') AND ' +
                                                'Account__r.Customer_key__c != NULL AND '+ 
                                                'Stripe_Token__c != NULL AND '+
                                                'Stripe_ID__c != NULL AND ' + 
                                                'Type__c = \'ACH\' WITH SECURITY_ENFORCED'
                                            ));
        return Database.getQueryLocator('SELECT Id, Verification_Status__c, Account__c, Account__r.Customer_key__c, Stripe_Token__c,Active__c, Is_Verified__c,Type__c,Stripe_ID__c '+
                                          'FROM Payment_Account__c '+
                                          'WHERE CreatedDate >= :pastDate AND '+ 
                                           //'Is_Verified__c = FALSE AND '+
                                           '(Verification_Status__c != \'Pass\' OR Verification_Status__c != \'New\') AND '+
                                           'Account__r.Customer_key__c != NULL AND '+ 
                                           'Stripe_Token__c != NULL AND '+
                                           'Stripe_ID__c != NULL AND ' + 
                                           'Type__c = \'ACH\' WITH SECURITY_ENFORCED'
                                        );
    }
    global void execute(Database.BatchableContext BC, List<Payment_Account__c> lstPaymentAccs){
        System.debug('JM :: StripeACHVerificationBatch execute method called');
        System.debug('JM :: lstPaymentAccs : '+lstPaymentAccs);
        StripeAccountVerifyBatchHelper.verifyACHAccounts(lstPaymentAccs);
    }
    global void finish(Database.BatchableContext BC){
        System.debug('JM :: StripeACHVerificationBatch finish method is called');
    }
}
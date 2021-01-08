/* Name         : StripeCustomerPaymentBatch
 * Date         : 10th Dec 2020
 * Author       : 
 * Description  : This batch class is for Verification of Payment done by Stripe ACH methods
**/
global class StripeCustomerPaymentBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    global Set<Id> setAccountIds;
    global StripeCustomerPaymentBatch(){
        System.debug('JM :: StripeCustomerPaymentBatch non parameterized constructor called');
        setAccountIds = null;
    }
    global StripeCustomerPaymentBatch(Set<id> setAccountIds){
        System.debug('JM :: StripeCustomerPaymentBatch parameterized constructor called');
        this.setAccountIds = new Set<Id>();
        this.setAccountIds.addAll(setAccountIds);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('StripeCustomerPaymentBatch start method called');
        String query;
        // if(this.setAccountIds == null)
        //     query = 'Select Id, Customer__c, Total_Amount__c, (Select Id, educato__Status__c from educato__Payments__r) FROM Invoice__c WHERE Customer__c != NULL AND Due_Date__c <= today() AND Status__c= \'Due\' AND Total_Amount__c > 0 AND Automation_Applied__c = FALSE'';
        // else
        //     query = 'Select Id, Customer__c, Total_Amount__c, (Select Id, educato__Status__c from educato__Payments__r) FROM Invoice__c WHERE Customer__c != NULL AND Due_Date__c <= today() AND Status__c= \'Due\' AND Total_Amount__c > 0 AND Customer__c IN :this.setAccountIds AND Automation_Applied__c = FALSE';
        
        if(this.setAccountIds == null)
            query = 'Select Id, Customer__c, Total_Amount__c, Automation_Applied__c, (Select Id, educato__Status__c from educato__Payments__r) FROM Invoice__c WHERE Customer__c != NULL AND Status__c= \'Due\' AND Total_Amount__c > 0 AND Automation_Applied__c = FALSE';
        else
            query = 'Select Id, Customer__c, Total_Amount__c, Automation_Applied__c, (Select Id, educato__Status__c from educato__Payments__r) FROM Invoice__c WHERE Customer__c != NULL AND Status__c= \'Due\' AND Total_Amount__c > 0 AND Customer__c IN :setAccountIds AND Automation_Applied__c = FALSE';
         System.debug('Database.getQueryLocator(query)--->'+Database.getQueryLocator(query));
        System.debug('JM :: Query : '+query);
        return Database.getQueryLocator(query);
       
        
    }
    global void execute(Database.BatchableContext BC, List<Invoice__c> lstInvoices){
        System.debug('JM :: StripeCustomerPaymentBatch execute method is called');
        StripeCustomerPaymentBatchHelper.getCustomerChargeDetails(lstInvoices);
    }
    global void finish(Database.BatchableContext BC){
        System.debug('JM :: StripeCustomerPaymentBatch finish method called');
    }
}
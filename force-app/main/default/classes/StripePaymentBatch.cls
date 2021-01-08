/* Name         : StripePaymentBatch
 * Date         : 10th Dec 2020
 * Author       : 
 * Description  : This batch class is for creating charge Payments against the invoices which are due and any of the payment mode is not successfull.
**/
global without sharing class StripePaymentBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    global Set<Id> setAccountIds;
    global StripePaymentBatch(){
        System.debug('JM :: StripePaymentBatch non parameterized constructor called');
        setAccountIds = null;
    }
    global StripePaymentBatch(Set<id> setAccountIds){
        System.debug('JM :: StripePaymentBatch parameterized constructor called');
        this.setAccountIds = new Set<Id>();
        this.setAccountIds.addAll(setAccountIds);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('StripePaymentBatch start method called');
        String query;
        // if(this.setAccountIds == null)
        //     query = 'Select Id, Customer__c, Total_Amount__c, (Select Id, educato__Status__c from educato__Payments__r) FROM Invoice__c WHERE Customer__c != NULL AND Due_Date__c <= today() AND Status__c= \'Due\' AND Total_Amount__c > 0 AND Automation_Applied__c = FALSE WITH SECURITY_ENFORCED';
        // else
        //     query = 'Select Id, Customer__c, Total_Amount__c, (Select Id, educato__Status__c from educato__Payments__r) FROM Invoice__c WHERE Customer__c != NULL AND Due_Date__c <= today() AND Status__c= \'Due\' AND Total_Amount__c > 0 AND Customer__c IN :this.setAccountIds AND Automation_Applied__c = FALSE WITH SECURITY_ENFORCED';
        
        if(this.setAccountIds == null)
            query = 'Select Id, Customer__c, Total_Amount__c, Automation_Applied__c, (Select Id, educato__Status__c from educato__Payments__r) FROM Invoice__c WHERE Customer__c != NULL AND Status__c= \'Due\' AND Total_Amount__c > 0 AND Automation_Applied__c = FALSE WITH SECURITY_ENFORCED';
        else
            query = 'Select Id, Customer__c, Total_Amount__c, Automation_Applied__c, (Select Id, educato__Status__c from educato__Payments__r) FROM Invoice__c WHERE Customer__c != NULL AND Status__c= \'Due\' AND Total_Amount__c > 0 AND Customer__c IN :setAccountIds AND Automation_Applied__c = FALSE WITH SECURITY_ENFORCED';
        
        //System.debug('Database.getQueryLocator(query)--->'+Database.getQueryLocator(query));
        System.debug('JM :: Query : '+query);
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Invoice__c> lstInvoices){
        System.debug('JM :: StripeCustomerPaymentBatch execute method is called');
        StripePaymentBatchHelper.getCustomerChargeDetails(lstInvoices);
    }
    global void finish(Database.BatchableContext BC){
        System.debug('JM :: StripeCustomerPaymentBatch finish method called');
    }
}
/* Name         : StripeChargeVerifyBatch
* Date         : 14th Dec 2020
* Author       : 
* Description  : This batch class will be verifing the status of charges created against the invoices in the Stripe.
**/
global without sharing class StripeChargeVerifyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global String paymentId;
    global StripeChargeVerifyBatch() {
    }
    global StripeChargeVerifyBatch(String paymentId) {
        this.paymentId = paymentId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date transactionDate = System.today().addDays(-7);
        /*String query = 'SELECT Payment_Date__c, Status__c, Invoice__c, Invoice__r.Status__c, Amount__c,Payment_Reference__c ' +
'FROM Payment__c '+
'WHERE Payment_Date__c <= :transactionDate ' +
'AND (Status__c = \'Pending\' OR Status__c = \'Failed\') '+
'AND Payment_Mode__c =\'ACH\' WITH SECURITY_ENFORCED';
*/
        
        if (String.isNotBlank(this.paymentId)){
            String query = 'SELECT Payment_Date__c, Status__c, Invoice__c, Invoice__r.Status__c, Amount__c,Payment_Reference__c '+
                'FROM Payment__c '+
                'WHERE Id = :paymentId ' +
                'AND (Status__c = \'Pending\' OR Status__c = \'Failed\') '+
                'AND Payment_Mode__c =\'ACH\' WITH SECURITY_ENFORCED';
            
            return Database.getQueryLocator(query);    
        }
        else{
            String query = 'SELECT Payment_Date__c, Status__c, Invoice__c, Invoice__r.Status__c, Amount__c,Payment_Reference__c '+
                'FROM Payment__c '+
                'WHERE (Status__c = \'Pending\' OR Status__c = \'Failed\') '+
                'AND Payment_Mode__c =\'ACH\' WITH SECURITY_ENFORCED';
            
            return Database.getQueryLocator(query);
        }
        
    }
    global void execute(Database.BatchableContext BC, List<Payment__c> lstPayments){
        StripeChargeVerifyBatchHelper.getUpdateChargesStatus(lstPayments);
    }
    global void finish(Database.BatchableContext BC){
        
    }
    
}
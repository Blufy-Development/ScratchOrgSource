global class StripeACHChargesVerificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global String paymentId;
    global StripeACHChargesVerificationBatch() {
    }
    global StripeACHChargesVerificationBatch(String paymentId) {
        this.paymentId = paymentId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date transactionDate = System.today().addDays(-7);
        //String query = 'SELECT Payment_Date__c, Status__c, Invoice__c, Invoice__r.Status__c, Amount__c,Payment_Reference__c FROM Payment__c WHERE Payment_Date__c <= :transactionDate AND (Status__c = \'Pending\' OR Status__c = \'Failed\') AND Payment_Mode__c =\'ACH\'';
        String query = 'SELECT Payment_Date__c, Status__c, Invoice__c, Invoice__r.Status__c, Amount__c,Payment_Reference__c FROM Payment__c WHERE Id = :paymentId';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Payment__c> lstPayments){
        StripeACHChargesVerificationBatchHelper.getUpdateChargesStatus(lstPayments);
    }
    global void finish(Database.BatchableContext BC){
    
    }
    
}
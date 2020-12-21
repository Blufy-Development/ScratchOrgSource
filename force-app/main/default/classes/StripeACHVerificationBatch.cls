global class StripeACHVerificationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    global Set<Id> setParentIds;
    global Id enrollmentId;
    public StripeACHVerificationBatch(Id enrollmentId) {
        this.setParentIds = new Set<Id>();
        this.enrollmentId = enrollmentId;
    }


    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('JM :: StripeACHVerificationBatch start method called');
        Date enrollmentDate = System.today().addDays(-2);
        
        return Database.getQueryLocator([SELECT Id, Parent__c FROM Enrollment__c WHERE ID =: this.enrollmentId]);
        //return Database.getQueryLocator([SELECT Id, Parent__c FROM Enrollment__c WHERE Enrollment_Date__c =: enrollmentDate AND Status__c = 'Active']);
    }
    global void execute(Database.BatchableContext BC, List<Enrollment__c> enrollmentList){
        System.debug('JM :: StripeACHVerificationBatch execute method called');
        this.setParentIds.addAll(StripeACHVerificationBatchHelper.verifyACHAccounts(enrollmentList));
    }
    global void finish(Database.BatchableContext BC){
        System.debug('JM :: StripeACHVerificationBatch finish method is called');
        System.debug('JM :: StripeACHVerificationBatch set size : '+this.setParentIds.size());
        if(this.setParentIds.size()>0)
            Database.executeBatch(new StripeCustomerPaymentBatch(this.setParentIds),50);
    }
}
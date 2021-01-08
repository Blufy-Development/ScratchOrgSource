global class StripeAccountVerifyScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        StripeAccountVerifyBatch stripeACHVerificationBatchObj = new StripeAccountVerifyBatch();
        Database.executeBatch(stripeACHVerificationBatchObj,50);
    }
}
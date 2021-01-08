global class StripeACHVerificationScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        StripeACHVerificationBatch stripeACHVerificationBatchObj = new StripeACHVerificationBatch();
        Database.executeBatch(stripeACHVerificationBatchObj,50);
    }
}
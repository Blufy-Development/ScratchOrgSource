global class StripeACHChargesVerificationScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        StripeACHChargesVerificationBatch stripeACHChargesVerificationBatchObj = new StripeACHChargesVerificationBatch();
        Database.executeBatch(stripeACHChargesVerificationBatchObj,50);
    }
}
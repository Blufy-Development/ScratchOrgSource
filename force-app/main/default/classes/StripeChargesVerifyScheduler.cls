global class StripeChargesVerifyScheduler implements Schedulable{
    global void execute(SchedulableContext SC) { 
        StripeChargeVerifyBatch stripeACHChargesVerificationBatchObj = new StripeChargeVerifyBatch();
        Database.executeBatch(stripeACHChargesVerificationBatchObj,50);
    }
}
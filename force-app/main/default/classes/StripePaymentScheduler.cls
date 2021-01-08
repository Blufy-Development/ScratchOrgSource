global class StripePaymentScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        StripePaymentBatch stripeCustomerPaymentBatchObj = new StripePaymentBatch();
        Database.executeBatch(stripeCustomerPaymentBatchObj,50);
    }
}
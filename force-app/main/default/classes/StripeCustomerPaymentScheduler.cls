global class StripeCustomerPaymentScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        StripeCustomerPaymentBatch stripeCustomerPaymentBatchObj = new StripeCustomerPaymentBatch();
        Database.executeBatch(stripeCustomerPaymentBatchObj,50);
    }
}
@isTest
public class TestPaymentAccountTrigger {
    @IsTest
    public static void TestAfterInsert(){
        Account accObj = new Account(LastName = 'Test Acc');
        insert accObj;
        Payment_Account__c paymentAccountObj = new Payment_Account__c();
        
        paymentAccountObj.Account_Number__c = '************4242';
        paymentAccountObj.Account__c = accObj.Id;
        paymentAccountObj.Active__c = true;
        paymentAccountObj.Holder_Name__c = 'Test Acc';
        paymentAccountObj.Stripe_ID__c = '';
        paymentAccountObj.Stripe_Token__c = '';
        paymentAccountObj.Type__c = 'Card'; 
        paymentAccountObj.Verification_Status__c = '';
        insert paymentAccountObj;
        Payment_Account__c paymentAccountObj1 = new Payment_Account__c();
        
        paymentAccountObj1.Account_Number__c = '************4343';
        paymentAccountObj1.Account__c = accObj.Id;
        paymentAccountObj1.Active__c = false;
        paymentAccountObj1.Holder_Name__c = 'Test Acc';
        paymentAccountObj1.Stripe_ID__c = '';
        paymentAccountObj1.Stripe_Token__c = '';
        paymentAccountObj1.Type__c = 'Card'; 
        paymentAccountObj1.Verification_Status__c = '';
        insert paymentAccountObj1;
        paymentAccountObj1.Active__c = true;
        update paymentAccountObj1;
        
    } 
}
@isTest
public class TestStripeUtility {
    /*
    @isTest  
    static void testStripeBankToken(){
       
        Test.setMock(HttpCalloutMock.class, new StrpeUtilityMock());
        String bankTokenId = StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId;
        
        StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789');
        System.assertEquals(bankTokenId,StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId);
       
        string customerId =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId;
        System.assertEquals(customerId,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId);
        string source =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId;
        System.assertEquals(source,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId);
        
        system.debug('source--->'+source);
        StripeUtility.getVerfiyStripeBank(customerId,source);

        system.debug('createStripeBankVerify--->'+StripeUtility.getVerfiyStripeBank(customerId,source));
        
        HttpResponse testResponse = StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)');
       
        
        system.debug('StripeChargeId--->'+StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)'));
        test.startTest();
        Account testAccount = new Account(Name='Test');
        Insert testAccount;
        
        StripeUtility.createStripeCustomerUsingACH(testAccount.id,'US','USD','Test','Individual','110000000','000123456789','test@gmail.com');
        test.stopTest();
    }
    
    
    @isTest  
    static void test2(){
        Test.setMock(HttpCalloutMock.class, new StrpeUtilityMock());
        String bankTokenId = StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId;
        
        StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789');
        System.assertEquals(bankTokenId,StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId);
       
        string customerId =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId;
        System.assertEquals(customerId,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId);
        string source =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId;
        System.assertEquals(source,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId);
        system.debug('source--->'+source);
        StripeUtility.getVerfiyStripeBank(customerId,source);
        system.debug('createStripeBankVerify--->'+StripeUtility.getVerfiyStripeBank(customerId,source));
        HttpResponse testResponse = StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)');
        system.debug('StripeChargeId--->'+StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)'));
        test.startTest();
        Account testAccount = new Account(Name='Test',Customer_key__c='16545456464');
        Insert testAccount;
        Payment_Account__c  testPaymentAccount = new Payment_Account__c(Account__c=testAccount.id, Routing_Number__c ='110000000');
        Insert testPaymentAccount;
        StripeUtility.createStripeCustomerUsingACH(testAccount.id,'US','USD','Test','Individual','110000000','000123456789','test@gmail.com');
        test.stopTest();
    }
*/
}
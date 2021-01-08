@isTest
private class TestStripeAccountVerifyBatch { 
    @testSetup  
    static void testSetUp(){
        Stripe_Custom_Settings__c testObj = new Stripe_Custom_Settings__c();
        testObj.educato__Secret_Key__c='testKey';
        Insert testObj;
      
        Account accountObj = new Account(LastName='testAccount',Customer_key__c='testCutomerKey');
        Insert accountObj;
        
        Payment_Account__c  paymentAccount = new Payment_Account__c(Verification_Status__c='',Account__c=accountObj.id ,
                                                                    Active__c= true,Stripe_Token__c='testToken',Is_Verified__c=false,
                                                                    Stripe_ID__c='testId',Type__c='ACH');
        
       
        Insert paymentAccount;
        
        
        Datetime yesterday = Datetime.now().addDays(5);
        Test.setCreatedDate(paymentAccount.Id, yesterday);
        system.debug('created date ---->'+paymentAccount.CreatedDate);
        
        /*String bankTokenId = StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId;
        StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789');
        System.assertEquals(bankTokenId,StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId);
        */

        
    }
    
    @isTest
    static void test1(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestStripeUtilityMock());
        StripeAccountVerifyScheduler sh1 = new StripeAccountVerifyScheduler(); 
        String sch = '0 0 23 * * ?';
        system.schedule('Test StripeAccountVerifyScheduler Check', sch, sh1);
        test.stopTest();
    }
    
    
}
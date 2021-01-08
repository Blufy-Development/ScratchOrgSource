@isTest
private class TestStripeACHVerificationBatch {
    @testSetup  
    static void testSetUp(){
        
      
        Account accountObj = new Account(Name='testAccount',Customer_key__c='testCutomerKey');
        Insert accountObj;
        
        Payment_Account__c  paymentAccount = new Payment_Account__c(Verification_Status__c='new',Account__c=accountObj.id ,
                                                                    Active__c= true,Stripe_Token__c='testToken',Is_Verified__c=false,
                                                                    Stripe_ID__c='testId',Type__c='ACH');
        
       
        Insert paymentAccount;
        
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(paymentAccount.Id, DateTime.newInstance(2012,12,12));
        
        
        system.debug('created date ---->'+paymentAccount.CreatedDate);
        
    }
    
    @isTest
    static void test1(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new StrpeUtilityMock());
        StripeACHVerificationScheduler sh1 = new StripeACHVerificationScheduler(); 
        String sch = '0 0 23 * * ?';
        system.schedule('Test StripeACHVerificationScheduler Check', sch, sh1);
        test.stopTest();
    }
    
    
}
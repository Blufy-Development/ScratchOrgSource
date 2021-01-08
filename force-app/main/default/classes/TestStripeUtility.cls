@isTest
private class TestStripeUtility {
    
    @testSetup  
    static void testSetUp(){
        Stripe_Custom_Settings__c testObj = new Stripe_Custom_Settings__c();
        testObj.educato__Secret_Key__c='testKey';
        Insert testObj; 
        
    }
    
    @isTest  
    static void testStripeBankToken(){
        Test.setMock(HttpCalloutMock.class, new TestStripeUtilityMock());
        /*

*/
        Account testAccount = new Account(LastName='Test',Customer_key__c = 'cus_IWkgCLgOc0fBlw');
        Insert testAccount;
        test.startTest();
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
        
        
        
        //test.startTest();
        
        StripeUtility.createStripeCustomerAndPaymentModeACH(testAccount.id,'US','USD','Test','Individual','110000000','000123456789');
        
        //StripeUtility.createStripeCustomerAndPaymentModeCard(testAccount.id,'100000',10,20,100);
        // StripeUtility.createStripeCustomerUsingACH(testAccount.id,'US','USD','Test','Individual','110000000','000123456789','test@gmail.com');
        test.stopTest();
    }
    
    
    @isTest  
    static void test2(){
        
        Test.setMock(HttpCalloutMock.class, new TestStripeUtilityMock());
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account testAccount1 = new Account(FirstName='TestFname', LastName = 'TestLName', PersonEmail='test@gmail.com',Customer_key__c = 'cus_IWkgCLgOc0fBlw');
        //testAccount1.RecordTypeId = personAccountRecordType.Id; 
        Insert testAccount1;
        
        test.startTest();
        String bankTokenId = StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId;
        
        StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789');
        System.assertEquals(bankTokenId,StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId);
        
        string customerId =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId;
        
        System.assertEquals(customerId,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId);
        
        
        string source =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId;
        System.assertEquals(source,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId);
        
        system.debug('source--->'+source);
        
        
        StripeUtility.createStripeCustomer('TestName','test@gmail.com');
        
        
        StripeUtility.getVerfiyStripeBank(customerId,source);
        system.debug('createStripeBankVerify--->'+StripeUtility.getVerfiyStripeBank(customerId,source));
        
        HttpResponse testResponse = StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)');
        system.debug('StripeChargeId--->'+StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)'));
        
        System.debug('lst PRK :: ' + [SELECT Id, Name FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']);
        
        Date dt = System.today();
        String strYear = String.valueOf(dt.year());
        Integer yr = (Integer.valueOf(strYear.substring(2)) + 5);
        StripeUtility.createStripeCustomerAndPaymentModeCard(testAccount1.id,'9999999999999999',10,yr,100);
        // StripeUtility.createStripeCustomerAndPaymentModeACH(testAccount1.id,'US','USD','Test','Individual','110000000','000123456789');
        
        test.stopTest();
    }
    
    
    
    @isTest  
    static void test3(){
        Test.setMock(HttpCalloutMock.class, new TestStripeUtilityMock());
        Account testAccount1 = new Account(FirstName='TestFname', LastName = 'TestLName', PersonEmail='test@gmail.com',Customer_key__c = 'cus_IWkgCLgOc0fBlw');
        Insert testAccount1;
        Payment_Account__c  PaymentAccountObj  = new Payment_Account__c(Account__c = testAccount1.id);
        Insert PaymentAccountObj;
        
        test.startTest();
        String bankTokenId = StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId;
        
        StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789');
        System.assertEquals(bankTokenId,StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId);
        
        string customerId =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId;
        
        System.assertEquals(customerId,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId);
        
        
        string source =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId;
        System.assertEquals(source,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId);
        
        system.debug('source--->'+source);
        
        
        StripeUtility.createStripeCustomer('TestName','test@gmail.com');
        
        
        StripeUtility.getVerfiyStripeBank(customerId,source);
        system.debug('createStripeBankVerify--->'+StripeUtility.getVerfiyStripeBank(customerId,source));
        
        HttpResponse testResponse = StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)');
        system.debug('StripeChargeId--->'+StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)'));
        
        System.debug('lst PRK :: ' + [SELECT Id, Name FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']);
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        
        Date dt = System.today();
        String strYear = String.valueOf(dt.year());
        Integer yr = (Integer.valueOf(strYear.substring(2)) + 5);
        StripeUtility.createStripeCustomerAndPaymentModeCard(testAccount1.id,'9999999999999999',10,yr,100);
        //StripeUtility.createStripeCustomerAndPaymentModeACH(testAccount1.id,'US','USD','Test','Individual','110000000','000123456789');
        test.stopTest();
    }
    
    @isTest  
    static void test4(){
        Test.setMock(HttpCalloutMock.class, new TestStripeUtilityMock());
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account testAccount1 = new Account(FirstName='TestFname', LastName = 'TestLName', PersonEmail='test@gmail.com',Customer_key__c = 'cus_IWkgCLgOc0fBlw');
        Insert testAccount1;
        Payment_Account__c  PaymentAccountObj  = new Payment_Account__c(Account__c = testAccount1.id);
        Insert PaymentAccountObj;
        
        test.startTest();
        String bankTokenId = StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId;
        
        StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789');
        System.assertEquals(bankTokenId,StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId);
        
        string customerId =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId;
        
        System.assertEquals(customerId,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId);
        
        
        string source =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId;
        System.assertEquals(source,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId);
        
        system.debug('source--->'+source);
        
        
        StripeUtility.createStripeCustomer('TestName','test@gmail.com');
        
        
        StripeUtility.getVerfiyStripeBank(customerId,source);
        system.debug('createStripeBankVerify--->'+StripeUtility.getVerfiyStripeBank(customerId,source));
        
        HttpResponse testResponse = StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)');
        system.debug('StripeChargeId--->'+StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)'));
        
        System.debug('lst PRK :: ' + [SELECT Id, Name FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']);
        
        try{
        	StripeUtility.createStripeCustomerAndPaymentModeCard(testAccount1.id,'9999999999999999',10,21,100);
        }
        catch(Exception e){
        	System.debug('Exception');    
        }
        StripeUtility.createStripeCustomerAndPaymentModeACH(testAccount1.id,'US','USD','Test','Individual','110000000','000123456789');
        
        test.stopTest();
    }
    
     
    
    @isTest  
    static void test5(){
        Test.setMock(HttpCalloutMock.class, new TestStripeUtilityMock());
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account testAccount1 = new Account(FirstName='TestFname', LastName = 'TestLName', PersonEmail='test@gmail.com',Customer_key__c = 'cus_IWkgCLgOc0fBle'); 
        Insert testAccount1;
        Payment_Account__c  PaymentAccountObj  = new Payment_Account__c(Account__c = testAccount1.id);
        Insert PaymentAccountObj;
        
        test.startTest();
        String bankTokenId = StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId;
        
        StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789');
        System.assertEquals(bankTokenId,StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId);
        
        string customerId =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId;
        
        System.assertEquals(customerId,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId);
        
        
        string source =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId;
        System.assertEquals(source,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId);
        
        system.debug('source--->'+source);
        
        
        StripeUtility.createStripeCustomer('TestName','test@gmail.com');
        
        
        StripeUtility.getVerfiyStripeBank(customerId,source);
        system.debug('createStripeBankVerify--->'+StripeUtility.getVerfiyStripeBank(customerId,source));
        
        HttpResponse testResponse = StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)');
        system.debug('StripeChargeId--->'+StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)'));
        
        System.debug('lst PRK :: ' + [SELECT Id, Name FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']);
        
        //test.startTest();
        //StripeUtility.createStripeCustomerAndPaymentModeCard(testAccount1.id,'9999999999999999',10,21,100);
        StripeUtility.createStripeCustomerAndPaymentModeACH(testAccount1.id,'US','USD','Test','Individual','110000000','000123456789');
        test.stopTest();
    }
    
    
    @isTest  
    static void test6(){
        Test.setMock(HttpCalloutMock.class, new TestStripeUtilityMock());
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account testAccount1 = new Account(FirstName='TestFname', LastName = 'TestLName', PersonEmail='test@gmail.com',Customer_key__c = 'cus_IWkgCLgOc0fBle');
        Insert testAccount1;
        Payment_Account__c  PaymentAccountObj  = new Payment_Account__c(Account__c = testAccount1.id);
        Insert PaymentAccountObj;
        
        test.startTest();
        String bankTokenId = StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId;
        
        StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789');
        System.assertEquals(bankTokenId,StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId);
        
        string customerId =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId;
        
        System.assertEquals(customerId,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId);
        
        
        string source =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId;
        System.assertEquals(source,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId);
        
        system.debug('source--->'+source);
        
        
        StripeUtility.createStripeCustomer('TestName','test@gmail.com');
        
        
        StripeUtility.getVerfiyStripeBank(customerId,source);
        system.debug('createStripeBankVerify--->'+StripeUtility.getVerfiyStripeBank(customerId,source));
        
        HttpResponse testResponse = StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)');
        system.debug('StripeChargeId--->'+StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)'));
        
        System.debug('lst PRK :: ' + [SELECT Id, Name FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']);
        
        //test.startTest();
        Date dt = System.today();
        String strYear = String.valueOf(dt.year());
        Integer yr = (Integer.valueOf(strYear.substring(2)) + 5);
        StripeUtility.createStripeCustomerAndPaymentModeCard(testAccount1.id,'9999999999999999',10,yr,100);
        //StripeUtility.createStripeCustomerAndPaymentModeACH(testAccount1.id,'US','USD','Test','Individual','110000000','000123456789');
        test.stopTest();
    }
    
    
    @isTest  
    static void test7(){
        Test.setMock(HttpCalloutMock.class, new TestStripeUtilityMock());
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account testAccount1 = new Account(FirstName='TestFname', LastName = 'TestLName', PersonEmail='test@gmail.com',Customer_key__c = 'cus_IWkgCLgOc0fBle');
        Insert testAccount1;
        Payment_Account__c  PaymentAccountObj  = new Payment_Account__c(Account__c = testAccount1.id);
        Insert PaymentAccountObj;
        
        test.startTest();
        String bankTokenId = StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId;
        
        StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789');
        System.assertEquals(bankTokenId,StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId);
        
        string customerId =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId;
        
        System.assertEquals(customerId,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId);
        
        
        string source =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId;
        System.assertEquals(source,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId);
        
        system.debug('source--->'+source);
        
        
        StripeUtility.createStripeCustomer('TestName','test@gmail.com');
        
        
        StripeUtility.getVerfiyStripeBank(customerId,source);
        system.debug('createStripeBankVerify--->'+StripeUtility.getVerfiyStripeBank(customerId,source));
        
        HttpResponse testResponse = StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)');
        system.debug('StripeChargeId--->'+StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)'));
        
        System.debug('lst PRK :: ' + [SELECT Id, Name FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']);
        
        //test.startTest();
        //StripeUtility.createStripeCustomerAndPaymentModeCard(testAccount1.id,'9999999999999999',10,21,100);
        StripeUtility.getUpdatedCharges('testCharge');
        StripeUtility.getUpdatedCharges('');
        test.stopTest();
    }
    
    @isTest  
    static void test8(){
        Test.setMock(HttpCalloutMock.class, new TestStripeUtilityMock());
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account testAccount1 = new Account(FirstName='TestFname', LastName = 'TestLName', PersonEmail='test@gmail.com');
        Insert testAccount1;
        Payment_Account__c  PaymentAccountObj  = new Payment_Account__c(Account__c = testAccount1.id,Active__c=true);
        Insert PaymentAccountObj;
        
        test.startTest();
        String bankTokenId = StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId;
        
        StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789');
        System.assertEquals(bankTokenId,StripeUtility.createBankToken('US','USD','Jenny Rosen','individual','110000000','000123456789').tokenId);
        
        string customerId =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId;
        
        System.assertEquals(customerId,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).customerId);
        
        
        string source =  StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId;
        System.assertEquals(source,StripeUtility.createStripeCustomer('TestName','test@gmail.com',bankTokenId).bankSourceId);
        
        system.debug('source--->'+source);
        
        
        StripeUtility.createStripeCustomer('TestName','test@gmail.com');
        
        
        StripeUtility.getVerfiyStripeBank(customerId,source);
        system.debug('createStripeBankVerify--->'+StripeUtility.getVerfiyStripeBank(customerId,source));
        
        HttpResponse testResponse = StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)');
        system.debug('StripeChargeId--->'+StripeUtility.getStripeCharge(10000,'inr','tok_visa','My First Test Charge (created for API docs)'));
        
        System.debug('lst PRK :: ' + [SELECT Id, Name FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']);
        StripeUtility.getStripeCustomerDetails('');
        StripeUtility.StripeCustomerCharge obj1 = new StripeUtility.StripeCustomerCharge();
        StripeUtility.Card cardObj = new StripeUtility.Card();
        //test.startTest();
        Date dt = System.today();
        String strYear = String.valueOf(dt.year());
        Integer yr = (Integer.valueOf(strYear.substring(2)) + 5);
        StripeUtility.createStripeCustomerAndPaymentModeCard(testAccount1.id,'9999999999999999',10,yr,100);
        //StripeUtility.getUpdatedCharges('testCharge');
        test.stopTest();
    }
}
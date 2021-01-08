/**
Name 		: InvoiceGeneratorBatchTest
Date 		: 8 April 2020
Author		:
Description :
*/
@isTest
public class InvoiceGeneratorBatchTest {
    @testSetup static void testDataSetup(){
        BlufyTestUtil.init();
        
        List<Session__c> sessionList = [SELECT Id, Class_session__c,Session_Date__c FROM Session__c];
        
        List<Class_Session__c> clsSessList = [SELECT Id FROM Class_session__c LIMIT 1];
        
        for(Session__c sessObj : sessionList){
            system.debug('Session_Date__c  =!@#$%^& '+sessObj.Session_Date__c);
            system.debug('class sessionId '+clsSessList[0].Id);
            sessObj.class_session__c = clsSessList[0].Id;
        }
        update sessionList;
    }
    private static testMethod void InvoiceGeneratorBatchTest() {
        
        Test.startTest();
        String year = '2021';
        String month = '1';
        InvoiceGeneratorBatch batchObj = new InvoiceGeneratorBatch(year,month);
        Database.executeBatch(batchObj);
        Test.stopTest();
        System.assertEquals(3, [SELECT COUNT() FROM Invoice__c]);
        
        
    }
    private static testMethod void InvoiceGeneratorBatchTest2() {
        Subscription__c sub = [SELECT Id,Location__c,Customer__c,Payment_Frequency__c,Subscription_Start_Date__c,
                               Subscription_End_Date__c,Status__c
                               FROM Subscription__c WHERE Payment_Frequency__c = 'Monthly'];
        
        List<Enrollment__c> enroList = [SELECT Id, Class_session__c FROM Enrollment__c];
        List<Class_Session__c> clsSessList = [SELECT Id FROM Class_session__c LIMIT 1];
        
        
        
        for(Enrollment__c enrollList : enroList){
            enrollList.class_session__c = clsSessList[0].Id;
        }
        update enroList;
        
        Test.startTest();
        MonthlyInvoiceScheduler sh1 = new MonthlyInvoiceScheduler();
        
        String sch = '0 0 23 * * ?'; 
        String year = '2021';
        String month = '1';
        system.schedule('Test Territory Check', sch, sh1);  
        InvoiceGeneratorBatch batchObj1 = new InvoiceGeneratorBatch(year,month);
        Database.executeBatch(batchObj1);
        InvoiceFactory invFac = new InvoiceFactory(sub,date.today(),year,month);
        // MonthlyFullInvoiceHandler mFullInv = new MonthlyFullInvoiceHandler()
        
        
        Test.stopTest();
        System.assertEquals('Monthly',sub.Payment_Frequency__c);
    }   
    
    private static testMethod void InvoiceGeneratorBatchTest3(){                
        List<Enrollment__c> enroList = [SELECT Id, Class_session__c FROM Enrollment__c];
        List<Class_Session__c> clsSessList = [SELECT Id FROM Class_session__c LIMIT 1];
        String year = '2021';
        String month = '1';
        for(Enrollment__c enrollList : enroList){
            enrollList.class_session__c = clsSessList[0].Id;
            enrollList.Start_Date__c = system.today().addMonths(1);
        }
        update enroList;
        
        InvoiceGeneratorBatch batchObj2 = new InvoiceGeneratorBatch(year,month);
        Database.executeBatch(batchObj2);
    }
}
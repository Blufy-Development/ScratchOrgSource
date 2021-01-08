@isTest
public class CreditNoteAdjustmentBatchTest{
    
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    @isTest
    public static void Test1(){
        Credit_Note__c creditNote = [SELECT Id,Amount__c FROM Credit_Note__c LIMIT 1];
        Test.startTest();
        CreditNoteAdjustmentBatchSchedular obj1 = new CreditNoteAdjustmentBatchSchedular();
        String sch = '0 0 20 * * ?'; 
        String jobID = system.schedule('obj2', sch, obj1);
        Test.stopTest();
        System.assertEquals(creditNote.Amount__c,50);
    }
}
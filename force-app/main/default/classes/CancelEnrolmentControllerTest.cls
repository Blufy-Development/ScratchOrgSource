@isTest
public class CancelEnrolmentControllerTest {
    	
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    @isTest
    static void validateCancelEnrolmentControllerrMethod1(){
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Lastname = 'Gates' AND personEmail = 'test1@gmail.com'];
        List<Enrollment__c> lstOfEnrollment = [SELECT Id, Name,Status__c FROM Enrollment__c];
        CancelEnrolmentController.getEnrolmentDetail(lstOfEnrollment[0].Id);
        CancelEnrolmentController.getEnrolmentLastSessionDate(lstOfEnrollment[0].Id, Date.today().addDays(-4));
        CancelEnrolmentController.cancelEnrolmentProcess(lstOfEnrollment[0].Id,Date.today().addDays(-4),'',accList[0].Id,Date.today().addDays(-1),'');
    }
}
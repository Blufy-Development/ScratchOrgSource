@isTest
private class TestStripeCustomerPaymentBatch {
    @testSetup  
    static void testSetUp(){
        Account locationObj = BlufyTestUtil.createLocationRec('New Harbor');
        insert locationObj;
        system.debug('locationObj -> '+locationObj);
        
        
        Account parentObj = BlufyTestUtil.createParentRec('Gates','test1@gmail.com');
        insert parentObj;
        system.debug('parentObj ->'+parentObj);
        
        Account teacherObj = BlufyTestUtil.createTeacherRec('Jonas', locationObj.id);
        insert teacherObj;
        system.debug('teacherObj ->'+teacherObj);
        
        Course__c courseObj = BlufyTestUtil.createCourseRec('French', 'Active','XYZ-01');
        insert courseObj;
        system.debug('courseObj ->'+courseObj);
        
        Module__c module = BlufyTestUtil.createModule('Module 1');
        insert module;
        
        Course_Module__c cModule = BlufyTestUtil.createCourseModule(module.Id,courseObj.Id,1);
        insert cModule;
        
        Class__c classObj = BlufyTestUtil.createClassRec('Name', courseObj.Id, 'Classroom', 'Open', teacherObj.Id, 20, 'Fixed', 24, Date.today().addDays(1), Time.newInstance(10, 00, 00, 00),'One-time', cModule.Id);
        classObj.Advance_Billing__c         = 2;
        classObj.Days_of_Week__c            = 'Fri;Mon;Tue;Wed;Sat;Thu;Sun';
        classObj.End_Date__c                = Date.today().addMonths(6);
        classObj.Exclude_Public_Holidays__c = true;
        insert classObj;
        system.debug('classObj ->'+classObj);
        
        Account studentObj = BlufyTestUtil.createStudentRec('Thomas','test1@gmail.com');
        insert studentObj;
        system.debug('studentObj ->'+studentObj);
       
        Enrollment__c enrollObj = BlufyTestUtil.createEnrollment(classObj.Id, Date.today().addDays(-4), locationObj.Id, studentObj.Id, ConstantClass.enrolledStatus, true,  Date.today().addDays(-4),parentObj.id);
        insert enrollObj;
     
        Fee__c feeObj = BlufyTestUtil.createFeeRecords('Math Monthly Fee','Tuition Fee',500,true,true,'Ongoing','Monthly',2,90);
        feeObj.Invoice_Label__c = 'Test';
        insert feeObj;
        
        Discount__c discount = BlufyTestUtil.createDiscount('testing','Discount',Date.today().addDays(1),Date.today().addMonths(1),'Active','Amount',500,true);
        insert discount;
        
         
        Invoice__c invoiceObj = BlufyTestUtil.createInvoice(parentObj.Id,ConstantClass.dueStatus,Date.today());
        insert invoiceObj;
        
        invoiceObj.Due_Date__c = System.today().addDays(-2);
        
        
         
        
        Invoice_Line_Item__c invLinItm = new   Invoice_Line_Item__c(Invoice__c = invoiceObj.Id,Enrollment__c = enrollObj.Id,Type__c = ConstantClass.depositFeeType,Amount__c = 150);    
        invLinItm.educato__Fee__c = feeObj.id;
        invLinItm.educato__Discount__c = discount.id;
        invLinItm.educato__GST_Amount__c = 100;
        insert invLinItm;
        
        
        Invoice_Line_Item__c invLinItm1 = new   Invoice_Line_Item__c(Invoice__c = invoiceObj.Id,Enrollment__c = enrollObj.Id,Type__c = ConstantClass.depositFeeType,Amount__c = 150);    
        invLinItm1.educato__Fee__c = feeObj.id;
        invLinItm1.educato__Discount__c = discount.id;
        invLinItm1.educato__GST_Amount__c = 100;
        insert invLinItm1;
        System.debug('Result : ' + [Select Id, Total_Amount__c,Customer__c,Due_Date__c,Status__c,Automation_Applied__c,educato__GST_Tax_Amount__c,educato__Fee_Amount__c,educato__Discount_Amount__c,educato__Deposit_Amount__c   from Invoice__c where Id = :invoiceObj.Id]);
        System.debug('invoiceObj Customer__c---->'+invoiceObj.Customer__c);
        System.debug('invoiceObj Total_Amount__c---->'+invoiceObj.Total_Amount__c);
        System.debug('invoiceObj Due_Date__c---->'+invoiceObj.Due_Date__c);
        System.debug('invoiceObj Status__c---->'+invoiceObj.Status__c);
        System.debug('invoiceObj Automation_Applied__c---->'+invoiceObj.Automation_Applied__c);
        System.debug('invoiceObj educato__GST_Tax_Amount__c---->'+invoiceObj.educato__GST_Tax_Amount__c);
        System.debug('invoiceObj educato__Fee_Amount__c---->'+invoiceObj.educato__Fee_Amount__c);
        System.debug('invoiceObj educato__Discount_Amount__c---->'+invoiceObj.educato__Discount_Amount__c);    
        System.debug('invoiceObj educato__Deposit_Amount__c---->'+invoiceObj.educato__Deposit_Amount__c);  
        
    }
    
    @isTest
    static void test1(){
        test.startTest();
        Set<Id> setOfAccountIds = new Set<Id>();
        Invoice__c  invoiceObj = [Select Id, Total_Amount__c,Customer__c,Due_Date__c,Status__c,Automation_Applied__c,educato__GST_Tax_Amount__c,educato__Fee_Amount__c,educato__Discount_Amount__c,educato__Deposit_Amount__c   from Invoice__c  limit 1];
        Account accObj = [Select id from account where name ='Gates' limit 1];
        setOfAccountIds.add(accObj.id);
        StripeCustomerPaymentBatch  objBatch = new StripeCustomerPaymentBatch (setOfAccountIds);
        Database.executeBatch(objBatch);
        
        Test.setMock(HttpCalloutMock.class, new StrpeUtilityMock());
      /*  StripeCustomerPaymentScheduler sh1 = new StripeCustomerPaymentScheduler(); 
        String sch = '0 0 23 * * ?';
        system.schedule('Test StripeCustomerPaymentScheduler Check', sch, sh1);
*/
        test.stopTest();
    }
    
    
}
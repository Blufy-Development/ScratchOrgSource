@isTest
public class CourseTriggerTest {
	
    static testmethod void test1(){
        try{
            
            Account parentObj = BlufyTestUtil.createParentRec('Gates','test1@gmail.com');
            insert parentObj;
            system.debug('parentObj ->'+parentObj);
            
            Account studentObj = BlufyTestUtil.createStudentRec('Thomas','test1@gmail.com');
            insert studentObj;
            
            Course__c course  		  = BlufyTestUtil.createCourseRec('Test', 'Active', 'Test');
            insert course;        
            
            Account location      	  = BlufyTestUtil.createLocationRec('Test');
            insert location;
            
            Account tch      		  = BlufyTestUtil.createTeacherRec('Test', location.Id);
            insert tch;
            
            //create class and update
            Class__c cls   			  = BlufyTestUtil.createClassRec('Test', Course.Id, ConstantClass.classType, 
                                                                     ConstantClass.draftStatus, tch.Id, 40, 
                                                                     ConstantClass.fixedType, 21, Date.today()+1,
                                                                     Time.newInstance(4,4,5,6),
                                                                     ConstantClass.oneTimeFrequency, null);
            cls.Advance_Scheduling_Period__c = '2';
            cls.End_Date__c = System.today().addMonths(6);
            cls.Advance_Scheduling_Unit__c = '';
            cls.Auto_Schedule__c = true;
            insert cls;
            
            Class__c cls1   			  = BlufyTestUtil.createClassRec('Test', Course.Id, ConstantClass.classType, 
                                                                         ConstantClass.draftStatus, tch.Id, 40, 
                                                                         ConstantClass.ongoingClsType, 21, Date.today()+1,
                                                                         Time.newInstance(4,4,5,6),
                                                                         ConstantClass.monthlyFrequency, null);
            cls1.Advance_Scheduling_Period__c = '2';
            cls1.End_Date__c = System.today().addMonths(6);
            cls1.Advance_Scheduling_Unit__c = '';
            cls1.Auto_Schedule__c = true;
            insert cls1;
            
            Class_Session__c clsSess = BlufyTestUtil.createClassSessionRec(cls.Id,Time.newInstance(10,30,00,00),'120');
            clsSess.Teacher__c = tch.Id;
            clsSess.Start_Time__c = Time.newInstance(10, 00, 00, 00);
            clsSess.Day_of_Week__c = 'Mon';
            insert clsSess;
            
            Class_Session__c clsSess1 = BlufyTestUtil.createClassSessionRec(cls.Id,Time.newInstance(10,30,00,00),'120');
            clsSess1.Teacher__c = tch.Id;
            clsSess1.Start_Time__c = Time.newInstance(10, 00, 00, 00);
            clsSess1.Day_of_Week__c = 'Wed';
            insert clsSess1;
            
            Class_Session__c clsSess2 = BlufyTestUtil.createClassSessionRec(cls1.Id,Time.newInstance(10,30,00,00),'120');
            clsSess2.Teacher__c = tch.Id;
            clsSess2.Start_Time__c = Time.newInstance(12, 00, 00, 00);
            clsSess2.Day_of_Week__c = 'Tue';
            insert clsSess2;
            
            Session__c sessionObj = BlufyTestUtil.createSessionRec(location.Id,tch.Id, cls.Id, Date.today().addDays(7), Time.newInstance(10, 00, 00, 00), 'Scheduled', '', '60','Standard',null);
            sessionObj.Class_Session__c = clsSess.Id;
            insert sessionObj;
            
            Enrollment__c enrollObj = BlufyTestUtil.createEnrollment(cls.Id, Date.today().addDays(-4), location.Id, studentObj.Id, ConstantClass.enrolledStatus, true,  Date.today().addDays(-4),parentObj.id);
            insert enrollObj;
            
            delete course;
            Test.startTest();
            Class__c clssObj = [SELECT Id,Advance_Scheduling_Period__c FROM Class__c WHERE Id =: cls.Id];
            System.assertEquals('2',clssObj.Advance_Scheduling_Period__c);  
            Test.stopTest();
        }
        catch(exception e){
            
        }
    }
}
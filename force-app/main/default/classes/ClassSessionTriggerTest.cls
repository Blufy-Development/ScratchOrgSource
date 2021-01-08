@isTest
public class ClassSessionTriggerTest {
@testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    static testmethod void validateClassSessionTriggerTest(){
        Account tch  = [SELECT Name FROM Account WHERE recordtypeid =: ConstantClass.teacherRecordTypeId Limit 1];
        Account loc  = [Select Name from Account where recordtypeid =: ConstantClass.locationRecordsTypeId Limit 1];
        Class__c cls = [SELECT Name FROM Class__c LIMIT 1];
        Room__c room = [SELECT Name, Type__c, Location__c, Capacity__c FROM Room__c LIMIT 1];
        Session__c sessionObj = [SELECT Id, Name, Session_Date__c,Class__c, Class_Session__c, Room__c, Teacher__c FROM Session__c LIMIT 1];
        Class_Session__c clsSessObj = BlufyTestUtil.createClassSessionRec(cls.Id,Time.newInstance(10,30,00,00),'60');
        clsSessObj.Teacher__c       = tch.Id;
        clsSessObj.Room__c          = room.Id;
        clsSessObj.Day_of_Week__c   = 'Wed';
        insert clsSessObj;
        
        Account teacherObj = BlufyTestUtil.createTeacherRec('Marry', loc.Id);
        insert teacherObj;
        
        Room__c roomObj = BlufyTestUtil.createRoom(loc.Id, 'Room6', 'Group', 35);
        insert roomObj;
        
        sessionObj.Class_Session__c = clsSessObj.Id;
        update sessionObj;
        clsSessObj.Teacher__c = teacherObj.Id;
        clsSessObj.Room__c    = roomObj.Id;
        update clsSessObj;
        
        System.assertEquals(clsSessObj.Teacher__c, teacherObj.Id);
        
        DELETE clsSessObj;
    }
}
@isTest
public class FamilyTriggerTest {
    private static testmethod void validateFamilyTriggerHandlerChildPicklist(){
        Account parObj = new Account(recordtypeid = ConstantClass.customerRecTypeId, LastName = 'Parent Test');
        insert parObj;
        Account stuObj = new Account(recordtypeid = ConstantClass.studCustomerRecordTypeId, LastName = 'Student Test');
        insert stuObj;
        Family__c fmly = new Family__c(Name = 'Test', Account__c = parObj.Id, Account_2__c = stuObj.Id,
                                       Relationship__c = ConstantClass.childFmlyRelationPicklist);
        insert fmly;
        
        Family__c recFmly = [SELECT Name, Account__c, Account_2__c, Relationship__c 
                             FROM Family__c 
                             WHERE Account__c =: stuObj.Id 
                             LIMIT 1];
        
        System.assertEquals(recFmly.Account__c, fmly.Account_2__c);
    }
    
    private static testmethod void validateFamilyTriggerHandlerSiblingPicklist(){   
        Account stuObj1 = new Account(recordtypeid = ConstantClass.studCustomerRecordTypeId, LastName = 'Student Test1');
        insert stuObj1;
        Account stuObj2 = new Account(recordtypeid = ConstantClass.studCustomerRecordTypeId, LastName = 'Student Test2');
        insert stuObj2;
        Family__c fmly1 = new Family__c(Name = 'Test', Account__c = stuObj1.Id, Account_2__c = stuObj2.Id,
                                        Relationship__c = ConstantClass.siblingFmlyRelationPicklist);
        insert fmly1;
     	Family__c fmlyObj = [SELECT Name, Relationship__c from Family__c where Account__c =: stuObj2.Id]; 
        System.assertEquals(fmly1.Relationship__c, fmlyObj.Relationship__c);
    }
}
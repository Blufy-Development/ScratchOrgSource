@isTest
public class FamilyTriggerHandlerTest {
    static testmethod void validateFamilyTriggerHandler(){
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
}
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
    }
}
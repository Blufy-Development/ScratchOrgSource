/**
* @author
* @date 
*
* 
* 
Trigger Helper Class name :- ClassTriggerHelper
Desc:- Creating Class term or sessions based on class type, frequency and status equals to open after class updation.
Create Class Term when class is update to Open status which having Type as fixed and Frequency as One-time.
Insert Class Term from Term object when class is update to Open status which having Type as Ongoing and Frequency as Term.
Create Sessions when class is update to Open status which having Frequency as Monthly and Advance scheduling unit as Month(s). 
*/
trigger ClassTrigger on Class__c (before update,before delete) {
    
    if(trigger.isBefore && trigger.isUpdate){
        /*   List<Class__c> clsList = new List<Class__c>();
for(Class__c cls: Trigger.new){
if(String.isNotBlank(cls.Type__c) && String.isNotBlank(cls.Frequency__c) && String.isNotBlank(cls.Status__c) && String.isNotBlank(Trigger.oldMap.get(cls.Id).Status__c) &&
Trigger.oldMap.get(cls.Id).Status__c.equalsIgnoreCase(ConstantClass.draftStatus) && cls.Status__c.equalsIgnoreCase(ConstantClass.clsOpenStatus)){
clsList.add(cls);
}
}
if(clsList.size() > 0)
ClassTriggerHelper.createTerm(clsList);*/
        
        List<Class__c> termTypeClsList   = new List<Class__c>();   
        List<Class__c> nonTermTypeClsList = new List<Class__c>();   
        for(Class__c cls: Trigger.new){
            if(String.isNotBlank(cls.Type__c) && String.isNotBlank(cls.Frequency__c) && String.isNotBlank(cls.Status__c) && String.isNotBlank(Trigger.oldMap.get(cls.Id).Status__c) &&
               Trigger.oldMap.get(cls.Id).Status__c.equalsIgnoreCase(ConstantClass.draftStatus) && cls.Status__c.equalsIgnoreCase(ConstantClass.clsOpenStatus) && cls.Start_Date__c != null){
                   
                   if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.termFrequency))
                       termTypeClsList.add(cls);
                   else 
                       nonTermTypeClsList.add(cls);                
               }
        }
        //if(termTypeClsList.size() > 0){
        // ClassTriggerHelper.checkStudentSessions(termTypeClsList);
        // ClassTriggerHelper.createTerm(termTypeClsList);
        //}
        
        if(nonTermTypeClsList.size() > 0){
            ClassTriggerHelper.checkStudentSessions(nonTermTypeClsList);
            ClassTriggerHelper.createSessions(nonTermTypeClsList);
        }
        
    } 
    
    if(trigger.isBefore && trigger.isDelete){
        for(Class__c cls : trigger.old){
            ClassTriggerHelper.checkEnrollmentBeforeClassDeletion(trigger.old);
        }
    }
    
}
/*
     * Name 		: EnrollmentTrigger  
     * Dependencies : EnrollmentTriggerHelper
     * Decription	: 
     * CH1          : Updated on 20th Nov 2020 by Mohit, trigger allows to rollup the total enrolments on Class Session.
     */
trigger EnrollmentTrigger on Enrollment__c (after insert, after update, after delete, after undelete) {
    
    if(trigger.isAfter){
        if(trigger.isUpdate){
            List<Enrollment__c> enrList = new List<Enrollment__c>();
            Set<Id> enrIdSet = new Set<Id>();
            for(Enrollment__c enr : trigger.new){
                if(enr.Status__c == ConstantClass.enrolledStatus && trigger.oldMap.get(enr.Id).Status__c != enr.Status__c){
                    enrList.add(enr);
                    enrIdSet.add(enr.Id);
                }
            }
            if(enrList.size() > 0){
                EnrollmentTriggerHelper.insertFeeAlloaction(enrList, enrIdSet);
                EnrollmentTriggerHelper.insertRecordsOnEnrolledEnrollment(enrList);
            }
        }
        
        //CH1 START
        if(trigger.isInsert || trigger.isUpdate || trigger.isDelete || trigger.isUndelete){
            Set<String> clsSessIdSet = new Set<String>();
            List<Enrollment__c> enrolList = trigger.isDelete ? trigger.old : trigger.new;
            Map<Id,Enrollment__c> oldMap = trigger.oldmap;
            for(Enrollment__c enrolObj : enrolList){
                if(oldMap != NULL && oldMap.get(enrolObj.id).Class_Session__c != enrolObj.Class_Session__c){
                    // when trigger is in update condition
                    if(enrolObj.Class_Session__c != NULL){
                        clsSessIdSet.add(enrolObj.Class_Session__c);
                    }
                    if(oldMap.get(enrolObj.id).Class_Session__c != NULL){
                        clsSessIdSet.add(oldMap.get(enrolObj.id).Class_Session__c);    
                    }
                    // when trigger is in insert condition
                }else if(enrolObj.Class_Session__c != NULL){
                    clsSessIdSet.add(enrolObj.Class_Session__c);
                }
            }
            
            if(clsSessIdSet.size()>0){
                EnrollmentTriggerHelper.enrolmentsRollUpOnClsSession(clsSessIdSet);        
            }
        }
        //CH1 END
    }   
}
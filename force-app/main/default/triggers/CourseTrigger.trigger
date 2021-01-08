trigger CourseTrigger on educato__Course__c (before delete) {
    
    if(trigger.isBefore && trigger.isDelete){
        for(Course__c course : trigger.old){
            CourseTriggerHelper.checkEnrollmentBeforeCourseDeletion(trigger.old);
        }
    }
    
}
trigger ClassSessionTrigger on Class_Session__c (after insert, after update, before delete) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ClassSessionTriggerHelper.createSessions(Trigger.New);
        }
        if(Trigger.isUpdate){
            Map <String, Class_Session__c> mapClsSess = new Map <String, Class_Session__c>();
            for(Class_Session__c clsSess : Trigger.New){
                // Check Whether Class Session's Teacher or Room is changed 
                if(String.isNotBlank(clsSess.Teacher__c) && clsSess.Teacher__c != Trigger.OldMap.get(clsSess.Id).Teacher__c){
                    mapClsSess.put(clsSess.Id, clsSess);
                }  
                if(String.isNotBlank(clsSess.Room__c) && clsSess.Room__c != Trigger.OldMap.get(clsSess.Id).Room__c){
                    mapClsSess.put(clsSess.Id, clsSess);
                }
            }
            
            if(mapClsSess.size() > 0){
                ClassSessionTriggerHelper.updateClsSessRelatedSessionRecords(mapClsSess);
            }
        }
    }
    
    if(Trigger.isBefore){   
        if(Trigger.isDelete){
            Set<String> ClsSessIds = new Set<String>();
            for(Class_Session__c clsSess : Trigger.Old){
                if(clsSess.Enrollments__c == NULL || clsSess.Enrollments__c <= 0){
                    ClsSessIds.add(clsSess.Id);
                }
            }
            if(ClsSessIds.size() > 0){
                List<Session__c> sessList = SessionService.getSessionsByClassSessionId(ClsSessIds);
                if(sessList.size() > 0){                   
                    SessionService.deleteSessionRecords(sessList);
                }
            }
        }
    }
}
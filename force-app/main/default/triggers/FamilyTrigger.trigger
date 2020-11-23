trigger FamilyTrigger on Family__c (after insert) {
    List<Family__c> fmlyList = new List<Family__c>();
    if(trigger.isAfter && trigger.isInsert) {
        if(FamilyTriggerHandler.isStopRecursion){
            FamilyTriggerHandler.isStopRecursion = false; // used to stop trigger for calling recursively
            for(Family__c fmly : trigger.new){
                if (String.isNotBlank(fmly.Account_2__c) && String.isNotBlank(fmly.Account__c) && 
                    String.isNotBlank(fmly.Relationship__c)){
                        fmlyList.add(fmly);
                    }
            }
        }
    }
    
    if(fmlyList.size() > 0){
        FamilyTriggerHandler.createReciprocalFamilyRecord(fmlyList);
    }
}
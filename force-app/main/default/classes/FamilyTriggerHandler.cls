public class FamilyTriggerHandler {
    public static Boolean isStopRecursion = true; // used to stop trigger for calling recursively
    public static void createReciprocalFamilyRecord(List<Family__c> fmlyList){
        List<Family__c> insertRecpFmlyRecord = new List<Family__c>();
        for(Family__c fmly : fmlyList){
            if(fmly.Relationship__c == ConstantClass.parentFmlyRelationPicklist){
                Family__c fam = new Family__c(Name            = fmly.Name,
                                              Account_2__c    = fmly.Account__c,
                                              Account__c      = fmly.Account_2__c,
                                              Relationship__c = ConstantClass.childFmlyRelationPicklist);
                insertRecpFmlyRecord.add(fam);
            }
            
            if(fmly.Relationship__c == ConstantClass.childFmlyRelationPicklist){
                Family__c fam = new Family__c(Name            = fmly.Name,
                                              Account_2__c    = fmly.Account__c,
                                              Account__c      = fmly.Account_2__c,
                                              Relationship__c = ConstantClass.parentFmlyRelationPicklist);
                insertRecpFmlyRecord.add(fam);
            }
            
            if(fmly.Relationship__c == ConstantClass.spouseFmlyRelationPicklist || 
               fmly.Relationship__c == ConstantClass.siblingFmlyRelationPicklist){
                   Family__c fam = new Family__c(Name            = fmly.Name,
                                                 Account_2__c    = fmly.Account__c,
                                                 Account__c      = fmly.Account_2__c,
                                                 Relationship__c = fmly.Relationship__c);
                   insertRecpFmlyRecord.add(fam);
               }
        }
        
        if(insertRecpFmlyRecord.size() > 0){
            FamilyService.insertRecords(insertRecpFmlyRecord);
        }
    }
}
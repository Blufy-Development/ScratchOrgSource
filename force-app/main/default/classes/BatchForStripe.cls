global class BatchForStripe implements  Database.Batchable<educato__Enrollment__c> {
    global List<educato__Enrollment__c> start(Database.BatchableContext bc) {
        list<educato__Enrollment__c> enrollmentList = [SELECT Id, Name, educato__Type__c FROM educato__Enrollment__c];
         system.debug('enrollmentList'+enrollmentList);
        
        return enrollmentList  ;
    }
    
    global void  execute(Database.BatchableContext BC, List<educato__Enrollment__c> enrollmentList ) {  
      
        
        system.debug('allmsg'+enrollmentList);
        
    }
    
    global void finish(Database.BatchableContext obj){
        
    }
   
}
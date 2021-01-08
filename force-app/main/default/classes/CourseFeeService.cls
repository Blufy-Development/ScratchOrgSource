public class CourseFeeService{
    
    public static List<Course_Fee__c> getByCourseId(String sId){  
        try{
            List<Course_Fee__c> listCourseFee = new List<Course_Fee__c>();
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Course__c,
                                      Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, 
                                      Fee__r.Required__c, Fee__r.Override__c,Fee__r.GST_Applicable__c,                                       
                                      Fee__r.Prorate__c                                     
                                      FROM Course_Fee__c 
                                      WHERE Course__c =: sId AND Fee__r.Amount__c != null AND Fee__r.Type__c != null 
                                      AND Fee__r.RecordTypeId=:ConstantClass.primaryFeeRecordTypeId WITH SECURITY_ENFORCED]){
                                          listCourseFee.add(crFee);
                                      }
            return listCourseFee;  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;    
    }

    public static List<Course_Fee__c> getByCourseIdOrType(String sId, String type, String frequency){        
        try{
            List<Course_Fee__c> listCourseFee = new List<Course_Fee__c>();        
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Course__c,
                                             Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, 
                                             Fee__r.Required__c, Fee__r.Override__c,Fee__r.GST_Applicable__c
                                      FROM Course_Fee__c 
                                      WHERE Course__c =: sId AND Fee__r.Amount__c != null AND Fee__r.Type__c =:type  
                                      AND Fee__r.RecordTypeId=:ConstantClass.primaryFeeRecordTypeId
                                      WITH SECURITY_ENFORCED]){
                                        listCourseFee.add(crFee);
            }
            return listCourseFee;
        }    
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;      
    }
}
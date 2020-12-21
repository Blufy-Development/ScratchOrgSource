public class AccountService {
    
    public static List<Account> getEnrollmentByParentIdAlongWithEnrolId(String accId,String enrolId){
        if(String.isNotBlank(accId)){
            try {
                List<Account> listAccount = [SELECT Id,(SELECT Id FROM Enrollments1__r 
                                                        WHERE Status__c =: ConstantClass.enrolledStatus
                                                        AND Id !=: enrolId)
                                             FROM Account WHERE Id =: accId WITH SECURITY_ENFORCED];
                return listAccount;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
         }
        return null;
    }
    
    public static List<Account> getCorporateOrCustomerById(String accId,Boolean isCorporateAccount){
        if(String.isNotBlank(accId)){
            try {
                List<Account> listAccount = new List<Account>();
                if(isCorporateAccount){
                    listAccount = [SELECT Id, Name, PersonEmail FROM Account WHERE Id=:accId WITH SECURITY_ENFORCED LIMIT 1];
                }
                else{
                    listAccount = [SELECT Id,Name,FirstName,LastName,PersonEmail,PersonMobilePhone,PersonMailingStreet,PersonMailingStateCode,PersonMailingCity,
                                   PersonMailingCountryCode,PersonMailingPostalCode,Relationship_with_contact__c,Gender__c,
                                   PersonBirthDate,Relationship_With_Student__c
                                   FROM Account WHERE Id=:accId WITH SECURITY_ENFORCED LIMIT 1];
                    
                }
                return listAccount;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<Account> getAccountByEmailId(String emailId){
        if(String.isNotBlank(emailId)){
            try {
                List<Account> listAccount = [SELECT Id, Name,PersonContactId, (SELECT Id, FirstName, LastName, PersonBirthDate FROM Students__r) 
                                   FROM Account WHERE PersonEmail =: emailId 
                                   WITH SECURITY_ENFORCED LIMIT 1];
                    return listAccount;
                }catch (System.QueryException e) {
                    System.debug(e.getMessage());
                }        
            }
            return null;
    }
    
    public static List<Account> getByTeacherRecTypeId(){
        try {
            return [SELECT Id, Name FROM Account 
                    WHERE recordtype.Id =: ConstantClass.teacherRecordTypeId
                    AND Teacher_user__c =: UserInfo.getUserId()
                    WITH SECURITY_ENFORCED];
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        } 
        return null;
    }
    
    public static List<Account> getByTeacherLocationId(Set<Id> teacherLocationIds){
        try {
            return [SELECT Id,Name FROM Account 
                    WHERE recordtype.Id =: ConstantClass.locationRecordsTypeId 
                    AND Id IN: teacherLocationIds
                    WITH SECURITY_ENFORCED];
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        } 
        return null;
    }
    
    public static List<Account> getByLocationRecTypeId(){
        try {
            return [SELECT Id,Name FROM Account 
                    WHERE recordtype.Id =: ConstantClass.locationRecordsTypeId
                    WITH SECURITY_ENFORCED];
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        } 
        return null;
    }
    
    public static List<Account> getByEnrollLocationPicklist(Set<String> locationPicklist){
        try {
            return [SELECT Id, Name FROM Account 
                    WHERE Name IN : locationPicklist
                    AND RecordType.Name =: ConstantClass.locationRecordType
                    WITH SECURITY_ENFORCED];
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        } 
        return null;
    }
    
    public static List<Account> getAccountByEmail(String email){
        List<Account> listAccount = new List<Account>();
        try {
            listAccount =  [SELECT Id FROM Account WHERE PersonEmail =: email AND RecordType.Id =: ConstantClass.customerRecTypeId
                            WITH SECURITY_ENFORCED LIMIT 1];
            
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        } 
        return listAccount;
    }
    
    //Upsertion of Account Records
    public static List<Account> upsertAccountRecords(List<Account> listAccount){
        try{
            System.debug('listAccount-->'+listAccount);
            if(listAccount.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, listAccount,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Account Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    upsert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Account Error Message--->'+e.getMessage());
        }
        return null;
    }
}
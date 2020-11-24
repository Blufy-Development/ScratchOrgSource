public class AccountContactRelationService {
	/*	
    public static List<AccountContactRelation> getByPrimaryAccountContactId(String primaryAccContactId){        
        if(String.isNotBlank(primaryAccContactId)){
            try {
                List<AccountContactRelation> listAccountContactRelation = [SELECT Id,AccountId,ContactId,Roles FROM AccountContactRelation 
                                                                           WHERE ContactId =: primaryAccContactId  
                                                                           WITH SECURITY_ENFORCED];
                return listAccountContactRelation;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<AccountContactRelation> getByFamilyAccountId(String familyAccountId){        
        if(String.isNotBlank(familyAccountId)){
            try {
                List<AccountContactRelation> listAccountContactRelation = [SELECT Id,AccountId,ContactId FROM AccountContactRelation 
                                                                           WHERE AccountId =: familyAccountId  
                                                                           WITH SECURITY_ENFORCED];
                return listAccountContactRelation;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    //Insertion of AccountContactRelation Records
    public static List<AccountContactRelation> insertAccountContactRelationRecords(List<AccountContactRelation> listAccountContactRelation){
        try{
            if(listAccountContactRelation.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listAccountContactRelation,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Account Contact Relation Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Account Contact Relation Error Message--->'+e.getMessage());
        }
        return null;
    }*/
}
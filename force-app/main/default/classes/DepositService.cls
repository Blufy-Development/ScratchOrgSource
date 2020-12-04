public class DepositService {

    //Insertion of Deposit Records
    public static List<Deposit__c> insertDepositRecords(List<Deposit__c> listDeposit){
        try{
            if(listDeposit.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listDeposit,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Deposit Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Deposit Error Message-->'+e.getMessage());
        }
        return null;
    }
}
public class ServiceRequestService {

    //Insertion of Enrollment Records
    public static List<Service_Request__c> insertServiceRequestRecords(List<Service_Request__c> listServiceRequest){
        if(listServiceRequest.size() > 0){
            try{
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE,listServiceRequest,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Service Request Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }catch(Exception e) {
                System.debug('Error While saving Service Request records'+e.getMessage());   
            }
        }
        return null;
    }
}
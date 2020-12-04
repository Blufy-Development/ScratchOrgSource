public with sharing class CancelEnrolmentController {
    
    //get enrolment details according to Enrolment id
    private static List<Enrollment__c> getEnrollmentByIdForCancellation(String enrolId){
        if(String.isNotBlank(enrolId)){
            try {
                    List<Enrollment__c> listEnrollment = [SELECT Id, Name,Status__c,Enrollment_End_Date__c,Reason_for_Cancellation__c,
                                                        Cancellation_Date__c,Cancellation_Comments__c,Class__c,Parent__c,Enrollment_date__c,
                                                        Class__r.Name,Class__r.Type__c,Class__r.Frequency__c,Parent__r.name,
                                                        (SELECT educato__Account__c, educato__Billable__c, educato__Class_Type__c,
                                                            educato__Course_Type__c, educato__Duration__c, educato__Enrollment__c, 
                                                            educato__Notes__c, educato__Session_Date__c, educato__Session__c, 
                                                            educato__Status__c, Name, Id 
                                                            FROM educato__Student_Sessions__r
                                                            order by educato__Session_Date__c desc)
                                                        FROM Enrollment__c 
                                                        WHERE Id =: enrolId 
                                                        LIMIT 1];
                return listEnrollment;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }

    // get enrolment details and Cancle Reason picklist values
    @AuraEnabled(cacheable=true)
    public static cancelEnrolmentClass getEnrolmentDetail(String recordId){
        EnrolmentDetails wrpcls = new EnrolmentDetails();
        try{
            List<Account> listParentAccount = new List<Account>();
            
            /* *************** Query for getting Enrollment  ***************** */
            List<Enrollment__c> listEnrollment = getEnrollmentByIdForCancellation(recordId);
            if(listEnrollment != NULL && listEnrollment.size() > 0){
                Enrollment__c enrollment = listEnrollment[0];
                wrpCls.enrolId = enrollment.Id;
                wrpCls.enrolName = enrollment.Name;
                wrpCls.enrolClassId = enrollment.Class__c;
                wrpCls.enrolClassName = enrollment.Class__r.Name;
                wrpCls.enrolClassType = enrollment.Class__r.Type__c;
                wrpCls.enrolClassFreqncy = enrollment.Class__r.Frequency__c;
                wrpCls.enrolCancelResn = enrollment.Reason_for_Cancellation__c;
                wrpCls.enrolCancelComm = enrollment.Cancellation_Comments__c;
                wrpCls.enrolCanDate = system.today();
                if(enrollment.educato__Student_Sessions__r != null && enrollment.educato__Student_Sessions__r.size() >0 ){
                    wrpCls.enrolEndDate = enrollment.educato__Student_Sessions__r[0].educato__Session_Date__c; 
                }else{
                    wrpCls.enrolEndDate = system.today().addDays(Integer.valueOf(Label.EnrollCancelNoticeTime)); 
                }
                wrpCls.enrolParent = enrollment.Parent__c;
                wrpCls.enrolParentName = enrollment.Parent__r.name;
                wrpcls.noticePeriod = enrollment.Enrollment_date__c.daysBetween(system.today());
                wrpcls.enrolStartDate =enrollment.Enrollment_date__c;
                //****Deposited amount is the amount present on invoice line item got from the query of deposit fee type.****
                if(string.isNotBlank(enrollment.Parent__c)){
                    wrpCls.depositedAmount = '$'+ getDepositAmount(enrollment.Parent__c);   
                    wrpCls.creditnoteAmount = '$'+ getTotalCreditNoteAmount(enrollment.Parent__c);          
                }
              
                Schema.DescribeFieldResult canReasonField = Enrollment__c.Reason_for_Cancellation__c.getDescribe();
                List<Schema.PicklistEntry> picList= canReasonField.getPicklistvalues();
                for(Schema.PicklistEntry plist : picList){
                    wrpCls.picklistCanReasValues.add(plist.getLabel());
                }
                wrpCls.status = enrollment.Status__c;
                return new cancelEnrolmentClass(200,'SUCCESS',wrpCls);
            }
            return new cancelEnrolmentClass(400,'Enrolment Not Found..',wrpCls);
        }
        catch(Exception e){
            return new cancelEnrolmentClass(400,e.getMessage());
        }
    }
    
    // updated enrolment and insert Service request records
    @AuraEnabled 
    public static cancelEnrolmentClass cancelEnrolmentProcess(String enrolmentid,Date enrolCanDate,String cancelReason,String requestedId,
                                                Date lastSessiondate,String commment){
        try{
            
            //******************** Cancel Enrollment *************  
            Enrollment__c enrolObj = new Enrollment__c();
            enrolObj.Id = enrolmentid;
            enrolObj.Cancellation_Date__c = enrolCanDate;
            enrolObj.Enrollment_End_Date__c = lastSessiondate;
            enrolObj.Cancellation_Comments__c = commment;
            enrolObj.Reason_for_Cancellation__c = cancelReason;
            update enrolObj;

            educato__Service_Request__c objServiceRequest = new educato__Service_Request__c(
                //educato__Service_Request_Type__c = 
                educato__Status__c ='New',
                educato__Requested_Date__c = system.today(),
                educato__Enrollment__c = enrolmentid,
                educato__Account__c = requestedId,
                educato__Comments__c = commment
            );
            insert objServiceRequest;
            return new cancelEnrolmentClass(200,'Enrolment updated Sucessfully!..');
        }
        catch(Exception e){
            return new cancelEnrolmentClass(400,e.getMessage());
        }
    }
    
    public class cancelEnrolmentClass{
        @AuraEnabled public Integer errorcode {get;set;}
        @AuraEnabled public String errorMessage {get;set;}
        @AuraEnabled public EnrolmentDetails objEnrolmentDetails {get;set;}
        public cancelEnrolmentClass(Integer errorcode,String errorMessage){
            this.errorcode = errorcode;
            this.errorMessage = errorMessage;
            this.objEnrolmentDetails = new EnrolmentDetails();
        }
        public cancelEnrolmentClass(Integer errorcode,String errorMessage,EnrolmentDetails objEnrolmentDetails){
            this.errorcode = errorcode;
            this.errorMessage = errorMessage;
            this.objEnrolmentDetails = new EnrolmentDetails();
            this.objEnrolmentDetails = objEnrolmentDetails;
        }
    }
    public class EnrolmentDetails{
        @AuraEnabled public String enrolId {get;set;}
        @AuraEnabled public String enrolName {get;set;}
        @AuraEnabled public String enrolClassId {get;set;}
        @AuraEnabled public String enrolClassName {get;set;}
        @AuraEnabled public String enrolClassType {get;set;}
        @AuraEnabled public String enrolClassFreqncy {get;set;}
        @AuraEnabled public String enrolCancelResn {get;set;}
        @AuraEnabled public String enrolCancelComm {get;set;}
        @AuraEnabled public Date enrolCanDate {get;set;}
        @AuraEnabled public Date enrolEndDate {get;set;}
        @AuraEnabled public Date enrolStartDate {get;set;}
        @AuraEnabled public String enrolParent {get;set;}
        @AuraEnabled public String enrolParentName {get;set;}
        @AuraEnabled public integer noticePeriod {get;set;}
        @AuraEnabled public List<String> picklistCanReasValues{get;set;}
        @AuraEnabled public String depositedAmount{get;set;}
        @AuraEnabled public String creditnoteAmount {get;set;}
        @AuraEnabled public Boolean custEnrolCount {get;set;}
        @AuraEnabled public String subLineItemId {get;set;}
        @AuraEnabled public String status {get;set;}
        
        public EnrolmentDetails(){
            picklistCanReasValues = new List<String>(); 
            custEnrolCount = false;
            creditnoteAmount = '$0';
            depositedAmount = '$0';
        }
    }

    // get total Credit Note Amount
    private static decimal getTotalCreditNoteAmount(string parentId){
        decimal totalCreditNoteAmount =0;
        List<AggregateResult> AggregateResultList = [select Id,Sum(educato__Amount__c)amt 
                                                        from educato__Credit_Note__c 
                                                        where educato__Account__c =: parentId
                                                        group by Id]; 
        if(AggregateResultList != null && AggregateResultList.size() > 0){ 
            if(AggregateResultList != null && AggregateResultList.size() > 0){ 
                for(AggregateResult objCreditNote : AggregateResultList){
                    totalCreditNoteAmount=(decimal)objCreditNote.get('amt'); 
                }
            } 
        }
        return totalCreditNoteAmount;
    }

    // get total Deposit Amount
    private static decimal getDepositAmount(string parentId){
        decimal totalDepositAmount =0;
        List<AggregateResult> AggregateResultList = [select educato__Account__c ,Sum(educato__Amount__c)amt 
                                                        from educato__Deposit__c 
                                                        where educato__Account__c =: parentId
                                                        group by educato__Account__c ]; 
        if(AggregateResultList != null && AggregateResultList.size() > 0){ 
            for(AggregateResult objdeposit : AggregateResultList){
                totalDepositAmount=(decimal)objdeposit.get('amt'); 
            }
        }
        return totalDepositAmount;
    }
    
    
}
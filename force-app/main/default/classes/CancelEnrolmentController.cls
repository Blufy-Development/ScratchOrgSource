public with sharing class CancelEnrolmentController {
    
    // get enrolment details and Cancle Reason picklist values
    @AuraEnabled(cacheable=true)
    public static cancelEnrolmentClass getEnrolmentDetail(String recordId){
        EnrolmentDetails wrpcls = new EnrolmentDetails();
        try{
            List<Account> listParentAccount = new List<Account>();
            
            /* *************** Query for getting Enrollment  ***************** */
            List<Enrollment__c> listEnrollment = EnrollmentService.getEnrollmentByIdForCancellation(recordId);
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
                wrpCls.enrolEndDate = getEnrolmentLastSessionDate(enrollment.id,system.today()); 
                wrpCls.enrolParent = enrollment.Parent__c;
                wrpCls.enrolParentName = enrollment.Parent__r.name;
                wrpcls.noticePeriod = enrollment.Enrollment_date__c.daysBetween(system.today());
                wrpcls.enrolStartDate =enrollment.Enrollment_date__c;
                //****Deposited amount is the amount present on invoice line item got from the query of deposit fee type.****
                if(string.isNotBlank(enrollment.Parent__c)){
                    wrpCls.depositedAmount = '$'+ DepositService.getDepositAmountByParentId(enrollment.Parent__c);
                    wrpCls.creditnoteAmount = '$'+ CreditNoteService.getTotalCreditNoteAmountByParentId(enrollment.Parent__c);          
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
    
    @AuraEnabled 
    public static Date getEnrolmentLastSessionDate(String enrolmentid,Date enrolCanDate){
        date lastSessionDate = system.today();//.addDays(Integer.valueOf(Label.EnrollCancelNoticeTime));
        if(string.isNotBlank(enrolmentid) && enrolCanDate != null){
            List<Student_Session__c> listOfStudentSession = StudentSessionService.getByEnrolIdAndEnrolCancelDate(enrolmentid, enrolCanDate);
            if(listOfStudentSession != null && listOfStudentSession.size() > 0){
                lastSessionDate=  listOfStudentSession[0].Session_Date__c;
            }   
        }        
        return lastSessionDate;
    }
    
    // updated enrolment and insert Service request records
    @AuraEnabled 
    public static cancelEnrolmentClass cancelEnrolmentProcess(String enrolmentid,Date enrolCanDate,String cancelReason,String requestedId,
                                                              Date lastSessiondate,String commment){
                                                                  try{
                                                                      
                                                                        //******************** Cancel Enrollment *************  
                                                                        Enrollment__c enrolObj = new Enrollment__c();
                                                                        enrolObj.Id = enrolmentid;
                                                                        enrolObj.Cancellation_Date__c = system.today();
                                                                        enrolObj.Enrollment_End_Date__c = enrolCanDate;
                                                                        enrolObj.Last_Session_Date__c = lastSessiondate;
                                                                        enrolObj.Cancellation_Comments__c = commment;
                                                                        enrolObj.Reason_for_Cancellation__c = cancelReason;
                                                                        EnrollmentService.updateByList(new List<Enrollment__c>{enrolObj});
                                                                        
                                                                        Service_Request__c objServiceRequest = new Service_Request__c(
                                                                            Service_Request_Type__c = 'Cancel Enrollment',
                                                                            Subject__c='Cancel Enrollment',
                                                                            Status__c ='New',
                                                                            Requested_Date__c = system.today(),
                                                                            Enrollment__c = enrolmentid,
                                                                            Account__c = requestedId,
                                                                            Comments__c = commment
                                                                        );
                                                                        ServiceRequestService.insertServiceRequestRecords(new List<Service_Request__c>{objServiceRequest});
                                                                        // last Session date is equals to Student_Session__c date than
                                                                        List<Student_Session__c> listOfDeleteStudentSession = new List<Student_Session__c>();
                                                                        List<Student_Session__c> listOfUpdatedStudentSession = new  List<Student_Session__c>();
                                                                        for(Student_Session__c objStudentSession: StudentSessionService.getStudentSessionList(enrolmentid, lastSessiondate)){
                                                                                Student_Session__c stuTemp = new Student_Session__c(Id=objStudentSession.Id);
                                                                            	if(objStudentSession.Session_Date__c == lastSessiondate){
                                                                                    stuTemp.Last_Session__c = true;
                                                                                    listOfUpdatedStudentSession.add(stuTemp);
                                                                                }else{
                                                                                    listOfDeleteStudentSession.add(stuTemp);
                                                                                }
                                                                        }
                                                                        system.debug('listOfUpdatedStudentSession'+listOfUpdatedStudentSession);
                                                                        system.debug('listOfDeleteStudentSession'+listOfDeleteStudentSession);
                                                                        if(listOfUpdatedStudentSession != null && listOfUpdatedStudentSession.size() > 0){
                                                                                StudentSessionService.updateStudentSessionRecords(listOfUpdatedStudentSession);
                                                                        }
                                                                        if(listOfDeleteStudentSession != null && listOfDeleteStudentSession.size() > 0){
                                                                                StudentSessionService.deleteStudentSessionRecords(listOfDeleteStudentSession);
                                                                        }
                                                                        return new cancelEnrolmentClass(200,'Enrollment cancellation request submitted!..');
                                                                    }catch(Exception e){
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
}
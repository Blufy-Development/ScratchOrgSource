import { LightningElement,wire,api,track } from 'lwc';
import getEnrolmentDetail from '@salesforce/apex/CancelEnrolmentController.getEnrolmentDetail';
import updateEnrolment from '@salesforce/apex/CancelEnrolmentController.cancelEnrolmentProcess';
import ENROLMENT from '@salesforce/resourceUrl/enrolment';
import {reduceErrors } from 'c/utilJs';

export default class CancelEnrollment extends LightningElement {
    @api enrolmentid; // get enrollment id
    @track enrolmentDetails={}; // show Enollement details
    // according to selection we update enrolment fields
    @track cancelReasonList;
    @track cancelReasonSalectedValue;
    @track lastSessiondate;
    @track commment;
    @track noticePeriod;
    @track enrolCanDate;
    @track requestedId;

    // manages and show error messages
    @track isError= false;
    @track isShowError = false;
    @track errorMessage = '';
    
    enrolmentUrl = ENROLMENT; // Expose the static resource URL for use in the template
    
    // get Enrolment details acccording to id
    @wire (getEnrolmentDetail,{ recordId: '$enrolmentid'})enrolmentDetail({error, data}){
        console.log('data',data);
        this.enrolmentDetails={};
        if(data){
            if(data.errorcode == 200){
                this.enrolmentDetails = data.objEnrolmentDetails;
                this.lastSessiondate = this.enrolmentDetails.enrolEndDate;
                this.enrolCanDate= this.enrolmentDetails.enrolCanDate;
                this.noticePeriod = this.enrolmentDetails.noticePeriod +' Days';
                console.log('data',this.enrolmentDetails);
                var targetListValue = [];
                this.enrolmentDetails.picklistCanReasValues.forEach(element =>
                    targetListValue.push({
                        label: element,
                        value: element
                    })
                );
                this.cancelReasonList = targetListValue;
            }else{
                const selectedRecordEvent = new CustomEvent("updateEnrollment",{
                    detail: {   state: 'error',
                                succesMessage: data.errorMessage
                            }
                });
                this.dispatchEvent(selectedRecordEvent);
            }
        }else{
            // if any error found then we close popup and show error messages
            let readableError = (error) ? reduceErrors(error) : [];
            const selectedRecordEvent = new CustomEvent("updateEnrollment",{
                detail: {   state: 'error',
                            succesMessage: readableError
                        }
            });
            this.dispatchEvent(selectedRecordEvent);
        }
    };

    // get requested id according to selected lookup values
    handleOnSelect(event) {
        let slectedRecord = event.detail;
        console.log(JSON.stringify(slectedRecord));
        if(slectedRecord.recordId !== '' && slectedRecord.recordId !== null && slectedRecord.recordId !== undefined){
            this.requestedId = slectedRecord.recordId;
            this.isShowError = false;
        }
    }

    //get lookup searching values
    addNewName(evt) {
        let { value } = evt.detail;
        console.log(value);
        if (value != '') {
            console.log('firstname', value);
        }
    }

    //if any field values is change then we update in related field
    handlechangeEnrolmentfield(event){
        let typeSearch = event.target.name;
        if(typeSearch == 'CancellationReason'){
            this.cancelReasonSalectedValue = event.target.value;
        }
        else if(typeSearch == 'EnrollmentEndDate'){
            this.enrolCanDate = event.target.value;
            var date1 = new Date(this.enrolmentDetails.enrolStartDate); 
            var date2 = new Date(this.enrolCanDate); 
            var Difference_In_Time = date2.getTime() - date1.getTime(); 
            var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            console.log('Difference_In_Days',Difference_In_Days);
            this.noticePeriod=Difference_In_Days+' Days';
        }else if(typeSearch == 'lastSessiondate'){
            this.lastSessiondate = event.target.value;
        }else if(typeSearch == 'commment'){
            this.commment = event.target.value;
        }else if(typeSearch == 'noticePeriod'){
            this.noticePeriod = event.target.value;
        }
    }

    // close popup 
    handleCancelRequest(){
        const selectedRecordEvent = new CustomEvent("updateEnrollment",{
            detail: {   state: 'Cancel',
                        succesMessage: ''
                    }
        });
        this.dispatchEvent(selectedRecordEvent);
    }

    // save cancel enrollment details and insert service request record
    submitCancelEnrolment(){
        this.isValidate();
        console.log('this.isError'+this.isError);
        if(!this.isError){
            updateEnrolment({ enrolmentid: this.enrolmentid,
                enrolCanDate: this.enrolCanDate,
                cancelReason: this.cancelReasonSalectedValue,
                requestedId: this.requestedId,
                lastSessiondate:this.lastSessiondate,
                commment:this.commment})
            .then(result => {
                console.log('result'+result);
                if(result.errorcode==200){
                    const selectedRecordEvent = new CustomEvent("updateEnrollment",{
                        detail: {   state: 'Success',
                                    succesMessage: result.errorMessage
                                }
                    });
                this.dispatchEvent(selectedRecordEvent);

                }else{
                    const selectedRecordEvent = new CustomEvent("updateEnrollment",{
                        detail: {   state: 'error',
                                    succesMessage: result.errorMessage
                                }
                    });
                    this.dispatchEvent(selectedRecordEvent);
                }
            })
            .catch(error => {
                let readableError = (error) ? reduceErrors(error) : [];
                const selectedRecordEvent = new CustomEvent("updateEnrollment",{
                    detail: {   state: 'error',
                                succesMessage: readableError
                            }
                });
                this.dispatchEvent(selectedRecordEvent);
            });
            
        }
    }

    // check all required fields is blank or not
    isValidate(){
        this.isError = false;
        this.isShowError = false;
        /*--Check Enrolment End date is blank or not -- */
        var enrollmentEndDate = this.template.querySelector('.EnrollmentEndDate');
        var enrollmentEndDateValue = enrollmentEndDate.value;
        if(enrollmentEndDateValue !== '' && enrollmentEndDateValue !== null && enrollmentEndDateValue !== undefined){
            enrollmentEndDate.setCustomValidity('');
        }else {
            enrollmentEndDate.setCustomValidity('Enrollment End Date is balnk..!!');
            this.isError = true;
        }
        enrollmentEndDate.reportValidity();

        /*--Check Enrolment Cancel Reason is blank or not -- */
        var CancellationReason = this.template.querySelector('.CancellationReason');
        var CancellationReasonValue = CancellationReason.value;
        if(CancellationReasonValue !== '' && CancellationReasonValue !== null && CancellationReasonValue !== undefined){
            CancellationReason.setCustomValidity('');
        }else {
            CancellationReason.setCustomValidity('Enrollment Cancellation Reason is blank..!!');
            this.isError = true;
        }
        CancellationReason.reportValidity();

          /*--Check Enrolment Notice Period is blank or not -- */
          var noticePeriod = this.template.querySelector('.noticePeriod');
        var noticePeriodValue = noticePeriod.value;
        if(noticePeriodValue !== '' && noticePeriodValue !== null && noticePeriodValue !== undefined){
            noticePeriod.setCustomValidity('');
        }else {
            noticePeriod.setCustomValidity('Enrollment Notice Period Day is blank..!!');
            this.isError = true;
        }
        noticePeriod.reportValidity();

         /*--Check Enrolment Last Session is blank or not -- */
        var lastSessiondate = this.template.querySelector('.lastSessiondate');
        var lastSessiondateValue = lastSessiondate.value;
        if(lastSessiondateValue !== '' && lastSessiondateValue !== null && lastSessiondateValue !== undefined){
            lastSessiondate.setCustomValidity('');
        }else {
            lastSessiondate.setCustomValidity('Enrollment Last Session Date is blank.!!');
            this.isError = true;
        }
        lastSessiondate.reportValidity();

         /*--Check requested Id is blank or not -- */
        if(this.requestedId !== '' && this.requestedId !== null && this.requestedId !== undefined){
            
        }else {
            this.errorMessage = 'Please Select Enrollment Requested By field value.';
            this.isShowError = true;
            this.isError = true;
        }
    }
}
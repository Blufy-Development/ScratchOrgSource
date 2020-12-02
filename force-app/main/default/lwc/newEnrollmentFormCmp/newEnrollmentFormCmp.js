import { LightningElement, track, wire } from 'lwc';
import doSaveEnrollmentApex from '@salesforce/apex/NewEnrollmentFormCntrl.doSaveEnrollmentApex';
import getSlcdAccDetailFromApex from '@salesforce/apex/NewEnrollmentFormCntrl.getchSlcdAccDetails';
import getGender from '@salesforce/apex/NewEnrollmentFormCntrl.getPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import findRecords from '@salesforce/apex/AutoCompleteCmpController.findRecords';
import jquery_date_picker from '@salesforce/resourceUrl/jquery_date_picker';
export default class NewEnrollmentFormCmp extends LightningElement {
    @track genderList = [];
    @track addressLine1;
    @track addressLine2;
    @track secondaryContactDetail = {};
    @track contactDetail = {};
    @track isCorporateAccount = false;
    @track isSameAsParent = false;
    @track studetnDetailsArr = [{}];
    @track enrolTotalAmt = 0.0;
    @track gstAmt = 0.0;
    @track grandTotal = 0.0;

    objectApiName = 'Account';
    fieldName = 'educato__Gender__c';
    stuClsWrapperList;
    globalDisList;
    gstAmount = 0;
    paymentRefNumber;
    toggleSpinner = false;
    showCourseAndClassModal = false;
    showAddClassAndCourseModal = false;

    get relationshipoptions() {
        return [
            { label: 'Parent', value: 'Parent' },
            { label: 'Guardian', value: 'Guardian' },
        ];
    }

    @wire(getGender, {
        "ObjectApi_name": '$objectApiName',
        "Field_name": '$fieldName'
    })
    wiredData({ error, data }) {
        if (data) {
            console.log('Data', data);
            data.forEach(ele => {
                this.genderList.push({ label: ele, value: ele });
            })
            this.genderList = JSON.parse(JSON.stringify(this.genderList))
            console.log(this.genderList);
        } else if (error) {
            console.error('Error:', error);
        }
    }

    handleOnSelect(event) {
        let slectedRecord = event.detail;
        //alert(JSON.stringify(slectedRecord))
        if (slectedRecord.type == 'PrimaryCorpContact' && slectedRecord.recordId != '') {
            getSlcdAccDetailFromApex({
                "accId": slectedRecord.recordId,
                "isCorporateAccount": this.isCorporateAccount
            }).then(res => {
                let contactDetail = JSON.parse(JSON.stringify(res));
                this.contactDetail.Name = contactDetail.Name;
                this.contactDetail.Id = contactDetail.Id;
            }).catch(error => {
                console.log('error while getting records', error);
            })
        }
        else if (slectedRecord.type == 'PrimaryCorpContact' && slectedRecord.recordId == '') {
            this.contactDetail = {};
        }

        if (slectedRecord.type == 'PrimaryCustContact' && slectedRecord.recordId != '') {
            getSlcdAccDetailFromApex({
                "accId": slectedRecord.recordId,
                "isCorporateAccount": this.isCorporateAccount
            }).then(res => {
                let contactDetail = JSON.parse(JSON.stringify(res));
                console.log('ddd', contactDetail)
                if (!this.isCorporateAccount) {
                    this.contactDetail.FirstName = contactDetail.FirstName;
                    this.contactDetail.LastName = contactDetail.LastName;
                    this.contactDetail.PersonEmail = contactDetail.PersonEmail
                    this.contactDetail.Phone = contactDetail.Phone
                    this.contactDetail.educato__Relationship_With_Student__c = contactDetail.educato__Relationship_With_Student__c;
                    this.contactDetail.educato__Gender__c = contactDetail.educato__Gender__c;
                    this.contactDetail.Id = contactDetail.Id;
                    this.contactDetail.PersonMailingCountryCode = contactDetail.PersonMailingCountryCode;
                    this.contactDetail.PersonMailingStateCode = contactDetail.PersonMailingStateCode;
                    this.contactDetail.PersonMailingPostalCode = contactDetail.PersonMailingPostalCode;
                    this.contactDetail.PersonMailingCity = contactDetail.PersonMailingCity;
                    this.addressLine1 = contactDetail.PersonMailingStreet.split('\r\n')[0];
                    this.addressLine2 = contactDetail.PersonMailingStreet.split('\r\n')[1];
                }
                else {
                    this.contactDetail.Name = contactDetail.Name;
                    this.contactDetail.Id = contactDetail.Id;
                }
            }).catch(error => {
                console.log('error while getting records', error);
            })
        }
        else if (slectedRecord.type == 'PrimaryCustContact' && slectedRecord.recordId == '') {
            this.contactDetail = {};
            this.addressLine1 = '';
            this.addressLine2 = '';
        }

        if (slectedRecord.type == 'SecondaryCustContact' && slectedRecord.recordId != '') {
            getSlcdAccDetailFromApex({
                "accId": slectedRecord.recordId,
                "isCorporateAccount": this.isCorporateAccount
            }).then(res => {
                let secondaryContactDetail = JSON.parse(JSON.stringify(res));
                this.secondaryContactDetail.Id = secondaryContactDetail.Id;
                this.secondaryContactDetail.FirstName = secondaryContactDetail.FirstName;
                this.secondaryContactDetail.LastName = secondaryContactDetail.LastName;
                this.secondaryContactDetail.PersonEmail = secondaryContactDetail.PersonEmail
                this.secondaryContactDetail.Phone = secondaryContactDetail.Phone
                this.secondaryContactDetail.educato__Relationship_With_Student__c = secondaryContactDetail.educato__Relationship_With_Student__c;
                this.secondaryContactDetail.educato__Gender__c = secondaryContactDetail.educato__Gender__c;
            }).catch(error => {
                console.log('error while getting records', error);
            })
        }
        else if (slectedRecord.type == 'SecondaryCustContact' && slectedRecord.recordId == '') {
            this.secondaryContactDetail = {};
        }
    }

    addNewName(evt) {
        let { value } = evt.detail;
        console.log(value);
        if (value != '') {
            console.log('firstname', value);
            this.contactDetail.FirstName = value;
        }
    }
    handleContactUserInput(event) {
        let { name, value } = event.currentTarget;
        this.contactDetail[name] = value;
    }

    handleSecondContactUserInput(event) {
        let { name, value } = event.currentTarget;
        this.secondaryContactDetail[name] = value;
    }

    handleAccountChange() {
        this.isCorporateAccount = !this.isCorporateAccount;
        this.contactDetail = {};
        this.secondaryContactDetail = {};
    }
    handleClassAndCourseModal() {
        this.showAddClassAndCourseModal = !this.showAddClassAndCourseModal;
    }

    handleStudentDetails(event) {
        console.log('Enrollment', event.detail)
        let studentDetails = event.detail;
        this.studetnDetailsArr = JSON.parse(JSON.stringify(this.studetnDetailsArr));
        this.studetnDetailsArr = studentDetails;
        this.enrolTotalAmt = 0.0;
        this.gstAmt = 0.0;
        this.grandTotal = 0.0;
        if (studentDetails.studentDetail.length > 0) {
            for (let i = 0; i < studentDetails.studentDetail.length; i++) {
                if (studentDetails.studentDetail[i].classDetails.length > 0) {
                    let classDetails = studentDetails.studentDetail[i].classDetails;
                    for (let j = 0; j < classDetails.length; j++) {
                        this.enrolTotalAmt += classDetails[j].classDetail.totalAmount;
                        this.gstAmt += classDetails[j].classDetail.gstAmount;
                    }
                }
            }
        }
        this.grandTotal = this.gstAmt + this.enrolTotalAmt;
        console.log('enrol Total Amount', this.enrolTotalAmt)
        console.log('gst Amount', this.gstAmt);
        console.log('grand total', this.grandTotal)
        console.log('Student Details-->', this.studetnDetailsArr)
    }

    saveEnrolments(event) {
        if (this.validateForm() == true) {
            console.log('this.contactDetail', this.contactDetail);
            doSaveEnrollmentApex({
                "studentDetails": JSON.stringify(this.studetnDetailsArr),
                "parentDetail": JSON.stringify(this.contactDetail),
                "secondaryDetail": JSON.stringify(this.secondaryContactDetail),
                "btnLabel" : event.target.label
            }).then(res => {
                console.log('res-->', res)
            }).catch(error => {
                console.log('error while getting records', error);
                console.log('save enrollment');
            })
        }
    }

    validateForm = () => {
        let allValid = [...this.template.querySelectorAll('.req')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        let bankData = this.template.querySelector("c-stripe-a-c-h-verification").sendDetails();
        console.log('json', bankData);
        if (allValid && bankData.length > 0) {
            console.log('all valid');
            return true;
        }
        this.showNotification('Error', 'Please fill the details', 'error');
        return false;
        // let bankData = [];
        // bankData = this.template.querySelector("c-stripe-a-c-h-verification").sendDetails();
        // console.log('save enrollment');
        // console.log('json', bankData);

    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}
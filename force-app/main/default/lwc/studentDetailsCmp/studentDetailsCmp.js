import { LightningElement, track, api, wire } from 'lwc';
import getGender from '@salesforce/apex/NewEnrollmentFormCntrl.getPicklistValues';
import getSlcdAccDetailFromApex from '@salesforce/apex/NewEnrollmentFormCntrl.getchSlcdAccDetails';
import GSTRate from '@salesforce/label/c.GST_Rate';
export default class StudentDetailsCmp extends LightningElement {

    @track genderList = [];
    objectApiName = 'Account';
    fieldName = 'educato__Gender__c';
    @track studentDetail = [{
        key: Math.random(),
        FirstName: '',
        LastName: '',
        Gender: '',
        PersonBirthdate: '',
        Id: '',
        classDetails: []
    }];
    rowIndex = -1;
    @track showAddClassModal = false;
    @track studentindex;
    @wire(getGender, {
        "ObjectApi_name": '$objectApiName',
        "Field_name": '$fieldName'
    })
    wiredData({ error, data }) {
        if (data) {
            data.forEach(ele => {
                this.genderList.push({ label: ele, value: ele });
            })
            this.genderList = JSON.parse(JSON.stringify(this.genderList))
        } else if (error) {
            console.error('Error:', error);
        }
    }

    handleOnSelectStudent(event) {
        let slectedRecord = event.detail;
        console.log('selected rec-->', slectedRecord)
        // alert(this.rowIndex)
        if (slectedRecord.type == 'Student' && slectedRecord.recordId != '') {
            console.log('inside handle')
            getSlcdAccDetailFromApex({
                "accId": slectedRecord.recordId,
                "isCorporateAccount": false
            }).then(res => {
                console.log('res-->', res)
                this.studentDetail = JSON.parse(JSON.stringify(this.studentDetail));
                let studentRec = JSON.parse(JSON.stringify(res));
                this.studentDetail[slectedRecord.index].FirstName = studentRec.FirstName;
                this.studentDetail[slectedRecord.index].LastName = studentRec.LastName;
                this.studentDetail[slectedRecord.index].PersonBirthdate = studentRec.PersonBirthdate;
                this.studentDetail[slectedRecord.index].Gender = studentRec.educato__Gender__c;
                //this.studentDetail[slectedRecord.index].Name = studentRec.FirstName +' '+studentRec.LastName;
                this.studentDetail[slectedRecord.index].Id = slectedRecord.recordId;
                console.log(this.studentDetail[slectedRecord.index])
            }).catch(error => {
                console.log('error while getting records', error);
            })
        }
        else if (slectedRecord.type == 'Student' && slectedRecord.recordId == '') {
            this.studentDetail = JSON.parse(JSON.stringify(this.studentDetail));
            console.log(this.studentDetail[slectedRecord.studentindex])
            this.studentDetail[slectedRecord.studentindex] = {
                key: Math.random(),
                FirstName: '',
                LastName: '',
                Gender: '',
                PersonBirthdate: '',
                Id: ''
            };
        }
    }

    openAddClassModal(event) {
        console.log(event.currentTarget.dataset.index);
        let allValid = [...this.template.querySelectorAll('.req')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {
            this.studentindex = event.currentTarget.dataset.index;
            this.showAddClassModal = true;
        }

    }

    addStudent() {
        this.rowIndex = this.studentDetail.length;
        this.studentDetail.push({
            key: Math.random(),
            FirstName: '',
            LastName: '',
            Gender: '',
            PersonBirthdate: '',
            Id: '',
            classDetails: []
        });
        console.log('this.studetnDetailsArr', this.studentDetail);
    }

    removeRow(event) {// method to remove particular row
        console.log('this.rows.length ', event.currentTarget.dataset.index);
        let rowReplica = Object.assign([], this.studentDetail);
        console.log('rowReplica', rowReplica)
        rowReplica.splice(event.currentTarget.dataset.index, 1);
        setTimeout(function (self) {
            self.studentDetail = JSON.parse(JSON.stringify(rowReplica));
            if (self.studentDetail.length === 0) {
                self.addStudent();
            }
        }, 500, this);
        console.log('stu detail-->', rowReplica)
        this.dispatchEvent(new CustomEvent('rowdeletion', { detail: { studentDetail: rowReplica } }));
    }

    handleClasseModal() {
        this.showAddClassModal = !this.showAddClassModal;
    }

    handleSaveEvent(event) {
        let courseDetails = event.detail;
        let studentDetail = JSON.parse(JSON.stringify(this.studentDetail));
        let classDetail = courseDetails.relatedCourseDetails.classDetail;
        classDetail.classFee = classDetail.tuitionFeeList[0].parentAmount;
        let total = 0.0;
        let gstApplicableAmount = 0.0;

        if (classDetail.tuitionFeeList.length > 0) {
            let listTuitionFee = classDetail.tuitionFeeList;
            for (let i = 0; i < listTuitionFee.length; i++) {
                total += listTuitionFee[i].parentProratedAmount;
                if (listTuitionFee[i].gstApplicable)
                    gstApplicableAmount += listTuitionFee[i].parentProratedAmount;
            }
        }

        if (classDetail['secondaryFeeList'] && classDetail.secondaryFeeList.length > 0) {
            let listSecondaryFee = classDetail.secondaryFeeList;
            for (let i = 0; i < listSecondaryFee.length; i++) {
                total += listSecondaryFee[i].feeAmount;
                if (listSecondaryFee[i].isGSTApplicable)
                    gstApplicableAmount += listSecondaryFee[i].feeAmount;
            }
        }

        if (classDetail['depositfeelist'] && classDetail.depositfeelist.length > 0) {
            let listDepositFee = classDetail.depositfeelist;
            for (let i = 0; i < listDepositFee.length; i++) {
                total += listDepositFee[i].parentAmount;
                if (listDepositFee[i].gstApplicable)
                    gstApplicableAmount += listDepositFee[i].parentAmount;
            }
        }

        console.log('gstApplicable', gstApplicableAmount);
        let gstAmount = gstApplicableAmount * parseInt(GSTRate) / 100;
        console.log('gstAmount-->', gstAmount)
        classDetail.gstAmount = gstAmount;
        classDetail.totalAmount = total;
        if (studentDetail[courseDetails.index].classDetails.length == 0)
            classDetail.showName = true;
        else
            classDetail.showName = false;
        courseDetails.relatedCourseDetails.classDetail = classDetail;

        studentDetail[courseDetails.index].classDetails.push(courseDetails.relatedCourseDetails);
        console.log('sdetail-->', studentDetail[courseDetails.index].classDetails)
        this.studentDetail[courseDetails.index].classDetails = studentDetail[courseDetails.index].classDetails;
        this.showAddClassModal = !this.showAddClassModal;
        this.dispatchEvent(new CustomEvent('savestudentdetails', { detail: { studentDetail: this.studentDetail } }));
    }

    handleStudentDetails(event) {
        let { name, value } = event.currentTarget;
        let { index } = event.currentTarget.dataset;
        this.studentDetail[index][name] = value;
        console.log('this.studentDetail', this.studentDetail);
    }

    addNewName(evt) {
        let { value, index } = evt.detail;
        console.log('value', value);
        console.log('index', index);
        if (value != '') {
            this.studentDetail[index].FirstName = value;
        }

    }
}
import { LightningElement, api, track } from 'lwc';
import GSTRate from '@salesforce/label/c.GST_Rate';
import LOCALE_CURRENCY from "@salesforce/i18n/currency";
import getBlufyConfigDetailsApex from "@salesforce/apex/NewEnrollmentFormCntrl.getBlufyConfigDetails";

export default class EnrollmentSummary extends LightningElement {
    @api studetnDetailsArr;
    @api enrolTotalAmt;
    classIndex;
    studentIndex;
    @track showEditClassForm = false;
    currentClassDetail;

    GSTApplicableByBlufyConfig = false;
    GSTRateByBlufyConfig = 0.0;

    label = {
        LOCALE_CURRENCY
    }

    connectedCallback() {
        console.log('studetnDetailsArr', this.studetnDetailsArr);
        getBlufyConfigDetailsApex()
            .then((response) => {
                console.log('response-->',response)
                if(response != null){
                    this.GSTApplicableByBlufyConfig = response.educato__GST_VAT_Applicable__c;
                    if(response.educato__GST_VAT_Rate__c != null)
                    this.GSTRateByBlufyConfig = response.educato__GST_VAT_Rate__c;
                    console.log('gstblufyconfigApplicable-->'+this.GSTApplicableByBlufyConfig)
                    console.log('gstblufyconfigRate-->'+this.GSTRateByBlufyConfig)
                }
            })
            .catch((error) => {
                console.log("error while getting records", error);
            });
    }
    editClass(event) {
        let { classindex, studentindex } = event.currentTarget.dataset;
        console.log(classindex);
        console.log(this.studetnDetailsArr.studentDetail);
        if (this.studetnDetailsArr.studentDetail[studentindex]) {
            this.classIndex = classindex;
            this.studentIndex = studentindex;
            this.showEditClassForm = true;
            this.currentClassDetail = this.studetnDetailsArr.studentDetail[studentindex];
            // console.log('currentClassDetail', this.currentClassDetail);
        }
    }

    handleClasseModal() {
        this.showEditClassForm = false;
    }


    handleSaveEvent(event) {
        console.log('event', event.detail);
        console.log('studentArr', this.studetnDetailsArr.studentDetail);
        let studentDetailArrReplica = JSON.parse(JSON.stringify(this.studetnDetailsArr));
        let studentClassDetail = studentDetailArrReplica.studentDetail[this.studentIndex];
        console.log('studentClassDetail', studentClassDetail.classDetails[this.classIndex]);
        console.log('calling');
        let courseDetails = event.detail;
        // console.log('courseDetails', courseDetails);
        // let courseStudentData = JSON.parse(JSON.stringify(this.studetnDetailsArr.studentDetail));
        // console.log('courseStudentData', courseStudentData);
        // let studentDetail = courseStudentData[courseDetails.index];
        let classDetail = courseDetails.relatedCourseDetails.classDetail;
        classDetail.classFee = classDetail.tuitionFeeList[0].parentAmount;
        let total = 0.0;
        let gstApplicableAmount = 0.0;
        console.log('46');
        if (classDetail.tuitionFeeList.length > 0) {
            let listTuitionFee = classDetail.tuitionFeeList;
            for (let i = 0; i < listTuitionFee.length; i++) {
                total += listTuitionFee[i].parentProratedAmount;
                if (this.GSTApplicableByBlufyConfig && this.GSTRateByBlufyConfig > 0)
                    gstApplicableAmount += listTuitionFee[i].parentProratedAmount;
            }
        }
        console.log('55');
        if (classDetail['secondaryFeeList'] && classDetail.secondaryFeeList.length > 0) {
            let listSecondaryFee = classDetail.secondaryFeeList;
            for (let i = 0; i < listSecondaryFee.length; i++) {
                total += listSecondaryFee[i].feeAmount;
                if (this.GSTApplicableByBlufyConfig && this.GSTRateByBlufyConfig > 0)
                    gstApplicableAmount += listSecondaryFee[i].feeAmount;
            }
        }
        console.log('64');
        if (classDetail['depositfeelist'] && classDetail.depositfeelist.length > 0) {
            let listDepositFee = classDetail.depositfeelist;
            for (let i = 0; i < listDepositFee.length; i++) {
                total += listDepositFee[i].parentAmount;
            }
        }
        console.log('73');

        let gstAmount = gstApplicableAmount * this.GSTRateByBlufyConfig / 100;
        console.log('76');
        classDetail.gstAmount = gstAmount;
        classDetail.totalAmount = total;
        // console.log('studentDetail', studentDetail.classDetails);
        console.log('81');
        if (studentClassDetail.classDetails.length == 0)
            classDetail.showName = true;
        else
            classDetail.showName = false;

        console.log('classDetail', classDetail);
        courseDetails.relatedCourseDetails.classDetail = JSON.parse(JSON.stringify(classDetail));
        studentClassDetail.classDetails[this.classIndex].classDetail = JSON.parse(JSON.stringify(courseDetails.relatedCourseDetails.classDetail));
        studentClassDetail.classDetails[this.classIndex].comments = JSON.parse(JSON.stringify(courseDetails.relatedCourseDetails.comments));
        studentClassDetail.classDetails[this.classIndex].enrollmentStartDate = JSON.parse(JSON.stringify(courseDetails.relatedCourseDetails.enrollmentStartDate));
        // if (studentDetail.classDetails.length == 0)
        //     classDetail.showName = true;
        // else
        //     classDetail.showName = false;
        // courseDetails.relatedCourseDetails.classDetail = classDetail;
        // tudentDetail.classDetails = [];
        // studentDetail.classDetails.push(courseDetails.relatedCourseDetails);
        this.showEditClassForm = false;
        // courseStudentData[courseDetails.index] = studentDetail;    
        console.log(' studentClassDetail.classDetails[this.classIndex]-->', studentClassDetail);
        studentDetailArrReplica.studentDetail[this.studentIndex] = studentClassDetail;
        console.log(' studentDetailArrReplica.classDetails[this.classIndex]-->', studentDetailArrReplica);
        this.dispatchEvent(new CustomEvent('savestudentdetails', { detail: { studentDetail: studentDetailArrReplica.studentDetail } }));


    }

}
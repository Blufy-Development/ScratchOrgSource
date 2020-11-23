import { LightningElement, track } from 'lwc';
import getClassDetails from '@salesforce/apex/NewEnrollmentFormCntrl.fetchClassDetails';
import getFessDetail from '@salesforce/apex/NewEnrollmentFormCntrl.fetchFessDetail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AddCourse extends LightningElement {
    @track classData = [];
    @track feesData = [];
    @track secondayFeesData = [];
    @track secondayFeesData = [];
    @track anotherFeesData = [];
    @track depositFeesData = [];
    @track classSessionData = {};
    @track btnName = 'Next';
    @track title = 'Select Course and Class';
    @track locationName = '';
    @track courseName = '';
    showAnotherFees = false;
    showSecondayFees = false;
    showDepositFees = false;

    courseId = '';
    totalCheckedCount = 0;
    selectedClassSessionId = '';
    showClassData = false;
    currentPage = 1;
    iconName = 'utility:jump_to_right';
    showBackButton = false;
    feesId = '';


    // showSection: function(component, event, helper){
    //     let section_to_hide= event.getSource().get('v.name');
    //     let section_heading= event.getSource().get('v.value');
    //     //console.log(section_to_hide);
    //     helper.showSec(component,event,section_to_hide,section_heading);
    //     },

    //     selectPlan: function(component, event, helper){
    //         let planVal= event.getSource().get('v.value');
    //         helper.showPlan(component,event,planVal);
    //     }

    // showSec : function(component,event,divId,sHeading){
    //     let pageSections = document.getElementsByClassName('courseSections');
    //     let footSections = document.getElementsByClassName('footerSection');	
    //     document.getElementById('modal-heading-01').innerHTML = sHeading;

    // 	for( var i=0; i <=2; i++){
    // 	pageSections[i].classList.add("slds-hide");
    //         footSections[i].classList.add("slds-hide");

    //     if(pageSections[i].classList.contains(divId) && footSections[i].dataset.name == divId ){
    // 		pageSections[i].classList.remove("slds-hide");
    //         footSections[i].classList.remove("slds-hide");
    // 	}
    //         else{//console.log('eror');
    //         }

    // }
    // }

    // showPlan : function(component,event,planSec){
    //     console.log(planSec);
    //     let x= ["module-based", "custom-installments"];
    //     x.forEach(myFunction);

    //     function myFunction(item) {
    //         document.getElementById(item).classList.add("slds-hide");
    //         if(item == planSec){document.getElementById(planSec).classList.remove("slds-hide");}
    //     } 

    // },   

    fetchClassDetailsFromApex() {
        getClassDetails({
            crId: this.courseId,
        }).then(res => {
            console.log('res', res);
            this.showClassData = true;
            this.classData = JSON.parse(JSON.stringify(res));
            this.locationName = this.classData.classWrapperList[0].location;
            this.courseName = this.classData.classWrapperList[0].course;
            console.log('classWrapperList', this.classData);
        }).catch(error => {
            console.log('error while getting data', error);
        })
    }

    fetchFeesDetailsFromApex() {
        console.log('selectedClassSessionId', this.selectedClassSessionId);
        this.showAnotherFees = false;
        this.showSecondayFees = false;
        this.showDepositFees = false;
        this.feesData = [];
        getFessDetail({
            classSessionId: this.selectedClassSessionId
        }).then(result => {
            console.log('resuilt', result);
            this.feesData = JSON.parse(JSON.stringify(result));
        }).catch(error => {
            console.log('Error while getting fees records', error);
        })
    }

    closemodal() {
        console.log('close');
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    changeScreen = (evt) => {
        console.log(evt.currentTarget.name);
        let { name } = evt.currentTarget;
        if (name == 'back') {
            if (this.currentPage == 3) {
                this.hideAllScreen();
                this.currentPage = 2;
                this.btnName = 'Next';
                this.iconName = 'utility:jump_to_right';
                this.template.querySelector('.courseSection2').classList.add('slds-show');
                this.template.querySelector('.courseSection2').classList.remove('slds-hide');
                this.title = 'Fees & Deposit';
            } else {
                this.hideAllScreen();
                this.currentPage = 1;
                this.template.querySelector('.courseSection1').classList.add('slds-show');
                this.template.querySelector('.courseSection1').classList.remove('slds-hide');
                this.showBackButton = false;
                this.title = 'Select Course and Class';
            }
        } else if (this.btnName == 'Next') {
            if (this.currentPage == 2) {
                if (this.validateFeeDeposit() == true) {
                    this.hideAllScreen();
                    this.btnName = 'Save';
                    this.iconName = 'utility:download';
                    this.template.querySelector('.courseSection3').classList.add('slds-show');
                    this.template.querySelector('.courseSection3').classList.remove('slds-hide');
                    this.title = 'Enrollment Date and Notes';
                    this.currentPage += 1;
                }
            } else if (this.currentPage == 1) {
                if (this.validateClassSession() == true) {
                    this.hideAllScreen();
                    this.showBackButton = true;
                    this.template.querySelector('.courseSection2').classList.add('slds-show');
                    this.template.querySelector('.courseSection2').classList.remove('slds-hide');
                    this.title = 'Fees & Deposit';
                    this.currentPage += 1;
                    this.fetchFeesDetailsFromApex();
                }
            }
        }
    }

    validateClassSession = () => {
        this.totalCheckedCount = 0;
        // this.selectedClassSessionId = '';
        // console.log(this.template.querySelectorAll('input[class="class-session-chkbx"]:checked').length);
        this.template.querySelectorAll(".class-session-chkbx").forEach(ele => {
            console.log(ele.checked);
            if (ele.checked == true) {
                this.totalCheckedCount += 1;
            }
        });
        if (this.totalCheckedCount != 1) {
            this.showNotification('Error', 'Please select one class session', 'error');
            return false;
        }
        return true;

    }
    hanldeSessionChkxBox(event) {
        console.log('event.currentTarget.checked', event.currentTarget.checked);
        if (event.currentTarget.checked == true) {
            this.template.querySelectorAll(".class-session-chkbx").forEach(ele => {
                ele.checked = false;
            });
            event.currentTarget.checked = true;
            this.selectedClassSessionId = event.currentTarget.dataset.id;
            this.classSessionData = {
                className: event.currentTarget.dataset.course,
                courseName: event.currentTarget.dataset.class,
                dayOfWeek: event.currentTarget.dataset.day,
                startTime: event.currentTarget.dataset.srttime,
                endTime: event.currentTarget.dataset.endtime
            };
        } else {
            this.selectedClassSessionId = '';
            this.classSessionData = [];
        }
    }
    validateFeeDeposit() {
        let isChecked = false;
        this.template.querySelectorAll('.primary-fees').forEach(ele => {
            console.log(ele.checked);
            if (ele.checked == true) {
                isChecked = true;
            }
        });
        if (!isChecked) {
            this.showNotification('Error', 'Please select primary Fee', 'error');
            return false;
        }
        return true;
    }

    getClassSessionData = () => {
        // let clsData = this.classData.classWrapperList;
        // for (let indx of clsData) {
        //     for (let data of indx.dayOfWeekClsList) {
        //         for (let sessionData of data.classSessionWrapperList) {
        //             if (this.selectedClassSessionId == sessionData.id) {

        //             }
        //         }
        //     }
        //     //selectedClassSessionId
        // }
    }
    hideAllScreen() {
        this.template.querySelectorAll('.courseSections').forEach(ele => {
            ele.classList.add('slds-hide');
            ele.classList.remove('slds-show');
        })
    }
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    toggleSection = (evt) => {
        let { name } = evt.currentTarget;
        let { index } = evt.currentTarget.dataset;
        this.template.querySelectorAll('.collapse-class-session').forEach(ele => {
            ele.classList.add('slds-hide');
            ele.classList.remove('slds-show');
            //added + icon
            console.log('ele', ele);
            ele.previousElementSibling.querySelector('.plus-util').classList.remove('slds-hide');
            ele.previousElementSibling.querySelector('.minus-util').classList.add('slds-hide');
        });
        if (name == 'plus') {
            console.log(evt.currentTarget);
            evt.currentTarget.classList.add('slds-hide');
            evt.currentTarget.nextSibling.classList.remove('slds-hide');
            evt.currentTarget.parentNode.parentNode.nextSibling.classList.remove('slds-hide');
            evt.currentTarget.parentNode.parentNode.nextSibling.classList.add('slds-show');
        }
        console.log(name);
        console.log(index);
    }

    handleCourseSelect(event) {
        console.log(event.detail);
        if (event.detail.recordId) {
            this.courseId = event.detail.recordId;
            this.fetchClassDetailsFromApex();
        }
    }

    handleFeesSelectChkbx(event) {
        console.log(event.currentTarget.dataset.id);
        this.secondayFeesData = [];
        this.depositFeesData = [];
        this.showAnotherFees = false;
        this.showSecondayFees = false;
        this.showDepositFees = false;

        this.anotherFeesData = this.feesData.find(ele => ele.parentFeeId == (event.currentTarget.dataset.id)).childFeeWrapper;
        console.log(this.anotherFeesData);

        if (this.anotherFeesData.length > 0) {
            this.anotherFeesData.forEach(ele => {
                if (ele.feeType == "Other Fee") {
                    this.secondayFeesData.push(ele);
                    this.showSecondayFees = true;
                } else {
                    this.depositFeesData.push(ele);
                    this.showDepositFees = true;
                }
            });
            this.showAnotherFees = true;
        }
        console.log('this.showSecondayFees', this.showSecondayFees);
        //this.secondayFeesData = ;
        //this.showSecondayFees = true;

    }
}
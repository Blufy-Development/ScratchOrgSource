import { LightningElement, track } from 'lwc';
import getClassDetails from '@salesforce/apex/NewEnrollmentFormCntrl.fetchClassDetails'
export default class AddCourseAndClassCmp extends LightningElement {
    @track classData = [];
    showClassData = false;
    currentPage = 1;
    iconName = 'utility:jump_to_right';
    showBackButton = false;
    @track btnName = 'Next';
    @track title = 'Select Course and Class';
    courseId = '';
    @track locationName = '';
    @track courseName = '';
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

    closemodal() {
        console.log('close');
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    showSection = (evt) => {
        console.log(evt.currentTarget.name);
        let { name } = evt.currentTarget;
        this.template.querySelectorAll('.courseSections').forEach(ele => {
            ele.classList.add('slds-hide');
            ele.classList.remove('slds-show');
        })
        if (name == 'back') {
            if (this.currentPage == 3) {
                this.currentPage = 2;
                this.btnName = 'Next';
                this.iconName = 'utility:jump_to_right';
                this.template.querySelector('.courseSection2').classList.add('slds-show');
                this.template.querySelector('.courseSection2').classList.remove('slds-hide');
                this.title = 'Fees & Deposit';
            } else {
                this.currentPage = 1;
                this.template.querySelector('.courseSection1').classList.add('slds-show');
                this.template.querySelector('.courseSection1').classList.remove('slds-hide');
                this.showBackButton = false;
                this.title = 'Select Course and Class';
            }
        } else if (this.btnName == 'Next') {
            if (this.currentPage == 2) {
                this.btnName = 'Save';
                this.iconName = 'utility:download';
                this.template.querySelector('.courseSection3').classList.add('slds-show');
                this.template.querySelector('.courseSection3').classList.remove('slds-hide');
                this.title = 'Enrollment Date and Notes';
            } else if (this.currentPage == 1) {
                this.showBackButton = true;
                this.template.querySelector('.courseSection2').classList.add('slds-show');
                this.template.querySelector('.courseSection2').classList.remove('slds-hide');
                this.title = 'Fees & Deposit';
            }
            this.currentPage += 1;
        }
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
}
import { LightningElement, api, track } from 'lwc';
import getClassDetails from '@salesforce/apex/NewEnrollmentFormCntrl.fetchClassDetails';
import getFessDetail from '@salesforce/apex/NewEnrollmentFormCntrl.fetchFessDetail';
import getProratedAmount from '@salesforce/apex/NewEnrollmentFormCntrl.calculateProratedAmount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import defaultCurrency from '@salesforce/label/c.Default_Currency';
export default class AddCourse extends LightningElement {
    @api index;
    @api mode = 'new';
    @api previousData;
    @track classData = [];
    @track feesData = [];
    @track primaryFeesData = [];
    @track secondayFeesData = [];
    @track anotherFeesData = [];
    @track depositFeesData = [];
    @track selectedClassSessionData = {};
    @track selectedFessData = {};
    @track btnName = 'Next';
    @track title = 'Select Course and Class';
    @track locationName = '';
    @track courseName = '';
    @track enrollmentSrtDt = new Date().toISOString();
    @track comment = '';
    showAnotherFees = false;
    showSecondayFees = false;
    showDepositFees = false;
    showSpinner = false;
    courseId = '';
    totalCheckedCount = 0;
    selectedClassSessionId = '';
    showClassData = false;
    currentPage = 1;
    iconName = 'utility:jump_to_right';
    showBackButton = false;
    feesId = '';
    isChanged = false;
    label = {
        defaultCurrency
    }

    connectedCallback() {
        if (this.mode == 'edit') {
            this.courseId = this.previousData.classDetails[0].classDetail.courseId;
            console.log(this.previousData);
            this.fetchClassDetailsFromApex();

        }
    }

    fetchClassDetailsFromApex() {
        this.showSpinner = true;
        getClassDetails({
            crId: this.courseId,
        }).then(res => {
            console.log('res', res);
            this.showSpinner = false;
            this.showClassData = true;
            this.classData = JSON.parse(JSON.stringify(res));
            this.locationName = this.classData.classWrapperList[0].location;
            this.courseName = this.classData.classWrapperList[0].course;
            console.log('classWrapperList', this.classData);
            // let classIndex;
            if (this.mode == 'edit' && this.previousData) {
                console.log('inside');
                let clasSessionObj;
                this.previousData.classDetails.forEach((classEle, index) => {
                    clasSessionObj = this.classData.classWrapperList.find(disEle => disEle.clsId == classEle.classDetail.classId);
                    console.log('clasSessionObj', console.log(clasSessionObj));
                    if (clasSessionObj) {
                        this.index = index;
                        this.comment = classEle.comments;
                        this.enrollmentSrtDt = classEle.enrollmentStartDate;
                        clasSessionObj.dayOfWeekClsList.forEach(dayObj => {
                            if (classEle.classDetail.dayOfWeek == dayObj.nameOfDay) {
                                console.log(dayObj.nameOfDay);
                                dayObj.classSessionWrapperList.forEach(clsObj => {
                                    if (clsObj.id == classEle.classDetail.classSessionId) {
                                        clsObj.selected = true;
                                        this.selectedClassSessionId = classEle.classDetail.classSessionId;
                                        this.selectedClassSessionData = {
                                            classId: classEle.classDetail.classId,
                                            locationId: classEle.classDetail.locationId,
                                            teacherId: classEle.classDetail.teacherId,
                                            teacherName: classEle.classDetail.teacherName,
                                            className: classEle.classDetail.className,
                                            courseName: classEle.classDetail.courseName,
                                            dayOfWeek: classEle.classDetail.dayOfWeek,
                                            startTime: classEle.classDetail.startTime,
                                            endTime: classEle.classDetail.endTime,
                                            clsFrequency: classEle.classDetail.clsFrequency,
                                            clsType: classEle.classDetail.clsType,
                                            courseId: this.courseId
                                        };
                                    }
                                });
                            }
                        });
                    }
                });
                console.log('clasSessionObj', clasSessionObj);
                //     if (ele.clsId == this.previousData.classDetails[0].classDetail.classId) {
                //         console.log(index);
                //         // classIndex = index;
                //         let classObj = ele;
                //         if (classObj) {
                //             console.log(classObj.dayOfWeekClsList);
                //             classObj.dayOfWeekClsList.forEach(dayObj => {
                //                 if (this.previousData.classDetails[0].classDetail.dayOfWeek == dayObj.nameOfDay) {
                //                     console.log(dayObj);
                //                     dayObj.classSessionWrapperList.forEach(clsObj => {
                //                         if (clsObj.id == this.previousData.classDetails[0].classDetail.classSessionId) {
                //                             console.log(clsObj);
                //                             clsObj.selected = true;
                //                         }
                //                     })
                //                 }
                //             })
                //         }
                //     }
                // }
            }
        }).catch(error => {
            this.showSpinner = false;
            console.log('error while getting data', error);
        })
    }

    fetchFeesDetailsFromApex() {
        console.log('selectedClassSessionId', this.selectedClassSessionId);
        this.showAnotherFees = false;
        this.showSecondayFees = false;
        this.showDepositFees = false;
        this.showSpinner = true;
        this.feesData = [];
        this.primaryFeesData = [];
        this.depositFeesData = [];
        getFessDetail({
            classSessionId: this.selectedClassSessionId
        }).then(result => {
            console.log('resuilt', result);
            this.feesData = JSON.parse(JSON.stringify(result));
            if (this.feesData.length > 0) {
                this.feesData.forEach(ele => {
                    //for edit functionality when a user reopen modal 
                    if (this.mode == 'edit' && this.isChanged == false) {
                        console.log('not changed');
                        this.previousData.classDetails.forEach((classEle) => {
                            classEle.classDetail.tuitionFeeList.forEach(tutEle => {
                                if (tutEle.parentFeeId == ele.parentFeeId) {
                                    ele.selected = true;
                                    this.anotherFeesData = ele;
                                    if (classEle.classDetail.secondaryFeeList) {
                                        classEle.classDetail.secondaryFeeList.forEach(secondayEle => {
                                            let secFeesObj = ele.childFeeWrapper.find(res => res.feeId == secondayEle.feeId);
                                            console.log('secFeesObj,', secFeesObj);
                                            if (secFeesObj) {
                                                secFeesObj.selected = true;
                                                this.secondayFeesData.push(secFeesObj);
                                                this.showSecondayFees = true;
                                                this.showAnotherFees = true;
                                            }
                                        });
                                    }
                                }
                            });
                            if (classEle.classDetail.depositfeelist) {
                                classEle.classDetail.depositfeelist.forEach(depoEle => {
                                    if (depoEle.parentFeeId == ele.parentFeeId) {
                                        ele.selected = true;
                                    }
                                });
                            }
                        });
                    }
                    //end
                    if (ele.parentFeeType == 'Tuition Fee') {
                        this.primaryFeesData.push(ele);
                    } else if (ele.parentFeeType == 'Deposit') {
                        this.depositFeesData.push(ele);
                    }
                })
            }
            if (this.depositFeesData.length > 0) {
                this.showDepositFees = true;
            }
            this.showSpinner = false;
        }).catch(error => {
            console.log('Error while getting fees records', error);
            this.showSpinner = false;
        })
    }

    fetchProrate(courseDetails) {
        let selectedDate = courseDetails.enrollmentStartDate;
        let primaryFeesDetail = courseDetails.classDetail.tuitionFeeList;
        getProratedAmount({
            classSessionId: this.selectedClassSessionId,
            selectedFee: JSON.stringify(primaryFeesDetail),
            enrolDate: selectedDate
        }).then(result => {
            console.log(result);
            courseDetails.classDetail.tuitionFeeList[0].parentProratedAmount = result.parentProratedAmount;
            console.log('courseDetails', courseDetails);
            this.setSaveEvent(courseDetails);
        }).catch(err => {
            console.log('Error while getting prorated ', err);
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
        } else if (this.btnName == 'Save') {
            console.log('save');
            if (this.validateEnrollmentAndNotes()) {
                // console.log('this.enrollmentSrtDt',this.enrollmentSrtDt);
                console.log(this.template.querySelector('.enroll-date').value);
                console.log(this.template.querySelector('.notes-cls').value);
                let courseDetails = {};
                // courseDetails.tuitionFeeList = [this.anotherFeesData];
                // courseDetails.secondaryFeeList = this.selectedFessData.second;
                // courseDetails.depositfeelist = this.selectedFessData.deposit;            
                courseDetails.classDetail = this.selectedClassSessionData;
                courseDetails.classDetail.location = this.locationName;
                courseDetails.classDetail.classSessionId = this.selectedClassSessionId;
                courseDetails.classDetail.tuitionFeeList = [this.anotherFeesData];
                courseDetails.classDetail.secondaryFeeList = this.selectedFessData.second;
                courseDetails.classDetail.depositfeelist = this.selectedFessData.deposit;

                courseDetails.enrollmentStartDate = this.template.querySelector('.enroll-date').value;
                courseDetails.comments = this.template.querySelector('.notes-cls').value ?? '';
                if (courseDetails.classDetail.tuitionFeeList[0].prorate == true) {
                    //courseDetails.classDetail.tuitionFeeList[0].parentProratedAmount = ;
                    this.fetchProrate(courseDetails);
                    //this.selectedClassSessionId,  courseDetails.enrollmentStartDate, courseDetails.classDetail.tuitionFeeList
                    //courseDetails.classDetail.tuitionFeeList[0].proratePrice = '';

                } else {
                    courseDetails.classDetail.tuitionFeeList[0].parentProratedAmount = courseDetails.classDetail.tuitionFeeList[0].parentAmount;
                    this.setSaveEvent(courseDetails);
                }
                console.log('courseDetails', courseDetails);

                // this.selectedFessData.second = [];
                // this.selectedFessData.deposit = [];
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
            if (this.selectedClassSessionId != event.currentTarget.dataset.id) {
                if (this.mode == 'edit') {
                    this.isChanged = true;
                    this.enrollmentSrtDt = new Date().toISOString();;
                    this.comment = '';
                }
                this.selectedClassSessionId = event.currentTarget.dataset.id;
            }
            this.selectedClassSessionData = {
                classId: event.currentTarget.dataset.clsid,
                locationId: event.currentTarget.dataset.locationid,
                teacherId: event.currentTarget.dataset.teacherid,
                teacherName: event.currentTarget.dataset.teachername,
                className: event.currentTarget.dataset.class,
                courseName: event.currentTarget.dataset.course,
                dayOfWeek: event.currentTarget.dataset.day,
                startTime: event.currentTarget.dataset.srttime,
                endTime: event.currentTarget.dataset.endtime,
                clsFrequency: event.currentTarget.dataset.clsfrequency,
                clsType: event.currentTarget.dataset.clstype,
                courseId: this.courseId
            };
        } else {
            this.selectedClassSessionId = '';
            this.selectedClassSessionData = [];
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
        this.collectFeesDetails();
        return true;
    }

    validateEnrollmentAndNotes() {
        const allValid = [...this.template.querySelectorAll('.req-fld')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {
            return true;
        } else {
            return false;
        }

    }

    // handleEnrollmentDate = (evt) => this.enrollmentSrtDt = evt.currentTarget.value; 

    collectFeesDetails() {
        this.selectedFessData = {};
        let feesChildIds = [];
        let depositId = [];
        if (this.template.querySelectorAll(".secondary-fees")) {
            this.template.querySelectorAll(".secondary-fees").forEach(ele => {
                if (ele.checked == true) {
                    feesChildIds.push(ele.dataset.id);
                }
            })
        }

        if (this.template.querySelectorAll(".deposit-fees")) {
            this.template.querySelectorAll(".deposit-fees").forEach(ele => {
                if (ele.checked == true) {
                    // feesChildIds.push(ele.dataset.id);
                    depositId.push(ele.dataset.id);
                }
            });
        }
        console.log(feesChildIds);
        //this.selectedFessData.push(this.anotherFeesData);
        //console.log( 'this.selectedFessData,',this.selectedFessData);
        this.selectedFessData.primary = [this.anotherFeesData];
        if (feesChildIds.length > 0) {
            this.selectedFessData.second = [];
            //this.selectedFessData.deposit = [];
            this.anotherFeesData.childFeeWrapper.forEach(ele => {
                console.log('ele.feeId ', ele.feeId);
                if (feesChildIds.includes(ele.feeId)) {
                    console.log('inside');
                    if (ele.feeType == "Other Fee") {
                        this.selectedFessData.second.push(ele);
                    } //else {
                    //  this.selectedFessData.deposit.push(ele);
                    // }
                }
            });
            if (this.selectedFessData.second.length == 0) {
                this.selectedFessData.second = undefined;
            } //else if (this.selectedFessData.deposit.length == 0) {
            //this.selectedFessData.deposit = undefined;
            //}
        }
        if (depositId.length > 0) {
            this.selectedFessData.deposit = [];
            this.depositFeesData.forEach(ele => {
                if (depositId.includes(ele.parentFeeId)) {
                    this.selectedFessData.deposit.push(ele);
                }
            });
            if (this.selectedFessData.deposit.length == 0) {
                this.selectedFessData.deposit = undefined;
            }
        }
        console.log(this.selectedFessData);
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
        //let { index } = evt.currentTarget.dataset;
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
        //console.log(index);
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
        // this.depositFeesData = [];
        this.showAnotherFees = false;
        this.showSecondayFees = false;
        // this.showDepositFees = false;

        this.anotherFeesData = this.feesData.find(ele => ele.parentFeeId == (event.currentTarget.dataset.id));
        console.log(this.anotherFeesData.childFeeWrapper);

        if (this.anotherFeesData.childFeeWrapper.length > 0) {
            this.anotherFeesData.childFeeWrapper.forEach(ele => {
                if (ele.feeType == "Other Fee") {
                    this.secondayFeesData.push(ele);
                    this.showSecondayFees = true;
                }// else {
                //     this.depositFeesData.push(ele);
                //     this.showDepositFees = true;
                // }
            });
            this.showAnotherFees = true;
        }
        console.log('this.showSecondayFees', this.showSecondayFees);
        //this.secondayFeesData = ;
        //this.showSecondayFees = true;

    }

    setSaveEvent(courseDetails) {
        this.dispatchEvent(new CustomEvent('savemodal', { detail: { relatedCourseDetails: courseDetails, index: this.index } }));
    }
}
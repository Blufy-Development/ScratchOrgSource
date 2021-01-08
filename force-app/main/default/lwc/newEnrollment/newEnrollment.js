import { LightningElement, track, wire,api } from "lwc";
import doSaveEnrollmentApex from "@salesforce/apex/NewEnrollmentFormCntrl.doSaveEnrollmentApex";
import getSlcdAccDetailFromApex from "@salesforce/apex/NewEnrollmentFormCntrl.getchSlcdAccDetails";
import getPicklistValues from "@salesforce/apex/NewEnrollmentFormCntrl.getPicklistValues";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import findRecords from "@salesforce/apex/AutoCompleteCmpController.findRecords";
//import jquery_date_picker from "@salesforce/resourceUrl/jquery_date_picker";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";

export default class NewEnrollmentForm extends NavigationMixin(LightningElement) {
  @track genderList = [];
  @track payModeList = [];
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
  @track paymentAmount = 0.0;
  @track paymentRefNumber = "";
  @track paymentComments = "";
  @track paymentMode = '';
  @track toggleSpinner = false;

  urlStateParameters = null;
  sessionId;
  @track classSessionId;
  objectApiName = "Account";
  fieldName = "educato__Gender__c";
  stuClsWrapperList;
  globalDisList;
  gstAmount = 0;
  showCourseAndClassModal = false;
  showAddClassAndCourseModal = false;
  //paymentType = "ACH";
 // showAchPayment = true;
 // showOfflinePayment = false;
  //showCardPayment = false;
 discountList = [{}];
 // achRelatedDetails = [{}];
  //cardDetail = [{}];

  @wire(CurrentPageReference)
  getStateParamters(currentPageReference) {
    if (currentPageReference) {
      this.urlStateParameters = currentPageReference.state;
      console.log('this.urlStateParameters', this.urlStateParameters);
      if (this.urlStateParameters.educato__sessId) {
        this.sessionId = this.urlStateParameters.educato__sessId;
        console.log('this.sessionId', this.sessionId);
      }
      if (this.urlStateParameters.educato__classSessionId) {
        this.classSessionId = this.urlStateParameters.educato__classSessionId;
        console.log('this.classSessionId', this.classSessionId);
      }
    }
  }

  get relationshipoptions() {
    return [
      { label: "Parent", value: "Parent" },
      { label: "Guardian", value: "Guardian" }
    ];
  }

  get paymentOptions() {
    return [
      { label: "ACH", value: "ACH" },
      { label: "Offline", value: "Offline" },
      { label: "Card", value: "Card" }
    ];
  }

  @wire(getPicklistValues, {
    ObjectApi_name: "$objectApiName",
    Field_name: "$fieldName"
  })

  genderValues({ error, data }) {
    if (data) {
      console.log("Data", data);
      data.forEach((ele) => {
        this.genderList.push({ label: ele, value: ele });
      });
      this.genderList = JSON.parse(JSON.stringify(this.genderList));
      console.log(this.genderList);
    } else if (error) {
      console.error("Error:", error);
    }
  }

  @wire(getPicklistValues, {
    ObjectApi_name: "educato__Payment__c",
    Field_name: "educato__Payment_Mode__c"
  })

  paymentModeValues({ error, data }) {
    if (data) {
      console.log("Data", data);
      data.forEach((ele) => {
        this.payModeList.push({ label: ele, value: ele });
      });
      this.payModeList = JSON.parse(JSON.stringify(this.payModeList));
      console.log(this.payModeList);
    } else if (error) {
      console.error("Error:", error);
    }
  }

  handleOnSelect(event) {
    let slectedRecord = event.detail;
    //alert(JSON.stringify(slectedRecord))
    if (
      slectedRecord.type == "PrimaryCorpContact" &&
      slectedRecord.recordId != ""
    ) {
      getSlcdAccDetailFromApex({
        accId: slectedRecord.recordId,
        isCorporateAccount: this.isCorporateAccount
      })
        .then((res) => {
          let contactDetail = JSON.parse(JSON.stringify(res));
          this.contactDetail.Name = contactDetail.Name;
          this.contactDetail.Id = contactDetail.Id;
        })
        .catch((error) => {
          console.log("error while getting records", error);
        });
    } else if (
      slectedRecord.type == "PrimaryCorpContact" &&
      slectedRecord.recordId == ""
    ) {
      this.contactDetail = {};
    }

    if (slectedRecord.type == "PrimaryCustContact" && slectedRecord.recordId != "") {
      getSlcdAccDetailFromApex({
        accId: slectedRecord.recordId,
        isCorporateAccount: this.isCorporateAccount
      })
        .then((res) => {
          let contactDetail = JSON.parse(JSON.stringify(res));
          console.log("ddd", contactDetail);
          if (!this.isCorporateAccount) {
            this.contactDetail.FirstName = contactDetail.FirstName;
            this.contactDetail.LastName = contactDetail.LastName;
            this.contactDetail.PersonEmail = contactDetail.PersonEmail;
            this.contactDetail.PersonMobilePhone = contactDetail.PersonMobilePhone;
            this.contactDetail.educato__Relationship_With_Student__c =
              contactDetail.educato__Relationship_With_Student__c;
            this.contactDetail.educato__Gender__c =
              contactDetail.educato__Gender__c;
            this.contactDetail.Id = contactDetail.Id;
            this.contactDetail.PersonMailingCountryCode =
              contactDetail.PersonMailingCountryCode;
            this.contactDetail.PersonMailingStateCode =
              contactDetail.PersonMailingStateCode;
            this.contactDetail.PersonMailingPostalCode =
              contactDetail.PersonMailingPostalCode;
            this.contactDetail.PersonMailingCity =
              contactDetail.PersonMailingCity;
            this.addressLine1 = contactDetail.PersonMailingStreet.split(
              "\r\n"
            )[0];
            this.addressLine2 = contactDetail.PersonMailingStreet.split(
              "\r\n"
            )[1];
          } else {
            this.contactDetail.Name = contactDetail.Name;
            this.contactDetail.Id = contactDetail.Id;
          }
        })
        .catch((error) => {
          console.log("error while getting records", error);
        });
    } else if (
      slectedRecord.type == "PrimaryCustContact" &&
      slectedRecord.recordId == ""
    ) {
      this.contactDetail = {};
      this.addressLine1 = "";
      this.addressLine2 = "";
    }

    if (
      slectedRecord.type == "SecondaryCustContact" &&
      slectedRecord.recordId != ""
    ) {
      getSlcdAccDetailFromApex({
        accId: slectedRecord.recordId,
        isCorporateAccount: this.isCorporateAccount
      })
        .then((res) => {
          let secondaryContactDetail = JSON.parse(JSON.stringify(res));
          console.log('hhh-->', secondaryContactDetail)
          this.secondaryContactDetail.Id = secondaryContactDetail.Id;
          this.secondaryContactDetail.FirstName =
            secondaryContactDetail.FirstName;
          this.secondaryContactDetail.LastName =
            secondaryContactDetail.LastName;
          this.secondaryContactDetail.PersonEmail =
            secondaryContactDetail.PersonEmail;
          this.secondaryContactDetail.PersonMobilePhone = secondaryContactDetail.PersonMobilePhone;
          this.secondaryContactDetail.educato__Relationship_With_Student__c =
            secondaryContactDetail.educato__Relationship_With_Student__c;
          this.secondaryContactDetail.educato__Gender__c =
            secondaryContactDetail.educato__Gender__c;
          console.log('hhh-->', this.secondaryContactDetail)
        })
        .catch((error) => {
          console.log("error while getting records", error);
        });
    } else if (
      slectedRecord.type == "SecondaryCustContact" &&
      slectedRecord.recordId == ""
    ) {
      this.secondaryContactDetail = {};
    }
  }

  addNewName(evt) {
    let { value } = evt.detail;
    console.log(value);
    if (evt.detail.type == 'PrimaryCustContact' && value != "") {
      console.log("firstname", value);
      this.contactDetail.FirstName = value;
    }
    if (evt.detail.type == 'PrimaryCorpContact' && value != "") {
      console.log("name", value);
      this.contactDetail.Name = value;
    }
    if (evt.detail.type == 'SecondaryCustContact' && value != "") {
      console.log("secondaryfirstname", value);
      this.secondaryContactDetail.FirstName = value;
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

  handleAddressUserInput(event) {
    let { name, value } = event.currentTarget;
    this.contactDetail[name] = value;
  }

  handleAddressLinesUserInput(event) {
    if (event.target.name === 'AddressLine1')
      this.addressLine1 = event.target.value;

    if (event.target.name === 'AddressLine2')
      this.addressLine2 = event.target.value;
  }

  handlePaymentDetailsUserInput(event) {
    if (event.target.name === 'PaymentRefNumber')
      this.paymentRefNumber = event.target.value;

    if (event.target.name === 'PaymentMode')
      this.paymentMode = event.target.value;

    if (event.target.name === 'PaymentComments')
      this.paymentComments = event.target.value;
  }

  handleSelectedCountryState(event) {
    console.log('countrystate-->', event.detail);
    this.contactDetail.PersonMailingCountryCode = event.detail.selectedCountry;
    this.contactDetail.PersonMailingStateCode = event.detail.selectedState;
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
    console.log("Enrollment", event.detail);
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
    this.paymentAmount = this.grandTotal;
    console.log("enrol Total Amount", this.enrolTotalAmt);
    console.log("gst Amount", this.gstAmt);
    console.log("grand total", this.grandTotal);
    console.log("Student Details-->", this.studetnDetailsArr);
  }

  saveEnrolments(event) {
    console.log("this.contactDetail", this.contactDetail);
   // console.log("this.cardDetail", this.cardDetail);
    if (this.validateForm() == true) {
      this.toggleSpinner = true;
      this.contactDetail.PersonMailingStreet = this.addressLine1 + '\r\n' + this.addressLine2;
      console.log("this.contactDetail", this.contactDetail);
      doSaveEnrollmentApex({
        studentDetails: JSON.stringify(this.studetnDetailsArr),
        parentDetail: JSON.stringify(this.contactDetail),
        secondaryDetail: JSON.stringify(this.secondaryContactDetail),
        btnLabel: event.target.label,
        grandTotal: this.paymentAmount,
        paymentRefNumber: this.paymentRefNumber,
        paymentComments: this.paymentComments,
        paymentMode: this.paymentMode,
        discountList: JSON.stringify(this.discountList)
      })
        .then((res) => {
          console.log("res-->", res);
          if (res.includes("SUCCESS")) {
            this.showNotification(
              "Success",
              "Enrollment has been created successfully",
              "success"
            );
            this.toggleSpinner = false;
            this[NavigationMixin.Navigate]({
              type: "standard__recordPage",
              attributes: {
                recordId: res.split("#")[1],
                objectApiName: "Enrollment__c",
                actionName: "view"
              }
            });
          } else {
            this.toggleSpinner = false;
            this.showNotification("Error", res, "error");
          }
        })
        .catch((error) => {
          this.toggleSpinner = false;
          this.showNotification("Error", error.message, "error");

          console.log("error while getting records", error);
          console.log("error while getting records", error.body.message);
          console.log("save enrollment");
        });
    }
  }

  validateForm = () => {
    let allValid = [...this.template.querySelectorAll(".req")].reduce(
      (validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      },
      true
    );

    if (allValid) {
      console.log("all valid");
      return true;
    }
   /* if (this.showAchPayment) {
      let bankData = this.template
        .querySelector("c-stripe-a-c-h-verification")
        .sendDetails();
      console.log("json", bankData);
      if (allValid && bankData.length > 0) {
        console.log("all valid");
        this.achRelatedDetails = bankData;
        return true;
      }
    }else if (this.showCardPayment) {
      let cardDetail = this.template
        .querySelector("c-stripe-card-creation")
        .sendDetails();
      console.log("json card", cardDetail);
      if (allValid && cardDetail.length > 0) {
        console.log("all valid");
        this.cardDetail = cardDetail;
        return true;
      }
    }
     else {
      if (allValid) {
        console.log("all valid");
        return true;
      }
    }*/

    this.showNotification("Error", "Please fill the details", "error");
    return false;
    // let bankData = [];
    // bankData = this.template.querySelector("c-stripe-a-c-h-verification").sendDetails();
    // console.log('save enrollment');
    // console.log('json', bankData);
  };

  showNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  /*handlePaymentChange(event) {
    this.paymentType = event.detail.value;
    if (this.paymentType == "ACH") {
      this.showAchPayment = true;
      this.showOfflinePayment = false;
      this.showCardPayment = false;
    } else if(this.paymentType == "Offline") {
      this.showOfflinePayment = true;
      this.showCardPayment = false;
      this.showAchPayment = false;
    }else if(this.paymentType == "Card"){
      this.showCardPayment = true;
      this.showAchPayment = false;
      this.showOfflinePayment = false;
    }
  }*/

  handleSaveDiscountModal(event) {
    console.log('discount event--->', event.detail);
    this.discountList = event.detail.selectedData;
    this.paymentAmount = event.detail.grandTotal;
  }
}
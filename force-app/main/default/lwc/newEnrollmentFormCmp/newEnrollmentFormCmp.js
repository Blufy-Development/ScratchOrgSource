import { LightningElement, track ,wire} from 'lwc';
import getSlcdAccDetailFromApex from '@salesforce/apex/NewEnrollmentFormCntrl.getchSlcdAccDetails';
import getGender from '@salesforce/apex/NewEnrollmentFormCntrl.getPicklistValues';
export default class NewEnrollmentFormCmp extends LightningElement {
    @track genderList = [];
    objectApiName = 'Account';
    fieldName = 'educato__Gender__c';
    @track secondaryContactDetail = {};
    @track contactDetail = {};
    isCorporateAccount = false;
    stuClsWrapperList;
    globalDisList;
    gstAmount = 0;
    paymentRefNumber;
    toggleSpinner = false;
    showCourseAndClassModal = false;
    showAddClassAndCourseModal = false;
    @track studetnDetailsArr = [{}];

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

    handleOnSelect(event){
        let slectedRecord = event.detail;
        //alert(JSON.stringify(slectedRecord))
        if(slectedRecord.type == 'PrimaryCustContact' && slectedRecord.recordId != ''){
            getSlcdAccDetailFromApex({
                "accId": slectedRecord.recordId,
                "isCorporateAccount": this.isCorporateAccount 
            }).then(res => {
                this.contactDetail = JSON.parse(JSON.stringify(res));
            }).catch(error => {
                console.log('error while getting records', error);
            })
        }
        else if(slectedRecord.type == 'PrimaryCustContact' && slectedRecord.recordId == ''){
            this.contactDetail = {};
        }
    
        if(slectedRecord.type == 'SecondaryCustContact' && slectedRecord.recordId != ''){
            getSlcdAccDetailFromApex({
                "accId": slectedRecord.recordId,
                "isCorporateAccount": this.isCorporateAccount 
            }).then(res => {
                this.secondaryContactDetail = JSON.parse(JSON.stringify(res));
            }).catch(error => {
                console.log('error while getting records', error);
            })
        }
        else if(slectedRecord.type == 'SecondaryCustContact' && slectedRecord.recordId == ''){
            this.secondaryContactDetail = {};
        }
    }

    addStudent(){
        console.log('call');
        alert(this.studetnDetailsArr.length)
        this.studetnDetailsArr.push({});
        console.log('this.studetnDetailsArr', this.studetnDetailsArr);
    }

    removeRow(event) {// method to remove particular row
        console.log('this.rows.length ', event.detail);
        //let removeIds = '';
        let rowReplica = Object.assign([], this.studetnDetailsArr);
        //if (tempRows[event.detail].Id) {
        //  removeIds = tempRows[event.detail].Id;
        //}
        console.log('rowReplica', rowReplica)
        rowReplica.splice(event.detail, 1);
        setTimeout(function (self) {
            self.studetnDetailsArr = JSON.parse(JSON.stringify(rowReplica));
            // console.log('**** ');
            // console.log(JSON.stringify(self.rows));
            if (self.studetnDetailsArr.length === 0) {
                self.addStudent();
            }
        }, 500, this);
    }

    handleAccountChange() {
        this.isCorporateAccount = !this.isCorporateAccount;
    }
    handleClassAndCourseModal() {
        this.showAddClassAndCourseModal = !this.showAddClassAndCourseModal;
    }
}
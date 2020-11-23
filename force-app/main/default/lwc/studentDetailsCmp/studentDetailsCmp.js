import { LightningElement, track, api, wire } from 'lwc';
import getGender from '@salesforce/apex/NewEnrollmentFormCntrl.getPicklistValues';
import getSlcdAccDetailFromApex from '@salesforce/apex/NewEnrollmentFormCntrl.getchSlcdAccDetails';
export default class StudentDetailsCmp extends LightningElement {

    @track genderList = [];
    objectApiName = 'Account';
    fieldName = 'educato__Gender__c';
    @track studentDetail;
    rowIndex = 0;
    
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

    @api studetnDetailsArr = [{}];
    /*get studetnDetailsArr(){
        this.rowIndex = 0;
        return this.studentDetail;
    }
    set studetnDetailsArr(value){            
        this.studentDetail = value;
    }

    get index(){
        return this.rowIndex +=1;
    }*/

    handleOnSelectStudent(event){
        let slectedRecord = event.detail;
        alert(JSON.stringify(this.studetnDetailsArr))
        //alert(JSON.stringify(this.studetnDetailsArr[slectedRecord.studentindex].studentdetail))
        if(slectedRecord.type == 'Student' && slectedRecord.recordId != ''){
            getSlcdAccDetailFromApex({
                "accId": slectedRecord.recordId,
                "isCorporateAccount": false 
            }).then(res => {
                alert(JSON.stringify(res))
                this.studetnDetailsArr[slectedRecord.studentindex].studentdetail = JSON.parse(JSON.stringify(res));
                alert(this.studetnDetailsArr[slectedRecord.studentindex].studentdetail)
            }).catch(error => {
                console.log('error while getting records', error);
            })
        }
        else if(slectedRecord.type == 'Student' && slectedRecord.recordId == ''){
            this.studetnDetailsArr[slectedRecord.studentindex].studentdetail = {};
        }

    }

    removeRow(event){
        console.log(event.currentTarget.dataset.index);
        this.dispatchEvent(new CustomEvent("remove", {
            detail: event.currentTarget.dataset.index
        }));
    }
}
import { LightningElement, api, wire } from 'lwc';
import fetchDiscount from '@salesforce/apex/NewEnrollmentFormCntrl.fetchAllDiscount';
import defaultCurrency from '@salesforce/label/c.Default_Currency';
export default class AdditionalDiscountModal extends LightningElement {
    @api preSelectedDiscount;    
    @api courseId = '';
    discountData;
    label = {
        defaultCurrency
    }
    // globalDiscount;
    // courseDiscount;
    selectedDiscountData = [];
    @wire(fetchDiscount, { courseId: '$courseId' })
    wiredDiscount({ error, data }) {
        if (data) {
            console.log('data', data);
            this.discountData = JSON.parse(JSON.stringify(data));
            if (this.preSelectedDiscount) {
                this.discountData.forEach(index => {
                    let discountObj = this.preSelectedDiscount.find(ele => ele.disId == index.disId);
                    if (discountObj) {
                        index.isSelected = true;
                        index.userId = discountObj.userId;
                        index.amount = discountObj.amount;
                    }
                });
                console.log('this.discountData', this.discountData);
            }
            // this.globalDiscount = [];
            //this.courseDiscount = [];
            // this.discountData.forEach(ele => {
            // if (ele.isGlobal) {
            // this.globalDiscount.push(ele);
            // console.log('global', ele.disId);
            // }// } else if (!ele.isGlobal) {
            //     this.courseDiscount.push(ele);
            //     console.log('course', ele.disId);
            // }
            // });
            // if (this.globalDiscount.length == 0) {
            // this.globalDiscount = undefined;
            // }// } else if (this.courseDiscount.length == 0) {
            //     this.courseDiscount = undefined;
            // }
        } else if (error) {
            console.log('Error while getting discount ', error);
        }
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closediscountmodal'));
    }

    saveDiscountModal() {
        let selectedDiscountIds = [];
        this.selectedDiscountData = [];
        console.log('calling');
        console.log(this.template.querySelectorAll('.discountChkbx'));
        this.template.querySelectorAll('.discountChkbx').forEach(element => {
            console.log(element);
            if (element.checked == true) {
                selectedDiscountIds.push(element.dataset.id);
            }
        });
        console.log(selectedDiscountIds);
        this.discountData.forEach(ele => {
            if (selectedDiscountIds.includes(ele.disId)) {
                this.selectedDiscountData.push(ele);
            }
        });
        console.log('this.selectedDiscountData', this.selectedDiscountData);
        const event = new CustomEvent('savediscount', {
            detail: {
                selectedData: this.selectedDiscountData
            }
        });
        this.dispatchEvent(event);
    }

    handleOnSelect(evt) {
        console.log(evt.detail);
        this.discountData[evt.detail.index].userId = evt.detail.recordId;
        console.log(this.discountData);
    }

    handleAmount(event) {
        let { index } = event.currentTarget.dataset;
        // if (name == 'global') {
        this.discountData[index].amount = event.currentTarget.value;
        // }// } else {
        //     this.courseDiscount[index].amount = event.currentTarget.value;
        // }

    }
}
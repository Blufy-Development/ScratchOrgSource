import { LightningElement, api } from 'lwc';
import gstLabel from '@salesforce/label/c.GST_Rate';
import defaultCurrency from '@salesforce/label/c.Default_Currency';
export default class AdditionalDiscount extends LightningElement {
    @api isGstApplicable = false;
    totalFeesAmount = 0;
    label = {
        gstLabel,
        defaultCurrency
    }
    showDiscountModal = false;
    selectedDiscounts;
    discountTotal = 0;
    @api gstAmount = 0;
    @api grandTotal = 0;
    @api get feeAmount() {
        return this.totalFeesAmount;
    }

    set feeAmount(value) {
        this.totalFeesAmount = value;
        this.calculateTotalAmount();
    }

    toggleDiscountModal() {
        console.log('open');
        this.showDiscountModal = !this.showDiscountModal;
    }

    handleSaveDiscountModal(event) {
        console.log('discount event', event.detail.selectedData.length);
        this.discountTotal = 0;
        if (event.detail.selectedData.length > 0) {
            this.selectedDiscounts = event.detail.selectedData;
            this.selectedDiscounts.forEach(element => {
                this.discountTotal += parseInt(element.amount);
            });
            this.calculateTotalAmount();
        } else {
            this.selectedDiscounts = undefined;
            this.grandTotal = 0;
        }
        this.toggleDiscountModal();
    }

    calculateTotalAmount() {
        console.log('this.totalFeesAmount', this.totalFeesAmount);
        console.log('this.grandTotal', this.grandTotal);
        console.log('this.gstAmount', this.gstAmount);
        console.log('discountTotal', this.discountTotal);
        // if (this.gstAmount != 0) {
        //     //let gstPrect = parseInt(label.gstLabel);
        //     // this.gstAmount = (this.totalFeesAmount * gstPrect / 100);
        //     this.grandTotal = this.totalFeesAmount + this.gstAmount;
        // } else {
        this.grandTotal = this.totalFeesAmount;
        // }

        this.grandTotal -= this.discountTotal;
    }
    // var gstPrcnt = parseInt($A.get("{!$Label.c.GST_Rate}"));
    // // var tempAmt = grandTot-totDepFee; 
    // // alert(gstAppFeeAmount);
    // var tempAmt = (gstAppFeeAmount*gstPrcnt/100);                            
    // component.set("v.gstAmount", tempAmt); 
}
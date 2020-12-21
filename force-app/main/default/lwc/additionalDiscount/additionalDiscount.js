import { LightningElement, api } from 'lwc';
import gstLabel from '@salesforce/label/c.GST_Rate';
import LOCALE_CURRENCY from "@salesforce/i18n/currency";
import getBlufyConfigDetailsApex from "@salesforce/apex/NewEnrollmentFormCntrl.getBlufyConfigDetails";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AdditionalDiscount extends LightningElement {
    @api isGstApplicable = false;
    totalFeesAmount = 0;
    totalGSTAmount = 0;
    label = {
        gstLabel,
        LOCALE_CURRENCY
    }
    showDiscountModal = false;
    selectedDiscounts;
    discountTotal = 0;
    grandTotalToReset;
    gstAmountToReset;
    GSTApplicableByBlufyConfig = false;
    GSTRateByBlufyConfig = 0.0;
    @api feeGSTAmount = 0;
    @api grandTotal = 0;
    @api get feeAmount() {
        return this.totalFeesAmount;
    }
    set feeAmount(value) {
        this.totalFeesAmount = value;
        this.calculateTotalAmount();
    }

    @api get gstAmount() {
        return this.totalGSTAmount;
    }
    set gstAmount(value) {
        this.totalGSTAmount = value;
        this.calculateTotalAmount();
    }

    connectedCallback(){
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

    toggleDiscountModal() {
        console.log('open');
        if(this.feeAmount > 0){
            this.showDiscountModal = !this.showDiscountModal;
        }else{
            this.showNotification('Error', 'Please add a course to this enrollment.', 'error');
        }
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleSaveDiscountModal(event) {
        console.log('discount event', event.detail.selectedData.length);
        console.log('ttttt-->'+this.gstAmountToReset);
        console.log('dsdd-->'+this.grandTotalToReset)
        this.discountTotal = 0;
        if (event.detail.selectedData.length > 0) {
            this.selectedDiscounts = event.detail.selectedData;
            this.selectedDiscounts.forEach(element => {
                this.discountTotal += parseInt(element.amount);
            });
            this.calculateTotalAmount();
        } else {
            this.selectedDiscounts = undefined;
            this.grandTotal = this.grandTotalToReset;
            this.gstAmount = this.gstAmountToReset;
        }
        this.toggleDiscountModal();
        const customevent = new CustomEvent('savediscountdetails', {
            detail: {
                selectedData: this.selectedDiscounts,grandTotal : this.grandTotal
            }
        });
        this.dispatchEvent(customevent);
    }

    calculateTotalAmount() {
        console.log('this.totalFeesAmount', this.totalFeesAmount);
        console.log('this.grandTotal', this.grandTotal);
        console.log('this.gstAmount', this.gstAmount);
        console.log('discountTotal', this.discountTotal);

        this.grandTotal = this.totalFeesAmount;
        this.feeGSTAmount = this.gstAmount;
        this.grandTotalToReset = this.grandTotal;
        this.gstAmountToReset = this.feeGSTAmount;
        this.grandTotal -= this.discountTotal;

        if (this.GSTApplicableByBlufyConfig && this.GSTRateByBlufyConfig > 0){
            let gstAmount = (this.discountTotal * this.GSTRateByBlufyConfig / 100);
            this.feeGSTAmount -= gstAmount
            this.grandTotal -= gstAmount;
        }
    } 
}
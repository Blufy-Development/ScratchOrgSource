import { LightningElement, api, track } from 'lwc';

export default class CreateRecordsNewStripePaymentMode extends LightningElement {
    @api paymentMode;
    @track isACH;
    constructor(){
        super();
        if(this.paymentMode == 'ACH')
            this.isACH = true;
        else
            this.isACH = false;
    }
}
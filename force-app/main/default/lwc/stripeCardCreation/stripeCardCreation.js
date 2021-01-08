import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class StripeCardCreation extends LightningElement {
    @api sendDetails(){
        let cardNumber = this.template.querySelector("[data-id=cardNumber]").value;
        let cardExpMonth = this.template.querySelector("[data-id=cardExpMonth]").value;
        let cardExpYear = this.template.querySelector("[data-id=cardExpYear]").value;
        let cardCVC = this.template.querySelector("[data-id=cardCVC]").value;
        if(this.checkValidation()){
            let cardDetails =[];
            cardDetails.push({
                CardNumber : cardNumber,
                ExpMonth: cardExpMonth,
                ExpYear: cardExpYear,
                CVCNumber: cardCVC,
            });
            console.log(cardDetails);
            return cardDetails;
        }
        else{
            return null;
        }
    }
    validateInput(){
        console.log('validation');
        let cardNumber = this.template.querySelector("[data-id=cardNumber]");
        let cardExpMonth = this.template.querySelector("[data-id=cardExpMonth]");
        let cardExpYear = this.template.querySelector("[data-id=cardExpYear]");
        let cardCVC = this.template.querySelector("[data-id=cardCVC]");
        let todaydate = new Date();
        let n = todaydate.getFullYear().toString();
        let year = n.substring(n.length - 2, n.length);
        console.log('querySelecotr ran all');
        let isReturnValue = true;
        console.log();
        if(cardNumber.value == '' || cardNumber.value == null || !(/^[0-9]+$/.test(cardNumber.value)) || cardNumber.value.length != 16){
            console.log('first if');
            cardNumber.setCustomValidity('Invalid Card Number');
            cardNumber.reportValidity();
            this.isReturnValue = false;
        }
        else{
            cardNumber.setCustomValidity('');
            cardNumber.reportValidity();
        }
        if(cardExpMonth.value == '' || cardExpMonth.value == null || cardExpMonth.value.length <= 0 || parseInt(cardExpMonth.value) > 12 || parseInt(cardExpMonth.value) <=0 ){
            cardExpMonth.setCustomValidity('Invalid Expiry Month');
            cardExpMonth.reportValidity();
            this.isReturnValue = false;
        }
        else{
            cardExpMonth.setCustomValidity('');
            cardExpMonth.reportValidity();
        }
        if(cardExpYear.value == '' || cardExpYear.value == null || cardExpYear.value.length <= 0  || cardExpYear.value > 99 || cardExpYear.value <=0){
            cardExpYear.setCustomValidity('Invalid Expiry Year');
            cardExpYear.reportValidity();
            this.isReturnValue = false;
        }
        else{
            cardExpYear.setCustomValidity('');
            cardExpYear.reportValidity();
        }
        if((parseInt(cardExpMonth.value)<=parseInt(todaydate.getMonth()+1) && parseInt(cardExpYear.value) <= parseInt(year))){
            cardExpMonth.setCustomValidity('Invalid Expiry Month');
            cardExpMonth.reportValidity();
            cardExpYear.setCustomValidity('Invalid Expiry Year');
            cardExpYear.reportValidity();
            this.isReturnValue = false;
        }
        else if(this.isReturnValue == true){
            cardExpYear.setCustomValidity('');
            cardExpYear.reportValidity();
            cardExpMonth.setCustomValidity('');
            cardExpMonth.reportValidity();
        }
        if(cardCVC.value == '' || cardCVC.value == null || cardCVC.value.length <= 0 || cardCVC.value < 99 || cardCVC.value > 999 || !(/^[0-9]+$/.test(cardCVC.value))){
            cardCVC.setCustomValidity('Invalid CVC Number');
            cardCVC.reportValidity();
            this.isReturnValue = false;
        }
        else{
            cardCVC.setCustomValidity('');
            cardCVC.reportValidity();
        }
        if(this.isReturnValue == true){
            
            // cardNumber.setCustomValidity('');
            // cardNumber.reportValidity();
            // cardExpMonth.setCustomValidity('');
            // cardExpMonth.reportValidity();
            // cardExpYear.setCustomValidity('');
            // cardExpYear.reportValidity();
            // cardCVC.setCustomValidity('');
            // cardCVC.reportValidity();
            return true;
        }
        else{
            return false;
        }

    }
    checkValidation(){
        this.validateInput();
        let allValid = [...this.template.querySelectorAll('.req')]
                .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
            if (allValid) {
                console.log('all valid');
                return true;
            }
            return false;
    }
    handleSubmit(event){
        console.log('handleSubmit');
    }
    // showNotification(variants, titles, messages) {
    //     console.log('showNotification called');
    //     const evt = new ShowToastEvent({
    //         title: titles,
    //         message: messages,
    //         variant: variants,
    //     });
    //     console.log(evt);
    //     this.dispatchEvent(evt);
    // }
}
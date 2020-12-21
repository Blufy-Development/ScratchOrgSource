import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class StripeCardCreationComponent extends LightningElement {
    @api sendDetails(){
        let cardNumber = this.template.querySelector("[data-id=cardNumber]").value;
        let cardExpMonth = this.template.querySelector("[data-id=cardExpMonth]").value;
        let cardExpYear = this.template.querySelector("[data-id=cardExpYear]").value;
        let cardCVC = this.template.querySelector("[data-id=cardCVC]").value;
        if(checkValidation()){
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
    checkValidation(){
        console.log('checkValidation');
        let cardNumber = this.template.querySelector("[data-id=cardNumber]").value;
        let cardExpMonth = this.template.querySelector("[data-id=cardExpMonth]").value;
        let cardExpYear = this.template.querySelector("[data-id=cardExpYear]").value;
        let cardCVC = this.template.querySelector("[data-id=cardCVC]").value;
        
        console.log('querySelecotr ran all');
        
        console.log();
        if(cardNumber == '' || cardNumber == null || !(/^[0-9]+$/.test(cardNumber)) || cardNumber.length != 16){
            console.log('first if');
            this.showNotification('error','Error', 'Invalid Card Number.');
            return false;
        }
        else if(cardExpMonth == '' || cardExpMonth == null || cardExpMonth.length <= 0 || cardExpMonth > 12){
            this.showNotification('error', 'Error', 'Please select a Month');
            return false;
        }
        else if(cardExpYear == '' || cardExpYear == null || cardExpYear.length <= 0  || cardExpYear > 99){
            this.showNotification('error', 'Error', 'Please enter a valid Year.');
            return false;
        }
        else if(cardCVC == '' || cardCVC == null || cardCVC.length <= 0 || cardCVC < 99 || cardCVC > 999){
            this.showNotification('error', 'Error', 'Please enter a valid CVC.');
            return false;
        }
        else{
            this.showNotification('success', 'Success', 'Details are submit for verification.');
            return true;
        }

    }
    handleSubmit(event){
        console.log('handleSubmit');
    }
    showNotification(variants, titles, messages) {
        console.log('showNotification called');
        const evt = new ShowToastEvent({
            title: titles,
            message: messages,
            variant: variants,
        });
        console.log(evt);
        this.dispatchEvent(evt);
    }
}
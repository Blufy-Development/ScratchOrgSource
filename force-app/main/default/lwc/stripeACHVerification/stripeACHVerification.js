import { LightningElement,api } from 'lwc';

export default class StripeACHVerification extends LightningElement {

    get options() {
        return [
            { label: 'Individual', value: 'Individual' },
            { label: 'one', value: 'one' },
            { label: 'two', value: 'two' },
        ];
    }

    @api
    validatefields(){
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

    validateConfirAccNo(){
     console.log('validateConfirAccNo');
     let accNumber =  this.template.querySelector("[data-my-id=AccountNumber]").value;
     let confirmAccNumber =  this.template.querySelector("[data-my-id=ConfirmAccNumber]").value;
     let confirmAccNumberField =  this.template.querySelector("[data-my-id=ConfirmAccNumber]");
     console.log('accNumber',accNumber);
     console.log('accNumber',confirmAccNumber);
     console.log('accNumber',confirmAccNumberField);

     if(confirmAccNumber==''){
        console.log('confirmAccNumber is null');
        confirmAccNumberField.setCustomValidity('Confirm Account Number Cannot be Empty');
        confirmAccNumberField.reportValidity();
     }
     if(accNumber!=confirmAccNumber && confirmAccNumber!='' ){
        console.log('Custome validity');
        confirmAccNumberField.setCustomValidity('Confirm Account Number Did Not Match');
        confirmAccNumberField.reportValidity();
     }

     if(accNumber===confirmAccNumber){
        console.log('Custome validity not');
        confirmAccNumberField.setCustomValidity('');
        confirmAccNumberField.reportValidity();
     }

    }
    @api
    sendDetails(){
        console.log('called sendDetails');
        let bankDetails =[];    
        if( this.validatefields() == true){
            let holderType =  this.template.querySelector("[data-my-id=holderType]").value;
            let holderName =  this.template.querySelector("[data-my-id=holderName]").value;
            let routingNo =  this.template.querySelector("[data-my-id=routingNumber]").value;
            let accNumber =  this.template.querySelector("[data-my-id=AccountNumber]").value;
            let confirmAccNumber =  this.template.querySelector("[data-my-id=ConfirmAccNumber]").value;
          
            if(holderType!='' && holderName!='' &&  routingNo!='' &&  accNumber!='' &&  confirmAccNumber!=''){
               bankDetails.push({
                   HolderType : holderType, 
                   HolderName : holderName,
                   RoutingNo : routingNo,
                   AccountNumber :accNumber,
                   ConfirmAccountNumber : confirmAccNumber
               });
            }
            console.log('bankDetails',bankDetails);
           return bankDetails;
        } 
        return bankDetails
     }
}
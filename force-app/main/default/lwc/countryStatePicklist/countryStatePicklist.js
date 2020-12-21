import { LightningElement, wire, track, api } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';

export default class DependentPickListInLWC extends LightningElement {

    // Reactive variables
    @track controllingValues = [];
    @track dependentValues = [];
    @track isEmpty = false;
    @track error;
    @api selectedCountry;
    @api selectedState;
    controlValues;
    totalDependentValues = [];

    // Account object info
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    // Picklist values based on record type
    @wire(getPicklistValuesByRecordType, { objectApiName: ACCOUNT_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId'})
    countryPicklistValues({error, data}) {
        if(data) {
            this.error = null;
            let countyOptions = [{label:'--None--', value:''}];
            // Account Country Control Field Picklist values
            data.picklistFieldValues.BillingCountryCode.values.forEach(key => {
                countyOptions.push({
                    label : key.label,
                    value: key.value
                })
            });

            this.controllingValues = countyOptions;

            let stateOptions = [{label:'--None--', value:''}];

             // Account State Control Field Picklist values
            this.controlValues = data.picklistFieldValues.BillingStateCode.controllerValues;
            // Account State dependent Field Picklist values
            this.totalDependentValues = data.picklistFieldValues.BillingStateCode.values;

            this.totalDependentValues.forEach(key => {
                stateOptions.push({
                    label : key.label,
                    value: key.value
                })
            });
            this.dependentValues = stateOptions;
        }
        else if(error) {
            this.error = JSON.stringify(error);
        }
    }

    connectedCallback(){
        if(!this.selectedCountry) {
            this.isEmpty = true;
            this.dependentValues = [{label:'--None--', value:''}];
            this.selectedCountry = null;
            this.selectedState = null;
        }
    }
    handleCountryChange(event) {
        // Selected Country Value
        this.selectedCountry = event.target.value;
        this.selectedState = '';
        this.isEmpty = false;
        let dependValues = [];
        if(this.selectedCountry) {
            // if Selected country is none returns nothing
            if(this.selectedCountry === '') {
                this.isEmpty = true;
                dependValues = [{label:'--None--', value:''}];
                this.selectedCountry = null;
                this.selectedState = null;
                this.sendDetails();
                return;
            }

            // filter the total dependent values based on selected country value 
            this.totalDependentValues.forEach(conValues => {
                if(conValues.validFor[0] === this.controlValues[this.selectedCountry]) {
                    dependValues.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            })
            this.dependentValues = dependValues;
            this.sendDetails();
        }
    }

    handleStateChange(event) {
        this.selectedState = event.target.value;
        this.sendDetails();
    }

    sendDetails() {
        this.dispatchEvent(new CustomEvent('sendcountrystate', { detail: { selectedCountry : this.selectedCountry,selectedState : this.selectedState } }));
    }
}
import { LightningElement, track, api } from 'lwc';

export default class AutoCompleteSearchComponent extends LightningElement {
    @api searchKey;
    @track variant;
    @api label;

    connectedCallback() {
        if(this.label.length == 0)
        this.variant = "label-hidden";
    }

    handleChange(event){
        /* eslint-disable no-console */
        //console.log('Search Event Started ');
        const searchKey = event.target.value;
        //alert(searchKey)
        /* eslint-disable no-console */
        event.preventDefault();
        const searchEvent = new CustomEvent(
            'change', 
            { 
                detail : searchKey
            }
        );
        this.dispatchEvent(searchEvent);
    }
}
import { LightningElement, api, track } from 'lwc';

export default class AutoCompleteRecordList extends LightningElement {
    @api record;
    @api fieldname;
    @api iconname;
    @track infoToDisplay;
    @track firstName = '';

    connectedCallback() {
        console.log(this.record)
        if (this.record['educato__Location__r']) {
            this.infoToDisplay = '; ' + this.record['educato__Location__r'].Name;
        }
        //if (this.record['FirstName'])
            //this.firstName = this.record.FirstName;
           // console.log('fnane',this.firstName)
    }

    handleSelect(event) {
        event.preventDefault();
            const selectedRecord = new CustomEvent(
                "select",
                {
                    detail: { recordId: this.record.Id, name: this.record.Name }
                }
            );
            this.dispatchEvent(selectedRecord);
        
        /* eslint-disable no-console */
        //console.log( this.record.Id);
        /* fire the event to be handled on the Parent Component */
        
    }
}
import { LightningElement, track, api } from 'lwc';
import findRecords from '@salesforce/apex/AutoCompleteCmpController.findRecords';

export default class AutoCompleteComponent extends LightningElement {
    @track records;
    @track error;
    @track selectedRecord;
    @track showFirstName = false;
    @track firstName = false;
    @track searchKey = '';
    @api index = -1;
    @api relationshipfield;
    @api iconname = "standard:account";
    @api objectname = 'Account';
    @api searchfield = 'Name';
    @api extendedwhereclause = '';
    @api label = '';
    @api type;
    @api value = '';
    @api name = '';


    /*constructor(){
        super();
        this.iconname = "standard:account";
        this.objectName = 'Account';
        this.searchField = 'Name';
    }*/

    connectedCallback() {
        if (this.value != '' && this.name != '') {
            this.selectedRecord = {
                Id: this.value,
                Name: this.name
            };
        }
    }

    handleOnchange(event) {
        //event.preventDefault();
        const searchKey = event.detail.value;
        this.searchKey = event.detail.value;
        //this.records = null;
        /* eslint-disable no-console */
        //console.log(searchKey);

        /* Call the Salesforce Apex class method to find the Records */
        findRecords({
            searchKey: searchKey,
            objectName: this.objectname,
            searchField: this.searchfield,
            extendedWhereClause: this.extendedwhereclause
        })
            .then(result => {
                if (searchKey != '') {
                    if (result.length > 0) {
                        this.records = result;
                        for (let i = 0; i < this.records.length; i++) {
                            const rec = this.records[i];
                            this.records[i].Name = rec[this.searchfield];
                        }
                        this.error = undefined;
                    } else {
                        this.records = undefined;
                    }
                }
                if (searchKey == '') {
                    this.records = undefined;
                }

            })
            .catch(error => {
                this.error = error;
                this.records = undefined;
            });
    }

    handleSelect(event) {
        let { recordId } = event.detail;
        let { name } = event.detail;

        this.selectedRecord = this.records.find(record => record.Id === recordId);

        if (this.selectedRecord['FirstName']) {
            this.showFirstName = true;
            this.firstName = this.selectedRecord.FirstName;
            console.log(this.selectedRecord.FirstName)
        }


        console.log('selectedRecordId', this.selectedRecord);
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail: { recordId: recordId, name: name, type: this.type, index: this.index }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleRemove(event) {
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail: { recordId: '', type: this.type, studentindex: this.index }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleFocusOut() {
        setTimeout(() => {
            this.records = undefined;
            if (this.searchKey != '') {
                let event = new CustomEvent(
                    "valuechange",
                    {
                        detail: { 'value': this.searchKey,type: this.type, index: this.index }
                    }
                );
                this.dispatchEvent(event);
            }
        }, 200);
    }
}
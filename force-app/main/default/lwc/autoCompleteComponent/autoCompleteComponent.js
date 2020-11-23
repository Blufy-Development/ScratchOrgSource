import { LightningElement, track, api} from 'lwc';
import findRecords from '@salesforce/apex/AutoCompleteCmpController.findRecords';

export default class AutoCompleteComponent extends LightningElement {
    @track records;
    @track error;
    @track selectedRecord;
    @api index;
    @api relationshipfield;
    @api iconname = "standard:account";
    @api objectname = 'Account';
    @api searchfield = 'Name';
    @api extendedwhereclause = '';
    @api label = '';
    @api type;
    @api studentindex = -1;
    

    /*constructor(){
        super();
        this.iconname = "standard:account";
        this.objectName = 'Account';
        this.searchField = 'Name';
    }*/

    handleOnchange(event){
        //event.preventDefault();
        const searchKey = event.detail.value;
        //this.records = null;
        /* eslint-disable no-console */
        //console.log(searchKey);
       // alert(searchKey)
        /* Call the Salesforce Apex class method to find the Records */
        findRecords({
            searchKey : searchKey, 
            objectName : this.objectname, 
            searchField : this.searchfield,
            extendedWhereClause : this.extendedwhereclause
        })
        .then(result => {
            if(searchKey != ''){
                if(result.length > 0){
                this.records = result;
                    for(let i=0; i < this.records.length; i++){
                        const rec = this.records[i];
                        this.records[i].Name = rec[this.searchfield];
                    }
                    this.error = undefined;
                    //console.log(' records ', this.records);
                }
            }
            if(searchKey == ''){
                this.records = undefined;
            }
            
        })
        .catch(error => {
            this.error = error;
            this.records = undefined;
        });
    }
    
    handleSelect(event){
        const selectedRecordId = event.detail;
        /* eslint-disable no-console*/
        this.selectedRecord = this.records.find( record => record.Id === selectedRecordId);
        //alert(JSON.stringify(selectedRecordId))
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                //detail : selectedRecordId
                detail : { recordId : selectedRecordId,type : this.type,studentindex : this.studentindex}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleRemove(event){
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail : { recordId : '',type : this.type,studentindex : this.studentindex}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }
}
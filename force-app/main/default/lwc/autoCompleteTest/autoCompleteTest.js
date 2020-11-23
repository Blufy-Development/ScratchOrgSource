import { LightningElement, api,track } from 'lwc';

export default class AutoCompleteTest extends LightningElement {
    @track lstData = [];
    @track inputValue = '';
    @track placeholder = 'Select Object';
    @track isClearOnSelected = false;
    @track lastSelectedObject = '';
    @track showSpinner = false;
    @track selectedObject = '';
    safeDate = [];
    lastSelectedIndex = 4;
    currentSelectedItemIndex = 0;
    scrollValue = 0;
    isFireBlur = true;

  /*  connectedCallback() {
        getObjectNames().then((result) => { // to objects name
            this.showSpinner = true;
            for (let curObject of result) {
                this.showSpinner = true;
                if (curObject) {
                    let obj = { 'value': curObject.value, 'label': curObject.label };
                    this.lstData.push(obj);
                    this.showSpinner = false;
                }
            }
            this.safeDate = this.lstData
            this.showSpinner = false;
        }).catch((err) => {
            console.log('Error in getObjectNames= ', err);
        });
    }
*/
    handleFocusChange(event) {// method to handle focus event 
        let element = this.template.querySelector('.slds-dropdown-trigger');
        if (element.className.indexOf('slds-is-open') != -1 && this.isFireBlur) {
            element.classList.remove('slds-is-open');
        }
        this.template.querySelector('[data-id=selectObjectId]').value = this.inputValue;
    }

    handleMouseOut(event) {  // method to handle selection
        this.isFireBlur = true;
    }

    hanldeMouseIn() { // method to handle selection
        this.isFireBlur = false;
    }

    renderedCallback() {
        if (!this.selectedObject) {
            let selectedItem = this.template.querySelector('[data-index="0"]');
            if (selectedItem && selectedItem.className && selectedItem.className.indexOf('hasSelected') == -1) {
                selectedItem.classList.add('hasSelected');
                this.currentSelectedItemIndex = 0;
            }
        } else {
            let selectedItem = this.template.querySelector('[data-index="0"]');
            if (selectedItem && selectedItem.className && selectedItem.className.indexOf('hasSelected') !== -1) {
                selectedItem.classList.remove('hasSelected');
            }
        }
    }

    openDropDownLst(event) {// mthod to open the drop down list        
        let element = this.template.querySelector('.slds-dropdown-trigger');
        if (element.className.indexOf('slds-is-open') == -1) {
            element.classList.add('slds-is-open');
        }
        if (this.selectedObject) {
            this.lstData = this.safeDate
            let selectedItem
            setTimeout(() => {
                selectedItem = this.template.querySelector('[data-value=' + this.selectedObject + ']');
                if (selectedItem && selectedItem.className && selectedItem.className.indexOf('hasSelected') == -1) {
                    selectedItem.classList.add('hasSelected');
                }
                
                let lstBox = this.template.querySelector('[data-id="listBoxSelect"]')
                if (lstBox && selectedItem) {
                    lstBox.scrollTop = selectedItem.offsetTop
                }
            }, 200);
        } else {
            this.lstData = this.safeDate
            this.inputValue = ''
        }
    }

    handleSelectedItem(event) {
        this.showSpinner = true
        let selSobject = event.currentTarget.getAttribute('data-value');
        this.inputValue = event.currentTarget.getAttribute('data-label');
        this.selectedObject = selSobject
        if (this.isClearOnSelected) {
            event.currentTarget.value = '';
        }
        if (this.lastSelectedObject !== selSobject) {

            this.sendSelectedValue(selSobject);
        } else {
            let selectObjectBox = this.template.querySelector('[data-id=selectObjectId]');
            selectObjectBox.value = selSobject;
            let element = this.template.querySelector('.slds-dropdown-trigger');
            element.classList.remove('slds-is-open');
            this.showSpinner = false;
        }
    }

    sendSelectedValue(selSobject) {
        let selectedItem
        if (this.lastSelectedObject) {
            selectedItem = this.template.querySelector('[data-value=' + this.lastSelectedObject + ']');
            if (selectedItem && selectedItem.className && selectedItem.className.indexOf('hasSelected') !== -1) {
                selectedItem.classList.remove('hasSelected');
            }
        }
        this.lastSelectedObject = selSobject
        let selectObjectBox = this.template.querySelector('[data-id=selectObjectId]');
        this.selectedObject = selSobject
        selectObjectBox.value = selSobject;
        let element = this.template.querySelector('.slds-dropdown-trigger');
        element.classList.remove('slds-is-open');
        this.showSpinner = false;
        this.dispatchEvent(new CustomEvent('selecteditem', { detail: { selSobject } }));
    }

    @api
    hanldeChangeItem(selectedValue) {
        let prevSelectedItem = this.template.querySelector('[data-index="' + this.currentSelectedItemIndex + '"]');
        if (prevSelectedItem && prevSelectedItem.classList) {
            prevSelectedItem.classList.remove('hasSelected');
        }

        if (!this.safeDate) {
            this.safeDate = this.lstData;
        } else {
            this.lstData = this.safeDate;
        }

        let element = this.template.querySelector('.slds-dropdown-trigger');
        let currValue = this.template.querySelector('[data-id=selectObjectId]').value;

        if (element.className.indexOf('slds-is-open') == -1 && currValue.trim()) {
            element.classList.add('slds-is-open');
        }

        if (!currValue.trim()) {
            this.lstData = this.safeDate;
        } else {
            let totalCount = 1;
            let tempArray = [];
            for (let row of this.lstData) {
                if (row && row.label.toUpperCase().startsWith(currValue.toUpperCase())) {
                    if (totalCount++ > 10) {
                        break;
                    }

                    tempArray.push(row);
                }
            }

            this.lstData = tempArray;
        }

        this.lastSelectedIndex = 4;
        this.scrollValue = 0;
        let container = this.template.querySelector('[data-id=listBox]');
        container.style.top = this.scrollValue + "px";
    }

    @api
    selectNextElement() {
        if (this.lstData.length - 1 > this.currentSelectedItemIndex) {
            let prevSelectedItem = this.template.querySelector('[data-index="' + this.currentSelectedItemIndex + '"]');
            prevSelectedItem.classList.remove('hasSelected');
            this.currentSelectedItemIndex++;
            let selectedItem = this.template.querySelector('[data-index="' + this.currentSelectedItemIndex + '"]');
            selectedItem.classList.add('hasSelected');
            if (this.lastSelectedIndex < this.currentSelectedItemIndex) {
                let container = this.template.querySelector('[data-id=listBox]');
                this.scrollValue += -36;
                container.style.top = this.scrollValue + "px";
                this.lastSelectedIndex += 1;
            }
        }
    }

    @api
    selectPreviousElement() {
        if (this.lstData.length != 0 && this.currentSelectedItemIndex > 0) {
            let prevSelectedItem = this.template.querySelector('[data-index="' + this.currentSelectedItemIndex + '"]');
            prevSelectedItem.classList.remove('hasSelected');
            this.currentSelectedItemIndex--;
            let selectedItem = this.template.querySelector('[data-index="' + this.currentSelectedItemIndex + '"]');
            selectedItem.classList.add('hasSelected');

            if ((this.lastSelectedIndex - 4) > this.currentSelectedItemIndex) {
                this.scrollValue -= -36;
                // console.log('scrollValue ',this.scrollValue);
                let container = this.template.querySelector('[data-id=listBox]');
                if (this.scrollValue != 0) {
                    container.style.top = this.scrollValue + "px";
                } else {
                    container.style.top = "-4px";
                }
                this.lastSelectedIndex -= 1;
            }
        }
    }

    @api
    getSelectedItem() {
        let selectedValue = this.template.querySelector('[data-index="' + this.currentSelectedItemIndex + '"]').getAttribute('data-value');
        this.inputValue = this.template.querySelector('[data-index="' + this.currentSelectedItemIndex + '"]').getAttribute('data-label');
        let prevSelectedItem = this.template.querySelector('[data-index="' + this.currentSelectedItemIndex + '"]');
        let element = this.template.querySelector('.slds-dropdown-trigger');
        let selectedObjectId = this.template.querySelector('[data-id=selectObjectId]');
        prevSelectedItem.classList.remove('hasSelected');
        element.classList.remove('slds-is-open');
        this.currentSelectedItemIndex = 0;
        selectedObjectId.value = '';
        return selectedValue;
    }

    handleKey(event) {

        if (event.keyCode == 40) {
            event.preventDefault();
            this.selectNextElement();
        } else if (event.keyCode == 38) {
            event.preventDefault();
            this.selectPreviousElement();
        } else if (event.keyCode == 13) {
            event.preventDefault();
            let selectedObjectId = this.template.querySelector('[data-id=selectObjectId]');
            let setValue = this.getSelectedItem();
            selectedObjectId.value = setValue;

            this.sendSelectedValue(setValue);
            this.lstData = this.safeDate
            if (this.isClearOnSelected) {
                selectedObjectId.value = '';
            }
        }
    }
}
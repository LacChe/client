import { LightningElement, track, wire } from 'lwc';

import { publish, MessageContext } from 'lightning/messageService';
import CONTACT_ROW_GET_DATA_MESSAGE from '@salesforce/messageChannel/ContactRowGetData__c';

import getContacts from '@salesforce/apex/ContactAPI.getContacts';

// TODO: bug when selecting rows right after refresh, seems to select multiple rows

export default class ServerContactsList extends LightningElement {
	
    // datatable params
    @track serverContactList = [];
    tableColumns = [
        { label: 'ID', fieldName: 'Id' },
        { label: 'First Name', fieldName: 'FirstName' },
        { label: 'Last Name', fieldName: 'LastName' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    ];

    // query params
    limitAmt = 10;
    @track offset = 1;
    @track selectedRows = [];

    @wire(MessageContext)messageContext;

    connectedCallback() {
        // get records on init
        this.refresh();
    }
    getRowData(){
        // publish row data for serverContactForm element
        const message = {
            rowData: this.template.querySelector('lightning-datatable').getSelectedRows() ? this.template.querySelector('lightning-datatable').getSelectedRows()[0] : undefined
        };
		publish(this.messageContext, CONTACT_ROW_GET_DATA_MESSAGE, message);
		console.log('Event published. Message: ' + JSON.stringify(message));
    }
    refresh(){
        getContacts({
            limitAmt : this.limitAmt,
            offset : (this.offset-1) * this.limitAmt
        })
        .then((result) => {
            // if there are no records and current page is not the first page, then go back a page
            if((result?.length > 0) || (result?.length === 0 && this.offset === 1)){
                this.serverContactList = result;
            } else {
                this.offset = Math.max(1, this.offset-1);
            }
        });
        this.selectedRows = [];
    }
    handlePrevPage(){
        this.offset = Math.max(1, this.offset-1);
        this.refresh();
    }
    handleNextPage(){
        this.offset++;
        // handle page out of bounds in refresh(), since this depends on returned records
        this.refresh();
    }
}
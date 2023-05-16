import { LightningElement, wire, track } from 'lwc';

import { subscribe, MessageContext } from 'lightning/messageService';
import CONTACT_ROW_GET_DATA_MESSAGE from '@salesforce/messageChannel/ContactRowGetData__c';

import createContact from '@salesforce/apex/ContactAPI.createContact';
import upsertContact from '@salesforce/apex/ContactAPI.upsertContact';
import updateContactFieldsByID from '@salesforce/apex/ContactAPI.updateContactFieldsByID';
import deleteContactByID from '@salesforce/apex/ContactAPI.deleteContactByID';

export default class ServerContactForm extends LightningElement {

    // to refresh input fields after retrieving row data
    @track renderInputs = true;

    // user inputs
    @track fields = {
        recordId : '',
        firstName : '',
        lastName : '',
        phone : ''
    };
    // paramaters to send to updateContactFieldsByID
    @track params = {
        FirstName : '',
        LastName : '',
        Phone : ''
    };

    @track buttonLabel = 'Create Contact';
    submitType = 'POST';

    subscription = null;
    @wire(MessageContext)
    messageContext;
    
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            CONTACT_ROW_GET_DATA_MESSAGE,
            (message) => {
                this.handleContactGetData(message);
            });
    }
    connectedCallback() {
        this.subscribeToMessageChannel();
    }
    handleContactGetData(message) {
        // every time a get data event is received, clear input fields and populate with received data
        this.inputClear();
        this.template.querySelector('.record_id_input').value = this.fields.recordId = message.rowData.Id;
        this.template.querySelector('.first_name_input').value = this.fields.firstName = message.rowData.FirstName;
        this.template.querySelector('.last_name_input').value = this.fields.lastName = message.rowData.LastName;
        this.template.querySelector('.phone_input').value = this.fields.phone = message.rowData.Phone;
        this.updateSubmitType();
    }
    inputClear() {
        this.renderInputs = false;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {this.renderInputs = true}, 0);
    }
    formUpdated(event){
        // track user inputs
        this.fields[event.target.name] = event.target.value;
        this.updateSubmitType();
    }
    updateSubmitType(){
        /* 
        parameters required for requests, patch needs at least one marked with '?'
                    post  dlt  put   patch
        id          Y     Y          Y
        firstName   Y          Y     ?
        lastName    Y          Y     ?
        phone       Y          Y     ?
        */
        if(this.fields.recordId === 'ERROR'){
            this.buttonLabel = 'ERROR';
            this.submitType = 'ERROR';
        } else if(this.fields.recordId === ''){
            this.buttonLabel = 'Create Contact';
            this.submitType = 'POST';
        } else {
            this.buttonLabel = 'Update Contact';
            if(this.fields.firstName === '' || this.fields.lastName === '' || this.fields.phone === ''){
                this.submitType = 'PATCH';
            } else {
                this.submitType = 'PUT';
            }
        }
        return this.submitType;
        
    }
    submit(){
        // perform request based off submitType
        switch(this.submitType){
            case 'POST':
                createContact({
                    firstName : this.fields.firstName,
                    lastName : this.fields.lastName,
                    phone : this.fields.phone
                })
                .then((result) => {
                    this.fields.recordId = result;
                });
                this.updateSubmitType();
                break;
            case 'PUT':
                upsertContact({
                    id : this.fields.recordId,
                    firstName : this.fields.firstName,
                    lastName : this.fields.lastName,
                    phone : this.fields.phone
                });
                this.updateSubmitType();
                break;
            case 'PATCH':
                this.params = {
                    FirstName : this.fields.firstName,
                    LastName : this.fields.lastName,
                    Phone : this.fields.phone
                };
                if(this.params.FirstName === '') delete this.params.FirstName;
                if(this.params.LastName === '') delete this.params.LastName;
                if(this.params.Phone === '') delete this.params.Phone;
                updateContactFieldsByID({
                    id : this.fields.recordId,
                    jsonBody : JSON.stringify(this.params)
                });
                this.updateSubmitType();
                break;
            default:
                break;
        }
    }
    deleteRecord(){
        // perform delete request
        deleteContactByID({id : this.fields.recordId});
        this.template.querySelector('.record_id_input').value = this.fields.recordId = '';
        this.template.querySelector('.first_name_input').value = this.fields.firstName = '';
        this.template.querySelector('.last_name_input').value = this.fields.lastName = '';
        this.template.querySelector('.phone_input').value = this.fields.phone = '';
        this.updateSubmitType();
    }

}
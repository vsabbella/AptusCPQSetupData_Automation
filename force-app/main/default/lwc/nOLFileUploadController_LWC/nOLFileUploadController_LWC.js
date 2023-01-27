/*
Name            : NOLFileUploadController_LWC
Author          : Sagar Gunjal
Release         : 1.0
Functionality   : Ability to import the data of Template into records.
Created         : May-20-2022

Modification History:
Date            Author             Date       Change  
 1.0            Sagar Gunjal.     5/20/2022   INITIAL DEVELOPMENT 
 2.0            Sagar Gunjal.     6/28/2022   Quick Action to invoke the batch process.
 3.0            Sagar Gunjal.     6/29/2022   Remove Modal after clicking on  Quick Action.
 4.0            Sagar Gunjal.     9/19/2022   GTMCLS-5478 - Popup do not closed automatically while batch job runs through NOL upload data quick action button.
*/

import { LightningElement, api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loadData from '@salesforce/apex/NOLFileUploadController.loadData';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class NOLFileUploadController_LWC extends NavigationMixin(LightningElement) {

    // @api recordId;
    error;
    isLoadeding = false;
    showmodel = true;
    /*
    @api invoke() {
        this.onSubmitHandler();
    }*/

    @api get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        this._recordId = value;
        if (this._recordId) {
            this.onSubmitHandler();
        }
    }
    onSubmitHandler() {
        this.isLoadeding = true;
        window.console.log('recordId >>' + this._recordId);
        loadData({ automatedDeploymentId: this._recordId })
            .then(result => {
                this.isLoadeding = false;
                window.console.log('result ===> ' + result);
                this.jsShowToastEvent('Data Load Initiated.', '..', 'info');
                // this.jsShowToastEvent('Success', result, 'success');
                this.dispatchEvent(new CloseActionScreenEvent());
                this.updateview(5000);
                this.jsNavigateToViewPage();
            })
            .catch(error => {
                this.isLoadeding = false;
                this.error = error;
                window.console.log('error==>' + JSON.stringify(error));
                this.jsShowToastEvent('Error!!', JSON.stringify(error.body.message), 'error');
                this.dispatchEvent(new CloseActionScreenEvent());
                this.jsNavigateToViewPage();
            })
        this.showmodel = false;
        this.isLoadeding = false;
    }

    jsShowToastEvent(title, message, variant) {
        const event = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant,
            mode: 'dismissible'
        });
        this.dispatchEvent(event);
    }

    jsNavigateToViewPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this._recordId,
                objectApiName: 'Automated_Deployment__c',
                actionName: 'view'
            },
        });
    }

    sleep(ms) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        return new Promise((resolve) => setTimeout(() => { document.location.reload(); }, ms));
    }
    updateview(sec) {
        setTimeout(() => {
            document.location.reload();
        }, sec);
    }
}
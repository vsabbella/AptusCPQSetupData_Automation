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
*/

import { LightningElement, api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loadData from '@salesforce/apex/NOLFileUploadController.loadData';
import { NavigationMixin } from 'lightning/navigation';

export default class NOLFileUploadController_LWC extends NavigationMixin(LightningElement) {

    // @api recordId;
    error;
    isLoaded = false;
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
        this.isLoaded = true;
        window.console.log('recordId >>' + this._recordId);
        loadData({ automatedDeploymentId: this._recordId })
            .then(result => {
                this.isLoaded = false;
                window.console.log('result ===> ' + result);
                this.jsShowToastEvent('Data Load Initiated.', '..', 'info');
                // this.jsShowToastEvent('Success', result, 'success');
                this.jsNavigateToViewPage();
            })
            .catch(error => {
                this.isLoaded = false;
                this.error = error;
                window.console.log('error==>' + JSON.stringify(error));
                this.jsShowToastEvent('Error!!', JSON.stringify(error.body.message), 'error');
                this.jsNavigateToViewPage();
            })
        this.showmodel = false;
        this.isLoaded = false;
    }

    jsShowToastEvent(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'dismissible'
            }),
        );
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
        return new Promise((resolve) => setTimeout(resolve, ms));
    }
}
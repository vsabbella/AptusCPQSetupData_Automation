import { LightningElement, api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loadData from '@salesforce/apex/NOLSetupUpdateController.loadData';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class NolSetupUpdateLWC extends  NavigationMixin(LightningElement) {
  // @api recordId;
  error;
  isLoadeding = false;
  showmodel = true;

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
    loadData({ setupUpdateId: this._recordId })
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
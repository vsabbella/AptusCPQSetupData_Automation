/*
Name            : NOLFileUploadController
Author          : Sagar Gunjal
Release         : 1.0
Functionality   : Ability to import the data of Template into records
Created         : May-23-2022

History                                                           
-------                                                           
VERSION   AUTHOR            DATE          DETAIL               
  1.0     Sagar Gunjal.     5/23/2022   INITIAL DEVELOPMENT 
  2.0     Somya Sriavstava  6/20/2022   Added method for upload of data with JSON.deserialize method with external ID approach for Product2 method. Same will be copied in other methods too.
  3.0     Somya Sriavstava  6/21/2022   Modified Class for sequencing of Batch in 4 batch jobs
  4.0     vsabbella         6/22/2022   review comments.
  5.0     Somya Srivastava  6/23/2022   Moved JSON parsing and other common methods to NOLAutomationUtil class
  6.0     Somya Srivastava  6/24/2022   Put external ID references using sobject.putSobject across the methods in which the data is getting inserted currently
  7.0     Somya Srivastava  6/25/2022   Added methods for uploading of Custom Setting Data for dynamic pricing.
  8.0     Somya Srivastava  6/25/2022   Fixed Issue for wrong List Prices for Uploaded Data

*/
public with sharing class NOLFileUploadBatchApex implements Database.Batchable<SObject>,Database.Stateful{
    Integer batchNo;
    String query;
    String automatedDeploymentId;

    public final String csvString = 'Product2,Apttus_Config2__PriceListItem__c,Apttus_Config2__ClassificationName__c,Apttus_Config2__ClassificationHierarchy__c,Apttus_Config2__ProductClassification__c,Apttus_Config2__ProductOptionGroup__c,Apttus_Config2__ProductOptionComponent__c,Apttus_Config2__PriceRule__c,Apttus_Config2__PriceRuleEntry__c,APTS_Price_Quantity__c,APTS_Unit_List_Price_1__c,APTS_Size_Relationship__c,APTS_Product_Adjustor__c,APTS_Industry_Adjustor__c,APTS_Discount_Guidelines_Max_Limits__c,APTS_Deployment_Adjustor__c,APTS_Country_Adjustor__c,APTS_ACV_Floor__c';
    List<String> csvStringsList = new List<String>{csvString};
    List<String> csvToProcess = new List<String>();
  
    public NOLFileUploadBatchApex(String automatedDepId, Integer BatchNum){
        batchNo=BatchNum;
        automatedDeploymentId = automatedDepId;
        String csvToProcessString = csvStringsList.get(batchNo);
        csvToProcess = csvToProcessString.split(',');

        query= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: automatedDeploymentId and Title In:csvToProcess';
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC ,List<ContentVersion> contentVersionObj){
      
        system.debug('records==>'+contentVersionObj);

        NOLFileUploadBatchApexHelper.initiateDataLoad(csvToProcess,contentVersionObj,automatedDeploymentId);
        
        updateNolAutomationSetting();
    }

    
    public void updateNolAutomationSetting(){

        Automated_Deployment__c ac = NOLAutomationUtil.getProductCodeName(automatedDeploymentId);
        NOL_Automation_Settings__c nol = NOLAutomationUtil.getNOLAutmationSettings();

        if(nol != null && ac !=null && String.isNotBlank(ac.SKU_Code__c)){
            if(String.isNotBlank(nol.Qty_Roundup_ProdCodes__c)){
                nol.Qty_Roundup_ProdCodes__c = nol.Qty_Roundup_ProdCodes__c + ',' + ac.SKU_Code__c;
            }else{
                nol.Qty_Roundup_ProdCodes__c = ac.SKU_Code__c;
            }
        }
        update nol;
    }

    public void finish(DataBase.BatchableContext BC){
        Integer batchSize =  csvStringsList.size()-1;
        if(batchNo < batchSize){
            batchNo = batchNo +1;
            Database.executebatch(new NOLFileUploadBatchApex(automatedDeploymentId,batchNo));
          }
    }
}
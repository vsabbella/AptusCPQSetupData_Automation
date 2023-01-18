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
  9.0     Somya Srivastava  10/2/2022   GTMCLS-5567 : Csv archive into static resource and External ID append SKU code changes
  10.0    Sagar Gunjal      11/3/2022   GTMCLS-5302 -Renewal Transaction: AEF= Active, Same -Added for Committed Usage SKU.
  11.0    vsabbella     11/8/2022   GTMCLS-5559 - Bypass widgets settings
*/
public with sharing class NOLFileUploadBatchApex implements Database.Batchable<SObject>,Database.Stateful,Database.AllowsCallouts{
    Integer batchNo;
    String query;
    String automatedDeploymentId;

    public final String csvString = 'Product2,Apttus_Config2__PriceListItem__c,Apttus_Config2__ClassificationName__c,Apttus_Config2__ClassificationHierarchy__c,Apttus_Config2__ProductClassification__c,Apttus_Config2__ProductOptionGroup__c,Apttus_Config2__ProductOptionComponent__c,Apttus_Config2__PriceRule__c,Apttus_Config2__PriceRuleEntry__c,APTS_Price_Quantity__c,APTS_Unit_List_Price_1__c,APTS_Size_Relationship__c,APTS_Product_Adjustor__c,APTS_Industry_Adjustor__c,APTS_Discount_Guidelines_Max_Limits__c,APTS_Deployment_Adjustor__c,APTS_Country_Adjustor__c,APTS_ACV_Floor__c,APTS_Discount_Guidelines_NonStd_SKU__c,APTS_Price_Matrix__c,APTS_SKU_Relationship_Size_Baseline__c,APTS_Master_Sku_List__c';//GTMCLS-5556 : Added Custom settings //GTMCLS-5567 : ssriv - Removed CSV files name which are in Static Resources
    public static String staticResourceFilesString = 'Apttus_Config2__ClassificationName__c,Apttus_Config2__ClassificationHierarchy__c,Apttus_Config2__ProductClassification__c,Apttus_Config2__ProductOptionGroup__c,Apttus_Config2__ProductOptionComponent__c';  //GTMCLS-5567 : ssriv - CSV file names which are uploaded in Static Resources
    List<String> csvStringsList = new List<String>{csvString};
    List<String> csvToProcess = new List<String>();
    List<String> staticResCsvsToProcess= new List<String>();  //GTMCLS-5567 : ssriv 
    Set<String> externalIdSet = new Set<String>(); //GTMCLS-5567 : ssriv 
  
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
        staticResCsvsToProcess = staticResourceFilesString.split(','); //GTMCLS-5567 : ssriv 
        NOLFileUploadBatchApexHelper.initiateDataLoad(csvToProcess,contentVersionObj,automatedDeploymentId,staticResCsvsToProcess,externalIdSet); //GTMCLS-5567 : ssriv 
        
        updateNolAutomationSetting();
        insertUpgradeUsageSetting(); //GTMCLS-5302
        insertWidgetByPassSetting();
        updateProduct2();
    }

    public void updateProduct2(){
        Automated_Deployment__c automatedDeploye = [SELECT ID,SKU_Description__c,Metric_Definition__c,Metric_Name__c,ISA_Identifier__c,Product_Guidance__c,GA_Date__c, Product__c from Automated_Deployment__c where ID =: automatedDeploymentId];

        Product2 proobj= new Product2();
        proobj.id = automatedDeploye.Product__c;
        proobj.Product_Description_for_output__c = automatedDeploye.SKU_Description__c;
        proobj.APTS_Metric_Definition__c = automatedDeploye.Metric_Definition__c;
        proobj.APTS_Metric_Name__c = automatedDeploye.Metric_Name__c;
        proobj.Product_Guidance__c = automatedDeploye.Product_Guidance__c;
        proobj.GA_Date__c = automatedDeploye.GA_Date__c;
        //proobj.APTS_ISA_Identifier__c = (Boolean)automatedDeploye.ISA_Identifier__c;

        if(proobj != null){
            update proobj;
        }
    }
    
    public void updateNolAutomationSetting(){

        Automated_Deployment__c ac = NOLAutomationUtil.getProductCodeName(automatedDeploymentId);
        APTS_Config_Setting__c nol = NOLAutomationUtil.getNOLAutmationSettings();

        if(nol != null && ac !=null && String.isNotBlank(ac.SKU_Code__c)){
            if(String.isNotBlank(nol.APTS_Value__c)){
                nol.APTS_Value__c = !nol.APTS_Value__c.containsIgnoreCase(ac.SKU_Code__c)?nol.APTS_Value__c + ',' + ac.SKU_Code__c:nol.APTS_Value__c;
            }else{
                nol.APTS_Value__c = ac.SKU_Code__c;
            }
        }
        update nol;
    }
    // GTMCLS-5302 -start
    public void insertUpgradeUsageSetting(){
        Automated_Deployment__c ac = NOLAutomationUtil.getProductCodeName(automatedDeploymentId);
        APTS_Upgrade_Fee_Settings__c  nolAutmation = APTS_Upgrade_Fee_Settings__c.getValues(ac.SKU_Code__c);
            APTS_Upgrade_Fee_Settings__c upgradeSetting = new APTS_Upgrade_Fee_Settings__c(); 
                if(ac !=null && ac.Upgrade_fee_Multiplier__c !=null && ac.SKU_Code__c!=null){
                    if(ac.SKU_Code__c !=null && nolAutmation == null){ 
                        upgradeSetting.Name = ac.SKU_Code__c;                          
                        upgradeSetting.Product_Code__c = ac.SKU_Code__c;
                        upgradeSetting.Upgrade_Fee__c = ac.Upgrade_fee_Multiplier__c;
                    }else{
                        upgradeSetting.id = nolAutmation.id;
                        upgradeSetting.Upgrade_Fee__c = ac.Upgrade_fee_Multiplier__c;
                    }
            }
            System.debug('upgradeSetting'+upgradeSetting);
            if(upgradeSetting.Name !=null && upgradeSetting.Upgrade_Fee__c !=null){
                upsert upgradeSetting;
            }
    }
   // GTMCLS-5302 -end
   public  void insertWidgetByPassSetting(){

    //Automated_Deployment__c ac = NOLAutomationUtil.getProductCodeName(automatedDeploymentId);
    String COMMITTED_USAGE_UOM = APTPS_Constants.PRICE_UOM_COMMITED_USAGE;
    APTS_Product_Price_Uom__c byPassUOM= APTS_Product_Price_Uom__c.getInstance(COMMITTED_USAGE_UOM);
    if(byPassUOM == null){
        bypassUOM = new APTS_Product_Price_Uom__c(Name= COMMITTED_USAGE_UOM,APTS_Price_Uom__c=COMMITTED_USAGE_UOM);
        insert bypassUOM;
    }
 }

    public void finish(DataBase.BatchableContext BC){
        Integer batchSize =  csvStringsList.size()-1;
        if(batchNo < batchSize){
            batchNo = batchNo +1;
            Database.executebatch(new NOLFileUploadBatchApex(automatedDeploymentId,batchNo));
          }
    }
}
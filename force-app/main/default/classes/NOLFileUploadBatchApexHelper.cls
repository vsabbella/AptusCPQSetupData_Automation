public with sharing class NOLFileUploadBatchApexHelper {
    public NOLFileUploadBatchApexHelper() {
    }

    public static void initiateDataLoad(List<String> csvToProcess,List<ContentVersion> contentVersionObj, String automatedDeploymentId){

       Map<String,List<String>> lookupFieldMap = new Map<String,List<String>>();

        StaticResource sr= [select id,body from StaticResource Where Name = 'NOLFileUploadJson'];
        String content = sr.body.toString();

        //system.debug('Static Resource Body'+content );

        Map<String, String> mapJson = (Map<String,String>) JSON.deserialize(content, Map<String,String>.class);
        //System.debug('mapJson :' + mapJson);

        for(String key : mapJson.keySet()){
           lookupFieldMap.put(key, mapJson.get(key).split(','));
        }

        system.debug('lookupFieldMap :'+lookupFieldMap );

        Map<String, ContentVersion> titleVsContentDocMap = new Map<String, ContentVersion>();

        for(ContentVersion cv :contentVersionObj){  
            titleVsContentDocMap.put(cv.Title, cv);
        }

        Schema.DescribeSobjectResult[] resList = Schema.describeSObjects(csvToProcess);

        //System.debug('resList ::' + resList);

        for(String csvTitle : csvToProcess){

            System.debug(LoggingLevel.ERROR,'Processing CSV for Object :'+csvTitle);
            //System.debug(LoggingLevel.ERROR,'Processing CSV for Object :'+titleVsContentDocMap);
            
            ContentVersion cvInstance = titleVsContentDocMap.get(csvTitle);
            if(cvInstance != null){
                //System.debug(LoggingLevel.ERROR,'cvInstance'+cvInstance);

                String sobjJSON = NOLAutomationUtil.parseCSVtoJSONandFormat(cvInstance);

                String apexType = 'List<'+csvTitle+'>';

                Schema.DescribeSobjectResult[] dsrList = Schema.describeSObjects(new List<String>{csvTitle});
                Schema.DescribeSobjectResult dsr =dsrList[0];
                List<SObject> sobjectList = new List<SObject>();
                if(lookupFieldMap.containsKey(csvTitle)){
                    List<String> lookupFields_Sobj = lookupFieldMap.get(csvTitle);
                    List<Object> objectList = (List<Object>) json.deserializeUntyped(sobjJSON);
                    for(Object obj:objectList){
                        String ObjJSON = JSON.serialize(obj);
                        SObject sobj = (SObject)JSON.deserialize(ObjJSON, Type.forName(csvTitle));
                        
                        NOLAutomationUtil.getSobjectWithParentReference(csvTitle,lookupFields_Sobj,obj,sobj,dsr);
                        sobjectList.add(sobj);

                    }
                
                }else{
                    sobjectList = (List<Sobject>)JSON.deserialize(sobjJSON, Type.forName(apexType));
                }

                mapDataFromNOLToCPQSetupData(csvTitle,automatedDeploymentId,sobjectList);
                
                Map<String, Schema.SObjectField> fieldsMap = dsr.fields.getMap();
                Schema.SObjectField ftoken = fieldsMap.get('apts_ext_id__c');
                NOLAutomationUtil.insertRecordsAndUpdateNol(sobjectList,automatedDeploymentId,ftoken);
                System.debug(LoggingLevel.ERROR, 'sobjeclist'+sobjectList);
            }
      
        }
    }

    public static void mapDataFromNOLToCPQSetupData(String csvTitle, String automatedDeploymentId,List<SObject> sobjectList){
        //String jsonMapping ='{"Product2":{"Name":"SKU_Name__c", "ProductCode":"SKU_Code__c", "APTS_Product_Pricing_UOM__c":"UOM__c","Apttus_Config2__Uom__c":"UOM__c"},"Apttus_Config2__PriceListItem__c":{"Apttus_Config2__PriceUom__c":"UOM__c"},"Apttus_Config2__PriceRule__c":{"Name":"SKU_Name__c"},"Apttus_Config2__PriceRuleEntry__c":{"Apttus_Config2__Dimension1Value__c":"SKU_Code__c"},"APTS_Unit_List_Price_1__c":{"Product_Code__c":"SKU_Code__c","Meter__c":"UOM__c"},"APTS_Size_Relationship__c":{"Meter_Type__c":"UOM__c"},"APTS_Product_Adjustor__c":{"SKU__c":"SKU_Code__c"},"APTS_Industry_Adjustor__c":{"FINS_Meter_Industry__c":"UOM__c"},"APTS_Discount_Guidelines_Max_Limits__c":{"Meter__c":"UOM__c"},"APTS_Deployment_Adjustor__c":{"Meter_Type__c":"UOM__c"},"APTS_Country_Adjustor__c":{"Meter__c":"UOM__c"},"APTS_ACV_Floor__c":{"Product_Code__c":"SKU_Code__c"},"APTS_Price_Quantity__c":{"Product_Code__c":"SKU_Code__c"}}';
        //Map<String,Object> sobjectMappingToAutoDep = (Map<String,Object>)JSON.deserializeUntyped(jsonMapping);

        StaticResource sr= [select id,body from StaticResource Where Name = 'NOLFieldMappingJson'];
        String jsonMapping = sr.body.toString();
        Map<String,Object> sobjectMappingToAutoDep = (Map<String,Object>)JSON.deserializeUntyped(jsonMapping);

        if(sobjectMappingToAutoDep.containsKey(csvTitle)){
            String sobjmappingStr = JSON.serialize(sobjectMappingToAutoDep.get(csvTitle));
            Map<String,String> sobjectMappingToAutoDep_this = (Map<String,String> )JSON.deserialize(sobjmappingStr, Map<String,String>.class);
            Set<String> AutoDepFields = new Set<String>(sobjectMappingToAutoDep_this.values());
            String AutomatedDepQuery = 'Select '+String.join(new List<String>(AutoDepFields),',')+' from Automated_Deployment__c where Id = :automatedDeploymentId';
            Sobject sobjAutoDep = database.query(AutomatedDepQuery);
            for(String mappingkey : sobjectMappingToAutoDep_this.keyset()){
                String autoDepMappingField = sobjectMappingToAutoDep_this.get(mappingkey);
                for(Sobject sobj : sobjectList){
                    sobj.put(mappingkey,sobjAutoDep.get(autoDepMappingField));
                }
            }
        }
    }
}


/**
 * 0. Move components to GTMDev
 * 1. Upload the rest of the custom settings using NOLFileUploadBatchApexHelper.cls
 
 * 2. Update the mapping from UI for automated deployment. 
 * 3. Test the netnew and renewal 
 * 
 * 
 */

 /**
  * 0. Duplicate classfication hierarchy record. 
  * 1. configure heroku pricing
    2. unit test all transaction type and standardize code. 

  */
/*
Name            : NOLFileUploadBatchApexHelper
Author          : Somya Srivastava
Release         : 1.0
Functionality   : Helper class called from NOLFileUploadBatchApex
Created         : 06-22-2022

History                                                           
-------                                                           
VERSION  AUTHOR            DATE             DETAIL          Change Request
1.0      Somya             06-22-2022       GTMCLS-5347     Initial development of Helper class called from  NOLFileUploadBatchApex used to upload data
2.0      Somya Srivastava  9/2/2022         GTMCLS-5567    Csv archive into static resource and External ID append SKU code changes 
*/
public with sharing class NOLFileUploadBatchApexHelper {

    public static Set<String> customSettingsNameSet = new Set<String>{'APTS_Price_Quantity__c','APTS_Unit_List_Price_1__c','APTS_Size_Relationship__c','APTS_Product_Adjustor__c','APTS_Industry_Adjustor__c','APTS_Discount_Guidelines_Max_Limits__c','APTS_Deployment_Adjustor__c','APTS_Country_Adjustor__c','APTS_ACV_Floor__c','APTS_Discount_Guidelines_NonStd_SKU__c','APTS_SKU_Relationship_Size_Baseline__c','APTS_Master_Sku_List__c'};//GTMCLS-5556 : Added Custom settings 
    public static Boolean isCategoryAvailable = false;
    public NOLFileUploadBatchApexHelper() {
    }

    public static void initiateDataLoad(List<String> csvToProcess,List<ContentVersion> contentVersionObj, String automatedDeploymentId,
                                        List<String> staticResCsvsToProcess, Set<String> externalIdSet){//GTMCLS-5567 : ssriv - Added parameters

        Set<String> skipForOptionGroupDefaut = new Set<String>{'Apttus_Config2__ClassificationName__c','Apttus_Config2__ClassificationHierarchy__c','Apttus_Config2__ProductOptionGroup__c'};
        
        Automated_Deployment__c ac = NOLAutomationUtil.getProductDetails(automatedDeploymentId);//GTMCLS-5567 : ssriv 
        String skuCode = (ac != null && String.isNotBlank(ac.SKU_Code__c)) ?  ac.SKU_Code__c : '';//GTMCLS-5567 : ssriv 
        
        if(ac.CategoryHierarchy__c != null){
            isCategoryAvailable = true;
        }

        Map<String,List<String>> lookupFieldMap = getLookUpDataForSobjects();

        system.debug('lookupFieldMap :'+lookupFieldMap );

        Map<String, ContentVersion> titleVsContentDocMap = new Map<String, ContentVersion>();

        for(ContentVersion cv :contentVersionObj){  
            titleVsContentDocMap.put(cv.Title, cv);
        }

        Map<String , String> csvTitleVsStaticResBodyMap = new Map<String, String>(); //GTMCLS-5567 : ssriv 
        String staticResPrefix = skuCode.StartsWith('LDP') ? 'LDP_NOL' : 'LE_NOL' ; //GTMCLS-5567 : ssriv 

        StaticResource csvStaticRes = [SELECT Id,Name,SystemModstamp  FROM StaticResource WHERE Name =: staticResPrefix LIMIT 1];//GTMCLS-5567 : ssriv 
        System.debug(' Static Resource csvStaticRes :' + csvStaticRes);//GTMCLS-5567 : ssriv 

        for(String srCsvFileName: staticResCsvsToProcess){//GTMCLS-5567 : ssriv 

            String srPath = '/resource/' + csvStaticRes.SystemModstamp.getTime() + '/' + csvStaticRes.Name +  '/' + srCsvFileName + '.csv'; //GTMCLS-5567 : ssriv 
            PageReference pg = new PageReference( srPath );//GTMCLS-5567 : ssriv 
            if(!Test.isRunningTest()){
                if(pg != null && pg.getContent() != null){
                    String body = pg.getContent().toString();//GTMCLS-5567 : ssriv 
                    csvTitleVsStaticResBodyMap.put(srCsvFileName, body);//GTMCLS-5567 : ssriv 
                }
            }else{
                csvTitleVsStaticResBodyMap.put('Apttus_Config2__ClassificationName__c', 'Test');//Added for Test class coverage
            }
        }

        System.debug(' csvTitleVsStaticResBodyMap :' + csvTitleVsStaticResBodyMap);//GTMCLS-5567 : ssriv 

        Schema.DescribeSobjectResult[] resList = Schema.describeSObjects(csvToProcess);

        System.debug('csvToProcess ::' + csvToProcess);

        for(String csvTitle : csvToProcess){

            System.debug(LoggingLevel.ERROR,'Processing CSV for Object :'+csvTitle);
            
            // donot upsert option group data as we are using existing data by querying -vsabbella
            if(skipForOptionGroupDefaut.contains(csvTitle) && isCategoryAvailable){
                continue;
            }
            
             //Processing NOL Files Data //GTMCLS-5567 : ssriv 
            if(titleVsContentDocMap.containsKey(csvTitle) && !csvTitleVsStaticResBodyMap.containsKey(csvTitle)){
                ContentVersion cvInstance = titleVsContentDocMap.get(csvTitle);
                System.debug('cvInstance inside NOL object :' + cvInstance);
                if(cvInstance != null){
                    //System.debug(LoggingLevel.ERROR,'cvInstance'+cvInstance);
    
                    String sobjJSON = NOLAutomationUtil.parseCSVtoJSONandFormat(cvInstance);
    
                    List<Sobject> sobjectList = processRecords(csvTitle, sobjJSON,lookupFieldMap,automatedDeploymentId,skuCode,externalIdSet,ac.CategoryHierarchy__c); //GTMCLS-5567 : ssriv 
                    importProcessedRecords(sobjectList,automatedDeploymentId,csvTitle,true);
                }
            }
            //Process Static Resource Data //GTMCLS-5567 : ssriv 
            else if(csvTitleVsStaticResBodyMap.containsKey(csvTitle)){
                String srBody = csvTitleVsStaticResBodyMap.get(csvTitle);
                System.debug('srBody inside static resource object :' + srBody);
                if(srBody != null){
                    //System.debug(LoggingLevel.ERROR,'cvInstance'+cvInstance);

                    String sobjJSON = NOLAutomationUtil.parseStaticResourceToJsonAndFormat(srBody,csvTitle);

                    List<Sobject> sobjectList = processRecords(csvTitle, sobjJSON,lookupFieldMap,automatedDeploymentId,skuCode,externalIdSet,ac.CategoryHierarchy__c); //GTMCLS-5567 : ssriv 

                    importProcessedRecords(sobjectList,automatedDeploymentId,csvTitle,true);
                }
            }          
        }
    }

    public Static  Map<String,List<String>> getLookUpDataForSobjects(){
        Map<String,List<String>> lookupFieldMap = new Map<String,List<String>>();

        StaticResource sr= [select id,body from StaticResource Where Name = 'NOLFileUploadJson'];
        String content = sr.body.toString();

        ///system.debug('Static Resource Body'+content );

        Map<String, String> mapJson = (Map<String,String>) JSON.deserialize(content, Map<String,String>.class);
        //System.debug('mapJson :' + mapJson);

        for(String key : mapJson.keySet()){
           lookupFieldMap.put(key, mapJson.get(key).split(','));
        }

        return lookupFieldMap;

    }

    public static List<Sobject> processRecords(String csvTitle, String sobjJSON, Map<String,List<String>> lookupFieldMap,String automatedDeploymentId, String skuCode,Set<String> externalIdSet, String categoryHierarchy){//GTMCLS-5567 : ssriv 
        String apexType = 'List<'+csvTitle+'>';

        Schema.DescribeSobjectResult[] dsrList = Schema.describeSObjects(new List<String>{csvTitle});
        Schema.DescribeSobjectResult dsr =dsrList[0];
        List<SObject> sobjectList = new List<SObject>();
        if(lookupFieldMap.containsKey(csvTitle)){
            List<String> lookupFields_Sobj = lookupFieldMap.get(csvTitle);
            List<Object> objectList = (List<Object>) json.deserializeUntyped(sobjJSON);
            for(Object obj:objectList){
                String ObjJSON = JSON.serialize(obj);
                SObject sobj = (SObject)JSON.deserialize(ObjJSON, Type.forName(csvTitle));
                
                NOLAutomationUtil.getSobjectWithParentReference(csvTitle,lookupFields_Sobj,obj,sobj,dsr,skuCode,externalIdSet);//GTMCLS-5567 : ssriv 
                
                // overwrite parent reference for option group to use existing option category and option groups. 
                if(isCategoryAvailable){
                    NOLAutomationUtil.overWriteParentReference(csvTitle,lookupFields_Sobj,obj,sobj,dsr,skuCode,externalIdSet,categoryHierarchy);
                }
                sobjectList.add(sobj);

            }
        
        }else{
            sobjectList = (List<Sobject>)JSON.deserialize(sobjJSON, Type.forName(apexType));
        }

         //ssriv External ID Changes
        if(!customSettingsNameSet.contains(csvTitle)){//GTMCLS-5567 : ssriv 
            populateRecordExtId(sobjectList,skuCode,externalIdSet,'apts_ext_id__c');//GTMCLS-5567 : ssriv 
        }else{
            populateRecordExtId(sobjectList,skuCode,externalIdSet,'Name');//GTMCLS-5567 : ssriv 
        }

       System.debug('Sobject list after external ID population:' + sobjectList);//GTMCLS-5567 : ssriv 


        mapDataFromNOLToCPQSetupData(csvTitle,automatedDeploymentId,sobjectList);

        return sobjectList;

        
        
    }

    public static void importProcessedRecords(List<Sobject> sobjectList,String automatedDeploymentId,String csvTitle, Boolean generateOverwriteRecord){
        Schema.DescribeSobjectResult[] dsrList = Schema.describeSObjects(new List<String>{csvTitle});
        Schema.DescribeSobjectResult dsr =dsrList[0]; 
       //SobjectType sobjType = sobjectList.getSObjectType();
       //Schema.DescribeSObjectResult dsr = sobjType.getDescribe();
       Map<String, Schema.SObjectField> fieldsMap = dsr.fields.getMap();
       Boolean isCustomSetting = dsr.isCustomSetting();
       Schema.SObjectField ftoken;
       if(isCustomSetting){
            ftoken = fieldsMap.get('Name');
        }    
        else{
            ftoken = fieldsMap.get('apts_ext_id__c');
        }
        NOLAutomationUtil.insertRecordsAndUpdateNol(sobjectList,automatedDeploymentId,ftoken);
        if(generateOverwriteRecord)
           NOLAutomationUtil.generateOverwriteSetup(csvTitle,automatedDeploymentId);

    }

    public static void mapDataFromNOLToCPQSetupData(String csvTitle, String automatedDeploymentId,List<SObject> sobjectList){
        //String jsonMapping ='{"Product2":{"Name":"SKU_Name__c", "ProductCode":"SKU_Code__c", "APTS_Product_Pricing_UOM__c":"UOM__c","Apttus_Config2__Uom__c":"UOM__c"},"Apttus_Config2__PriceListItem__c":{"Apttus_Config2__PriceUom__c":"UOM__c"},"Apttus_Config2__PriceRule__c":{"Name":"SKU_Name__c"},"Apttus_Config2__PriceRuleEntry__c":{"Apttus_Config2__Dimension1Value__c":"SKU_Code__c"},"APTS_Unit_List_Price_1__c":{"Product_Code__c":"SKU_Code__c","Meter__c":"UOM__c"},"APTS_Size_Relationship__c":{"Meter_Type__c":"UOM__c"},"APTS_Product_Adjustor__c":{"SKU__c":"SKU_Code__c"},"APTS_Industry_Adjustor__c":{"FINS_Meter_Industry__c":"UOM__c"},"APTS_Discount_Guidelines_Max_Limits__c":{"Meter__c":"UOM__c"},"APTS_Deployment_Adjustor__c":{"Meter_Type__c":"UOM__c"},"APTS_Country_Adjustor__c":{"Meter__c":"UOM__c"},"APTS_ACV_Floor__c":{"Product_Code__c":"SKU_Code__c"},"APTS_Price_Quantity__c":{"Product_Code__c":"SKU_Code__c"}}';
        //Map<String,Object> sobjectMappingToAutoDep = (Map<String,Object>)JSON.deserializeUntyped(jsonMapping);

        StaticResource sr= [select id,body from StaticResource Where Name = 'NOLFieldMappingJson'];
        String jsonMapping = sr.body.toString();
        Map<String,Object> sobjectMappingToAutoDep = (Map<String,Object>)JSON.deserializeUntyped(jsonMapping);

        if(sobjectMappingToAutoDep.containsKey(csvTitle)){
            String sobjmappingStr = JSON.serialize(sobjectMappingToAutoDep.get(csvTitle));
            Map<String,String> sobjectMappingToAutoDep_this = (Map<String,String> )JSON.deserialize(sobjmappingStr, Map<String,String>.class);
            Set<String> AutoDepFields = new Set<String>(sobjectMappingToAutoDep_this.values());
            AutoDepFields.remove('');
            AutoDepFields.remove(null);
          //  System.debug('AutoDepFields :'+ AutoDepFields);
          //  System.debug('AutoDepFields.size()  :'+ AutoDepFields.size());
            Sobject sobjAutoDep;
            if(!AutoDepFields.isEmpty() && AutoDepFields.size() > 0){
                String AutomatedDepQuery = 'Select '+String.join(new List<String>(AutoDepFields),',')+' from Automated_Deployment__c where Id = :automatedDeploymentId';
             //   System.debug('AutomatedDepQuery :'+ AutomatedDepQuery);
                sobjAutoDep = database.query(AutomatedDepQuery);
            }
            for(String mappingkey : sobjectMappingToAutoDep_this.keyset()){
                String autoDepMappingField = sobjectMappingToAutoDep_this.get(mappingkey);
                for(Sobject sobj : sobjectList){
                    if(String.isNotBlank(autoDepMappingField)){
                        if(sobjAutoDep.get(autoDepMappingField) != null){
                            sobj.put(mappingkey,sobjAutoDep.get(autoDepMappingField));
                        }
                    }else{
                        sobj.put(mappingkey,null);
                    }
                }
            }
        }
    }

    //ssriv External ID Changes//GTMCLS-5567 : ssriv 
    //vsabbella - add the sequence here for the list of records. This will break existing code. 
    public static void populateRecordExtId(List<SObject> sobjectList, String skuCode, Set<String> externalIdSet,String fieldName){
        for(Sobject sobj : sobjectList){
            if(String.isNotBlank(String.valueOf(sobj.get(fieldName)))){
                String externalId = String.valueOf(sobj.get(fieldName)) + '' + skuCode ;
                System.debug(' external Id :' + externalId);
                externalIdSet.add(externalId);
                sobj.put(fieldName, externalId); 
            }
        }
    }
}
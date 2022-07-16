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
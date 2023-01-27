/*
Name            : NOLAutomationUtil
Author          : Somya Srivastava
Release         : 1.0
Functionality   : Contains all Util methods used in NOL Autmation POC
Created         : June-22-2022

History                                                           
-------                                                           
VERSION   AUTHOR                DATE            DETAIL               
  1.0     Somya Srivastava.     6/22/2022       INITIAL DEVELOPMENT 
  2.0     Somya Srivastava      9/2/2022        GTMCLS-5567 : Csv archive into static resource and External ID append SKU code changes 
  3.0     Sagar Gunjal          11/3/2022       GTMCLS-5302 -Renewal Transaction: AEF= Active, Same -Added for Committed Usage SKU.
  */

public with sharing class NOLAutomationUtil {
    public NOLAutomationUtil() {    
    }

        // reuse this method in other methods where parsing is required.   
        public static String parseCSVtoJSONandFormat(ContentVersion contentVersionObj){
            // calling CSV to Json parser method
            String jsonString = parceCsvToJson(contentVersionObj);        
            String jsonStringPostSpecialChar = jsonString.replaceAll('\n','').replaceAll('\r','');
            String jsonStringfinal = jsonStringPostSpecialChar.replaceAll('TRUE','true').replaceAll('FALSE','false');
            String jsonStringfinal2 = jsonStringfinal.replaceAll('"\\b\\w*_?Date_?(__c)?\\w*\\b":\\s*"",?','');

            System.debug('jsonStringfinal of >>>'  + contentVersionObj.Title + ' :: ' +jsonStringfinal2);
            return     jsonStringfinal2;
        }
        
         // method for parsin CSV files from Static Resources,    //GTMCLS-5567 : ssriv 
         public static String parseStaticResourceToJsonAndFormat(String csvString, String csvTitle){
            // calling CSV to Json parser method
            String jsonString = convernCsvStringToJSon(csvString, csvTitle);        
            String jsonStringPostSpecialChar = jsonString.replaceAll('\n','').replaceAll('\r','');
            String jsonStringfinal = jsonStringPostSpecialChar.replaceAll('TRUE','true').replaceAll('FALSE','false');
            String jsonStringfinal2 = jsonStringfinal.replaceAll('"\\b\\w*_?Date_?(__c)?\\w*\\b":\\s*"",?','');

            System.debug('Check jsonStringfinal >>>'  + csvTitle + ' :: ' +jsonStringfinal2);
            return     jsonStringfinal2;
        }

        public static void getSobjectWithParentReference(String SObjectName, List<String> lookupFields, Object ObjInstance, 
                                                        Sobject sobj,Schema.DescribeSobjectResult dsr,String skuCode, Set<String> externalIdSet){
            Map<String, Schema.SObjectField> fieldsMap = dsr.fields.getMap();
            
            for(String LookupField : lookupFields){
                System.debug(LoggingLevel.ERROR, 'LookupField : '+LookupField);  
                //System.debug(LoggingLevel.ERROR, '222'+ObjInstance); 
                Map<String,Object> objectRelationShipMap = (Map<String,Object>)ObjInstance;
                //System.debug(LoggingLevel.ERROR, '333'+objectRelationShipMap); 
                Schema.DescribeFieldResult dfr = fieldsMap.get(LookupField).getDescribe();
                    
                String parentSobjRelationShipName = dfr.getRelationshipName();
                System.debug(LoggingLevel.ERROR, 'parentSobjRelationShipName : '+parentSobjRelationShipName); 
    
                Sobject sobjInstance = dfr.getReferenceTo()[0].newSobject();// find out a better way. This will fail if there are multiple looks to the same parent
                //System.debug(LoggingLevel.ERROR, '444'+parentSobjRelationShipName); 
    
                //Map<String,Object> parentObj = (Map<String,Object>) objectRelationShipMap.get(parentSobjRelationShipName);
                String parentExternalIdReference  = parentSobjRelationShipName+'.APTS_Ext_ID__c';
                System.debug(LoggingLevel.ERROR, 'parentExternalIdReference :'+parentExternalIdReference); 
                
                String jsonObj1 = JSON.serialize(objectRelationShipMap);
                Map<String,String> jsonStringMap = ( Map<String,String>)JSON.deserialize(jsonObj1,  Map<String,String>.class);
                
                if(String.isEmpty(jsonStringMap.get(parentExternalIdReference))){
                    continue;
                }
                System.debug(LoggingLevel.ERROR, 'parentExternalIdReference :value : '+objectRelationShipMap.get(parentExternalIdReference).toString()); 
                
                String externalIdOfLookupRecord  = objectRelationShipMap.get(parentExternalIdReference).toString() + '' + skuCode;//GTMCLS-5567 : ssriv 
                System.debug(' externalIdOfLookupRecord : ' + externalIdOfLookupRecord);//GTMCLS-5567 : ssriv 
                System.debug(' externalIdSet : ' + externalIdSet);//GTMCLS-5567 : ssriv 

                String externalId =  (!externalIdSet.isEmpty() && externalIdSet.contains(externalIdOfLookupRecord)) ?  externalIdOfLookupRecord : objectRelationShipMap.get(parentExternalIdReference).toString() ;//GTMCLS-5567 : ssriv 
                System.debug(' externalId : ' + externalId);//GTMCLS-5567 : ssriv 

                sobjInstance.put('APTS_Ext_ID__c', externalId);
                if(sobjInstance!=null)
                sobj.putSObject(parentSobjRelationShipName, sobjInstance);
                
                //System.debug(LoggingLevel.ERROR, 'sobj'+sobj);
                
            }
           // Insert sobj;
            
        }

        public static void insertRecordsAndUpdateNol(List<Sobject> listToInsert, ID SobjectId,Schema.SObjectField ftoken){
        
            
            System.debug('listToInsert : ' + listToInsert + ' ftoken :' + ftoken);
            Database.UpsertResult[] results ;

            if(ftoken != null)
            results = Database.upsert(listToInsert, ftoken, false);

             

            String sobjectTypeStr = SobjectId.getSobjectType().getDescribe().getName();
            System.debug(LoggingLevel.DEBUG, '@@'+sobjectTypeStr);
            String sobjectQuery = 'SELECT ID , RollBackIds__c from '+sobjectTypeStr+ ' where Id =:SobjectId';
            Sobject nolSobject = Database.query(sobjectQuery);
            System.debug(LoggingLevel.DEBUG, '@@2:'+nolSobject.get('RollBackIds__c'));
            String rollBackIdStr = nolSobject.get('RollBackIds__c')!=null?(String)nolSobject.get('RollBackIds__c'):'';
            //System.debug(Logginglevel.Debug, rollbackIds);
            //Sobject sobjectTypeStr = SobjectId.getSobjectType().newSObject(SobjectId);

            //Automated_Deployment__c ac = [SELECT ID , RollBackIds__c from Automated_Deployment__c where ID =: automatedDepId];
            //if(rollBackIdStr!= null){
            //    rollBackIdStr = rollBackIdStr+ ac.RollBackIds__c;
            //}

            for (Database.UpsertResult sr : results) {
                if (sr.isSuccess()) {
                    if(sr.isCreated()){
                        System.debug('Successfully inserted ' + sr.getId());
                        if(String.isblank(rollBackIdStr)){
                            rollBackIdStr = sr.getId();
                        }else{
                            rollBackIdStr= rollBackIdStr + ',' + sr.getId();
                        }
                    } else{
                        System.debug('Successfully updated ' + sr.getId());
                    }              
                }else{
                    for(Database.Error err : sr.getErrors()) {
                      System.debug('Error Message : ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                } 
            }
            System.debug('rollBackIdStr: '+ rollBackIdStr);
            nolSobject.put('RollBackIds__c',rollBackIdStr);// = rollBackIdStr;
            System.debug('Automated deployment : '+ nolSobject);
            update nolSobject;

        }
          
          
    public static String parceCsvToJson(ContentVersion contentVersionObj){    
         String CSV = contentVersionObj.VersionData.toString();
         CSV+='\n';
         //System.debug(LoggingLevel.Error, '@@@@'+CSV);
         //String encodedCSV = EncodingUtil.urlEncode(CSV, 'UTF-8');
         String JSONString = convernCsvStringToJSon(CSV,contentVersionObj.Title);//GTMCLS-5567 : ssriv 
         return JSONString;
    }

    //GTMCLS-5567 : ssriv 
    public static String convernCsvStringToJSon(String CSV, String csvTitle){
        System.debug(LoggingLevel.Error, '@@@@'+CSV);
        
        try{ 
            String cell = '';
            List<String> row = new List<String>();
            List<List<String>> listedCSV = new List<List<String>>();
            Integer headerIndex = 0;
            Integer rowIndex = 0;
            Boolean InsideDoubleQuotes = false;
            Integer countOfDoubleQuotesInsideDoubleQuote = 0;
            Integer countOfNewLineInsideDoubleQuote = 0;
            Integer countOfCommaInsideDoubleQuote = 0;
            // Need logic to split string into lines
            for(Integer index = 0; index < CSV.length(); index++) {
               String character = CSV.substring(index, index+1);
               if (character == '"') {
                       if(InsideDoubleQuotes == false) {
                           InsideDoubleQuotes = true;
                           countOfDoubleQuotesInsideDoubleQuote += 1;
                           cell += character;
                       } else {
                           countOfDoubleQuotesInsideDoubleQuote += 1;
                           cell += character;
                       }
                   } 
               else if(character == ',') {
                       if(countOfDoubleQuotesInsideDoubleQuote > 0 && math.mod(countOfDoubleQuotesInsideDoubleQuote,2) == 0) {
                           InsideDoubleQuotes = false;
                       }
                       if(InsideDoubleQuotes == false) {
                           String unescapedCSV = cell.unescapeCsv();
                           row.add(unescapedCSV);
                           cell = '';
                           headerIndex += 1;
                           countOfCommaInsideDoubleQuote = 0;
                       } else {
                           cell += character;
                           countOfCommaInsideDoubleQuote += 1;

                       }
                   }
               else if (character == '\n') {
                       if(countOfDoubleQuotesInsideDoubleQuote > 0 && math.mod(countOfDoubleQuotesInsideDoubleQuote,2) == 0) {
                           InsideDoubleQuotes = false;
                       }
                       if(InsideDoubleQuotes == false) {
                           String unescapedCSV = cell.unescapeCsv();                           
                           row.add(unescapedCSV);
                           //System.debug('row>>>'+row);
                           cell = '';
                           listedCSV.add(new List<String>(row));
                           row.clear();
                           rowIndex += 1;
                           countOfNewLineInsideDoubleQuote = 0;
                   } else {
                           cell += character;
                           countOfNewLineInsideDoubleQuote += 1;
                       }
                   } 
               else {
                   cell += character;
               }
            }
          
            // To Build JSON String
            String JSONString = '[';
            try
            {
                for(Integer i = 1; i < listedCSV.size(); i++){
                    List<String> rowValues = listedCSV[i];
                    JSONString = JSONString + '{';
                    for(Integer j = 0; j < rowValues.size(); j++) {
                        //calling escapeJava here  i= row, j=column,
                        JSONString = JSONString +'"' + listedCSV[0][j] + '"' + ':' + '"' + listedCSV[i][j].escapeJava() + '"' + ',';
                    }
                    JSONString = JSONString.removeEnd(',');
                    JSONString = JSONString  + '},';    
                }
            } 
           catch (Exception e) {
                System.debug('Error Occured whie parsing'+e.getMessage());
            }
           
            JSONString = JSONString.removeEnd(',');
            JSONString = JSONString + ']';
        
            System.debug('JSONString After Parse Of >>>>'+ csvTitle + ' JSON :' + JSONString);
            return JSONString;
        } 
        catch (Exception e) {
           System.debug(LoggingLevel.ERROR, e.getMessage());
           throw new AuraHandledException(e.getMessage());
        }
    }

    public static Automated_Deployment__c getProductDetails(String automatedDeploymentId){
        Automated_Deployment__c ad = [SELECT ID, SKU_Code__c,SKU_Name__c,UOM__c,Upgrade_fee_Multiplier__c,CategoryHierarchy__c from Automated_Deployment__c where ID =: automatedDeploymentId]; //GTMCLS-5302 -added parameter-Upgrade_fee_Multiplier__c

        return ad;
    }

    public static APTS_Config_Setting__c getNOLAutmationSettings(){//APTS_Config_Setting__c

        //NOL_Automation_Settings__c nolAutmation = NOL_Automation_Settings__c.getValues('NOL Automation');
        //System.debug('nolAutmation :' + nolAutmation);

        String data_set_name = APTS_ConfigKeyValueService.getString('CommittedUsage_ProductCode_Reference');
        APTS_Config_Setting__c nolAutmation = APTS_Config_Setting__c.getValues(data_set_name);
        return nolAutmation;
    }
    //NOLAutomationUtil.generateOverwriteSetup('APTS_Unit_List_Price_1__c','aTP8M00000037v7WAA');

    public static void generateOverwriteSetup(String csvTitle, Id automatedDeploymentId){
        List<Sobject> sobjectList = Database.query('Select Id,name from Overwrite_Setup__c ' + ' where Overwrite_Type_API__c =:csvTitle and Automated_Deployment__c =:automatedDeploymentId' );
        Map<String,String> csvInfoMap = NOLAutomationUtil.getCSVCategorization(csvTitle);
        if(  (sobjectList.size()==0 && csvInfoMap.keySet().size()>0)){
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{'Overwrite_Setup__c'});
            Schema.DescribeSObjectResult descResult_0 = descResult[0];
            Sobject sobj = descResult_0.getSObjectType().newSObject();
            sobj.put('Overwrite_Type_API__c',csvInfoMap.get('Overwrite_Type_API__c'));
            sobj.put('Automated_Deployment__c',automatedDeploymentId);
            sobj.put('CSV_Type__c',csvInfoMap.get('CSV_Type__c'));//
            sobj.put('Setup_Data_Type__c',csvInfoMap.get('Setup_Data_Type__c'));
            sobj.put('Setup_Data_Features__c',csvInfoMap.get('Setup_Data_Features__c'));
            Insert sobj;
        }
    }

    public static Map<String,String> getCSVCategorization(String csvtitle){
        //String csvtitle = 'Apttus_Config2__PriceListItem__c';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Automated_Deployment_Input_Fields' LIMIT 1];
        String jsonbody = sr.Body.toString();
        Object overWriteSetupObject =   JSON.deserializeUntyped(jsonbody);
        Map<String,Object> overWriteSetupMap =  (Map<String,Object>) overWriteSetupObject;
        //System.debug(LoggingLevel.Debug, '-->'+overWriteSetupMap.get('Apttus_Config2__PriceListItem__c'));
        if(!overWriteSetupMap.containsKey(csvtitle)){
            return new Map<String,String>();
        }
        Object csvInfo = overWriteSetupMap.get(csvtitle);
        String csvInfoJSON = JSON.serialize(csvInfo);
        Map<String,String> catMap = (Map<String,String>)JSON.deserialize(csvInfoJSON, Map<String,String>.class);
        System.debug(LoggingLevel.Debug, catMap.get('fields'));

        return catMap;
        
    }

    public static void overWriteParentReference(String SObjectName, List<String> lookupFields, Object ObjInstance, Sobject sobj,Schema.DescribeSobjectResult dsr,String skuCode, Set<String> externalIdSet, String categoryHierarchy){
       
        List<Apttus_Config2__ClassificationHierarchy__c> classHier_List= [Select Id,name,Apttus_Config2__Label__c,APTS_Ext_ID__c  from Apttus_Config2__ClassificationHierarchy__c where ID=: categoryHierarchy and Apttus_Config2__ProductCount__c >0];
        if(SObjectName=='Apttus_Config2__ProductClassification__c'){
            sobj.put('Apttus_Config2__ClassificationId__c',classHier_List[0].Id);
            sobj.putSObject('Apttus_Config2__ClassificationId__r', null);
        }
        if(SObjectName=='Apttus_Config2__ProductOptionComponent__c'){
            List<Apttus_Config2__ProductOptionGroup__c> optionGroupList = [Select Id,name,Apttus_Config2__OptionGroupId__r.Apttus_Config2__Label__c  from Apttus_Config2__ProductOptionGroup__c where Apttus_Config2__OptionGroupId__c =: categoryHierarchy];
            sobj.put('Apttus_Config2__ProductOptionGroupId__c',optionGroupList[0].Id);
            sobj.putSObject('Apttus_Config2__ProductOptionGroupId__r', null);
        }        
        return;
      }

     // reuse this method in other methods to cast this to ApexObjectType
        /*public static void castJSONToApexObjectType(String ApexObjectType){
            //String jsonstr = '[{"attributes":{"type":"Product2","url":"/services/data/v51.0/sobjects/Product2/01t80000003DEX8AAO"},"Name":"Cloud Connect for Third Party Payroll - LDP"},{"attributes":{"type":"Product2","url":"/services/data/v51.0/sobjects/Product2/01t80000003DEX9AAO"},"Name":"Cloud Connect for Workday Payroll - LDP"}]';
            String jsonstr = '[{"Name":"Test Product Dynamic Insert"}]';

            system.debug(jsonstr);
            List<Product2> pr = (List<Sobject>)JSON.deserialize(jsonstr, Type.forName('List<Product2>'));
            System.debug(LoggingLevel.ERROR,'-->'+pr[0].getSobjectType());
        }*/

        //NOLAutomationUtil.clstestParentReference();

        /*public static void testParentReference(){
            //String JsonPriceListItem = '[{"Apttus_Config2__ChargeType__c":"Expansion Fee","Apttus_Config2__ProductId__r":{"APTS_Ext_ID__c":"01t4X0000072ESqQAMpocv6"},"Apttus_Config2__PriceListId__r":{"APTS_Ext_ID__c":"a9qc00000004HqqAAE"}}]';
            String JsonPriceListItem = '[{"Apttus_Config2__ChargeType__c":"Expansion Fee","Apttus_Config2__ProductId__r.APTS_Ext_ID__c":"01t4X0000072ESqQAMpocv6","Apttus_Config2__PriceListId__r.APTS_Ext_ID__c":"a9qc00000004HqqAAE"}]';
            List<Object> objectList = (List<Object>) json.deserializeUntyped(JsonPriceListItem);
            List<SObject> sobjlist = (List<SObject>)JSON.deserialize(JsonPriceListItem, Type.forName('List<Apttus_Config2__PriceListItem__c>'));

            Sobject sobj = sobjlist[0];
            
            String SObjectName = 'Apttus_Config2__PriceListItem__c';
            List<String> lookupFields = new List<String>{'Apttus_Config2__ProductId__c','Apttus_Config2__PriceListId__c'};
            Object ObjInstance = objectList[0];

            String[] types = new String[]{SObjectName};

            // Make the describe call
            Schema.DescribeSobjectResult[] res = Schema.describeSObjects(types);
            Schema.DescribeSobjectResult dsr= res[0];
            getSobjectWithParentReference(SObjectName,lookupFields,ObjInstance,sobj,dsr);

        }*/
        
   /* public static void testMapping(){
        Map<SObjectField,SObjectField> fieldMapping = new  Map<SObjectField,SObjectField>{ 
            Automated_Deployment__c.SKU_Name__c => Product2.Name
            // Automated_Deployment__c.UOM__c => Apttus_Config2__PriceListItem__c.Apttus_Config2__PriceUom__c     
            };

            
            List<String> AutomatedDepQueryFieldStrings= new List<String>();
            for(Schema.SObjectField sfield : fieldMapping.keySet()){
                AutomatedDepQueryFieldStrings.add(sfield.getDescribe().getLocalName());

            }
            String automatedDeploymentId = 'aSM8J000000001TWAQ';
            String AutomatedDepQuery = 'Select '+String.join(AutomatedDepQueryFieldStrings,',')+' from Automated_Deployment__c where Id = :automatedDeploymentId';
            Sobject sobjAutoDep = database.query(AutomatedDepQuery);
            List<Sobject> sobjList = new List<Sobject>();
            String sobjectProductType='List<Product2>';
            string sobjJson = '[{"Name":"Committed Usage(POC-V91)","APTS_Ext_ID__c":"01t4X0000072ESqQAMpocv91","ProductCode":"cmuse-v91"}]';
            sobjList = (List<Sobject>)JSON.deserialize(sobjJson, Type.forName(sobjectProductType));

            for(Schema.SObjectField automatedFieldMappingKey : fieldMapping.keySet()){
                Schema.SObjectField sobjMapvalue = fieldMapping.get(automatedFieldMappingKey);
                System.debug(LoggingLevel.ERROR, '-->'+fieldMapping.get(automatedFieldMappingKey).getDescribe().getReferenceTo());
                
                System.debug(LoggingLevel.ERROR, 'desc:'+fieldMapping.get(automatedFieldMappingKey).getDescribe());
            }

            System.debug(LoggingLevel.ERROR, 'fieldmap1'+sobjList[0].get('Name'));
    }

    public static void testMapping2(){

                //price list item  object mapping is updated.
        String jsonMapping ='{"Product2":{"Name":"SKU_Name__c"},"Apttus_Config2__PriceListItem__c":{"Apttus_Config2__PriceUom__c":"UOM__c"}}';

        Map<String,Object> sobjectMappingToAutoDep = (Map<String,Object>)JSON.deserializeUntyped(jsonMapping);//(jsonMapping, Map<String,String>.class);
        String automatedDeploymentId = 'aSM8J000000001TWAQ';
        String csvTitle = 'Apttus_Config2__PriceListItem__c';
        List<Sobject> sobjList = new List<Sobject>();
        String sobjectPriceListType='List<Apttus_Config2__PriceListItem__c>';
        //string sobjJson = '[{"Name":"Committed Usage(POC-V91)","APTS_Ext_ID__c":"01t4X0000072ESqQAMpocv91","ProductCode":"cmuse-v91"}]';
        String sobjJson = '[{"APTS_Ext_ID__c":"a9p7500000004EiAA211v91","Apttus_Config2__PriceUom__c":"Messages"},{"APTS_Ext_ID__c":"a9p7500000004EiAA311v91","Apttus_Config2__PriceUom__c":"Messages"}]';

        sobjList = (List<Sobject>)JSON.deserialize(sobjJson, Type.forName(sobjectPriceListType));

        if(sobjectMappingToAutoDep.containsKey(csvTitle)){
        String sobjmappingStr = JSON.serialize(sobjectMappingToAutoDep.get(csvTitle));
        Map<String,String> sobjectMappingToAutoDep_this = (Map<String,String> )JSON.deserialize(sobjmappingStr, Map<String,String>.class);
        Set<String> AutoDepFields = new Set<String>(sobjectMappingToAutoDep_this.values());
        String AutomatedDepQuery = 'Select '+String.join(new List<String>(AutoDepFields),',')+' from Automated_Deployment__c where Id = :automatedDeploymentId';
        Sobject sobjAutoDep = database.query(AutomatedDepQuery);
        for(String mappingkey : sobjectMappingToAutoDep_this.keyset()){
            String autoDepMappingField = sobjectMappingToAutoDep_this.get(mappingkey);
            for(Sobject sobj : sobjList){
                sobj.put(mappingkey,sobjAutoDep.get(autoDepMappingField));
            }
         }
        }

        System.debug(LoggingLevel.ERROR, sobjList[0].get('Apttus_Config2__PriceUom__c'));
    }

    public static void testMapping3(){
        //Product object mapping is updated
        String jsonMapping ='{"Product2":{"Name":"SKU_Name__c"},"Apttus_Config2__PriceListItem__c":{"Apttus_Config2__PriceUom__c":"UOM__c"}}';
        Map<String,Object> sobjectMappingToAutoDep = (Map<String,Object>)JSON.deserializeUntyped(jsonMapping);//(jsonMapping, Map<String,String>.class);

        String csvTitle = 'Product2';
        String automatedDeploymentId = 'aSM8J000000001TWAQ';
        List<Sobject> sobjList = new List<Sobject>();
        String sobjectProductType='List<Product2>';
        string sobjJson = '[{"Name":"Committed Usage(POC-V91)","APTS_Ext_ID__c":"01t4X0000072ESqQAMpocv91","ProductCode":"cmuse-v91"}]';
        sobjList = (List<Sobject>)JSON.deserialize(sobjJson, Type.forName(sobjectProductType));

        if(sobjectMappingToAutoDep.containsKey(csvTitle)){
        String sobjmappingStr = JSON.serialize(sobjectMappingToAutoDep.get(csvTitle));
        Map<String,String> sobjectMappingToAutoDep_this = (Map<String,String> )JSON.deserialize(sobjmappingStr, Map<String,String>.class);
        Set<String> AutoDepFields = new Set<String>(sobjectMappingToAutoDep_this.values());
        String AutomatedDepQuery = 'Select '+String.join(new List<String>(AutoDepFields),',')+' from Automated_Deployment__c where Id = :automatedDeploymentId';
        Sobject sobjAutoDep = database.query(AutomatedDepQuery);
        for(String mappingkey : sobjectMappingToAutoDep_this.keyset()){
            String autoDepMappingField = sobjectMappingToAutoDep_this.get(mappingkey);
            for(Sobject sobj : sobjList){
                sobj.put(mappingkey,sobjAutoDep.get(autoDepMappingField));
            }
         }
        }

        System.debug(LoggingLevel.ERROR, sobjList[0].get('Name'));
 }

 // NOLAutomationUtil.testInitiateUpload('','aSM8J000000001OWAQ');
 public static void testInitiateUpload(String csvString, String automatedDeploymentId){
    
    List<String> csvStringsList = new List<String>{csvString};
    List<String> csvToProcess = new List<String>();

      Integer batchNo=0;
      //String automatedDeploymentId = 'aSM8J000000001OWAQ';
      String csvToProcessString = csvStringsList.get(batchNo);
      csvToProcess = csvToProcessString.split(',');
      System.debug(LoggingLevel.ERROR, '-->'+csvToProcess);
      String query= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: automatedDeploymentId and Title In:csvToProcess';
      List<ContentVersion> ContentVersionList = (List<ContentVersion>)database.query(query);
      //ContentVersion cv = (ContentVersion) cvsobj;
      NOLFileUploadBatchApexHelper.initiateDataLoad(csvToProcess,ContentVersionList,automatedDeploymentId);
}*/

    public static void insertRecordsAndUpdateNol_Test(){
        //----------------------------------------------

        String sobjectProductType='List<Product2>';
        string sobjJson = '[{"Name":"Committed Usage(POC-V91.1)","APTS_Ext_ID__c":"01t4X0000072ESqQAMpocv91.1","ProductCode":"cmuse-v91.1"}]';
        String csvTitle = 'Product2';
        List<Sobject> listToInsert = (List<Sobject>) JSON.deserialize(sobjJson, Type.forName(sobjectProductType));
        System.debug(LoggingLevel.DEBUG, '-->'+listToInsert);

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
            //----------------------------------------------
    }
        
}
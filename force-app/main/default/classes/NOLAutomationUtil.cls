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
    
                Sobject sobjInstance = dfr.getReferenceTo()[0].newSobject();
                //System.debug(LoggingLevel.ERROR, '444'+parentSobjRelationShipName); 

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
        Automated_Deployment__c ad = [SELECT ID, SKU_Code__c,SKU_Name__c,UOM__c,Upgrade_fee_Multiplier__c,Apttus_Catalog_Header__c from Automated_Deployment__c where ID =: automatedDeploymentId]; //GTMCLS-5302 -added parameter-Upgrade_fee_Multiplier__c

        return ad;
    }

    public static APTS_Config_Setting__c getNOLAutmationSettings(){//APTS_Config_Setting__c

        String data_set_name = APTS_ConfigKeyValueService.getString('CommittedUsage_ProductCode_Reference');
        APTS_Config_Setting__c nolAutmation = APTS_Config_Setting__c.getValues(data_set_name);
        return nolAutmation;
    }

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
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Automated_Deployment_Input_Fields' LIMIT 1];
        String jsonbody = sr.Body.toString();
        Object overWriteSetupObject =   JSON.deserializeUntyped(jsonbody);
        Map<String,Object> overWriteSetupMap =  (Map<String,Object>) overWriteSetupObject;
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
        
}
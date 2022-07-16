/*
Name            : NOLAutomationUtil
Author          : Somya Srivastava
Release         : 1.0
Functionality   : Contains all Util methods used in NOL Autmation POC
Created         : June-22-2022

History                                                           
-------                                                           
VERSION   AUTHOR                DATE          DETAIL               
  1.0     Somya Srivastava.     6/22/2022   INITIAL DEVELOPMENT 
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
    
        // reuse this method in other methods to cast this to ApexObjectType
        public static void castJSONToApexObjectType(String ApexObjectType){
            //String jsonstr = '[{"attributes":{"type":"Product2","url":"/services/data/v51.0/sobjects/Product2/01t80000003DEX8AAO"},"Name":"Cloud Connect for Third Party Payroll - LDP"},{"attributes":{"type":"Product2","url":"/services/data/v51.0/sobjects/Product2/01t80000003DEX9AAO"},"Name":"Cloud Connect for Workday Payroll - LDP"}]';
            String jsonstr = '[{"Name":"Test Product Dynamic Insert"}]';

            system.debug(jsonstr);
            List<Product2> pr = (List<Sobject>)JSON.deserialize(jsonstr, Type.forName('List<Product2>'));
            System.debug(LoggingLevel.ERROR,'-->'+pr[0].getSobjectType());
        }

        //NOLAutomationUtil.clstestParentReference();

        public static void testParentReference(){
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

        }

        public static void getSobjectWithParentReference(String SObjectName, List<String> lookupFields, Object ObjInstance, Sobject sobj,Schema.DescribeSobjectResult dsr){
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
                System.debug(LoggingLevel.ERROR, 'parentExternalIdReference :value'+objectRelationShipMap.get(parentExternalIdReference).toString()); 
    
                sobjInstance.put('APTS_Ext_ID__c',objectRelationShipMap.get(parentExternalIdReference).toString());
                if(sobjInstance!=null)
                sobj.putSObject(parentSobjRelationShipName, sobjInstance);
                
                //System.debug(LoggingLevel.ERROR, 'sobj'+sobj);

                
            }
           // Insert sobj;
            
        }

        public static void insertRecordsAndUpdateNol(List<Sobject> listToInsert, ID automatedDepId,Schema.SObjectField ftoken){

            System.debug('listToInsert : ' + listToInsert + ' ftoken :' + ftoken);
            Database.UpsertResult[] results ;

            if(ftoken != null)
            results = Database.upsert(listToInsert, ftoken, false);
            else
            results = Database.upsert(listToInsert, false);

            String rollBackIdStr = '';

            Automated_Deployment__c ac = [SELECT ID , RollBackIds__c from Automated_Deployment__c where ID =: automatedDepId];

            if(ac.RollBackIds__c!= null){
                rollBackIdStr = rollBackIdStr+ ac.RollBackIds__c;
            }

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
            ac.RollBackIds__c = rollBackIdStr;
            System.debug('Automated deployment : '+ ac);
            update ac;

        }
          
          
    public static String parceCsvToJson(ContentVersion contentVersionObj){
        try{ 
         String CSV = contentVersionObj.VersionData.toString();
         CSV+='\n';
         //System.debug(LoggingLevel.Error, '@@@@'+CSV);
         //String encodedCSV = EncodingUtil.urlEncode(CSV, 'UTF-8');
         
         System.debug(LoggingLevel.Error, '@@@@'+CSV);

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
            try{
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
            } catch (Exception e) {System.debug('Error Occured whie parsing'+e.getMessage());}
            
            JSONString = JSONString.removeEnd(',');
            JSONString = JSONString + ']';
         
           System.debug('JSONString After Parse Of >>>>'+ contentVersionObj.Title + ' JSON :' + JSONString);
            return JSONString;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Automated_Deployment__c getProductCodeName(String automatedDeploymentId){
        //Automated_Deployment__c ad = [SELECT ID, SKU_Code__c,SKU_Name__c from Automated_Deployment__c where ID =: automatedDeploymentId];
        Automated_Deployment__c ad = [SELECT ID, SKU_Code__c,SKU_Name__c,UOM__c from Automated_Deployment__c where ID =: automatedDeploymentId];

        return ad;
    }

    public static NOL_Automation_Settings__c getNOLAutmationSettings(){

        NOL_Automation_Settings__c nolAutmation = NOL_Automation_Settings__c.getValues('NOL Automation');
        System.debug('nolAutmation :' + nolAutmation);
        return nolAutmation;
    }

    public static void testMapping(){
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

 public static void testInitiateUpload(String csvString){
    
List<String> csvStringsList = new List<String>{csvString};
List<String> csvToProcess = new List<String>();

        Integer batchNo=0;
        String automatedDeploymentId = 'aSM8J000000001OWAQ';
        String csvToProcessString = csvStringsList.get(batchNo);
        csvToProcess = csvToProcessString.split(',');
System.debug(LoggingLevel.ERROR, '-->'+csvToProcess);
String query= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: automatedDeploymentId and Title In:csvToProcess';
List<ContentVersion> ContentVersionList = (List<ContentVersion>)database.query(query);
    //ContentVersion cv = (ContentVersion) cvsobj;
    NOLFileUploadBatchApexHelper.initiateDataLoad(csvToProcess,ContentVersionList,automatedDeploymentId);
 }
        
}
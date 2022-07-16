public with sharing class BatchApexV1 implements Database.Batchable<SObject>,Database.Stateful{
    
    //SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId ='aSM8J000000000fWAA' and Title In :cpqcsv0


    Integer batchNo;
    String query;
    String automatedDeploymentId;
    //public final String cpqcsv0 = 'Product2,Apttus_Config2__PriceList__c';
    public final String cpqcsv0 = 'Product2';
    //,Apttus_Config2__PriceListItem__c,Apttus_Config2__ClassificationName__c,Apttus_Config2__ClassificationHierarchy__c,Apttus_Config2__ProductClassification__c,Apttus_Config2__ProductOptionGroup__c,Apttus_Config2__ProductOptionComponent__c,Apttus_Config2__PriceRuleset__c,Apttus_Config2__PriceRule__c,Apttus_Config2__PriceRuleEntry__c,APTS_Price_Quantity__c,APTS_Unit_List_Price_1__c,APTS_Size_Relationship__c,APTS_Product_Adjustor__c,APTS_Industry_Adjustor__c,APTS_Discount_Guidelines_Max_Limits__c,APTS_Deployment_Adjustor__c,APTS_Country_Adjustor__c,APTS_ACV_Floor__c';
    //public final String cpqcsv0 = 'Product2';
    List<String> csvStringsList = new List<String>{cpqcsv0};
    Map<String,List<String>> objectRefMapping = new Map<String,List<String>>{'Apttus_Config2__PriceListItem__c'=> new List<String>{'Apttus_Config2__ProductId__c','Apttus_Config2__PriceListId__c'}};
    //Map<String, Sobject> mapExtIdVsSobject = new Map<String, Sobject>{'Apttus_Config2__ProductId' => Product2.class};
  
    public BatchApexV1(String automatedDepId, Integer BatchNum) {
        batchNo=BatchNum;
        automatedDeploymentId = automatedDepId;
        query= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: automatedDeploymentId and Title In:csvStringsList';
        
    }
  
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC ,List<ContentVersion> contentVersionList){
      
        system.debug('records==>'+contentVersionList);
        
        String csvString = csvStringsList.get(batchNo);
        List<String> csvToProcess = csvString.split(',');

        Map<String, ContentVersion> titleVsContentDocMap = new Map<String, ContentVersion>();

        for(ContentVersion cv :contentVersionList){  
            titleVsContentDocMap.put(cv.Title, cv);
        }

        for(String csvTitle : csvToProcess){

            System.debug(LoggingLevel.ERROR,'Processing CSV for Object :'+csvTitle);
            ContentVersion cvInstance = titleVsContentDocMap.get(csvTitle);
            String sobjJSON = NOLAutomationUtil.parseCSVtoJSONandFormat(cvInstance);

            String apexType = 'List<'+csvTitle+'>';
            List<SObject> sobjectList = (List<Sobject>)JSON.deserialize(sobjJSON, Type.forName(apexType));

            Schema.SObjectField ftoken = Product2.Fields.APTS_Ext_ID__c;
            NOLAutomationUtil.insertRecordsAndUpdateNol(sobjectList,automatedDeploymentId,ftoken);

          
      
        }
        updateNolAutomationSetting();
    }

    

    
    public void uploadData(ContentVersion contentVersionObj , String listApexObjectType,  String apexObjectType, Schema.SObjectField ftoken){
       
        // calling CSV to Json parser method
        String jsonStringfinal2 = NOLAutomationUtil.parseCSVtoJSONandFormat(contentVersionObj);
        List<Sobject> sObjList = new List<Sobject>();
        List<Sobject> updatedSObjList = new List<Sobject>();
        if('List<Product2>'.equalsIgnoreCase(listApexObjectType))
        {
            sObjList = castJSONToListApexObjectType(jsonStringfinal2,listApexObjectType);
            updatedSObjList = populateProdCode(automatedDeploymentId, sObjList);
            sObjList.clear();
            sObjList.addAll(updatedSObjList);

        }else{
            List<Object> listOfJsontoObject = (List<Object>)Json.deserializeUntyped(jsonStringfinal2);
            List<string > finalJsonStringList = new List<string>();
            Automated_Deployment__c ac = NOLAutomationUtil.getProductCodeName(automatedDeploymentId);
            for(Object obj : listOfJsontoObject){
                finalJsonStringList.add(JSON.serialize(obj));
            }
            
            for(string s: finalJsonStringList){
                Sobject sobj = castJSONToApexObjectType(s , apexObjectType);
                sObjList.add(sobj);
            }
            
            Map<String, Sobject> mapSobj = new Map<String,Sobject>();
            for(Sobject sObj: sObjList){
                mapSobj.put((String)sObj.get('APTS_Ext_ID__c'), sObj);
            }

            for(Object obj : listOfJsontoObject){
                Map<String,Object> jsonMap =  (Map<String,Object>) obj;
                if(jsonMap.get('APTS_Ext_ID__c') != null){
                    Sobject objSobj = mapSobj.get((String)jsonMap.get('APTS_Ext_ID__c'));

                    //Setting up lookup references using external ID
                   /* List<String> lookupFieldsList = objectRefMapping.get(apexObjectType);

                    for(String lookupFieldStr: lookupFieldsList){
                        String extId =  (String)jsonMap.get(lookupFieldStr);
                    }*/
                    String extIdProd =  (String)jsonMap.get('Apttus_Config2__ProductId');
                    String extIdPriceList =  (String)jsonMap.get('Apttus_Config2__PriceListId');
                    Product2 probj = new Product2(APTS_Ext_ID__c = extIdProd);
                    Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(APTS_Ext_ID__c = extIdPriceList);
                    

                    SObjectField prodLookup = Apttus_Config2__PriceListItem__c.Apttus_Config2__ProductId__c;
                    String prodRelationShipName = prodLookup.getDescribe().getRelationshipName();

                    SObjectField priceListLookup = Apttus_Config2__PriceListItem__c.Apttus_Config2__PriceListId__c;
                    String prRelationShipName = priceListLookup.getDescribe().getRelationshipName();

                    objSobj.putSObject(prodRelationShipName,probj);
                    objSobj.putSObject(prRelationShipName,priceList);

                    if(ac.UOM__c!=null)
                    objSobj.put('Apttus_Config2__PriceUom__c',ac.UOM__c);
                    updatedSObjList.add(objSobj);
                }
            }
            
            sObjList.clear();
            sObjList.addAll(updatedSObjList);
        }

        if(sObjList.size()>0 && !sObjList.isempty()){
          
            NOLAutomationUtil.insertRecordsAndUpdateNol(sObjList,automatedDeploymentId,ftoken);
        } 
    }  
    
   
    
   
 public static List<Sobject> castJSONToListApexObjectType(String jsonStringfinal2,String listApexObjectType){

    List<Sobject> sObjList = (List<Sobject>)JSON.deserialize(jsonStringfinal2, Type.forName(listApexObjectType));
    System.debug(LoggingLevel.ERROR,'-->'+sObjList[0].getSobjectType());
    return sObjList;
}

public static Sobject castJSONToApexObjectType(String jsonStringfinal2,String apexObjectType){

    Sobject sObj = (Sobject)JSON.deserialize(jsonStringfinal2, Type.forName(apexObjectType));
    return sObj;
}

public List<Sobject> populateProdCode(String automatedDeploymentId, List<Sobject> sObjList){
    List<Sobject> updatedsObjList = new List<Sobject>();
        Automated_Deployment__c ac = NOLAutomationUtil.getProductCodeName(automatedDeploymentId);
        
        for(Sobject sObj : sObjList){

            sObj.put('ProductCode',ac.SKU_Code__c);
            sObj.put('Name',ac.SKU_Name__c);
            if(ac.UOM__c!=null){
                sObj.put('APTS_Product_Pricing_UOM__c',ac.UOM__c);
                sObj.put('Apttus_Config2__Uom__c',ac.UOM__c);
            }
            
            updatedsObjList.add(sObj);
        }
    
    return updatedsObjList;

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
            Database.executebatch(new TestBatchClass(automatedDeploymentId,batchNo));
          }
    }

}
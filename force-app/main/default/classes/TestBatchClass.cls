public with sharing class TestBatchClass implements Database.Batchable<SObject>,Database.Stateful{
    Integer batchNo;
    String query;
    String automatedDeploymentId;
    public final String cpqcsv0 = 'Product2,Apttus_Config2__PriceList__c,Apttus_Config2__PriceListItem__c,Apttus_Config2__ClassificationName__c,Apttus_Config2__ClassificationHierarchy__c,Apttus_Config2__ProductClassification__c,Apttus_Config2__ProductOptionGroup__c,Apttus_Config2__ProductOptionComponent__c,Apttus_Config2__PriceRuleset__c,Apttus_Config2__PriceRule__c,Apttus_Config2__PriceRuleEntry__c,APTS_Price_Quantity__c,APTS_Unit_List_Price_1__c,APTS_Size_Relationship__c,APTS_Product_Adjustor__c,APTS_Industry_Adjustor__c,APTS_Discount_Guidelines_Max_Limits__c,APTS_Deployment_Adjustor__c,APTS_Country_Adjustor__c,APTS_ACV_Floor__c';
    //public final String cpqcsv0 = 'Product2';
    List<String> csvStringsList = new List<String>{cpqcsv0};
    Map<String,List<String>> objectRefMapping = new Map<String,List<String>>{'Apttus_Config2__PriceListItem__c'=> new List<String>{'Apttus_Config2__ProductId','Apttus_Config2__PriceListId'}};
    //Map<String, Sobject> mapExtIdVsSobject = new Map<String, Sobject>{'Apttus_Config2__ProductId' => Product2.class};
  
  
    public TestBatchClass(String automatedDepId, Integer BatchNum){
        batchNo=BatchNum;
        automatedDeploymentId = automatedDepId;
        query= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: automatedDeploymentId';
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC ,List<ContentVersion> contentVersionObj){
      
        system.debug('records==>'+contentVersionObj);
        
        String csvString = csvStringsList.get(batchNo);
        List<String> csvToProcess = csvString.split(',');

        Map<String, ContentVersion> titleVsContentDocMap = new Map<String, ContentVersion>();

        for(ContentVersion cv :contentVersionObj){  
            titleVsContentDocMap.put(cv.Title, cv);
        }

        for(String csvTitle : csvToProcess){

            if(titleVsContentDocMap!= null && titleVsContentDocMap.containsKey(csvTitle)){
                Schema.SObjectField ftoken;

                if(csvTitle == 'Product2'){
                    System.debug('Inside Product2');
                    ftoken = Product2.Fields.APTS_Ext_ID__c;
                    uploadData(titleVsContentDocMap.get(csvTitle), 'List<Product2>',null, ftoken); 
                }        
                if(csvTitle== 'Apttus_Config2__PriceListItem__c'){
                    System.debug('Inside Apttus_Config2__PriceListItem__c');
                    ftoken = Apttus_Config2__PriceListItem__c.Fields.APTS_Ext_ID__c;
                    uploadData(titleVsContentDocMap.get(csvTitle), null, 'Apttus_Config2__PriceListItem__c',ftoken); 
                }  
            }
      
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
    
   
    
   /* public  void uploadPriceListItemUpdated(contentVersion contentVersionObj ){
        // calling CSV to Json parser method
        String jsonStringfinal2 = NOLAutomationUtil.parseCSVtoJSONandFormat(contentVersionObj);
        
        List<Object> listOfJsontoObject = (List<Object>)Json.deserializeUntyped(jsonStringfinal2);
        List<string > finalJsonStringList = new List<string>();
        Automated_Deployment__c ac = NOLAutomationUtil.getProductCodeName(automatedDeploymentId);
        for(Object obj : listOfJsontoObject){
            finalJsonStringList.add(JSON.serialize(obj));
        }
        
        List<Apttus_Config2__PriceListItem__c> pricelistitemlist = new List<Apttus_Config2__PriceListItem__c>();
        for(string s: finalJsonStringList){
            Apttus_Config2__PriceListItem__c objPriceListItem = (Apttus_Config2__PriceListItem__c)JSON.deserialize(s, Apttus_Config2__PriceListItem__c.class);
            pricelistitemlist.add(objPriceListItem);
        }
        Map<String, Apttus_Config2__PriceListItem__c> mapPriceListItem = new Map<String,Apttus_Config2__PriceListItem__c>();
        for(Apttus_Config2__PriceListItem__c objPli: pricelistitemlist){
            mapPriceListItem.put(objPli.APTS_Ext_ID__c, objPli);
        }
        List<Apttus_Config2__PriceListItem__c> pliListToUpdate =new List<Apttus_Config2__PriceListItem__c>();
        for(Object obj : listOfJsontoObject){
            Map<String,Object> jsonMap =  (Map<String,Object>) obj;
            if(jsonMap.get('APTS_Ext_ID__c') != null){
                Apttus_Config2__PriceListItem__c pricelisttemObj = mapPriceListItem.get((String)jsonMap.get('APTS_Ext_ID__c'));
                //Setting up lookup references using external ID
                String extIdProd =  (String)jsonMap.get('Apttus_Config2__ProductId');
                String extIdPriceList =  (String)jsonMap.get('Apttus_Config2__PriceListId');
                Product2 probj = new Product2(APTS_Ext_ID__c = extIdProd);
                Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(APTS_Ext_ID__c = extIdPriceList);
                //use sobject.put method - somya

                SObjectField prodLookup = Apttus_Config2__PriceListItem__c.Apttus_Config2__ProductId__c;
                String prodRelationShipName = prodLookup.getDescribe().getRelationshipName();

                SObjectField priceListLookup = Apttus_Config2__PriceListItem__c.Apttus_Config2__PriceListId__c;
                String prRelationShipName = priceListLookup.getDescribe().getRelationshipName();

                pricelisttemObj.putSObject(prodRelationShipName,probj);
                pricelisttemObj.putSObject(prRelationShipName,priceList);

                if(ac.UOM__c!=null)
                   pricelisttemObj.Apttus_Config2__PriceUom__c = ac.UOM__c;


                //pricelisttemObj.Apttus_Config2__ProductId__r = probj;
               // pricelisttemObj.Apttus_Config2__PriceListId__r = priceList;
                pliListToUpdate.add(pricelisttemObj);
            }
        }
        
        if(pliListToUpdate != null && !pliListToUpdate.isEmpty()){
            // Database.DeleteResult deleteResult = Database.delete( contentVersionObj.contentDocumentId, true );
            Schema.SObjectField ftoken = Apttus_Config2__PriceListItem__c.Fields.APTS_Ext_ID__c;
            NOLAutomationUtil.insertRecordsAndUpdateNol(pliListToUpdate,automatedDeploymentId,ftoken);
        }
    }
    */
    // reuse this method in other methods to cast this to ApexObjectType
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

    public  static void updateList(List<Product2> productList){

        Integer i = 0;

        for(Product2 objProd : productList){
            objProd.Name = 'Changed' + i;
            i++;
        }

    }
}
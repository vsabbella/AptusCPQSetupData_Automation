public with sharing class NOLAutomationScriptsTester {
    public NOLAutomationScriptsTester() {

    }
    //NOLAutomationScriptsTester.initiateDataLoad('')
    public static void initiateDataLoad(String automatedDeploymentId){


        List<String> lookupFields = new List<String>{'Apttus_Config2__ProductId__c','Apttus_Config2__PriceListId__c'};
        Map<String,List<String>> lookupFieldMap = new Map<String,List<String>>{'Apttus_Config2__PriceListItem__c'=>lookupFields};

        String csvString = 'Product2,Apttus_Config2__PriceListItem__c';
        List<String> csvToProcess = csvString.split(',');
        String query= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: automatedDeploymentId and Title In:csvToProcess';
        List<ContentVersion> contentVersionList = Database.query(query);
        system.debug('records==>'+contentVersionList);

        Map<String, ContentVersion> titleVsContentDocMap = new Map<String, ContentVersion>();

        for(ContentVersion cv :contentVersionList){  
            titleVsContentDocMap.put(cv.Title, cv);
        }
        Schema.DescribeSobjectResult[] resList = Schema.describeSObjects(csvToProcess);

        Map<String,Schema.DescribeSobjectResult> dsrMap = new Map<String,Schema.DescribeSobjectResult>{'Product2'=>resList[0],'Apttus_Config2__PriceListItem__c'=>resList[1]};

        for(String csvTitle : csvToProcess){


            


            System.debug(LoggingLevel.ERROR,'Processing CSV for Object :'+csvTitle);
            System.debug(LoggingLevel.ERROR,'Processing CSV for Object :'+titleVsContentDocMap);
            
            ContentVersion cvInstance = titleVsContentDocMap.get(csvTitle);
            System.debug(LoggingLevel.ERROR,'cvInstance'+cvInstance);

            String sobjJSON = NOLAutomationUtil.parseCSVtoJSONandFormat(cvInstance);

            String apexType = 'List<'+csvTitle+'>';
            //List<SObject> sobjectList = (List<Sobject>)JSON.deserialize(sobjJSON, Type.forName(apexType));

            Schema.DescribeSobjectResult[] dsrList = Schema.describeSObjects(new List<String>{csvTitle});
            Schema.DescribeSobjectResult dsr =dsrList[0];
            //List<Object> objectList = (List<Object>) json.deserializeUntyped(sobjJSON);
            List<SObject> sobjectList = new List<SObject>();
            if(lookupFieldMap.containsKey(csvTitle)){
                List<String> lookupFields_Sobj = lookupFieldMap.get(csvTitle);
                List<Object> objectList = (List<Object>) json.deserializeUntyped(sobjJSON);
                for(Object obj:objectList){
                    String ObjJSON = JSON.serialize(obj);
                    SObject sobj = (SObject)JSON.deserialize(ObjJSON, Type.forName(csvTitle));
                    
                    
                    //NOLAutomationUtil.getSobjectWithParentReference(csvTitle,lookupFields_Sobj,obj,sobj,dsr);
                    //getSobjectWithParentReference(csvTitle,lookupFields,ObjInstance,sobj,dsr);
                    sobjectList.add(sobj);

                }
               
            }else{
                sobjectList = (List<Sobject>)JSON.deserialize(sobjJSON, Type.forName(apexType));
            }
            
            Map<String, Schema.SObjectField> fieldsMap = dsr.fields.getMap();
            //Schema.SObjectField ftoken = Product2.Fields.APTS_Ext_ID__c;
            Schema.SObjectField ftoken = fieldsMap.get('apts_ext_id__c');
            NOLAutomationUtil.insertRecordsAndUpdateNol(sobjectList,automatedDeploymentId,ftoken);
            System.debug(LoggingLevel.ERROR, 'sobjeclist'+sobjectList);
            //Insert sobjectList;

          
      
        }
        //updateNolAutomationSetting();
        

    }
}
/*
Name            : Downloadcsvctrl
Author          : vsabbella
Release         : 1.0
Functionality   : To process and download csv file for a committed usage product type. 
Created         : 11/21/2022

History                                                           
-------                                                           
VERSION  AUTHOR            DATE             DETAIL          Change Request
1.0      vsabbella         11/21/2022       GTMCLS-5739     Initial development
2.0      Sagar Gunjal      1/3/2023         GTMCLS-6035     On click, Generate button it should direct to the proper page
*/

public with sharing class Downloadcsvctrl {
    
    public Downloadcsvctrl() {

    }
    //Downloadcsvctrl.initiateDownload2()
    public static void initiateDownload2(){
        List<String> csvToProcess = new List<String>{'APTS_Price_Matrix__c'};
        //String automatedDeploymentId = 'aTM6t0000004CALGA2';
        String automatedDeploymentId = ApexPages.currentPage().getParameters().get('Id');
        String query= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: automatedDeploymentId and Title In:csvToProcess';
        ContentVersion cv = database.query(query);
        String sobjJSON = NOLAutomationUtil.parseCSVtoJSONandFormat(cv);
        //String sobjJSON2 = '[{"APTS_Adjustment_Type__c": "Price Override","APTS_Ext_ID__c": "aRp7500000003N9CAI","APTS_End_Date__c": "2122-12-31","APTS_UOM__c": "Input Rows(M)"  },  {"APTS_Adjustment_Type__c": "Price Override","APTS_Ext_ID__c": "aRp7500000003NACAY","APTS_End_Date__c": "2122-12-31","APTS_UOM__c": "Input Rows(M)"  },  {"APTS_Adjustment_Type__c": "Price Override","APTS_Ext_ID__c": "aRp7500000003NBCAY","APTS_End_Date__c": "2122-12-31","APTS_UOM__c": "Input Rows(M)"}]';
        //String sobjJSON3 ='[  {    "APTS_Adjustment_Type__c": "Price Override",    "APTS_Ext_ID__c": "aRp7500000003N9CAI",    "APTS_End_Date__c": "2122-12-31",    "APTS_Adjustment_Amount__c": "1734802"  },  {    "APTS_Adjustment_Type__c": "Price Override",    "APTS_Ext_ID__c": "aRp7500000003NACAY",    "APTS_End_Date__c": "2122-12-31",    "APTS_Adjustment_Amount__c": "1805514"  },  {    "APTS_Adjustment_Type__c": "Price Override",    "APTS_Ext_ID__c": "aRp7500000003NBCAY",    "APTS_End_Date__c": "2122-12-31",    "APTS_Adjustment_Amount__c": "1875052"  }]';
        //sobjJSON = extractBusinessInputFields(sobjJSON,csvToProcess[0]);
        
        System.debug(LoggingLevel.ERROR, 'json string-->'+sobjJSON);
        
        String csvString = JsontoCSVUtility.getCSVString(sobjJSON);
        System.debug(LoggingLevel.ERROR, 'csv string'+csvString);
    }
    
//Downloadcsvctrl.initiateDownload
    public static PageReference initiateDownload(){
        
        String overWriteSetupId = ApexPages.currentPage().getParameters().get('Id');
        Overwrite_Setup__c ovsetup = [Select Id,Name,Overwrite_Type_API__c,Automated_Deployment__c,Automated_Deployment__r.SKU_Code__c from Overwrite_Setup__c where Id = :overWriteSetupId];
        String automatedDeploymentId = ovsetup.Automated_Deployment__c;
        String skuCode = ovsetup.Automated_Deployment__r.SKU_Code__c;
        System.assertNotEquals(ovsetup.Overwrite_Type_API__c, null, 'Overwrite Type is required.');
        //System.debug(LoggingLevel.DEBUG, skuCode);
        //List<String> csvToProcess = new List<String>{'APTS_Price_Matrix__c'};
        String csvToProcess0 = ovsetup.Overwrite_Type_API__c;

        //List<String> csvToProcess = new List<String>{'APTS_Price_Matrix__c'};
        
        //String automatedDeploymentId = [Select Id,Name,Automated_Deployment__c from Overwrite_Setup__c where Id = :overWriteSetupId].Automated_Deployment__c;
        String query= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: automatedDeploymentId and Title =:csvToProcess0';
        ContentVersion cv = database.query(query);
        String sobjJSON = NOLAutomationUtil.parseCSVtoJSONandFormat(cv);
        //String sobjJSON2 = '[{"APTS_Adjustment_Type__c": "Price Override","APTS_Ext_ID__c": "aRp7500000003N9CAI","APTS_End_Date__c": "2122-12-31","APTS_UOM__c": "Input Rows(M)"  },  {"APTS_Adjustment_Type__c": "Price Override","APTS_Ext_ID__c": "aRp7500000003NACAY","APTS_End_Date__c": "2122-12-31","APTS_UOM__c": "Input Rows(M)"  },  {"APTS_Adjustment_Type__c": "Price Override","APTS_Ext_ID__c": "aRp7500000003NBCAY","APTS_End_Date__c": "2122-12-31","APTS_UOM__c": "Input Rows(M)"}]';
        //String sobjJSON3 ='[  {    "APTS_Adjustment_Type__c": "Price Override",    "APTS_Ext_ID__c": "aRp7500000003N9CAI",    "APTS_End_Date__c": "2122-12-31",    "APTS_Adjustment_Amount__c": "1734802"  },  {    "APTS_Adjustment_Type__c": "Price Override",    "APTS_Ext_ID__c": "aRp7500000003NACAY",    "APTS_End_Date__c": "2122-12-31",    "APTS_Adjustment_Amount__c": "1805514"  },  {    "APTS_Adjustment_Type__c": "Price Override",    "APTS_Ext_ID__c": "aRp7500000003NBCAY",    "APTS_End_Date__c": "2122-12-31",    "APTS_Adjustment_Amount__c": "1875052"  }]';
        sobjJSON = extractBusinessInputFields(sobjJSON,csvToProcess0);
        String csvString = JsontoCSVUtility.getCSVString(sobjJSON);
        System.debug(LoggingLevel.ERROR, 'csv string'+csvString);
        System.debug(LoggingLevel.ERROR, 'sobjJSON from init download:'+sobjJSON);
        //return null;

        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = csvToProcess0+'.csv';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = UserInfo.getUserId();//Owner of the file
        cVersion.Title = csvToProcess0;//Name of the file
        cVersion.VersionData = Blob.valueOf(csvString);//File content
        Insert cVersion;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = overWriteSetupId;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
        //GTMCLS-6035 -start
        PageReference demoPage;
        string url = '';
        if(UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t'){
            url = '/lightning/r/Overwrite_Setup__c/'+ overWriteSetupId +'/view';
        }else{
            url = '/'+overWriteSetupId;
        }
        demoPage = new pagereference(url);
        demoPage.setRedirect(true);
        return demoPage;
    //GTMCLS-6035 -end
    }
    
    //Downloadcsvctrl.extractBusinessInputFields();
    public static String extractBusinessInputFields(String sobjJSON,String csvTitle){
       Map<String,String> csvInfoMap = NOLAutomationUtil.getCSVCategorization(csvTitle);
       String businessInputFieldsStr = csvInfoMap.get('fields');
       Set<String> businessInputFields = new Set<String>(businessInputFieldsStr.split(','));
        if(businessInputFields!=null && businessInputFields.size()>0){
            //Map<String,String> fieldValueByAPI_minialFields= new Map<String,String>();
            //List<String> jsonList_minimalfields = new List<String>();
            List<Sobject> sobjList_minimalFields = new List<Sobject>();
            
            List<Object> objectList = (List<Object>) json.deserializeUntyped(sobjJSON);
            System.debug(LoggingLevel.ERROR, 'size.-->'+objectList.size());
                
            for(Object obj:objectList){
                    String ObjJSON = JSON.serialize(obj);
                    //SObject sobj = (SObject)JSON.deserialize(ObjJSON, Type.forName(csvTitle));
                    //Map<String,String> fieldValueByNameMap_Original = (Map<String,String>) JSON.deserialize(ObjJSON, Map<String,String>.class);
                    //SObject sobj_minFields = (SObject)Type.forName(csvTitle).newInstance();
                    //fieldValueByAPI_minialFields  
                    //
                    System.debug(LoggingLevel.ERROR, 'unfiltered JSON:'+ObjJSON);
                    Map<String,Object> objMap = (Map<String,Object>)obj;
                    
                    //Map<String,Object> objMap2 = (Map<String,Object>)obj;
                    
                    System.debug(LoggingLevel.DEBUG, 'objMap-->'+objMap.keySet());
                    for(String str : objMap.keySet()){
                        if(!businessInputFields.contains(str)){
                            objMap.remove(str);
                            //objMap2.put(str,objMap.get(str));

                        }
                    }
                   
                   System.debug(LoggingLevel.DEBUG, 'objMap after-->'+objMap.keySet());
                   obj =(Object)objMap;
                   String json_obj1 = JSON.serialize(obj);
                   System.debug(LoggingLevel.DEBUG, 'filteredjson:'+json_obj1);
                        
                }
                 System.debug(LoggingLevel.DEBUG, 'filteredjson List:'+JSON.serialize(objectList) );
                 String jsonMinimalFields = JSON.serialize(objectList);
                //System.debug(LoggingLevel.ERROR, 'JSON Minimal Fields:'+jsonMinimalFields);
                return jsonMinimalFields;
                //return sobjJSON;
        }
        return sobjJSON;//return unfiltered at this return statement. 
        
    }
}
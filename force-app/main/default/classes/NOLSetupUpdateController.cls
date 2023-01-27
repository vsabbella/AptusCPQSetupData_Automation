/*
Name            : NOLSetupUpdateController
Author          : Venkata Sabbella
Release         : 1.0
Functionality   : NOLSetupUpdateController called from Update Setup to update any data uploaded as part of upload activities.
Created         : 12-22-2022

History                                                           
-------                                                           
VERSION  AUTHOR            DATE             DETAIL          Change Request
1.0      Venkata Sabella   12-22-2022       Initial Dev     Update the setup after batch upload of the CPQ setup data.
2.0      Somya Srivastava  1-4-2023         GTMCLS-6087     External Id Fix for custom setting 
*/

public with sharing class NOLSetupUpdateController{
    @AuraEnabled	
    public static String loadData( Id setupUpdateId ) {
        String strMessage;
        System.debug('setupUpdateId>>'+ setupUpdateId);
        try{
            if ( setupUpdateId != null ) { 
                    NOLSetupUpdateController.updateSetup(setupUpdateId);
                    
            }else{
                strMessage = 'setupUpdateId is Null';  
                 return strMessage ;
                //throw new AuraHandledException(strMessage);
            }               
        }catch(Exception e){
       
            throw new AuraHandledException('An Error has occured. Please try again or contact System Administrator.'+e.getMessage()+ 'Stack Trace :' + e.getStackTraceString() );            
        }
        return strMessage ;
    }
    
    public static Id executeBatchJob(Id setupUpdateId,Integer batchnum){
        return null;
    }  
  
    public static void updateSetup(Id setUpUpdateId){
        Overwrite_Setup__c ovsetup = [Select Id,Name,Overwrite_Type_API__c,Automated_Deployment__c,Automated_Deployment__r.SKU_Code__c from Overwrite_Setup__c where Id = :setUpUpdateId];
        
        String automatedDeploymentId = ovsetup.Automated_Deployment__c;
        String skuCode = ovsetup.Automated_Deployment__r.SKU_Code__c;
        System.assertNotEquals(ovsetup.Overwrite_Type_API__c, null, 'Overwrite Type is required.');
        String csvToProcess0 = ovsetup.Overwrite_Type_API__c;
        Set<String> externalIdSet =new Set<String>();
        //get master data
        String query_master= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: automatedDeploymentId and Title =:csvToProcess0';
        ContentVersion cv_master = database.query(query_master);
        String sobjJSON_master = NOLAutomationUtil.parseCSVtoJSONandFormat(cv_master);
        List<Object> objList = ( List<Object>)JSON.deserializeUntyped(sobjJSON_master);
        List<Object> objList_0 =new List<Object>{objList[0]};
        String sobjJSON_template_0 = JSON.serialize(objList_0);
        System.debug(LoggingLevel.DEBUG, 'sobjJSON_template_0 -->'+sobjJSON_template_0); 

        Map<String,List<String>> lookupFieldMap = NOLFileUploadBatchApexHelper.getLookUpDataForSobjects();
        system.debug('lookupFieldMap :'+lookupFieldMap );

        Automated_Deployment__c ac = NOLAutomationUtil.getProductDetails(automatedDeploymentId); 

        List<Sobject> sobjectList_Template = NOLFileUploadBatchApexHelper.processRecords(csvToProcess0, sobjJSON_template_0,lookupFieldMap,automatedDeploymentId,skuCode,externalIdSet,ac.Apttus_Catalog_Header__c); //GTMCLS-5567 : ssriv
        Sobject sobjectList_Template0 = sobjectList_Template[0];
        
        //get updated data
        String query_updatedData= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: setUpUpdateId and Title =:csvToProcess0';
        ContentVersion cv_updateddata = database.query(query_updatedData);
        String sobjJSON_updated = NOLAutomationUtil.parseCSVtoJSONandFormat(cv_updateddata);
        List<Object> objectList = (List<Object>)JSON.deserializeUntyped(sobjJSON_updated);

        List<Sobject> sobjList_ModifiedFromCSV = new List<Sobject>();
        
        for(Object obj: objectList){
            Sobject sobject_Template_Clone = sobjectList_Template0.clone(false,false,false,false);
            Map<String,Object> objbyStringMap = ( Map<String,Object>)obj;
            String updatedJSON = JSON.serialize(obj);
            Sobject updatedSobject = (Sobject)JSON.deserialize(updatedJSON,Type.forName(csvToProcess0));

            for(String fieldAPI : objbyStringMap.keySet()){
                sobject_Template_Clone.put(fieldAPI,updatedSobject.get(fieldAPI));
            }

            //GTMCLS-6087 starts
            String externalId = '';
            if(!NOLFileUploadBatchApexHelper.customSettingsNameSet.contains(csvToProcess0)){
                externalId = updatedSobject.get('APTS_Ext_ID__c')!=null?(String)updatedSobject.get('APTS_Ext_ID__c'):'';
                externalId = externalId.trim();
                externalId+=skuCode.trim();
                sobject_Template_Clone.put('APTS_Ext_ID__c',externalId);
            }else{
                externalId = updatedSobject.get('Name')!=null?(String)updatedSobject.get('Name'):'';
                externalId = externalId.trim();
                externalId+=skuCode.trim();
                sobject_Template_Clone.put('Name',externalId);
            }
            sobjList_ModifiedFromCSV.add(sobject_Template_Clone);
            //GTMCLS-6087 ends
        }

        System.debug(LoggingLevel.DEBUG, 'size: --->'+sobjList_ModifiedFromCSV.size());
        NOLFileUploadBatchApexHelper.importProcessedRecords(sobjList_ModifiedFromCSV, setUpUpdateId, csvToProcess0,false);

    }

    public static void deleteSetup(Id setUpUpdateId){
        Overwrite_Setup__c ovsetup = [Select Id,Name,RollBackIds__c,Automated_Deployment__c,Automated_Deployment__r.SKU_Code__c from Overwrite_Setup__c where Id = :setUpUpdateId];
        String rollBackIdStr = ovsetup.RollBackIds__c!=null?ovsetup.RollBackIds__c:'';
        List<Id> rollBackIds = rollBackIdStr.split(',');
        if(rollBackIds.size()>0){
            String SobjectTypeStr = rollBackIds[0].getSobjectType().getDescribe().getName();
            List<Sobject> sobjs_for_delete = Database.query('Select Id from '+SobjectTypeStr+ ' where Id In:rollBackIds');
            Delete sobjs_for_delete;
        }
    }


}
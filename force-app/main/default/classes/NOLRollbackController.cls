/*
Name            : NOLRollbackController
Author          : Somya Srivastava
Release         : 1.0
Functionality   : Ability to rollback inserted records of CPQ objects
Created         : 06-22-2022

History                                                           
-------                                                           
VERSION  AUTHOR            DATE              DETAIL         Change Request
1.0 -    Somya             06-22-2022        GTMCLS-5347    Initial development of Rollback of inserted CPQ data from NOL      
  2.0    vsabbella     11/8/2022   GTMCLS-5559 - Bypass widgets settings 

*/
public with sharing class NOLRollbackController { 


    public NOLRollbackController() {
    }

    @AuraEnabled(cacheable = false)
    public static void deleteRecords(String automatedDepId){
        try {
            system.debug(' Inside delete records');

            Automated_Deployment__c autDeploymentObj = [SELECT ID , RollBackIds__c,SKU_Code__c from Automated_Deployment__c where ID =: automatedDepId];
            String strRollBackId = autDeploymentObj.RollBackIds__c;

            if(String.isNotBlank(strRollBackId)){
                List<String> rollBackIdList = strRollBackId.split(',');
                System.debug('rollBackIdList : ' + rollBackIdList);
            
            Map<SObjectType, List<ID>> sObjTypeVsIdsMap  = getSobjectTypeVsIdsMap(rollBackIdList);

            for (SObjectType sObjType : sObjTypeVsIdsMap.keySet()) {
                
                List<ID> idList = sObjTypeVsIdsMap.get(sObjType);

                SObject[] records = Database.query('SELECT Id, Name from ' + sObjType + ' WHERE Id in :idList');
                System.debug('Records to delete :' + records);
                delete records;
            }
            autDeploymentObj.RollBackIds__c = '';
            update autDeploymentObj;
            }

            removeProdCodeFromNolSettings(autDeploymentObj.SKU_Code__c);
            removeBypassWidgetSettings();
            

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<SObjectType, List<ID>> getSobjectTypeVsIdsMap(List<ID> rollBackIdList){
        Map<SObjectType, List<ID>> sObjTypeVsIdsMap = new Map<SObjectType, List<ID>> ();

        for(ID rollBackId :  rollBackIdList){
            SObjectType type = rollBackId.getSobjectType();
            if(sObjTypeVsIdsMap.containsKey(type)){
                List<ID> existingIdsList = sObjTypeVsIdsMap.get(type);
                existingIdsList.add(rollbackId);
                sObjTypeVsIdsMap.put(type,existingIdsList);
            }else{
                sObjTypeVsIdsMap.put(type, new List<ID>{rollBackId});
            }
        }
        return sObjTypeVsIdsMap;
    }

    public static void removeProdCodeFromNolSettings(String skuCode){

        if(String.isNotBlank(skuCode)){
            APTS_Config_Setting__c nol = NOLAutomationUtil.getNOLAutmationSettings();
            if(nol != null && String.isNotBlank(nol.APTS_Value__c)){
                String qtyRoundUpProdCodes  = nol.APTS_Value__c;
                String regex = '\\b' + skuCode + '\\b';
                String result  = qtyRoundUpProdCodes.replaceAll(regex,'').replaceAll('^\\s*,+\\s*|\\s*,+\\s*$','').replaceAll(',,',',');
                System.debug('result :'+result);
                nol.APTS_Value__c = result;
                update nol;
            }
                   
        }

    }

    public static void removeBypassWidgetSettings(){
        String COMMITTED_USAGE_UOM = APTPS_Constants.PRICE_UOM_COMMITED_USAGE;
        APTS_Product_Price_Uom__c byPassUOM= APTS_Product_Price_Uom__c.getInstance(COMMITTED_USAGE_UOM);
        if(byPassUOM!=null){
           Delete byPassUOM;
        }
    }
  
}
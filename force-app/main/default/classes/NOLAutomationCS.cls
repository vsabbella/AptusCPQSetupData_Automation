/*
Name            : NOLAutomationCS
Author          : Venkata sabbella
Release         : 1.0
Functionality   : Ability to import the Product code from custom settings.
Created         : July-27-2022

Modification History:
Date            Author             Date       Change  

*/

public with sharing class NOLAutomationCS {
    
    public static List<APTS_Config_Setting__c> getProdCodeforQtyRoundup(){
        String data_set_name = APTS_ConfigKeyValueService.getString('CommittedUsage_ProductCode_Reference');
        APTS_Config_Setting__c mc = APTS_Config_Setting__c.getValues(data_set_name);
        List<APTS_Config_Setting__c> nolcs = new List<APTS_Config_Setting__c>{mc};
        return nolcs;

    }

    public static String getProdCodeStrforQtyRoundup(){
        String str = '';
        List<APTS_Config_Setting__c> nolcs = getProdCodeforQtyRoundup();
        
        
        if(nolcs!=null && nolcs.size()>0)
          {
            str = nolcs[0].APTS_Value__c;
          }
          return str;

    }

    public static void setProdCodeforQtyRoundup(String prodCode){
        List<APTS_Config_Setting__c> nolcs = getProdCodeforQtyRoundup();
        APTS_Config_Setting__c nol=nolcs[0];
        String str =nol.APTS_Value__c;
        List<String> prodcodes = str.split(',');
        prodcodes.add(prodCode);
        String csvprodcodes = String.join(prodcodes,',');
        nol.APTS_Value__c = csvprodcodes;
        update nol;    

    }

    public NOLAutomationCS() {

    }

}
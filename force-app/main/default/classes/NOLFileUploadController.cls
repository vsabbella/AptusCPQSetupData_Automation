/*
Name            : NOLFileUploadController
Author          : Sagar Gunjal
Release         : 1.0
Functionality   : GTMCLS- Ability to import the data of Template into records
Created         : May-20-2022

Modification History:
VERSION		AUTHOR            DATE          DETAIL               
  1.0		Sagar Gunjal.     5/20/2022   INITIAL DEVELOPMENT
  2.0		Sagar Gunjal.     6/28/2022   From Quick Action to invoke the batch process	 
*/

public with sharing class NOLFileUploadController{
    @AuraEnabled	
    public static String loadData( Id automatedDeploymentId ) {
        String strMessage;
        System.debug('automatedDeploymentId>>'+ automatedDeploymentId);
        try{
            if ( automatedDeploymentId != null ) { 
               List<ContentVersion> contentVersionlist = [ SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion WHERE FirstPublishLocationId =: automatedDeploymentId ];
               // For(ContentVersion cv :contentVersionlist){ 
        
                 /* if(cv.Title == 'Product2' || cv.Title == 'Apttus_Config2__PriceList__c' || cv.Title == 'Apttus_Config2__PriceListItem__c' ||
                       cv.Title =='Apttus_Config2__PriceRuleEntry__c' || cv.Title =='Apttus_Config2__PriceRule__c' || cv.Title == 'Apttus_Config2__PriceRuleSet__c'||
                       cv.Title =='Apttus_Config2__ClassificationName__c' || cv.Title =='Apttus_Config2__ClassificationHierarchy__c' || cv.Title =='Apttus_Config2__ProductClassification__c'||
                       cv.Title =='Apttus_Config2__ProductOptionGroup__c' || cv.Title =='Apttus_Config2__ProductOptionComponent__c' || cv.Title =='Apttus_Config2__ProductGroup__c'||
                       cv.Title =='Apttus_Config2__ProductGroupMember__c' ||  cv.Title =='Apttus_Config2__ProductAttributeGroup__c' || cv.Title =='Apttus_Config2__ProductAttributeGroupMember__c' ||
                       cv.Title =='Apttus_Config2__ProductAttribute__c' || cv.Title =='Apttus_Config2__PriceDimension__c' || cv.Title =='Apttus_Config2__RelatedPriceListItem__c' ||
                       cv.Title =='Apttus_Config2__PriceMatrix__c' || cv.Title =='Apttus_Config2__PriceMatrixEntry__c' || cv.Title =='Apttus_Config2__ConstraintRule__c' || 
                       cv.Title =='Apttus_Config2__ConstraintRuleAction__c'|| cv.Title =='Apttus_Config2__ConstraintRuleCondition__c' || cv.Title =='Apttus_Config2__PriceListCategory__c'){ */
             
                    Id jobid = executeBatchJob(automatedDeploymentId,0); 
                    AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobid];
                    System.debug('jobinfo'+jobInfo);  
                    
                    if(jobInfo.Status =='Completed' && jobInfo.NumberOfErrors <0 ){                        
                        strMessage = 'Records loaded successfully'+'\n ...'+'Job Id'+jobid; 
                        
                    } else if(jobInfo.Status =='Holding' && jobInfo.NumberOfErrors <0 ){                        
                        strMessage = 'Records are loading....Please Wait'+'\n ...'+'Job Id'+jobid; 
                    }                              
               /* } else{
                    strMessage = 'File Name should be the API name of Object'; 
                    throw new AuraHandledException(strMessage);
                }   */            
           // }
            }else{
                strMessage = 'automatedDeploymentId is Null'; 
                throw new AuraHandledException(strMessage);
            }               
        }catch(Exception e){
       
            throw new AuraHandledException('An Error has occured. Please try again or contact System Administrator.'+e.getMessage()+ 'Stack Trace :' + e.getStackTraceString() );            
        }
        return strMessage ;
    }
    
    public static Id executeBatchJob(Id automatedDeploymentId,Integer batchnum){
        NOLFileUploadBatchApex bobj = new NOLFileUploadBatchApex(automatedDeploymentId,batchnum);
        System.debug('Inside execute batch job ');
        Id batchJobId = Database.executeBatch(bobj, 100);
      
        return batchJobId;
    }  
}
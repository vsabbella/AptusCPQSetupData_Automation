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
                    Id jobid = executeBatchJob(automatedDeploymentId,0);
            }else{
                strMessage = 'automatedDeploymentId is Null';  
                 return strMessage ;
                //throw new AuraHandledException(strMessage);
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
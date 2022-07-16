public class NewOfferLaunchDataLoadBatch implements Database.Batchable<sObject>, Database.Stateful{

  Integer batchNo;
  String query;
  String automatedDeploymentId;

  public final String cpqcsv1 = 'Product2,Apttus_Config2__PriceList__c,Apttus_Config2__PriceListItem__c';
  public final String cpqcsv2 = 'Apttus_Config2__ClassificationName__c,Apttus_Config2__ClassificationHierarchy__c,Apttus_Config2__ProductClassification__c';
  public final String cpqcsv3 = 'Apttus_Config2__ProductOptionGroup__c,Apttus_Config2__ProductOptionComponent__c';
  public final String cpqcsv4 = 'Apttus_Config2__PriceRuleset__c,Apttus_Config2__PriceRule__c,Apttus_Config2__PriceRuleEntry__c';
  List<String> csvStringsList = new List<String>{cpqcsv1,cpqcsv2,cpqcsv3,cpqcsv4};
  
  public NewOfferLaunchDataLoadBatch(String automatedDepId, Integer BatchNum){

    System.debug('Somya Inside Constructor');
    System.debug('Somya Batch Number :' + BatchNum);
     batchNo=BatchNum;
     automatedDeploymentId = automatedDepId;
     query= 'SELECT Id,Title, VersionData,ContentDocumentId, Content_Type__c, Content__c FROM ContentVersion  WHERE FirstPublishLocationId =: automatedDeploymentId';
     
  }

  public Database.QueryLocator start(Database.BatchableContext BC){
    System.debug('Somya query Inside Start Method :' + query);
    return Database.getQueryLocator(query);
  }
  
   
  public void execute(Database.BatchableContext BC, List<ContentVersion> contentVersionList){

    System.debug('Somya Inside Execute');
    System.debug('Somya csvStringsList : '+ csvStringsList);

    String csvString = csvStringsList.get(batchNo);

    System.debug('Somya csvString : '+ csvString);

    List<String> csvToProcessList = csvString.split(',');

    System.debug('Somya csvToProcessList :' + csvToProcessList);

    Map<String, ContentVersion> titleVsContentDocMap = new Map<String, ContentVersion>();

    System.debug('Somya contentVersionList: '+ contentVersionList);

    for(ContentVersion cv :contentVersionList){  
      titleVsContentDocMap.put(cv.Title, cv);
    }

    System.debug('Somya titleVsContentDocMap :' + titleVsContentDocMap);

    for(String csvTitle : csvToProcessList){

      System.debug('Somya csvTitle: '+ csvTitle);

      if(titleVsContentDocMap!= null && titleVsContentDocMap.containsKey(csvTitle)){
        if(csvTitle == 'Product2'){
           System.debug('Somya1');
        } 
        if(csvTitle== 'Apttus_Config2__PriceList__c'){
          System.debug('Somya2');
        }          
        if(csvTitle== 'Apttus_Config2__PriceListItem__c'){
          System.debug('Somya3');
        }  
        if(csvTitle== 'Apttus_Config2__ClassificationName__c'){ // for category
          System.debug('Somya4');
        } 
        if(csvTitle== 'Apttus_Config2__ClassificationHierarchy__c'){ // for Category Hierarchy [ ClassificationHierarchy ]
          System.debug('Somya5');  
        }  
        if(csvTitle== 'Apttus_Config2__ProductClassification__c'){ // ProductClassification
          System.debug('Somya6');  
        } 
        if(csvTitle== 'Apttus_Config2__ProductOptionGroup__c'){ // Product Option Group (Option Group)
          System.debug('Somya7');   
        }
        if(csvTitle== 'Apttus_Config2__ProductOptionComponent__c'){ // Product Option (Option mapping to option group)
          System.debug('Somya8');  
        }
        if(csvTitle== 'Apttus_Config2__PriceRuleSet__c'){
          System.debug('Somya9');  
        } 
        if(csvTitle== 'Apttus_Config2__PriceRule__c'){
          System.debug('Somya10');    
        } 
        if(csvTitle== 'Apttus_Config2__PriceRuleEntry__c'){
          System.debug('Somya11');    
        }
      } 
    }

  }

public void finish(Database.BatchableContext BC){

  System.debug('Somya Inside Finish :'+ batchNo);
    //chain this batch
    if(batchNo < 3){
      batchNo = batchNo +1;
      System.debug('Somya Before Execute Again : '+ batchNo);
      Database.executebatch(new NewOfferLaunchDataLoadBatch(automatedDeploymentId,batchNo));
    }
   }

}
/*
    Name            : NOL_QualHelper
    Author          : Bhoopender Pal Singh
    Release         : 1.0
    Description     : This class contains business logics implementation
    Functionality   :   
    Created         : Sep-20-2019
                      
    Modification History:
    Date            Author                  Change  
    Sep 23, 2019    Bhoopender Pal Singh    GTMSER-1965 - AC#4 - Check Edit/Read permissions
    Sep 23,2019     Bhoopender Pal Singh    GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
    Sep 24, 2019    Bhoopender Pal Singh    Refactored: Moved all relevant NOL code, asmentioned below, from 'ProductDetailTriggerHelper.cls' to here
        Sep 13, 2019    Bhoopender Pal Singh    GTMSER-1965: NOL - Phase 2 - (1) Create Qualification Form Record on Prod Qual  
        Sep 18, 2019    Bhoopender Pal Singh    GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
        Sep 19, 2019    Bhoopender Pal Singh    GTMSER-2672: Create Qual Form for the Product only if it's enabled in Custom Settings and also available in Picklist on NOL Template
        Sep 20, 2019    Bhoopender Pal Singh    GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
        Oct 03, 2019    Bhoopender Pal Singh    GTMSER-2738: The Sub-Question is not displaying, even if it meets the criteria
        Oct 07, 2019    Bhoopender Pal Singh    GTMSER-2743: NOL - Multiple Sub-Questions, Multi-Select and Operators
*/

public class NOL_QualHelper {
    //GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
    private static final String PRESALES_FIT_TYPE = 'PreSales';
    private static final String BDM_FIT_TYPE = 'BDM';
    private static final String FIT_FORMULA_QUESTIONS_SEPARATOR = ',';
    private static final String SCORE_RED = 'Red';
    private static final String SCORE_YELLOW = 'Yellow';
    private static final String SCORE_GREEN = 'Green';

    //GTMSER-1965: NOL - Phase 2 - (1) Create Qualification Form Record on Prod Qual    
    public static void createQualForm(Map<Id, Product_Detail__c> newProdDetailMap) {
        system.debug('===========createQualForm() started');

        //Get Product Names
        Map<String, Product_Detail__c> prodNameToProdDetailRecMap = new Map<String, Product_Detail__c>();
        Set<String> nolEnabledProdSet = NOL_QualUtils.getNOLEnabledProducts();
        List<Product_Detail__c> prodDetailListToUpdate = new List<Product_Detail__c>();
        
        for(Product_Detail__c prodDetailRec : [SELECT Id, Name, RecordTypeId FROM Product_Detail__c WHERE Id IN: newProdDetailMap.keySet()]) {   
            if(nolEnabledProdSet.contains(prodDetailRec.Name)) {
                prodNameToProdDetailRecMap.put(prodDetailRec.Name, prodDetailRec);

                // To update record type of Product Detail
                prodDetailRec.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Product Qual - Digital' and sObjectType = 'Product_Detail__c'][0].Id;
                prodDetailListToUpdate.add(prodDetailRec);
            }
        }
        
        //
        if(!prodNameToProdDetailRecMap.isEmpty()) {

            //Load Templates and associated its Fit Formulas matching the Product Names
            Map<Id, NOL_Template__c> templateIdToRecMap = new Map<Id, NOL_Template__c>();
            List<NOL_Template_Fit_Formula__c> templateFitFRecList = new List<NOL_Template_Fit_Formula__c>();

            for(NOL_Template__c nolTemplateRec : [SELECT Id, Product__c,
                                                    (SELECT Id, Name, NOL_Template__c, NOL_Template_Questions_List__c,
                                                    Fit_Type__c, NOL_Template__r.Product__c
                                                    FROM NOL_Template_Fit_Formulas__r WHERE NOL_Template_Questions_List__c != null)
                                                FROM NOL_Template__c 
                                                WHERE Product__c IN: prodNameToProdDetailRecMap.keySet()
                                                    AND Is_Active__c = True]) {
                // Template data
                templateIdToRecMap.put(nolTemplateRec.Id, nolTemplateRec);

                //Template's associated Fit Formulas data
                templateFitFRecList.addAll(nolTemplateRec.NOL_Template_Fit_Formulas__r);
            }    

            system.debug('===========templateIdToRecMap: ' + templateIdToRecMap);            
            system.debug('===========templateFitFRecList: ' + templateFitFRecList);            

            //
            if(!templateIdToRecMap.isEmpty()) {

                // Prepare data to create Qual Forms
                Map<String, NOL_Qual_Form__c> prodNameToqualFormRecMap = new Map<String, NOL_Qual_Form__c>();

                for(Id templateId : templateIdToRecMap.keySet()) {
                    NOL_Template__c templateRec = templateIdToRecMap.get(templateId);
                    String prodName = templateRec.Product__c;

                    // Prepare Qual Form data
                    NOL_Qual_Form__c qualFormRec =  new NOL_Qual_Form__c();
                    qualFormRec.NOL_Template__c = templateRec.Id;
                    qualFormRec.Product_Qualification__c = prodNameToProdDetailRecMap.get(prodName).Id;

                    prodNameToqualFormRecMap.put(prodName, qualFormRec);
                }
                
                system.debug('===========prodNameToqualFormRecMap: ' + prodNameToqualFormRecMap);

                //Save Qual Forms
                if(!prodNameToqualFormRecMap.isEmpty()) {
                    insert prodNameToqualFormRecMap.values();
                }

                //Load Template Questions
                Map<Id, NOL_Template_Question__c> templateQIdToRecMap = new Map<Id, NOL_Template_Question__c>(
                                                                        [SELECT Id, Name, NOL_Template__c, NOL_Template__r.Product__c,
                                                                            NOL_Question__c, Section__c, Order__c, Parent_Question__c, 
                                                                            Parent_Question_Criteria__c, PQ_Obj_Field_To_Sync_Ans__c, 
                                                                            PQ_Obj_Field_To_Sync_Ans_When__c
                                                                        FROM NOL_Template_Question__c 
                                                                        WHERE NOL_Template__r.Id IN: templateIdToRecMap.keySet()
                                                                            AND NOL_Question__c != null]);
                system.debug('===========templateQIdToRecMap: ' + templateQIdToRecMap);

                //
                Set<Id> qIdSet = new Set<Id>();
                Map<String, Id> templateQNameToIdMap = new Map<String, Id>();

                for(NOL_Template_Question__c templateQRec : templateQIdToRecMap.values()) {

                    qIdSet.add(templateQRec.NOL_Question__c);
                    templateQNameToIdMap.put(templateQRec.Name, templateQRec.Id);
                }

                system.debug('===========templateQNameToIdMap: ' + templateQNameToIdMap);
                system.debug('===========qIdSet: ' + qIdSet);


                //Load Questions and related data i.e. Options and Responses
                Map<Id, NOL_Question__c> qIdToRecMap = new Map<Id, NOL_Question__c>();
                Map<Id, List<NOL_Question_Options__c>> qIdToQOptionRecListMap = new Map<Id, List<NOL_Question_Options__c>>();
                Map<Id, List<NOL_Question_Response__c>> qIdToQResponseRecListMap = new Map<Id, List<NOL_Question_Response__c>>();
                Map<Id, NOL_Question_Response__c> qResponseIdToQResponseRecMap = new Map<Id, NOL_Question_Response__c>();

                for(NOL_Question__c qRec : [SELECT Id, Name, Question_Title__c, Type__c, Help_Text__c,
                                                (SELECT Name, Option__c FROM NOL_Question_Options__r WHERE Is_Active__c = True),
                                                (SELECT Name, Answer__c, Operator__c, Score__c FROM NOL_Question_Scores__r WHERE Is_Active__c = True) 
                                            FROM NOL_Question__c WHERE Id IN: qIdSet]) {

                    
                    //Questions data
                    qIdToRecMap.put(qRec.Id, qRec);

                    //Question's associated Options data
                    List<NOL_Question_Options__c> qOptionsRecList = qIdToQOptionRecListMap.get(qRec.Id);

                    if(qOptionsRecList == null) {
                        qOptionsRecList = new List<NOL_Question_Options__c>();
                    }

                    qOptionsRecList.addAll(qRec.NOL_Question_Options__r);
                    qIdToQOptionRecListMap.put(qRec.Id, qOptionsRecList);

                    //Question's associated Responses data
                    List<NOL_Question_Response__c> qResponsesRecList = qIdToQResponseRecListMap.get(qRec.Id);

                    if(qResponsesRecList == null) {
                        qResponsesRecList = new List<NOL_Question_Response__c>();
                    }

                    qResponsesRecList.addAll(qRec.NOL_Question_Scores__r);
                    qIdToQResponseRecListMap.put(qRec.Id, qResponsesRecList);
                }

                system.debug('===========qIdToRecMap: ' + qIdToRecMap);
                system.debug('===========qIdToQOptionRecListMap: ' + qIdToQOptionRecListMap);
                system.debug('===========qIdToQResponseRecListMap: ' + qIdToQResponseRecListMap);
                system.debug('===========qResponseIdToQResponseRecMap: ' + qResponseIdToQResponseRecMap);

                //Prepare Qual Questions
                Map<String, NOL_Qual_Question__c> templateQIdToQualQRecMap = new Map<String, NOL_Qual_Question__c>();
                Map<String, Id> qIdToTemplateQIdMap = new Map<String, Id>();            
                Set<Id> templateQIdHavingParentQSet = new Set<Id>();
                
                for(Id templateQId : templateQIdToRecMap.keySet()) {
                    NOL_Template_Question__c templateQRec = templateQIdToRecMap.get(templateQId);
                    String prodName = templateQRec.NOL_Template__r.Product__c;
                    Id qualFormRecId = prodNameToqualFormRecMap.get(prodName).Id;
                    
                    system.debug('===========templateQId: ' + templateQId);
                    system.debug('===========templateQRec: ' + templateQRec);
                    system.debug('===========templateQRec.NOL_Question__c: ' + templateQRec.NOL_Question__c);
                    system.debug('===========qIdToRecMap.get(templateQRec.NOL_Question__c): ' + qIdToRecMap.get(templateQRec.NOL_Question__c));

                    // Question data
                    NOL_Qual_Question__C qualQRec = prepareNOLQuestion(templateQRec, qualFormRecId, qIdToRecMap.get(templateQRec.NOL_Question__c));
                    templateQIdToQualQRecMap.put(templateQId, qualQRec);
                    qIdToTemplateQIdMap.put(templateQRec.NOL_Template__c + '_' + templateQRec.NOL_Question__c + '_' + templateQRec.Section__c, templateQId); // Combination of NOL Question Id and Section supports same question to be used in multiple sections

                    // Parent Question data
                    if(templateQRec.Parent_Question__c != null) {
                        templateQIdHavingParentQSet.add(templateQId);
                    }
                }

                system.debug('===========templateQIdToQualQRecMap: ' + templateQIdToQualQRecMap);
                system.debug('===========qIdToTemplateQIdMap: ' + qIdToTemplateQIdMap);
                system.debug('===========templateQIdHavingParentQSet: ' + templateQIdHavingParentQSet);

                //Save Qual Questions
                Map<Id, String> qualQIdToNameMap = new Map<Id, String>();

                if(!templateQIdToQualQRecMap.isEmpty()) {
                    insert templateQIdToQualQRecMap.values();

                    //Load records with auto generated Name
                    Set<Id> insertedQualQIdSet = new Set<Id>();

                    for(NOL_Qual_Question__c qualQRec : templateQIdToQualQRecMap.values()) {
                        insertedQualQIdSet.add(qualQRec.Id);
                    }

                    // Load with auto generated Name
                    for(NOL_Qual_Question__c qualQRec : [SELECT Id, Name FROM NOL_Qual_Question__c WHERE Id IN :insertedQualQIdSet]) {
                        qualQIdToNameMap.put(qualQRec.Id, qualQRec.Name);
                    }
                    system.debug('================qualQIdToNameMap: ' + qualQIdToNameMap);
                }

                //Prepare Qual Questions' Options
                List<NOL_Qual_Question_Option__c> qualQOptionRecList = new List<NOL_Qual_Question_Option__c>();            

                for(Id templateQId : templateQIdToRecMap.keySet()) {
                    NOL_Template_Question__c templateQRec = templateQIdToRecMap.get(templateQId);

                    // Question Options
                    Id qualQId = templateQIdToQualQRecMap.get(templateQId).Id;
                    List<NOL_Question_Options__c> qOptionRecList = qIdToQOptionRecListMap.get(templateQRec.NOL_Question__c);
                    qualQOptionRecList.addAll(prepareNOLQuestionOption(qualQId, qOptionRecList));                           
                }
                
                system.debug('===========qualQOptionRecList: ' + qualQOptionRecList);

                //Save Qual Ouestion Options
                if(!qualQOptionRecList.isEmpty()) {
                    insert qualQOptionRecList;
                }

                //Prepare Qual Questions' Responses
                Map<String, NOL_Qual_Question_Response__c> qResponseIdToQualQResponseRecMap = new Map<String, NOL_Qual_Question_Response__c>();
                                    
                for(Id templateQId : templateQIdToRecMap.keySet()) {
                    NOL_Template_Question__c templateQRec = templateQIdToRecMap.get(templateQId);

                    // Question Response
                    Id qualQId = templateQIdToQualQRecMap.get(templateQId).Id;
                    List<NOL_Question_Response__c> qResponseRecList = qIdToQResponseRecListMap.get(templateQRec.NOL_Question__c);
                    prepareNOLQuestionResponse(qualQId, qResponseRecList, templateQId, qResponseIdToQualQResponseRecMap, templateQRec.NOL_Template__c);
                }

                system.debug('===========qResponseIdToQualQResponseRecMap: ' + qResponseIdToQualQResponseRecMap);

                if(!qResponseIdToQualQResponseRecMap.isEmpty()) {
                    insert qResponseIdToQualQResponseRecMap.values();
                }

                //Update Qual Questions with Parent Question and Criteria Response references
                List<NOL_Qual_Question__c> qualQRecList = new List<NOL_Qual_Question__c>();

                for(Id templateQRecId : templateQIdHavingParentQSet) {

                    NOL_Template_Question__c templateQRec = templateQIdToRecMap.get(templateQRecId);
                    
                    //Link Parent Question                                     
                    Id templateParentQId = qIdToTemplateQIdMap.get(templateQRec.NOL_Template__c + '_' + templateQRec.Parent_Question__c + '_' + templateQRec.Section__c);

                    NOL_Qual_Question__C qualQRec = templateQIdToQualQRecMap.get(templateQRecId);   
                    NOL_Qual_Question__C parentQualQRec = templateQIdToQualQRecMap.get(templateParentQId);
                    qualQRec.Parent_Question__c = parentQualQRec.Id;

                    //Link Parent Question Criteria
                    NOL_Qual_Question_Response__c qualQResponseRec = qResponseIdToQualQResponseRecMap.get(templateQRec.NOL_Template__c + '_' + templateQRec.Parent_Question_Criteria__c);

                    if(qualQResponseRec == null) {
                        throw new InvalidParentQuestionCriteriaException();
                    } else {
                        qualQRec.Parent_Question_Criteria__c = qualQResponseRec.Id;
                    }

                    qualQRecList.add(qualQRec);
                }

                system.debug('===========qualQRecList: ' + qualQRecList);

                if(!qualQRecList.isEmpty()) {
                    update qualQRecList;
                }

                //GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
                //Prepare Qual Fit Formulas
                List<NOL_Qual_Fit_Formula__c> qualFitFRecList = new List<NOL_Qual_Fit_Formula__c>();

                for (NOL_Template_Fit_Formula__c templateFitFRec : templateFitFRecList) {
                    
                    system.debug('==============templateFitFRec: ' + templateFitFRec);
                    NOL_Qual_Fit_Formula__c qualFitFRec = new NOL_Qual_Fit_Formula__c();

                    
                    String prodName = templateFitFRec.NOL_Template__r.Product__c;
                    qualFitFRec.NOL_Qual_Form__c = prodNameToqualFormRecMap.get(prodName).Id;
                    qualFitFRec.Fit_Type__c = templateFitFRec.Fit_Type__c;
                    
                    String qualQListStr = '';

                    for(String qName : templateFitFRec.NOL_Template_Questions_List__c.split(',')) {
                        qName = qName.trim();
                        system.debug('==============qName: ' + qName);
                        
                        String qualName = qualQIdToNameMap.get(templateQIdToQualQRecMap.get(templateQNameToIdMap.get(qName)).Id);
                        system.debug('==============qualName: ' + qualName);
                        
                        if(qualName != null) {
                            qualQListStr += qualName + FIT_FORMULA_QUESTIONS_SEPARATOR;
                        }
                    }
                    
                    // Remove extra separator at end
                    qualQListStr = qualQListStr.removeEnd(FIT_FORMULA_QUESTIONS_SEPARATOR);

                    qualFitFRec.NOL_Qual_Questions_List__c = qualQListStr;

                    //
                    qualFitFRecList.add(qualFitFRec);
                }

                //Save Qual Fit Formulas
                if(!qualFitFRecList.isEmpty()) {
                    insert qualFitFRecList;
                }

                // Change the record type of its Product Detail record
                if(!prodDetailListToUpdate.isEmpty()) {
                    update prodDetailListToUpdate;
                }
            }
        }

        system.debug('===========createQualForm() finished');
    }

    
    
    //GTMSER-1965: NOL - Phase 2 - (1) Create Qualification Form Record on Prod Qual    
    private static NOL_Qual_Question__C prepareNOLQuestion(NOL_Template_Question__c templateQRec, Id qualFormRecId, NOL_Question__c qRec) {
        NOL_Qual_Question__C qualQRec = new NOL_Qual_Question__C();
        qualQRec.NOL_Qual_Form__c = qualFormRecId;                
        qualQRec.Question_Title__c = qRec.Question_Title__c;
        qualQRec.Type__c = qRec.Type__c;
        qualQRec.Help_Text__c = qRec.Help_Text__c;
        qualQRec.Section__c = templateQRec.Section__c;
        qualQRec.Order__c = templateQRec.Order__c;
        qualQRec.PQ_Obj_Field_To_Sync_Ans__c = templateQRec.PQ_Obj_Field_To_Sync_Ans__c;
        qualQRec.PQ_Obj_Field_To_Sync_Ans_When__c = templateQRec.PQ_Obj_Field_To_Sync_Ans_When__c;

        return qualQRec;
    }

    //GTMSER-1965: NOL - Phase 2 - (1) Create Qualification Form Record on Prod Qual    
    private static List<NOL_Qual_Question_Option__c> prepareNOLQuestionOption(Id qualQId, List<NOL_Question_Options__c> qOptionRecList) {
        List<NOL_Qual_Question_Option__c> qualQOptionRecList = new List<NOL_Qual_Question_Option__c>();

        for(NOL_Question_Options__c qOption : qOptionRecList) {
            NOL_Qual_Question_Option__c qualQOptionRec = new NOL_Qual_Question_Option__c();
            qualQOptionRec.NOL_Qual_Question__c = qualQId;
            qualQOptionRec.Option__c = qOption.Option__c;
            qualQOptionRecList.add(qualQOptionRec);
        }

        return qualQOptionRecList;
    }

    //GTMSER-1965: NOL - Phase 2 - (1) Create Qualification Form Record on Prod Qual    
    private static void prepareNOLQuestionResponse(Id qualQId, List<NOL_Question_Response__c> qResponseRecList, String templateQId, Map<String, NOL_Qual_Question_Response__c> qResponseIdToQualQResponseRecMap, Id templateId) {

        for(NOL_Question_Response__c qResponseRec : qResponseRecList) {
            system.debug('===========qResponseRec.Id: ' + qResponseRec.Id);

            NOL_Qual_Question_Response__c qualQResponseRec = new NOL_Qual_Question_Response__c();
            qualQResponseRec.NOL_Qual_Question__c = qualQId;
            qualQResponseRec.Answer__c = qResponseRec.Answer__c;
            qualQResponseRec.Operator__c = qResponseRec.Operator__c;
            qualQResponseRec.Score__c = qResponseRec.Score__c;

            qResponseIdToQualQResponseRecMap.put(templateId + '_' + qResponseRec.Id, qualQResponseRec);
        }
    }

    //GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
    public static NOL_Qual_Form__c calculateRecommendedFits(Id qualFormId) {

        //Load Qual Form
        NOL_Qual_Form__c qualForm = [SELECT Id FROM NOL_Qual_Form__c WHERE Id =: qualFormId];
        System.debug('====================qualForm: ' + qualForm);

        //Load Formulas
        Map<String, List<String>> qualFitFormulaFitToQualQNamesListMap = new Map<String, List<String>>();        
        List<String> allFormulaQualQNamesList = new List<String>();
            
        for(NOL_Qual_Fit_Formula__c qualFitFRec : [SELECT Id, Fit_Type__c, NOL_Qual_Questions_List__c 
                                                    FROM NOL_Qual_Fit_Formula__c 
                                                    WHERE NOL_Qual_Form__c =: qualForm.Id AND NOL_Qual_Questions_List__c != null]) {
                                                        
            List<String> formulaQualQNamesList = qualFitFRec.NOL_Qual_Questions_List__c.split(FIT_FORMULA_QUESTIONS_SEPARATOR); 
            allFormulaQualQNamesList.addAll(formulaQualQNamesList);
            qualFitFormulaFitToQualQNamesListMap.put(qualFitFRec.Fit_Type__c, formulaQualQNamesList);
        }                                                                
        
        system.debug('===========qualFitFormulaFitToQualQNamesListMap: ' + qualFitFormulaFitToQualQNamesListMap);

        //Load Questions and Responses
        Map<String, NOL_Qual_Question__C> qualQNameToRecMap = new Map<String, NOL_Qual_Question__C>();
        Map<String, List<NOL_Qual_Question_Response__c>> qualQNameToResListMap = new  Map<String, List<NOL_Qual_Question_Response__c>>();
    
        for(NOL_Qual_Question__c qualQRec : [SELECT Name, Answer__c, Type__c,
                                                (SELECT Answer__c, Operator__c, Score__c FROM NOL_Qual_Question_Scores__r)
                                            FROM NOL_Qual_Question__c 
                                            WHERE Name IN :allFormulaQualQNamesList]) {
            qualQNameToRecMap.put(qualQRec.Name, qualQRec);
            qualQNameToResListMap.put(qualQRec.Name, qualQRec.NOL_Qual_Question_Scores__r);
        }
        
        System.debug('====================qualQNameToResListMap: ' + qualQNameToResListMap); 
        
        // Update recommeded fits on Qual Form
        Boolean shouldUpdateQualForm = false;

        if(qualFitFormulaFitToQualQNamesListMap.get(PRESALES_FIT_TYPE) != null) {
            qualForm.PreSales_Recommended_Fit__c = calculateRecommendedFits(qualFitFormulaFitToQualQNamesListMap.get(PRESALES_FIT_TYPE), qualQNameToRecMap, qualQNameToResListMap);
            shouldUpdateQualForm = true;
            System.debug('====================PreSales_Recommended_Fit__c: ' + qualForm.PreSales_Recommended_Fit__c);
        }

        if(qualFitFormulaFitToQualQNamesListMap.get(BDM_FIT_TYPE) != null) {
            qualForm.BDM_Recommended_Fit__c = calculateRecommendedFits(qualFitFormulaFitToQualQNamesListMap.get(BDM_FIT_TYPE), qualQNameToRecMap, qualQNameToResListMap); 
            shouldUpdateQualForm = true;
            System.debug('====================BDM_Recommended_Fit__c: ' + qualForm.BDM_Recommended_Fit__c);
        }

        if(shouldUpdateQualForm) {
            return qualForm;
            
        } else {
            return null;
        }       
    }

    //GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
    private static String calculateRecommendedFits(List<String> formulaQualQNamesList, Map<String, NOL_Qual_Question__C> qualQNameToRecMap, Map<String, List<NOL_Qual_Question_Response__c>> qualQNameToResListMap) {        
        String recommendedFit;                
        Boolean isAllQInFormulaPopulated = true;
        Boolean isAnyResScoredRed = false;
        Boolean isAnyResScoredYellow = false;

        //Iterate Response List
        for(String qualQName : formulaQualQNamesList) {
            system.debug('===============qualQName: ' + qualQName);

            NOL_Qual_Question__C qualQRec =  qualQNameToRecMap.get(qualQName);
            system.debug('===============qualQRec: ' + qualQRec);

            //Don't proceed if any of the Question specified in formula calculation is NOT populated
            if(String.isBlank(qualQRec.Answer__c)) {
                isAllQInFormulaPopulated = false;
                break;
            }
            
            //Iterate over Responses and find match
            for(NOL_Qual_Question_Response__c qualQResRec : qualQNameToResListMap.get(qualQName)) {                
                system.debug('===============qualQResRec: ' + qualQResRec);

                //GTMSER-2743: NOL - Multiple Sub-Questions, Multi-Select and Operators
                //Check if criteria matched
                Boolean isCriteriaMatched;

                if(qualQRec.Type__c.equals('Multi-Select')) {
                    isCriteriaMatched = NOL_QualUtils.evalOpeartorExpression(qualQRec.Answer__c, qualQResRec.Answer__c, qualQResRec.Operator__c, true, NOL_QualUtils.LIST_VALUES_SEPARATOR);
                } else {
                    isCriteriaMatched = NOL_QualUtils.evalOpeartorExpression(qualQRec.Answer__c, qualQResRec.Answer__c, qualQResRec.Operator__c);
                }
                
                //Check Score if there is a match
                if(isCriteriaMatched) {

                    if(qualQResRec.Score__c.equals(SCORE_RED)) {
                        isAnyResScoredRed = true;
                    } else if(qualQResRec.Score__c.equals(SCORE_YELLOW)) {
                        isAnyResScoredYellow = true;
                    }
                }
            }
        }

        if(isAllQInFormulaPopulated) {

            if(isAnyResScoredRed) {
                recommendedFit = SCORE_RED;
            } else if(isAnyResScoredYellow) {
                recommendedFit = SCORE_YELLOW;
            } else {
                recommendedFit = SCORE_GREEN;
            }
        }

        return recommendedFit;
    }

    //******************************* Exceptions ********************    
    public class InvalidParentQuestionCriteriaException extends Exception{}
}